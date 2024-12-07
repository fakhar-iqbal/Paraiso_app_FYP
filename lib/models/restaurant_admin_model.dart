import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantAdmin {
  final String userId;
  final String email;
  final String password;
  final String phone;
  final String username;
  final String logo;
  final String address;
  final String prepDelay;
  final String openingHrs;
  final GeoPoint? location;

  RestaurantAdmin({
    required this.userId,
    required this.email,
    required this.password,
    required this.phone,
    required this.username,
    required this.logo,
    required this.address,
    required this.prepDelay,
    required this.openingHrs,
    this.location,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'email': email,
      'password': password,
      'phone': phone,
      'username': username,
      'logo': logo,
      'address': address,
      'prepDelay': prepDelay,
      'openingHrs': openingHrs,
      'location': location,
    };
  }

  factory RestaurantAdmin.fromMap(Map<String, dynamic> map) {
    return RestaurantAdmin(
      userId: map['userId'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      username: map['username'] ?? '',
      logo: map['logo'] ?? '',
      address: map['address'] ?? '',
      prepDelay: map['prepDelay'] ?? '',
      openingHrs: map['openingHrs'] ?? '',
      location: map['location'],
    );
  }
}
