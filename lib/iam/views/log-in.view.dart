import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartparking_mobile_application/parking-management/components/parking-map.component.dart';
import '../services/auth.service.dart';

class LogInView extends StatefulWidget {
  const LogInView({super.key});

  @override
  State<LogInView> createState() => _LogInViewState();
}

class _LogInViewState extends State<LogInView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  String _responseMessage = '';
  bool _rememberMe = false;

  Future<void> _logIn(BuildContext context) async {
    setState(() {
      _responseMessage = 'Attempting to sign in...';
    });

    try {
      final user = await _authService.logIn(
        _emailController.text,
        _passwordController.text,
      );

      // Check if token exists
      final token = user['token'];
      if (token == null) {
        setState(() {
          _responseMessage = 'Error: Authentication token not found.';
        });
        return;
      }

      // Check if userId exists
      final userId = user['id'];
      if (userId == null) {
        setState(() {
          _responseMessage = 'Error: User ID not found.';
        });
        return;
      }

      // Save authentication data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', token);
      await prefs.setInt('userId', userId);

      if (!mounted) return;
      setState(() {
        _responseMessage = 'Sign in successful. Welcome!';
      });

      // Navigate to ParkingCard screen
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const ParkingMap()),
      );
    } catch (e) {
      // Log removed for production; keep a concise user message

      // More descriptive error messages based on exception
      String errorMessage = 'Error signing in. Please check your credentials.';
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Connection refused')) {
        errorMessage = 'Network error. Please check your connection.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Invalid email or password.';
      } else if (e.toString().contains('timeout')) {
        errorMessage =
            'Server is taking too long to respond. Please try again.';
      }

      setState(() {
        _responseMessage = errorMessage;
      });
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? prefixIcon,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: labelText,
        hintStyle: const TextStyle(color: Colors.black45),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.black45) : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 12.0,
        ),
      ),
      style: const TextStyle(color: Colors.black87),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 40.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 28.0,
                horizontal: 22.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo - conservar literal
                  Container(
                    height: 120,
                    width: 300,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                      color: Colors.white,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.asset(
                        'assets/images/SpotFinderLogo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Email
                  _buildTextField(
                    controller: _emailController,
                    labelText: 'Email',
                    prefixIcon: Icons.email,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  _buildTextField(
                    controller: _passwordController,
                    labelText: 'Contraseña',
                    prefixIcon: Icons.lock,
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),

                  // Recordarme + Olvidaste contraseña
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (v) {
                          setState(() => _rememberMe = v ?? false);
                        },
                      ),
                      const SizedBox(width: 4),
                      const Text('Recordarme'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          // Mantener acción simple por ahora
                          // Aquí se puede navegar a una pantalla de recuperación
                        },
                        child: const Text('¿Olvidaste tu contraseña?'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Ingresar (botón primario negro)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _logIn(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Ingresar',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mensaje de respuesta
                  if (_responseMessage.isNotEmpty) ...[
                    Text(
                      _responseMessage,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Crear cuenta (outline)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/signup-driver',
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14.0),
                        side: const BorderSide(color: Colors.black),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        foregroundColor: Colors.black,
                      ),
                      child: const Text(
                        'Crear cuenta',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
