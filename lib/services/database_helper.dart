import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fuzzy/fuzzy.dart';

class AdvancedDatabaseHelper {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Main query processing method remains the same
  Future<QueryResult> processQuery(String query) async {
    print("Processing query: $query");
    query = query.toLowerCase().trim();

    if (_isAvailabilityQuery(query)) {
      if (_containsKeywords(query, ['item', 'menu', 'food'])) {
        return await _checkItemAvailability(query);
      } else if (_containsKeywords(query, ['restaurant', 'place', 'cafe'])) {
        return await _checkRestaurantAvailability(query);
      }
    }

    if (_isDiscountQuery(query)) {
      return await _handleSpecificDiscountQuery(query);
    }

    // Priority-based query handling
    if (_containsKeywords(query, ['restaurant', 'cafe', 'place'])) {
      return await _handleRestaurantQuery(query);
    }

    if (_containsKeywords(query, ['menu', 'item', 'food', 'dish'])) {
      return await _handleMenuItemQuery(query);
    }

    if (_containsKeywords(query, ['discount', 'sale', 'offer', 'cheap'])) {
      return await _handleDiscountQuery(query);
    }

    if (_containsKeywords(query, ['vegetarian', 'vegan', 'cuisine', 'type'])) {
      return await _handleCuisineQuery(query);
    }

    // Fallback fuzzy search
    return await _performFuzzySearch(query);
  }

  // New utility methods for more precise intent detection
  bool _isAvailabilityQuery(String query) {
    List<String> availabilityPhrases = [
      'is',
      'are',
      'available',
      'open',
      'running',
      'serving'
    ];
    return availabilityPhrases.any((phrase) => query.contains(phrase));
  }

  bool _isDiscountQuery(String query) {
    List<String> discountPhrases = [
      'discount',
      'sale',
      'offer',
      'promo',
      'deal',
      'reduced',
      'cheap'
    ];
    return discountPhrases.any((phrase) => query.contains(phrase));
  }

// New method to check specific item availability
  Future<QueryResult> _checkItemAvailability(String query) async {
    try {
      List<Map<String, dynamic>> availableItems = [];

      QuerySnapshot restaurantSnapshot =
          await _firestore.collection('restaurantAdmins').get();

      for (var restaurantDoc in restaurantSnapshot.docs) {
        QuerySnapshot itemsSnapshot = await _firestore
            .collection('restaurantAdmins')
            .doc(restaurantDoc.id)
            .collection('items')
            .where('availability', isEqualTo: true)
            .get();

        for (var itemDoc in itemsSnapshot.docs) {
          var itemData = itemDoc.data() as Map<String, dynamic>;
          var restaurantData = restaurantDoc.data() as Map<String, dynamic>;

          availableItems.add({
            'name': itemData['name'] ?? 'Unnamed Item',
            'restaurant': restaurantData['name'] ?? 'Unknown Restaurant',
            'type': itemData['type'] ?? 'Unspecified'
          });
        }
      }

      return QueryResult(
          type: 'item_availability',
          data: availableItems,
          message: availableItems.isNotEmpty
              ? "Available items (${availableItems.length} found):"
              : "No items are currently available.");
    } catch (e) {
      print("Error checking item availability: $e");
      return QueryResult(
          type: 'error',
          message: "Error checking item availability: ${e.toString()}");
    }
  }

// New method to check restaurant availability/opening status
  Future<QueryResult> _checkRestaurantAvailability(String query) async {
    try {
      List<Map<String, dynamic>> openRestaurants = [];

      QuerySnapshot restaurantSnapshot =
          await _firestore.collection('restaurantAdmins').get();

      for (var doc in restaurantSnapshot.docs) {
        var restaurantData = doc.data() as Map<String, dynamic>;

        // You might want to add more sophisticated time-based checking here
        openRestaurants.add({
          'name': restaurantData['name'] ?? 'Unnamed Restaurant',
          'openingHrs': restaurantData['openingHrs'] ?? 'Hours Not Available',
          'status': 'Open' // Modify this based on actual open/closed logic
        });
      }

      return QueryResult(
          type: 'restaurant_availability',
          data: openRestaurants,
          message: openRestaurants.isNotEmpty
              ? "Restaurants (${openRestaurants.length} found):"
              : "No restaurants found.");
    } catch (e) {
      print("Error checking restaurant availability: $e");
      return QueryResult(
          type: 'error',
          message: "Error checking restaurant availability: ${e.toString()}");
    }
  }

// Specific discount query method
  Future<QueryResult> _handleSpecificDiscountQuery(String query) async {
    try {
      List<Map<String, dynamic>> discountedItems = [];

      QuerySnapshot restaurantSnapshot =
          await _firestore.collection('restaurantAdmins').get();

      for (var restaurantDoc in restaurantSnapshot.docs) {
        QuerySnapshot itemsSnapshot = await _firestore
            .collection('restaurantAdmins')
            .doc(restaurantDoc.id)
            .collection('items')
            .where('discount', isNotEqualTo: null)
            .get();

        for (var itemDoc in itemsSnapshot.docs) {
          var itemData = itemDoc.data() as Map<String, dynamic>;
          var restaurantData = restaurantDoc.data() as Map<String, dynamic>;
          var pricesData = itemData['prices'] as Map<String, dynamic>? ?? {};

          // Only add items with meaningful discounts
          var discountValue = itemData['discount'];
          if (discountValue is num && discountValue > 0) {
            discountedItems.add({
              'name': itemData['name'] ?? 'Unnamed Item',
              'restaurant': restaurantData['name'] ?? 'Unknown Restaurant',
              'discount': '$discountValue%',
              'originalPrice': {
                'Small': pricesData['Small'] ?? 'N/A',
                'Medium': pricesData['Medium'] ?? 'N/A',
                'Large': pricesData['Large'] ?? 'N/A'
              }
            });
          }
        }
      }

      return QueryResult(
          type: 'discounts',
          data: discountedItems,
          message: discountedItems.isNotEmpty
              ? "Items with active discounts (${discountedItems.length} found):"
              : "No items currently have meaningful discounts.");
    } catch (e) {
      print("Error in specific discount query: $e");
      return QueryResult(
          type: 'error',
          message: "Error fetching discount information: ${e.toString()}");
    }
  }

