import 'package:cloud_firestore/cloud_firestore.dart';

class Restaurant {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final List<MenuItem> items;
  final int prepDelay;

  Restaurant({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.items,
    required this.prepDelay,
  });

  factory Restaurant.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Handle location array
    List<dynamic> locationData = data['location'] ?? [0.0, 0.0];
    double latitude = double.tryParse(locationData[0].toString().replaceAll('° N', '')) ?? 0.0;
    double longitude = double.tryParse(locationData[1].toString().replaceAll('° E', '')) ?? 0.0;

    return Restaurant(
      id: doc.id,
      name: data['name'] ?? '',
      latitude: latitude,
      longitude: longitude,
      prepDelay: data['prepDelay'] ?? 0,
      items: (data['items'] as List<dynamic>)
          .map((item) => MenuItem.fromMap(item))
          .toList(),
    );
  }
}

class MenuItem {
  final String name;
  final double price;

  MenuItem({
    required this.name,
    required this.price,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      name: map['name'] ?? '',
      price: (map['price'] ?? 0.0).toDouble(),
    );
  }
}