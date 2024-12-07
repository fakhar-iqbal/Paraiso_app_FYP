import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> searchRestaurants(String query) async {
    try {
      // Search in restaurant admins collection
      QuerySnapshot restaurantSnapshot = await _firestore
          .collection('restaurantAdmins')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: query + 'z')
          .get();

      List<Map<String, dynamic>> restaurants = [];

      for (var doc in restaurantSnapshot.docs) {
        // Fetch items for each restaurant
        QuerySnapshot itemsSnapshot = await _firestore
            .collection('restaurantAdmins')
            .doc(doc.id)
            .collection('items')
            .get();

        Map<String, dynamic> restaurantData = doc.data() as Map<String, dynamic>;
        List<Map<String, dynamic>> items = itemsSnapshot.docs
            .map((item) => item.data() as Map<String, dynamic>)
            .toList();

        restaurants.add({
          'restaurantDetails': restaurantData,
          'items': items
        });
      }

      return restaurants;
    } catch (e) {
      print('Error searching restaurants: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> searchItems(String query) async {
    try {
      // Search across all restaurants' items
      QuerySnapshot restaurantSnapshot = await _firestore
          .collection('restaurantAdmins')
          .get();

      List<Map<String, dynamic>> matchedItems = [];

      for (var restaurantDoc in restaurantSnapshot.docs) {
        QuerySnapshot itemsSnapshot = await _firestore
            .collection('restaurantAdmins')
            .doc(restaurantDoc.id)
            .collection('items')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThan: query + 'z')
            .get();

        for (var itemDoc in itemsSnapshot.docs) {
          Map<String, dynamic> itemData = itemDoc.data() as Map<String, dynamic>;
          Map<String, dynamic> restaurantData = 
              restaurantDoc.data() as Map<String, dynamic>;

          matchedItems.add({
            'restaurantDetails': restaurantData,
            'itemDetails': itemData
          });
        }
      }

      return matchedItems;
    } catch (e) {
      print('Error searching items: $e');
      return [];
    }
  }
}