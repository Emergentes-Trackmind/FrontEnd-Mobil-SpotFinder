class Review {
  final int? id;
  final int? driverId;
  final String? driverName;
  final int? parkingId;
  final String? parkingName;
  final String? comment;
  final double rating;
  final String? createdAt;

  Review({
    this.id,
    this.driverId,
    this.driverName,
    this.parkingId,
    this.parkingName,
    this.comment,
    required this.rating,
    this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['id'],
      driverId: json['driverId'],
      driverName: json['driverName'],
      parkingId: json['parkingId'],
      parkingName: json['parkingName'],
      comment: json['comment'],
      rating: json['rating'],
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'driverId': driverId,
      'driverName': driverName,
      'parkingId': parkingId,
      'parkingName': parkingName,
      'comment': comment,
      'rating': rating,
      'createdAt': createdAt,
    };
  }
}