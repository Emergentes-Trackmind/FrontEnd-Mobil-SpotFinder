import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartparking_mobile_application/reservations/views/reservation-payment.dart';
import 'package:smartparking_mobile_application/shared/i18n.dart';
import 'package:smartparking_mobile_application/shared/components/success-dialog.component.dart';
import '../../parking-management/components/parking-spot-viewer.dart';
import '../../parking-management/models/parking.entity.dart';
import '../services/reservation.service.dart';

class ParkingReservationPage extends StatefulWidget {
  final Parking parking;

  const ParkingReservationPage({super.key, required this.parking});

  @override
  State<ParkingReservationPage> createState() => _ParkingReservationPageState();
}

class _ParkingReservationPageState extends State<ParkingReservationPage> {
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String _vehiclePlate = '';
  double _totalHours = 0.0;
  Map<String, dynamic>? _selectedSpot;
  final ReservationService _reservationService = ReservationService();

  double _calculateTotal() {
    if (_startTime == null || _endTime == null || _selectedSpot == null) {
      return 0.0;
    }

    final startMinutes = _startTime!.hour * 60 + _startTime!.minute;
    final endMinutes = _endTime!.hour * 60 + _endTime!.minute;

    _totalHours = (endMinutes - startMinutes) / 60.0;

    // Use a fixed simulated rate of S/5.00 per hour (user requested)
    const double simulatedRatePerHour = 5.0;
    return _totalHours > 0 ? _totalHours * simulatedRatePerHour : 0.0;
  }

  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  Future<String> _convertValueTimeTo24HourFormatAndString(value) async {
    if (value == null) return '';
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      value.hour,
      value.minute,
    );

    // Formatear hora y minuto con dos dígitos
    final String hour = dateTime.hour.toString().padLeft(2, '0');
    final String minute = dateTime.minute.toString().padLeft(2, '0');
    final formattedTime = '$hour:$minute';

    print('Converted time: $formattedTime');
    return formattedTime;
  }

  void _onSpotSelected(Map<String, dynamic>? spot) {
    setState(() {
      _selectedSpot = spot;
    });
  }

  void _reserveSpot() async {
    if (_selectedSpot == null || _startTime == null || _endTime == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('form.error_complete_fields'))));
      return;
    }
    if (_startTime == _endTime) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('form.error_same_times'))));
      return;
    }
    if (_endTime!.hour < _startTime!.hour ||
        (_endTime!.hour == _startTime!.hour &&
            _endTime!.minute <= _startTime!.minute)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('form.error_end_before_start'))),
      );
      return;
    }
    if (_vehiclePlate.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('form.error_enter_plate'))));
      return;
    }

    // Aquí se puede hacer la llamada al backend para reservar
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final driverId = prefs.getInt('userId');
    if (driverId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('reservations.no_driver'))));
      return;
    }
    final parkingId = widget.parking.id;
    final spotIdRaw = _selectedSpot!['id'];
    if (spotIdRaw == null ||
        (spotIdRaw is String && spotIdRaw.trim().isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invalid spot id')));
      return;
    }
    // Format date as YYYY-MM-DD (backend example expects this format)
    final dateOnly = DateTime.now().toIso8601String().split('T').first;

    final reservationData = {
      'driverId': driverId,
      'vehiclePlate': _vehiclePlate,
      'parkingId': parkingId,
      // send spot id as returned by API (could be int or string/uuid)
      'parkingSpotId': spotIdRaw,
      'date': dateOnly,
      'startTime': await _convertValueTimeTo24HourFormatAndString(_startTime),
      'endTime': await _convertValueTimeTo24HourFormatAndString(_endTime),
    };

    // Debug: print the payload so you can check in the console what we send
    debugPrint('Reservation payload: ${reservationData.toString()}');
    try {
      final response = await _reservationService.post(reservationData);
      if (response.containsKey('id')) {
        SuccessDialog.show(
          context: context,
          message: tr('form.success_reservation'),
          buttonLabel: tr('form.go_to_payment'),
          icon: Icons.check_circle,
          onClose: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => ReservationPayment(
                  userId: driverId,
                  reservationId:
                  (response['id'] is int)
                      ? response['id'] as int
                      : int.tryParse(
                    response['id']?.toString() ?? '',
                  ) ??
                      0,
                  amount: _calculateTotal(),
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      // If POST failed, try to confirm whether the reservation actually exists
      try {
        final reservations = await _reservationService.getAllByParkingId(
          parkingId,
        );
        // try to find a reservation matching driverId, spot and date
        final found = reservations.firstWhere((r) {
          final rDriver = r['driverId']?.toString();
          final rSpot = r['parkingSpotId']?.toString();
          final rDate = r['date']?.toString();
          return rDriver == driverId.toString() &&
              rSpot == spotIdRaw.toString() &&
              rDate == (DateTime.now().toIso8601String().split('T').first);
        }, orElse: () => {});

        if (found.isNotEmpty) {
          final resId =
          (found['id'] is int)
              ? found['id'] as int
              : int.tryParse(found['id']?.toString() ?? '') ?? 0;
          SuccessDialog.show(
            context: context,
            message: tr('form.success_reservation'),
            buttonLabel: tr('form.go_to_payment'),
            icon: Icons.check_circle,
            onClose: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ReservationPayment(
                    userId: driverId,
                    reservationId: resId,
                    amount: _calculateTotal(),
                  ),
                ),
              );
            },
          );
          return;
        }
      } catch (_) {
        // ignore and show original error below
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('form.error_reserving')}: $e')),
      );
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.parking.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Time and plate inputs
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('form.vehicle_plate'),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.directions_car),
                    hintText: tr('form.vehicle_plate_hint'),
                    border: const OutlineInputBorder(),
                  ),
                  maxLength: 7,
                  onChanged: (value) {
                    setState(() {
                      _vehiclePlate = value;
                    });
                  },
                ),
                const SizedBox(height: 10),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('form.start_time'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.access_time),
                          onPressed: _pickStartTime,
                          label: Text(
                            _startTime == null
                                ? tr('form.select_start')
                                : _startTime!.format(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('form.end_time'),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.access_time),
                          onPressed: _pickEndTime,
                          label: Text(
                            _endTime == null
                                ? tr('form.select_end')
                                : _endTime!.format(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
            const SizedBox(height: 1),

            // Parking spot viewer
            Expanded(
              child: ParkingSpotViewer(
                parking: widget.parking,
                onSpotSelected: _onSpotSelected,
              ),
            ),

            const SizedBox(height: 40),

            // Selected spot
            Text(
              _selectedSpot != null
                  ? '${tr('form.selected_spot')}: ${_selectedSpot!['label']}'
                  : tr('form.no_spot_selected'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),

            // Total
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('form.total'),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      '\$${_calculateTotal().toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    Text(
                      ' / ${_totalHours.toStringAsFixed(2)} ${tr('form.hours_label')}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.lightBlue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Cancel and Reserve buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.cancel, color: Colors.black87),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5E7EB),
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    label: Text(
                      tr('form.cancel'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _reserveSpot,
                    icon: const Icon(
                      Icons.check_circle,
                      color: Colors.white,
                      size: 24,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3B82F6),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    label: Text(
                      tr('form.reserve'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
