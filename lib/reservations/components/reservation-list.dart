import 'package:flutter/material.dart';
import '../models/reservation.entity.dart';
import '../services/reservation.service.dart';
import 'reservation-card.dart';

class ReservationList extends StatefulWidget {
  final String status;
  final int driverId;

  const ReservationList({
    Key? key,
    required this.status,
    required this.driverId,
  }) : super(key: key);

  @override
  State<ReservationList> createState() => _ReservationListState();
}

class _ReservationListState extends State<ReservationList> {
  final ReservationService _reservationService = ReservationService();
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  @override
  void didUpdateWidget(ReservationList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.status != widget.status ||
        oldWidget.driverId != widget.driverId) {
      setState(() {
        _isLoading = true;
      });
      _loadReservations();
    }
  }

  Future<void> _loadReservations() async {
    try {
      String status = widget.status.toUpperCase();
      if (widget.status.contains('cancelled')) {
        status = 'CANCELED';
      }
      final reservations = await _reservationService.getAllByDriverIdAndStatus(
        widget.driverId,
        status,
      );
      setState(() {
        _reservations = reservations;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _reservations = [];
        _isLoading = false;
        _error = 'Error loading reservations: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadReservations,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_reservations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(
                  Icons.calendar_today_outlined,
                  size: 48,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'No tienes reservas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cuando hagas tu primera reserva aparecerá aquí',
              style: TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadReservations,
      child: ListView.builder(
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          return ReservationCard(reservation: _reservations[index]);
        },
      ),
    );
  }
}
