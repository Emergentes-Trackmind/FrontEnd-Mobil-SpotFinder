class Driver {
  final int? userId;
  final int? driverId;
  final String? fullName;
  final String? city;
  final String? country;
  final String? phone;
  final String? dni;

  Driver({
    this.userId,
    this.driverId,
    this.fullName,
    this.city,
    this.country,
    this.phone,
    this.dni,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      userId: json['userId'],
      driverId: json['driverId'],
      fullName: json['fullName'],
      city: json['city'],
      country: json['country'],
      phone: json['phone'],
      dni: json['dni'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'driverId': driverId,
      'fullName': fullName,
      'city': city,
      'country': country,
      'phone': phone,
      'dni': dni,
    };
  }
}
