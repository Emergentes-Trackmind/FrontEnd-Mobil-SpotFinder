import 'package:flutter/material.dart';
import '../models/reservation.entity.dart';
import '../services/reservation.service.dart';
import 'package:smartparking_mobile_application/parking-management/services/parking.service.dart';
import 'package:smartparking_mobile_application/reservations/views/reservation-detail.view.dart';
import 'package:smartparking_mobile_application/shared/i18n.dart';

class ReservationCard extends StatefulWidget {
  final Reservation reservation;

  const ReservationCard({Key? key, required this.reservation})
      : super(key: key);

  @override
  State<ReservationCard> createState() => _ReservationCardState();
}

class _ReservationCardState extends State<ReservationCard> {
  String parkingName = '';
  bool isLoading = true;
  final ReservationService _reservationService = ReservationService();

  @override
  void initState() {
    super.initState();
    _loadParkingDetails();
  }

  Future<void> _loadParkingDetails() async {
    try {
      final parkingService = ParkingService();
      final parking = await parkingService.getById(
        widget.reservation.parkingId,
      );
      setState(() {
        parkingName = parking['name'] ?? 'Parking';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        parkingName = 'Parking';
        isLoading = false;
      });
    }
  }

  void _openDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => ReservationDetailView(reservation: widget.reservation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reservation;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _openDetail,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isLoading ? tr('common.loading') : parkingName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${r.date} • ${r.startTime} - ${r.endTime}',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tr('reservation.view_details'),
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusColor(r.status),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _statusLabel(r.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String s) {
    final st = s.toLowerCase();
    if (st.contains('completed')) return Colors.grey.shade600;
    if (st.contains('confirmed') || st.contains('active'))
      return Colors.green.shade600;
    if (st.contains('pending')) return Colors.orange.shade600;
    return Colors.blue.shade600;
  }

  String _statusLabel(String s) {
    final st = s.toLowerCase();
    if (st.contains('completed')) return tr('reservation.status.completed');
    if (st.contains('confirmed') || st.contains('active')) return tr('reservation.status.active');
    if (st.contains('pending')) return tr('reservation.status.pending');
    return s;
  }
}
