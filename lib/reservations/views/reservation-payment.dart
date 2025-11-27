import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../shared/components/success-dialog.component.dart';
import '../../shared/i18n.dart';

class ReservationPayment extends StatefulWidget {
  final int userId;
  final int reservationId;
  final double amount;

  const ReservationPayment({
    super.key,
    required this.userId,
    required this.reservationId,
    required this.amount,
  });

  @override
  State<ReservationPayment> createState() => _ReservationPaymentState();
}

class _ReservationPaymentState extends State<ReservationPayment> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expirationDateController =
  TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  void _handlePayment() async {
    if (_formKey.currentState!.validate()) {
      final reservationId = widget.reservationId;

      try {
        final prefs = await SharedPreferences.getInstance();
        // Store a local flag indicating this reservation was "paid" locally.
        await prefs.setBool('reservation_paid_$reservationId', true);
        await prefs.setDouble(
          'reservation_paid_amount_$reservationId',
          widget.amount,
        );

        SuccessDialog.show(
          context: context,
          // Show a plain success message (do not reveal this is simulated)
          message: tr('payment.success'),
          buttonLabel: tr('nav.home'),
          icon: Icons.check_circle,
          routeToNavigate: '/home',
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${tr('payment.failed')}: $e')),
        );
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tr('reservation.payment_title'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade100,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${tr('form.total')}:',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue,
                      ),
                    ),
                    Text(
                      'S/ ${widget.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ],
                ),
              ),

              // Name on Card
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('payment.name_on_card'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    validator:
                        (value) =>
                    value == null || value.isEmpty
                        ? 'This field is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),

              // Card Number
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tr('payment.card_number'),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.credit_card),
                      border: OutlineInputBorder(),
                      hintText: '1234-5678-9012-3456',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 19,
                    validator:
                        (value) =>
                    value == null || value.isEmpty
                        ? 'This field is required'
                        : null,
                  ),
                  const SizedBox(height: 16),
                ],
              ),

              // Expiration Date and CVV
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Expiration Date
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('payment.expiration_date'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _expirationDateController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.calendar_today),
                            hintText: 'MM/AA',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          keyboardType: TextInputType.datetime,
                          maxLength: 5,
                          validator:
                              (value) =>
                          value == null || value.isEmpty
                              ? 'Field is required'
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // CVV
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tr('payment.cvv'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _cvvController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.security),
                            hintText: '123',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 3,
                          validator:
                              (value) =>
                          value == null || value.isEmpty
                              ? 'Field is required'
                              : null,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 42),

              // Pay Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _handlePayment(),
                  icon: const Icon(
                    Icons.payment,
                    color: Colors.white,
                    size: 20,
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
                    tr('payment.pay_now'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
