import 'package:flutter/material.dart';
import '../services/auth.service.dart';
import '../../shared/components/success-dialog.component.dart';

class SignUpDriverView extends StatefulWidget {
  const SignUpDriverView({super.key});

  @override
  State<SignUpDriverView> createState() => _SignUpDriverViewState();
}

class _SignUpDriverViewState extends State<SignUpDriverView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();

  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _responseMessage = '';
  bool _passwordVisible = false;
  bool _confirmPasswordVisible = false;
  // This view is driver-only now

  Future<void> _signUp(BuildContext context) async {
    if (_formKey.currentState?.validate() != true) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() => _responseMessage = 'Las contraseñas no coinciden.');
      return;
    }

    setState(() {
      _isLoading = true;
      _responseMessage = '';
    });

    final userData = <String, dynamic>{
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'fullName': _fullNameController.text.trim(),
      'city': _cityController.text.trim(),
      'country': _countryController.text.trim(),
      'phone': _phoneController.text.trim(),
    };

    // driver-only
    final userType = 'driver';
    userData['dni'] = _dniController.text.trim();

    try {
      final response = await _authService.singUp(userData, userType: userType);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (response.containsKey('id')) {
        final msg = 'Registrado correctamente como conductor.';
        if (!mounted) return;
        SuccessDialog.show(
          context: context,
          icon: Icons.check_circle,
          message: msg,
          buttonLabel: 'Ir al inicio',
          routeToNavigate: '/login',
        );
      } else {
        setState(() {
          _responseMessage = 'Respuesta inválida del servidor';
        });
      }
    } catch (e) {
      setState(
        () => _responseMessage = 'Error registrando usuario: ${e.toString()}',
      );
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    IconData? prefixIcon,
    bool isPassword = false,
    bool isVisible = false,
    bool isEmail = false,
    bool isPhone = false,
    bool isDNI = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      keyboardType:
          isEmail
              ? TextInputType.emailAddress
              : isPhone
              ? TextInputType.phone
              : isDNI
              ? TextInputType.number
              : TextInputType.text,
      validator:
          validator ??
          (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingresa $labelText';
            }
            if (isEmail &&
                !RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}").hasMatch(value)) {
              return 'Ingresa un correo válido';
            }
            if (isPassword && value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
      decoration: InputDecoration(
        hintText: labelText,
        hintStyle: const TextStyle(color: Colors.black45),
        prefixIcon:
            prefixIcon != null ? Icon(prefixIcon, color: Colors.black45) : null,
        suffixIcon:
            isPassword
                ? IconButton(
                  icon: Icon(
                    isVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black45,
                  ),
                  onPressed: () {
                    setState(() {
                      if (controller == _passwordController) {
                        _passwordVisible = !_passwordVisible;
                      } else if (controller == _confirmPasswordController) {
                        _confirmPasswordVisible = !_confirmPasswordVisible;
                      }
                    });
                  },
                )
                : null,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade600, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 36.0),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 22.0,
                horizontal: 18.0,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Container(
                      height: 100,
                      width: 160,
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
                    const SizedBox(height: 18),

                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _fullNameController,
                      labelText: 'Nombre completo',
                      prefixIcon: Icons.person,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      prefixIcon: Icons.email,
                      isEmail: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _passwordController,
                      labelText: 'Contraseña',
                      prefixIcon: Icons.lock,
                      isPassword: true,
                      isVisible: _passwordVisible,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _confirmPasswordController,
                      labelText: 'Confirmar contraseña',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      isVisible: _confirmPasswordVisible,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _phoneController,
                      labelText: 'Teléfono',
                      prefixIcon: Icons.phone,
                      isPhone: true,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _dniController,
                      labelText: 'DNI',
                      prefixIcon: Icons.assignment_ind,
                      isDNI: true,
                    ),
                    const SizedBox(height: 12),

                    _buildTextField(
                      controller: _cityController,
                      labelText: 'Ciudad',
                      prefixIcon: Icons.location_city,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: _countryController,
                      labelText: 'País',
                      prefixIcon: Icons.flag,
                    ),
                    const SizedBox(height: 18),

                    if (_responseMessage.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                              _responseMessage.contains('Error')
                                  ? Colors.red.withAlpha(51)
                                  : Colors.green.withAlpha(51),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          _responseMessage,
                          style: TextStyle(
                            color:
                                _responseMessage.contains('Error')
                                    ? Colors.red[700]
                                    : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],

                    _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(color: Colors.black),
                        )
                        : SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _signUp(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                vertical: 14.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              elevation: 4,
                            ),
                            child: const Text(
                              'Crear cuenta',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed:
                            () => Navigator.pushReplacementNamed(
                              context,
                              '/login',
                            ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          padding: const EdgeInsets.symmetric(vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          foregroundColor: Colors.black,
                        ),
                        child: const Text(
                          'Ir al inicio',
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
      ),
    );
  }
}
