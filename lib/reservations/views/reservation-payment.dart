import 'package:flutter/material.dart';
import 'package:smartparking_mobile_application/reservations/services/reservation.service.dart';

import '../../shared/components/success-dialog.component.dart';

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
  final ReservationService _reservationService = ReservationService();

  void _handlePayment() async {
    if (_formKey.currentState!.validate()) {
      final paymentData = {
        'userId': widget.userId,
        'amount': widget.amount,
        'nameOnCard': _nameController.text,
        'cardNumber': _cardNumberController.text,
        'cardExpiryDate': _expirationDateController.text,
      };
      final reservationId = widget.reservationId;

      try {
        final response = await _reservationService.createReservationPayment(paymentData, reservationId);
        if (response.containsKey('id')) {
          SuccessDialog.show(
            context: context,
            message: 'Payment successful! Your reservation has been confirmed.',
            buttonLabel: 'Go to Home',
            icon: Icons.check_circle,
            routeToNavigate: '/home',
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reservation Payment')),
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
                    const Text(
                      'Total:',
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
                  const Text(
                    'Name on Card',
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
                  const Text(
                    'Card Number',
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
                        const Text(
                          'Expiration Date',
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
                        const Text(
                          'CVV',
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
                  label: const Text(
                    'Pay Now',
                    style: TextStyle(
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
