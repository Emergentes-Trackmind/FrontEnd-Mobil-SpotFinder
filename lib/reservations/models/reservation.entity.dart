class Reservation {
  final int id;
  final String driverFullName;
  final int driverId;
  final String vehiclePlate;
  final int parkingId;
  final String parkingSpotId;
  final String spotLabel;
  final String date;
  final String startTime;
  final String endTime;
  final double totalPrice;
  late final String status;

  Reservation({
    required this.id,
    required this.driverFullName,
    required this.driverId,
    required this.vehiclePlate,
    required this.parkingId,
    required this.parkingSpotId,
    required this.spotLabel,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.totalPrice,
    required this.status,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'] ?? 0,
      driverFullName: json['driverFullName'] ?? '',
      driverId: json['driverId'] ?? 0,
      vehiclePlate: json['vehiclePlate'] ?? '',
      parkingId: json['parkingId'] ?? 0,
      parkingSpotId: json['parkingSpotId'] ?? '',
      spotLabel: json['spotLabel'] ?? '',
      date: json['date'] ?? '',
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      status: json['status'] ?? '',
    );
  }

  @override
  String toString() {
    return 'Reservation(id: $id, driverFullName: $driverFullName, driverId: $driverId, vehiclePlate: $vehiclePlate, parkingId: $parkingId, parkingSpotId: $parkingSpotId, spotLabel: $spotLabel, date: $date, startTime: $startTime, endTime: $endTime, totalPrice: $totalPrice, status: $status)';
  }
}
