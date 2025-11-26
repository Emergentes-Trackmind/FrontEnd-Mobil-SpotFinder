import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// simplified: no direct http/bytes fetching here
import '../../shared/i18n.dart';
import '../models/driver.model.dart';
import '../services/driver.service.dart';
import '../../shared/components/navigator-bar.dart';

class DriverDetailsPage extends StatefulWidget {
  const DriverDetailsPage({Key? key}) : super(key: key);

  @override
  State<DriverDetailsPage> createState() => _DriverDetailsPageState();
}

class _DriverDetailsPageState extends State<DriverDetailsPage> {
  final DriverService _driverService = DriverService();
  Driver? _driver;
  bool _isLoading = true;
  String _errorMessage = '';
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 0) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (index == 1) {
        // Go to reviews (reusing existing reviews view)
        Navigator.pushReplacementNamed(context, '/reviews');
      } else if (index == 2) {
        Navigator.pushReplacementNamed(context, '/reservations');
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _loadDriverDetails();
  }

  Future<void> _loadDriverDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId');

      if (userId == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'User ID not found. Please log in again.';
        });
        return;
      }

      final driverData = await _driverService.getById(userId);

      setState(() {
        _driver = Driver.fromJson(driverData);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading driver details: $e';
      });
    }
  }

  String? _avatarPreview(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    final s = raw.trim();
    if (s.startsWith('http')) return s;
    try {
      final base = Uri.parse(DriverService().baseUrl).origin;
      return s.startsWith('/') ? '$base$s' : '$base/$s';
    } catch (_) {
      return s;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDriverDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (_errorMessage.isNotEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage,
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadDriverDetails,
                          child: Text(tr('profile.retry')),
                        ),
                      ],
                    ),
                  )
                else if (_driver == null)
                    Center(
                      child: Text(
                        tr('profile.driver_not_available'),
                        style: const TextStyle(fontSize: 18),
                      ),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: Text(tr('profile.change_photo_title')),
                                    content: Text(tr('profile.change_photo_content')),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Cerrar'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              child: Builder(builder: (ctx) {
                                final preview = _avatarPreview(_driver?.avatarUrl);
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 42,
                                      backgroundColor: Colors.grey.shade200,
                                      backgroundImage: (preview != null) ? NetworkImage(preview) : null,
                                      child: (preview == null)
                                          ? const Icon(
                                        Icons.person,
                                        size: 44,
                                        color: Colors.black54,
                                      )
                                          : null,
                                    ),
                                  ],
                                );
                              }),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _driver!.fullName ?? 'Usuario',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _driver!.driverId != null
                                        ? 'user#${_driver!.driverId}'
                                        : '',
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),


                        Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              ListTile(
                                leading: const Icon(Icons.person_outline),
                                title: Text(tr('profile.personal_data')),
                                subtitle: Text(tr('profile.edit_info')),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    '/profile/edit',
                                  );
                                  // If edit returned an avatarUrl (string), refresh only avatar
                                  if (result is String && result.isNotEmpty) {
                                    setState(() {
                                      if (_driver != null) _driver = Driver(
                                        userId: _driver!.userId,
                                        driverId: _driver!.driverId,
                                        fullName: _driver!.fullName,
                                        city: _driver!.city,
                                        country: _driver!.country,
                                        phone: _driver!.phone,
                                        dni: _driver!.dni,
                                        avatarUrl: result,
                                        email: _driver!.email,
                                        role: _driver!.role,
                                      );
                                    });
                                    // avatar updated in-memory; the UI will use the returned URL
                                  } else {
                                    // fallback: reload whole profile
                                    _loadDriverDetails();
                                  }
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.credit_card_outlined),
                                title: Text(tr('profile.payment_methods')),
                                subtitle: Text(tr('profile.stored_cards')),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/profile/payments',
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.notifications_outlined),
                                title: Text(tr('profile.notifications')),
                                subtitle: Text(tr('profile.view_notifications')),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/profile/notifications',
                                  );
                                },
                              ),
                              const Divider(height: 1),
                              ListTile(
                                leading: const Icon(Icons.settings_outlined),
                                title: Text(tr('profile.settings')),
                                subtitle: Text(tr('profile.preferences')),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/profile/settings',
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              tr('profile.logout'),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigatorBar(
        selectedIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
