import 'package:flutter/material.dart';
import '../models/parking.entity.dart';

class ParkingInfo extends StatelessWidget {
  final Parking parking;
  final String defaultImageUrl =
      'https://via.placeholder.com/400x180?text=Parking';

  const ParkingInfo({super.key, required this.parking});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
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
            child: parking.imageUrl?.isNotEmpty == true
                ? Image.network(
              parking.imageUrl!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) => _buildDefaultImage(),
            )
                : _buildDefaultImage(),
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
                        Icons.bookmark,
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
                // Reserve button
                ElevatedButton(
                  onPressed: () {
                    // Reserve functionality
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStatePropertyAll<Color>(
                      Colors.blue[500]!,
                    ),
                    shape: MaterialStatePropertyAll<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                      ),
                    ),
                    minimumSize: MaterialStateProperty.all(Size(double.infinity, 50)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Reserve Now",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultImage() {
    return Image.network(
      defaultImageUrl,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          height: 180,
          width: double.infinity,
          color: Colors.grey[300],
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_parking, size: 50, color: Colors.grey),
              SizedBox(height: 8),
              Text("No image available", style: TextStyle(color: Colors.grey)),
            ],
          ),
        );
      },
    );
  }
}