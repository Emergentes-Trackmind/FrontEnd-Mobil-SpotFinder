class Parking {
  final int id;
  final int ownerId;
  final String name;
  final String description;
  final String address;
  final double lat;
  final double lng;
  final double ratePerHour;
  final double rating;
  final int totalSpots;
  final int availableSpots;
  final int totalRows;
  final int totalColumns;
  final String imageUrl;

  Parking({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.address,
    required this.lat,
    required this.lng,
    required this.ratePerHour,
    required this.rating,
    required this.totalSpots,
    required this.availableSpots,
    required this.totalRows,
    required this.totalColumns,
    required this.imageUrl,
  });

  factory Parking.fromJson(Map<String, dynamic> json) {
    return Parking(
      id: json['id'] ?? 0,
      ownerId: json['ownerId'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      ratePerHour: (json['ratePerHour'] ?? 0.0).toDouble(),
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalSpots: json['totalSpots'] ?? 0,
      availableSpots: json['availableSpots'] ?? 0,
      totalRows: json['totalRows'] ?? 0,
      totalColumns: json['totalColumns'] ?? 0,
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Parking{id: $id, ownerId: $ownerId, name: $name, description: $description, address: $address, lat: $lat, lng: $lng, ratePerHour: $ratePerHour, rating: $rating, totalSpots: $totalSpots, availableSpots: $availableSpots, totalRows: $totalRows, totalColumns: $totalColumns, imageUrl: $imageUrl}';
  }
}