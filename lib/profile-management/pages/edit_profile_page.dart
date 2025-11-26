import 'package:flutter/material.dart';
import '../models/driver.model.dart';
import '../services/driver.service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final DriverService _driverService = DriverService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _avatarUrlController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();

  bool _isLoading = true;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _avatarUrlController.dispose();
    _emailController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final data = await _driverService.getCurrentProfile();
      // attempt to extract userId for later saves
      _userId = (data['userId'] ?? data['id']) is int ? (data['userId'] ?? data['id']) as int : null;
      final driver = Driver.fromJson(data);
      _nameController.text = driver.fullName ?? '';
      _phoneController.text = driver.phone ?? '';
      _avatarUrlController.text = driver.avatarUrl ?? '';
      _emailController.text = driver.email ?? '';
      _roleController.text = driver.role ?? '';
    } catch (e) {
      // ignore
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String? _computedAvatarPreviewUrl() {
    final raw = _avatarUrlController.text.trim();
    if (raw.isEmpty) return null;
    if (raw.startsWith('http')) return raw;
    try {
      final base =
          Uri.parse(DriverService().baseUrl).origin; // scheme://host[:port]
      return raw.startsWith('/') ? '$base$raw' : '$base/$raw';
    } catch (_) {
      return raw; // fallback
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // Payload must contain exactly: fullName, email, phone, role, avatarUrl
    final payload = {
      'fullName': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'role': _roleController.text.trim(),
      'avatarUrl': _avatarUrlController.text.trim(),
    };

    try {
      if (_userId == null) throw Exception('User id missing');
      // Send payload with exactly the required fields to the backend
      final response = await _driverService.updateProfile(payload);
      if (!mounted) return;

      // After updating, fetch the canonical profile from the server to ensure
      // we display exactly what was persisted (server may enrich/normalize data).
      Map<String, dynamic> fresh;
      try {
        fresh = await _driverService.getCurrentProfile();
      } catch (e) {
        // If fetching current profile fails, fall back to server response or payload
        fresh = Map<String, dynamic>.from(response);
      }

      final returnedAvatar = (fresh.containsKey('avatarUrl') && fresh['avatarUrl'] != null)
          ? fresh['avatarUrl'].toString()
          : (payload['avatarUrl']?.toString() ?? '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil actualizado: ${returnedAvatar.isNotEmpty ? returnedAvatar : '(no avatar)'}'),
        ),
      );

      // Return the canonical profile object so the details page can update fully
      Navigator.pop(context, fresh);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final preview = _computedAvatarPreviewUrl();
    return Scaffold(
      appBar: AppBar(title: const Text('Editar perfil')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre completo',
                ),
                validator:
                    (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator:
                    (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Teléfono',
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value:
                _roleController.text.isNotEmpty
                    ? _roleController.text
                    : null,
                decoration: const InputDecoration(labelText: 'Role'),
                items: const [
                  DropdownMenuItem(
                    value: 'ROLE_PARKING_OWNER',
                    child: Text('PARKING_OWNER'),
                  ),
                  DropdownMenuItem(
                    value: 'ROLE_DRIVER',
                    child: Text('DRIVER'),
                  ),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _roleController.text = v);
                },
                validator:
                    (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _avatarUrlController,
                decoration: const InputDecoration(
                  labelText: 'Avatar URL',
                  hintText: 'https://.../avatar.jpg',
                ),
                keyboardType: TextInputType.url,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),
              // Preview image from URL (if provided)
              if (preview != null && preview.isNotEmpty)
                SizedBox(
                  height: 120,
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      preview,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          size: 48,
                        ),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14.0),
                    child: Text(
                      'Guardar',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
