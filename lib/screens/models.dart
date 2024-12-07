
// models.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class RestaurantModel {
  final String userId;
  final String name;
  final String username;
  final String address;
  final String category;
  final String description;
  final double distance;
  final String email;
  final GeoPoint location;
  final String logo;
  final String phone;
  final String workingHrs;

  RestaurantModel({
    required this.userId,
    required this.name,
    required this.username,
    required this.address,
    required this.category,
    required this.description,
    required this.distance,
    required this.email,
    required this.location,
    required this.logo,
    required this.phone,
    required this.workingHrs,
  });

  factory RestaurantModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RestaurantModel(
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      username: data['username'] ?? '',
      address: data['address'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      distance: data['distance'] ?? 0.0,
      email: data['email'] ?? '',
      location: data['location'] ?? GeoPoint(0, 0),
      logo: data['logo'] ?? '',
      phone: data['phone'] ?? '',
      workingHrs: data['workingHrs'] ?? '',
    );
  }
}

class ItemModel {
  final String itemId;
  final String name;
  final String description;
  final String type;
  final bool availability;
  final String discount;
  final double discountedPrice;
  final String photo;
  final Map<String, dynamic> prices;
  final List<String> sizes;
  final List<dynamic> addOns;

  ItemModel({
    required this.itemId,
    required this.name,
    required this.description,
    required this.type,
    required this.availability,
    required this.discount,
    required this.discountedPrice,
    required this.photo,
    required this.prices,
    required this.sizes,
    required this.addOns,
  });

  factory ItemModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ItemModel(
      itemId: data['itemId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      type: data['type'] ?? '',
      availability: data['availability'] ?? false,
      discount: data['discount'] ?? '',
      discountedPrice: data['discountedPrice'] ?? 0.0,
      photo: data['photo'] ?? '',
      prices: data['prices'] ?? {},
      sizes: List<String>.from(data['sizes'] ?? []),
      addOns: data['addOns'] ?? [],
    );
  }
}