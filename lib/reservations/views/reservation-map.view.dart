import 'package:flutter/material.dart';
import '../models/reservation.entity.dart';
import '../services/reservation.service.dart';

class ReservationMapView extends StatefulWidget {
  final Reservation reservation;
  const ReservationMapView({super.key, required this.reservation});

  @override
  State<ReservationMapView> createState() => _ReservationMapViewState();
}

class _ReservationMapViewState extends State<ReservationMapView> {
  final ReservationService _reservationService = ReservationService();

  Future<void> _finalizeReservation() async {
    try {
      await _reservationService.updateReservationStatus(
        widget.reservation.id,
        'COMPLETED',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Reserva finalizada')));
      // Redirect to the reservations screen after finalizing.
      // Use pushReplacementNamed to replace the current active reservation view
      // with the reservations list so the user sees their updated reservations.
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/reservations');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void _extendTime() {
    // Placeholder: you can open a dialog to select extra minutes/hours and call an API
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        title: const Text('Extender tiempo'),
        content: const Text(
          'Funcionalidad de extender tiempo (placeholder).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reserva activa')),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F3FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFEDE9FE)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.reservation.driverFullName.isNotEmpty
                          ? widget.reservation.driverFullName
                          : 'Parking Centro Premium',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Espacio: ${widget.reservation.spotLabel}',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Text('Tiempo restante:'),
                        const SizedBox(width: 8),
                        Text(
                          '${widget.reservation.startTime} - ${widget.reservation.endTime}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _extendTime,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Extender tiempo'),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _finalizeReservation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey.shade300),
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text('Finalizar'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Map placeholder
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.location_on,
                  size: 64,
                  color: Color(0xFF7C3AED),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}