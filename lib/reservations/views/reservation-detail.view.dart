import 'dart:async';

import 'package:flutter/material.dart';
import 'package:smartparking_mobile_application/shared/i18n.dart';
import '../models/reservation.entity.dart';
import '../services/reservation.service.dart';
import 'reservation-map.view.dart';

class ReservationDetailView extends StatefulWidget {
  final Reservation reservation;

  const ReservationDetailView({super.key, required this.reservation});

  @override
  State<ReservationDetailView> createState() => _ReservationDetailViewState();
}

class _ReservationDetailViewState extends State<ReservationDetailView> {
  final ReservationService _reservationService = ReservationService();
  Duration _remaining = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _computeRemaining();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (_) => _computeRemaining(),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _computeRemaining() {
    try {
      final r = widget.reservation;
      DateTime end;

      // Try to parse date and time. Reservation.date may be ISO or plain date.
      if (r.date.contains('T')) {
        // Likely full ISO
        end = DateTime.parse(r.date).toLocal();
      } else {
        // Combine date and endTime (assumed HH:mm)
        final datePart = r.date.split(' ').first;
        end = DateTime.parse(datePart);
        final parts = r.endTime.split(':');
        if (parts.length >= 2) {
          end = DateTime(
            end.year,
            end.month,
            end.day,
            int.parse(parts[0]),
            int.parse(parts[1]),
          );
        } else {
          end = end.add(const Duration(hours: 1));
        }
      }

      final now = DateTime.now();
      setState(() {
        _remaining = end.difference(now);
        if (_remaining.isNegative) _remaining = Duration.zero;
      });
    } catch (e) {
      // fallback
      setState(() => _remaining = const Duration(hours: 1));
    }
  }

  Future<void> _cancelReservation() async {
    try {
      await _reservationService.updateReservationStatus(
        widget.reservation.id,
        'CANCELED',
      );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(tr('reservations.canceled_snack'))));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${tr('reservations.error_canceling')}: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return Scaffold(
      appBar: AppBar(title: Text(tr('reservations.active_title'))),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Center(
              child: Column(
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.green.shade400,
                        width: 6,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$minutes:$seconds',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tr('reservation.remaining_label'),
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.reservation.driverFullName.isNotEmpty
                        ? widget.reservation.driverFullName
                        : 'Parking',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${tr('reservation.spot')} ${widget.reservation.spotLabel} • ${tr('reservation.remaining_label')} ${widget.reservation.endTime}',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Buttons
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => ReservationMapView(
                        reservation: widget.reservation,
                      ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  tr('reservations.view_on_map'),
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _cancelReservation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red.shade600,
                  side: BorderSide(color: Colors.red.shade200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(tr('reservations.cancel_label')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
