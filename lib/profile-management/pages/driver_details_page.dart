import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No AppBar here: header is rendered inside the body so we don't show a back arrow
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
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                else if (_driver == null)
                  const Center(
                    child: Text(
                      'Driver details not available.',
                      style: TextStyle(fontSize: 18),
                    ),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header: avatar, name and email
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // TODO: implement change profile picture (image picker)
                              showDialog(
                                context: context,
                                builder:
                                    (ctx) => AlertDialog(
                                      title: const Text(
                                        'Cambiar foto de perfil',
                                      ),
                                      content: const Text(
                                        'Funcionalidad para cambiar foto aún no implementada.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Cerrar'),
                                        ),
                                      ],
                                    ),
                              );
                            },
                            child: CircleAvatar(
                              radius: 42,
                              backgroundColor: Colors.grey.shade200,
                              child: const Icon(
                                Icons.person,
                                size: 44,
                                color: Colors.black54,
                              ),
                            ),
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
                                  // email may be in driver model under userId mapping; fetch from prefs if needed
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

                      // Options: Datos personales, Métodos de pago, Notificaciones, Configuración
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.person_outline),
                              title: const Text('Datos personales'),
                              subtitle: const Text('Editar información'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () async {
                                await Navigator.pushNamed(
                                  context,
                                  '/profile/edit',
                                );
                                // refresh after edit returns
                                _loadDriverDetails();
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.credit_card_outlined),
                              title: const Text('Métodos de pago'),
                              subtitle: const Text('Tarjetas guardadas'),
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
                              title: const Text('Notificaciones'),
                              subtitle: const Text('Visualizar Notificaciones'),
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
                              title: const Text('Configuración'),
                              subtitle: const Text('Preferencias de la app'),
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
                          child: const Text(
                            'Cerrar sesión',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
