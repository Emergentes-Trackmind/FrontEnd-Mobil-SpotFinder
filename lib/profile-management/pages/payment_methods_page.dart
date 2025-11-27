import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/payment.service.dart';

class PaymentMethodsPage extends StatefulWidget {
  const PaymentMethodsPage({super.key});

  @override
  State<PaymentMethodsPage> createState() => _PaymentMethodsPageState();
}

class _PaymentMethodsPageState extends State<PaymentMethodsPage> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = true;
  List<Map<String, dynamic>> _methods = [];
  List<Map<String, dynamic>> _localMethods = [];

  @override
  void initState() {
    super.initState();
    _loadMethods();
  }

  Future<void> _loadMethods() async {
    setState(() => _isLoading = true);
    try {
      final list = await _paymentService.get();
      // Expecting list of payment method maps
      _methods = List<Map<String, dynamic>>.from(list);
    } catch (e) {
      _methods = [];
    } finally {
      // Also load locally stored payment methods
      try {
        final prefs = await SharedPreferences.getInstance();
        final raw = prefs.getString('local_payment_methods');
        if (raw != null && raw.isNotEmpty) {
          final parsed = json.decode(raw) as List<dynamic>;
          _localMethods = parsed.map((e) => Map<String, dynamic>.from(e as Map)).toList();
        } else {
          _localMethods = [];
        }
      } catch (_) {
        _localMethods = [];
      }

      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openAdd() async {
    final result = await Navigator.pushNamed(context, '/profile/payments/add');
    if (result == true) {
      _loadMethods();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Métodos de pago')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            Expanded(
              child:
              (_methods.isEmpty && _localMethods.isEmpty)
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.credit_card,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'No tienes métodos de pago guardados',
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                itemCount: _methods.length + _localMethods.length,
                itemBuilder: (context, index) {
                  final isLocal = index >= _methods.length;
                  final m = isLocal ? _localMethods[index - _methods.length] : _methods[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 8,
                    ),
                    child: ListTile(
                      title: Text(m['brand'] ?? 'Tarjeta'),
                      subtitle: Text(
                        '•••• •••• •••• ${m['last4'] ?? ''}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isLocal)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('Local', style: TextStyle(color: Colors.blue)),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.more_horiz),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _openAdd,
                child: const Text('+ Agregar método de pago'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
