import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/payment.service.dart';

class PaymentMethodAddPage extends StatefulWidget {
  const PaymentMethodAddPage({super.key});

  @override
  State<PaymentMethodAddPage> createState() => _PaymentMethodAddPageState();
}

class _PaymentMethodAddPageState extends State<PaymentMethodAddPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    final payload = {
      'brand': _nameController.text.trim(),
      'cardNumber': _cardNumberController.text.replaceAll(' ', ''),
      'expiry': _expiryController.text.trim(),
    };
    try {
      await _paymentService.post(payload);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      // If backend fails, save locally so user still sees the card
      try {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString('local_payment_methods');
        List<dynamic> existing = [];
        if (raw != null && raw.isNotEmpty) {
          existing = json.decode(raw) as List<dynamic>;
        }
        // Prepare local tokenized-like entry
        final last4 = payload['cardNumber']?.toString();
        final entry = {
          'brand': payload['brand'],
          'last4': last4 != null && last4.length >= 4 ? last4.substring(last4.length - 4) : last4,
        };
        existing.add(entry);
        await prefs.setString('local_payment_methods', json.encode(existing));
        if (!mounted) return;
        Navigator.pop(context, true);
        return;
      } catch (e2) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agregar método de pago')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Titular (ej. Visa, Mastercard)',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Número de tarjeta',
                ),
                keyboardType: TextInputType.number,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _expiryController,
                decoration: const InputDecoration(
                  labelText: 'Vencimiento (MM/AA)',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
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
