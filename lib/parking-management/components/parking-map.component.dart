import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart' as gl;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mp;
import 'package:smartparking_mobile_application/parking-management/components/parking-card.component.dart';
import 'package:smartparking_mobile_application/parking-management/services/parking.service.dart';
import 'package:smartparking_mobile_application/shared/components/navigator-bar.dart';
import 'package:smartparking_mobile_application/shared/i18n.dart';
import '../models/parking.entity.dart';

class ParkingMap extends StatefulWidget {
  // Allow const construction so callers can use `const ParkingMap()`.
  const ParkingMap({super.key});

  // Top search bar overlay (Inicio screen)

  @override
  State<ParkingMap> createState() => _ParkingMapState();
}

class _ParkingMapState extends State<ParkingMap> {
  late mp.MapboxMap mapboxMap;
  mp.PointAnnotationManager? pointAnnotationManager;
  StreamSubscription<gl.Position>? userLocationStream;
  final ParkingService _parkingService = ParkingService();
  final List<Parking> _parkingList = [];
  final Map<String, Parking> _annotationIdToParking = {};
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  bool _filterCovered = false;
  bool _filter24h = false;
  bool _isSearching = false;

  bool _isMapReady = false;
  bool _isParkingDataReady = false;
  // diagnostic fields removed (badge removed)

