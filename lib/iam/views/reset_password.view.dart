import 'package:flutter/material.dart';
import '../../shared/i18n.dart';
import '../services/auth.service.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  final AuthService _auth = AuthService();
  bool _loading = false;

  Future<void> _submit() async {
    final token = _tokenController.text.trim();
    final pw = _passwordController.text;
    final conf = _confirmController.text;
    if (token.isEmpty || pw.isEmpty || conf.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('form.field_required'))),
      );
      return;
    }
    if (pw != conf) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('reset.error_mismatch'))),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _auth.resetPassword(token, pw);
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(tr('reset.title')),
          content: Text(tr('reset.success')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: Text(tr('common.close')),
            )
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${tr('reset.error')}: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('reset.title'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _tokenController,
              decoration: InputDecoration(
                hintText: tr('reset.token_hint'),
                prefixIcon: const Icon(Icons.key),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                hintText: tr('reset.new_password_hint'),
                prefixIcon: const Icon(Icons.lock),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _confirmController,
              decoration: InputDecoration(
                hintText: tr('reset.confirm_password_hint'),
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(
                  height: 16,
                  width: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : Text(tr('reset.submit')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
