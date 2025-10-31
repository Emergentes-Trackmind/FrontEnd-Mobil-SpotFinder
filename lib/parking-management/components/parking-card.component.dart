import 'package:flutter/material.dart';
import 'package:smartparking_mobile_application/reservations/views/reservation-view.dart';
import '../../rating-and-review/views/reviews_view.dart';
import '../models/parking.entity.dart';

class ParkingCard extends StatelessWidget {
  final Parking parking;
  final String defaultImageUrl =
      'https://via.placeholder.com/400x180?text=Parking';

  const ParkingCard({super.key, required this.parking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minWidth: MediaQuery.of(context).size.width,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Parking Details Title
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'Parking Details',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Divider
              const Divider(height: 1, color: Colors.grey, thickness: 2),
              // Parking image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: AspectRatio(
                  aspectRatio: 16/9,
                  child: parking.imageUrl?.isNotEmpty == true
                      ? Image.network(
                    parking.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => _buildDefaultImage(),
                  )
                      : _buildDefaultImage(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Parking name with favorite icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            parking.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.bookmark_border,
                            color: Colors.blue[700],
                            size: 28,
                          ),
                          onPressed: () {
                            // Add to favorites functionality
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Parking address with location icon
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 18, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            parking.address,
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Parking price with money icon
                    Row(
                      children: [
                        Icon(Icons.attach_money, size: 20, color: Colors.green[700]),
                        const SizedBox(width: 4),
                        Text(
                          '\$${parking.ratePerHour.toStringAsFixed(2)}/hour',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Rating with stars
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < parking.rating.floor() ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 20,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          parking.rating.toStringAsFixed(1),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Available spots with parking icon
                    Row(
                      children: [
                        Icon(Icons.local_parking, size: 20, color: Colors.blue[700]),
                        const SizedBox(width: 4),
                        Text(
                          '${parking.availableSpots} available / ${parking.totalSpots} total',
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // See More button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ParkingReservationPage(parking: parking),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          backgroundColor: const MaterialStatePropertyAll<Color>(
                            Colors.blue,
                          ),
                          shape: const MaterialStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            ),
                          ),
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Reserve Now",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.calendar_today,
                              color: Colors.white,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // View Reviews button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewsView(
                                parkingId: parking.id,
                                title: "${parking.name} Reviews",
                              ),
                            ),
                          );
                        },
                        style: ButtonStyle(
                          side: MaterialStateProperty.all(
                            BorderSide(color: Colors.blue.shade700),
                          ),
                          shape: const MaterialStatePropertyAll<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(16)),
                            ),
                          ),
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 12)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "View Reviews",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.blue.shade700,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.star_rate,
                              color: Colors.blue.shade700,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_parking, size: 50, color: Colors.grey),
            const SizedBox(height: 8),
            Text("No image available", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}