  @override
  void initState() {
    super.initState();

    // Start tracking user location and load initial parking data.
    // We load all parkings initially so markers are visible on the map.
    // If you prefer to show no markers until a user searches, remove the
    // following load and keep only location tracking.
    _startLocationTracking().catchError((e) {
      debugPrint('Location init error: $e');
      // Show a user-visible message after the first frame so they know
      // to enable location permissions if needed.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Location error: $e')));
        }
      });
    });

    _parkingService
        .search()
        .then((data) {
      final list =
      data.map<Parking>((item) => Parking.fromJson(item)).toList();
      setState(() {
        _parkingList.clear();
        _parkingList.addAll(list);
        _isParkingDataReady = true;
      });

      if (_isMapReady) {
        _createParkingMarkers();
      }
    })
        .catchError((e) {
      debugPrint('Failed to load parkings: $e');
      setState(() {
        _isParkingDataReady = false;
      });
    });

    // If the map never becomes ready, surface a helpful error after a short
    // timeout so the user knows why markers aren't visible.
    Timer(const Duration(seconds: 4), () {
      if (mounted && !_isMapReady && _parkingList.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'El mapa no pudo inicializarse. Verifica el token de Mapbox y la conexión.',
                ),
              ),
            );
          }
        });
      }
    });

  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await gl.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    gl.LocationPermission permission = await gl.Geolocator.checkPermission();
    if (permission == gl.LocationPermission.denied) {
      permission = await gl.Geolocator.requestPermission();
      if (permission == gl.LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == gl.LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
    }

    const locationSettings = gl.LocationSettings(
      accuracy: gl.LocationAccuracy.high,
      distanceFilter: 100,
    );

    userLocationStream?.cancel();
    userLocationStream = gl.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((gl.Position position) {
      // Only update the camera if the map is already created.
      if (_isMapReady) {
        try {
          mapboxMap.setCamera(
            mp.CameraOptions(
              center: mp.Point(
                coordinates: mp.Position(position.longitude, position.latitude),
              ),
              zoom: 15,
            ),
          );
        } catch (e) {
          debugPrint('Failed to set camera on location update: $e');
        }
      }
    });

    // location tracking started
  }

  Future<void> _onMapCreated(mp.MapboxMap mapboxMap) async {
    this.mapboxMap = mapboxMap;

    await mapboxMap.location.updateSettings(
      mp.LocationComponentSettings(enabled: true, pulsingEnabled: true),
    );

    pointAnnotationManager =
    await mapboxMap.annotations.createPointAnnotationManager();

    // Add tap listener
    pointAnnotationManager?.addOnPointAnnotationClickListener(
      _ParkingAnnotationClickListener(this),
    );

    setState(() {
      _isMapReady = true;
    });

    // Try to center on user immediately when map becomes ready.
    _goToUserLocation().catchError(
          (e) => debugPrint('goToUserLocation failed: $e'),
    );

    if (_isParkingDataReady) {
      _createParkingMarkers();
    }
  }

  Future<void> _createParkingMarkers() async {
    if (pointAnnotationManager == null) return;

    final Uint8List? icon = await _loadMarkerIcon(
      'assets/icons/parking_icon.png',
    );
    if (icon == null) return;

    for (var parking in _parkingList) {
      final marker = mp.PointAnnotationOptions(
        geometry: mp.Point(coordinates: mp.Position(parking.lng, parking.lat)),
        image: icon,
        iconSize: 2.0,
      );
      var createdAnnotation = await pointAnnotationManager!.create(marker);
      _annotationIdToParking[createdAnnotation.id] = parking;
    }
  }

  Future<Uint8List?> _loadMarkerIcon(String path) async {
    try {
      final ByteData bytes = await rootBundle.load(path);
      return bytes.buffer.asUint8List();
    } catch (e) {
      debugPrint('Failed to load icon: $e');
      return null;
    }
  }

  Future<void> _goToUserLocation() async {
    try {
      final gl.Position position = await gl.Geolocator.getCurrentPosition();
      mapboxMap.setCamera(
        mp.CameraOptions(
          center: mp.Point(
            coordinates: mp.Position(position.longitude, position.latitude),
          ),
          zoom: 16,
        ),
      );
    } catch (e) {
      debugPrint('Failed to get user location: $e');
    }
  }

  void _showParkingDetails(Parking parking) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ParkingCard(parking: parking);
      },
    );
  }



  Future<void> _searchParkings() async {
    setState(() {
      _isSearching = true;
    });

    try {
      final q = _searchController.text.trim();

      // If the user hasn't typed anything and no filters are active,
      // do not perform a search or show results.
      if (q.isEmpty && !_filterCovered && !_filter24h) {
        setState(() {
          _isSearching = false;
        });
        return;
      }

      final data = await _parkingService.search(
        q: q.isEmpty ? null : q,
        covered: _filterCovered ? true : null,
        open24: _filter24h ? true : null,
      );

      final results =
      data.map<Parking>((item) => Parking.fromJson(item)).toList();

      setState(() {
        _isSearching = false;
      });

      if (results.isEmpty) {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          builder: (context) {
            return SizedBox(
              height: 200,
              child: Center(child: Text(tr('parking.no_results'))),
            );
          },
        );
        return;
      }

      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (context) {
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final parking = results[index];
              return ListTile(
                title: Text(parking.name),
                subtitle: Text(parking.address),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (parking.covered) const Icon(Icons.roofing, size: 18),
                    if (parking.open24) const Icon(Icons.schedule, size: 18),
                  ],
                ),
                onTap: () async {
                  Navigator.pop(context);
                  // center map on selection and show details
                  try {
                    mapboxMap.setCamera(
                      mp.CameraOptions(
                        center: mp.Point(
                          coordinates: mp.Position(parking.lng, parking.lat),
                        ),
                        zoom: 16,
                      ),
                    );
                  } catch (_) {}
                  _showParkingDetails(parking);
                },
              );
            },
            separatorBuilder: (_, __) => const Divider(),
            itemCount: results.length,
          );
        },
      );
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error buscando parkings: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            mp.MapWidget(
              onMapCreated: _onMapCreated,
              styleUri: mp.MapboxStyles.MAPBOX_STREETS,
            ),
            // Top search bar overlay (Inicio screen)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 8),
                              const Icon(Icons.search, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                    hintText: tr('parking.search_hint'),
                                    border: InputBorder.none,
                                    isCollapsed: true,
                                  ),
                                ),
                              ),
                              if (_isSearching)
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.filter_list),
                          onPressed: () {
                            // TODO: open filters
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FilterChip(
                        label: Text(tr('parking.filter.covered')),
                        selected: _filterCovered,
                        onSelected: (v) {
                          setState(() {
                            _filterCovered = v;
                          });
                          _searchParkings();
                        },
                      ),
                      const SizedBox(width: 6),
                      FilterChip(
                        label: Text(tr('parking.filter.open24')),
                        selected: _filter24h,
                        onSelected: (v) {
                          setState(() {
                            _filter24h = v;
                          });
                          _searchParkings();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // (diagnostic badge removed)
            Positioned(
              bottom: 20,
              right: 20,
              child: FloatingActionButton(
                onPressed: _goToUserLocation,
                child: const Icon(Icons.my_location),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigatorBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/reviews');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/reservations');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
      default:
        break;
    }
  }
}

class _ParkingAnnotationClickListener
    extends mp.OnPointAnnotationClickListener {
  final _ParkingMapState mapState;

  _ParkingAnnotationClickListener(this.mapState);

  @override
  void onPointAnnotationClick(mp.PointAnnotation annotation) {
    final parking = mapState._annotationIdToParking[annotation.id];
    if (parking != null) {
      mapState._showParkingDetails(parking);
    }
  }
}