  // Restaurant Query Method
  Future<QueryResult> _handleRestaurantQuery(String query) async {
    try {
      QuerySnapshot restaurantSnapshot =
          await _firestore.collection('restaurantAdmins').get();

      print("Total restaurants found: ${restaurantSnapshot.docs.length}");

      List<Map<String, dynamic>> results = [];

      results = restaurantSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'name': data['name'] ?? 'Unknown Name',
          'address': data['address'] ?? 'No Address',
          'category': data['category'] ?? 'Uncategorized',
          'openingHrs': data['openingHrs'] ?? 'Hours Not Available',
          'phone': data['phone'] ?? 'No Contact',
          'description': data['description'] ?? 'No Description'
        };
      }).toList();

      print("Processed results: $results");

      return QueryResult(
          type: 'restaurants',
          data: results,
          message: results.isNotEmpty
              ? "Here are the restaurants (${results.length} found):"
              : "No restaurants found matching your query.");
    } catch (e) {
      print("Comprehensive error in restaurant query: $e");
      return QueryResult(
          type: 'error',
          message:
              "Detailed error fetching restaurant information: ${e.toString()}");
    }
  }

  // Menu Item Query Method
  Future<QueryResult> _handleMenuItemQuery(String query) async {
    try {
      List<Map<String, dynamic>> allItems = [];

      // Fetch items from all restaurants
      QuerySnapshot restaurantSnapshot =
          await _firestore.collection('restaurantAdmins').get();

      for (var restaurantDoc in restaurantSnapshot.docs) {
        var restaurantData = restaurantDoc.data() as Map<String, dynamic>;

        QuerySnapshot itemsSnapshot = await _firestore
            .collection('restaurantAdmins')
            .doc(restaurantDoc.id)
            .collection('items')
            .get();

        for (var itemDoc in itemsSnapshot.docs) {
          var itemData = itemDoc.data() as Map<String, dynamic>;

          // Safely extract prices
          var pricesData = itemData['prices'] as Map<String, dynamic>? ?? {};

          allItems.add({
            'name': itemData['name'] ?? 'Unnamed Item',
            'restaurant': restaurantData['name'] ?? 'Unknown Restaurant',
            'description': itemData['description'] ?? 'No Description',
            'price': {
              'Small': pricesData['Small'] ?? 'N/A',
              'Medium': pricesData['Medium'] ?? 'N/A',
              'Large': pricesData['Large'] ?? 'N/A'
            },
            'type': itemData['type'] ?? 'Unspecified',
            'availability': itemData['availability'] ?? false,
            'discount': itemData['discount'] ?? 'No Discount',
            'sizes': itemData['sizes'] ?? []
          });
        }
      }

      print("Total menu items found: ${allItems.length}");

      return QueryResult(
          type: 'menu_items',
          data: allItems,
          message: allItems.isNotEmpty
              ? "Here are the menu items (${allItems.length} found):"
              : "No menu items found matching your query.");
    } catch (e, stackTrace) {
      print("Detailed error in menu item query: $e");
      print("Stacktrace: $stackTrace");
      return QueryResult(
          type: 'error',
          message: "Detailed error fetching menu items: ${e.toString()}");
    }
  }

  // Discount Query Method
  Future<QueryResult> _handleDiscountQuery(String query) async {
    try {
      List<Map<String, dynamic>> discountedItems = [];

      QuerySnapshot restaurantSnapshot =
          await _firestore.collection('restaurantAdmins').get();

      for (var restaurantDoc in restaurantSnapshot.docs) {
        var restaurantData = restaurantDoc.data() as Map<String, dynamic>;

        QuerySnapshot itemsSnapshot = await _firestore
            .collection('restaurantAdmins')
            .doc(restaurantDoc.id)
            .collection('items')
            .where('discount', isNotEqualTo: null)
            .get();

        for (var itemDoc in itemsSnapshot.docs) {
          var itemData = itemDoc.data() as Map<String, dynamic>;
          var pricesData = itemData['prices'] as Map<String, dynamic>? ?? {};

          discountedItems.add({
            'name': itemData['name'] ?? 'Unnamed Item',
            'restaurant': restaurantData['name'] ?? 'Unknown Restaurant',
            'discount': itemData['discount'] ?? 'No Discount',
            'originalPrice': {
              'Small': pricesData['Small'] ?? 'N/A',
              'Medium': pricesData['Medium'] ?? 'N/A',
              'Large': pricesData['Large'] ?? 'N/A'
            },
            'discountedPrice': itemData['discountedPrice'] ?? 'N/A'
          });
        }
      }

      print("Total discounted items found: ${discountedItems.length}");

      return QueryResult(
          type: 'discounts',
          data: discountedItems,
          message: discountedItems.isNotEmpty
              ? "Here are the current discounts (${discountedItems.length} found):"
              : "No items are currently on discount.");
    } catch (e) {
      print("Error in discount query: $e");
      return QueryResult(
          type: 'error',
          message:
              "Detailed error fetching discount information: ${e.toString()}");
    }
  }

  // Cuisine Query Method
  Future<QueryResult> _handleCuisineQuery(String query) async {
    try {
      QuerySnapshot restaurantSnapshot =
          await _firestore.collection('restaurantAdmins').get();

      List<Map<String, dynamic>> matchingRestaurants = [];

      for (var doc in restaurantSnapshot.docs) {
        var restaurantData = doc.data() as Map<String, dynamic>;
        var category =
            restaurantData['category']?.toString().toLowerCase() ?? '';

        if (query.contains(category)) {
          matchingRestaurants.add({
            'name': restaurantData['name'] ?? 'Unnamed Restaurant',
            'category': category,
            'address': restaurantData['address'] ?? 'No Address',
            'description': restaurantData['description'] ?? 'No Description'
          });
        }
      }

      print(
          "Total matching cuisine restaurants: ${matchingRestaurants.length}");

      return QueryResult(
          type: 'cuisine',
          data: matchingRestaurants,
          message: matchingRestaurants.isNotEmpty
              ? "Restaurants matching your cuisine query (${matchingRestaurants.length} found):"
              : "No restaurants found in that cuisine category.");
    } catch (e) {
      print("Error in cuisine query: $e");
      return QueryResult(
          type: 'error',
          message:
              "Detailed error fetching cuisine information: ${e.toString()}");
    }
  }

  // Fallback Fuzzy Search
  Future<QueryResult> _performFuzzySearch(String query) async {
    try {
      QuerySnapshot restaurantSnapshot =
          await _firestore.collection('restaurantAdmins').get();

      List<Map<String, dynamic>> allData = [];

      // Search across restaurants and items
      for (var restaurantDoc in restaurantSnapshot.docs) {
        var restaurantData = restaurantDoc.data() as Map<String, dynamic>;

        // Restaurant name fuzzy match
        final restaurantFuzzy = Fuzzy([restaurantData['name'] ?? ''],
            options: FuzzyOptions(threshold: 0.4));

        if (restaurantFuzzy.search(query).isNotEmpty) {
          allData.add({
            'type': 'restaurant',
            'name': restaurantData['name'] ?? 'Unnamed Restaurant',
            'category': restaurantData['category'] ?? 'Uncategorized'
          });
        }

        // Item name fuzzy match
        QuerySnapshot itemsSnapshot = await _firestore
            .collection('restaurantAdmins')
            .doc(restaurantDoc.id)
            .collection('items')
            .get();

        final itemFuzzy = Fuzzy(
            itemsSnapshot.docs.map((doc) => (doc['name'] ?? '')).toList(),
            options: FuzzyOptions(threshold: 0.4));

        var itemMatches = itemFuzzy.search(query);
        for (var match in itemMatches) {
          var matchedItem =
              itemsSnapshot.docs.firstWhere((doc) => doc['name'] == match.item);
          var itemData = matchedItem.data() as Map<String, dynamic>;
          var pricesData = itemData['prices'] as Map<String, dynamic>? ?? {};

          allData.add({
            'type': 'item',
            'name': itemData['name'] ?? 'Unnamed Item',
            'restaurant': restaurantData['name'] ?? 'Unknown Restaurant',
            'price': pricesData['Medium'] ?? 'Price Unavailable'
          });
        }
      }

      print("Total fuzzy search results: ${allData.length}");

      return QueryResult(
          type: 'fuzzy_search',
          data: allData,
          message: allData.isNotEmpty
              ? "I found some matches for your query (${allData.length} results):"
              : "Sorry, I couldn't find anything matching your query.");
    } catch (e) {
      print("Error in fuzzy search: $e");
      return QueryResult(
          type: 'error',
          message: "Detailed error performing search: ${e.toString()}");
    }
  }

  // Utility methods
  bool _containsKeywords(String query, List<String> keywords) {
    return keywords.any((keyword) => query.contains(keyword));
  }
}

// Result wrapper class
class QueryResult {
  final String type;
  final List<Map<String, dynamic>>? data;
  final String message;

  QueryResult({required this.type, this.data, required this.message});
}
