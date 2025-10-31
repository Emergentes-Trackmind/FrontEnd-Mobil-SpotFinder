import 'package:flutter/material.dart';
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
                          _methods.isEmpty
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
                                itemCount: _methods.length,
                                itemBuilder: (context, index) {
                                  final m = _methods[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 8,
                                    ),
                                    child: ListTile(
                                      title: Text(m['brand'] ?? 'Tarjeta'),
                                      subtitle: Text(
                                        '•••• •••• •••• ${m['last4'] ?? ''}',
                                      ),
                                      trailing: const Icon(Icons.more_horiz),
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
