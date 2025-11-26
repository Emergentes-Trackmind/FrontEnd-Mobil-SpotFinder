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
  final String type;
  final String phone;
  final String email;
  final String website;
  final String status;
  final bool covered;
  final bool open24;

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
    this.type = '',
    this.phone = '',
    this.email = '',
    this.website = '',
    this.status = '',
    required this.covered,
    required this.open24,
  });

  factory Parking.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is String) {
        final trimmed = v.trim();
        return int.tryParse(trimmed) ?? double.tryParse(trimmed)?.toInt() ?? 0;
      }
      return 0;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      if (v is String) return double.tryParse(v.trim()) ?? 0.0;
      return 0.0;
    }

    bool parseBool(dynamic v) {
      if (v == null) return false;
      if (v is bool) return v;
      if (v is int) return v != 0;
      if (v is String) {
        final s = v.toLowerCase().trim();
        return s == 'true' || s == '1' || s == 'yes';
      }
      return false;
    }

    return Parking(
      id: parseInt(json['id']),
      ownerId: parseInt(json['ownerId']),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      address: json['address'] ?? '',
      lat: parseDouble(json['lat']),
      lng: parseDouble(json['lng']),
      ratePerHour: parseDouble(json['ratePerHour']),
      rating: parseDouble(json['rating']),
      totalSpots: parseInt(json['totalSpots'] ?? json['totalSpaces']),
      availableSpots: parseInt(json['availableSpots'] ?? json['availableSpaces'] ?? json['accessibleSpaces']),
      totalRows: parseInt(json['totalRows']),
      totalColumns: parseInt(json['totalColumns']),
      imageUrl: json['imageUrl'] ?? '',
      type: json['type'] ?? json['parkingType'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      website: json['website'] ?? '',
      status: json['status'] ?? json['parkingStatus'] ?? '',
      // Support several possible key names from backend for covered / 24h flags
      covered: parseBool(json['covered'] ?? json['isCovered'] ?? json['is_covered']),
      open24: parseBool(json['open24'] ?? json['is24h'] ?? json['open_24']),
    );
  }

  @override
  String toString() {
    return 'Parking{id: $id, ownerId: $ownerId, name: $name, description: $description, address: $address, lat: $lat, lng: $lng, ratePerHour: $ratePerHour, rating: $rating, totalSpots: $totalSpots, availableSpots: $availableSpots, totalRows: $totalRows, totalColumns: $totalColumns, imageUrl: $imageUrl, type: $type, phone: $phone, email: $email, website: $website, status: $status, covered: $covered, open24: $open24}';
  }
}
