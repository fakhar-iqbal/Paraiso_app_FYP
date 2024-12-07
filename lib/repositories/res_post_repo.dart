import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../models/nearby_restaurants.dart';
import '../models/order_model.dart';
import '../models/product_item.dart';
import '../models/restaurant_admin_model.dart';
import '../util/local_storage/shared_preferences_helper.dart';

class RestaurantPostRepo {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // GET NEARBY RESTAURANTS from firebase
  Future<List<NearbyRestaurants>> getNearbyRestaurants(String email) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('email', isEqualTo: email)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantAdminData =
            snap.docs[0];

        final CollectionReference<Map<String, dynamic>> restaurantsRef =
            restaurantAdminData.reference.collection('restaurants');

        final QuerySnapshot<Map<String, dynamic>> restaurantsSnap =
            await restaurantsRef.get();

        final List<NearbyRestaurants> restaurantsList = restaurantsSnap.docs
            .map((restaurantDoc) =>
                NearbyRestaurants.fromMap(restaurantDoc.data()))
            .toList();

        return restaurantsList;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch nearby restaurants: $e');
    }
  }

  Future<void> toggleRestaurantFavorite(
      String restaurantId, bool isFavorite) async {
    try {
      final email = SharedPreferencesHelper.getCustomerEmail();
      final userDocRef = _firestore.collection("clients").doc(email);
      final currentUserDocument = await userDocRef.get();

      final List<String> favorites =
          List<String>.from(currentUserDocument.data()?["favorites"] ?? []);

      if (!isFavorite) {
        if (!favorites.contains(restaurantId)) {
          favorites.add(restaurantId);
          await userDocRef.update({'favorites': favorites});
        }
      } else {
        if (favorites.contains(restaurantId)) {
          favorites.remove(restaurantId);
          await userDocRef.update({'favorites': favorites});
        }
      }
    } catch (e) {
      throw Exception('Failed to toggle restaurant favorite: $e');
    }
  }

  Future<bool> isRestaurantFavorite(String restaurantId) async {
    try {
      final email = SharedPreferencesHelper.getCustomerEmail();
      final userDocRef = _firestore.collection("clients").doc(email);
      final currentUserDocument = await userDocRef.get();

      final List<String> favorites =
          List<String>.from(currentUserDocument.data()?["favorites"] ?? []);

      return favorites.contains(restaurantId);
    } catch (e) {
      throw Exception('Failed to check if restaurant is a favorite: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getRestaurantsWithDiscounts(
      RestaurantAdmin admin) async {
    final restaurantAdminsCollection =
        _firestore.collection('restaurantAdmins');
    final List<Map<String, dynamic>> restaurants = [];

    try {
      final currentRestaurantQuery = await restaurantAdminsCollection
          .where('userId', isEqualTo: admin.userId)
          .get();
      //
      // if (kDebugMode) print("111111");

      if (currentRestaurantQuery.docs.isNotEmpty) {
        // final currentRestaurantData = currentRestaurantQuery.docs.first.data();

        final restaurantAdminsQuery = await restaurantAdminsCollection.get();

        final nearbyRestaurants = await currentRestaurantQuery
            .docs.first.reference
            .collection("restaurants")
            .get();

        // if (kDebugMode) print("22222");
        // if (kDebugMode) print(nearbyRestaurants.docs.length);

        for (final restaurantDocument in nearbyRestaurants.docs) {
          final restaurantData = restaurantDocument.data();

          // if (kDebugMode) print("333333");
          // if (kDebugMode) print(restaurantData["email"]);

          // Find a matching main restaurant by email
          final matchingMainRestaurant =
              restaurantAdminsQuery.docs.firstWhereOrNull(
            (mainDoc) => mainDoc.data()['email'] == restaurantData['email'],
          );
          //
          // if (kDebugMode) print("44444444");
          // if (kDebugMode) print(matchingMainRestaurant?.data());

          final restaurantId = matchingMainRestaurant?.id;
          final restaurantName = matchingMainRestaurant?.data()['username'];
          final restaurantLogo = matchingMainRestaurant?.data()['logo'];
          //
          // if (kDebugMode) print("555555");

          final restaurantMenu =
              await matchingMainRestaurant?.reference.collection("items").get();

          if (restaurantMenu != null) {
            // if (kDebugMode) print(restaurantMenu.docs.length);
            //
            // if (kDebugMode) print("66666");

            for (final itemDocument in restaurantMenu.docs) {
              // if (kDebugMode) print("7777777");
              final itemData = itemDocument.data();

              if (itemData['discount'] != '0%' &&
                  itemData.containsKey("lastUpdated")) {
                // if (kDebugMode) print("8888888");
                restaurants.add({
                  'restaurantId': restaurantId,
                  'restaurantName': restaurantName,
                  'restaurantLogo': restaurantLogo,
                  'itemName': itemData['name'],
                  'discount': itemData['discount'],
                  'lastUpdated': itemData['lastUpdated'],
                });
              }
            }
          }
        }

        // Sort the restaurants by "lastUpdated" in descending order
        restaurants
            .sort((a, b) => b['lastUpdated'].compareTo(a['lastUpdated']));

        // if (kDebugMode) print("999999");

        return restaurants.take(10).toList();
      } else {
        // Handle the case when the current restaurant is not found
        return [];
      }
    } catch (error, stk) {
      // if (kDebugMode) print(stk);
      // if (kDebugMode) print("10101010110");
      if (kDebugMode) print('Error fetching restaurants: $error');
      rethrow;
    }
  }

  // find nearby restaurants & save in firebase
  Future<void> fetchAndSaveNearbyRestaurants(RestaurantAdmin admin) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> restaurantAdminsSnap =
          await _firestore.collection('restaurantAdmins').get();

      final QuerySnapshot<Map<String, dynamic>> currentResUser =
          await _firestore
              .collection('restaurantAdmins')
              .where('userId', isEqualTo: admin.userId)
              .get();

      final GeoPoint currentGeoPoint = GeoPoint(
        admin.location!.latitude,
        admin.location!.longitude,
      );

      final List<DocumentSnapshot<Map<String, dynamic>>>
          matchedRestaurants1000 = await searchRestaurantsWithinRadius(
              admin, restaurantAdminsSnap.docs, currentGeoPoint, 1000);

      if (matchedRestaurants1000.length < 10) {
        final List<DocumentSnapshot<Map<String, dynamic>>>
            matchedRestaurants10000 = await searchRestaurantsWithinRadius(
                admin, restaurantAdminsSnap.docs, currentGeoPoint, 10000);

        if (matchedRestaurants10000.length < 10) {
          final List<DocumentSnapshot<Map<String, dynamic>>>
              matchedRestaurants50000 = await searchRestaurantsWithinRadius(
                  admin, restaurantAdminsSnap.docs, currentGeoPoint, 50000);

          final List<DocumentSnapshot<Map<String, dynamic>>> allMatches = [
            ...matchedRestaurants1000,
            ...matchedRestaurants10000,
            ...matchedRestaurants50000,
          ];

          final Set<String> addedEmails = {};
          final List<DocumentSnapshot<Map<String, dynamic>>>
              deduplicatedMatches = deduplicateMatches(allMatches, addedEmails);

          addMatchesToSubcollection(deduplicatedMatches,
              currentResUser.docs[0].reference.collection('restaurants'));
        } else {
          addMatchesToSubcollection(matchedRestaurants10000,
              currentResUser.docs[0].reference.collection('restaurants'));
        }
      } else {
        addMatchesToSubcollection(matchedRestaurants1000,
            currentResUser.docs[0].reference.collection('restaurants'));
      }
    } catch (e) {
      throw Exception('Failed to fetch and save nearby restaurants: $e');
    }
  }

  // remove duplicates if any
  List<DocumentSnapshot<Map<String, dynamic>>> deduplicateMatches(
      List<DocumentSnapshot<Map<String, dynamic>>> matches,
      Set<String> addedEmails) {
    final List<DocumentSnapshot<Map<String, dynamic>>> deduplicatedMatches = [];

    for (final DocumentSnapshot<Map<String, dynamic>> restaurantAdminData
        in matches) {
      final String email = restaurantAdminData["email"];
      if (!addedEmails.contains(email)) {
        deduplicatedMatches.add(restaurantAdminData);
        addedEmails.add(email);
      }
    }

    return deduplicatedMatches;
  }

  // search restaurants with in specified radius
  Future<List<DocumentSnapshot<Map<String, dynamic>>>>
      searchRestaurantsWithinRadius(
          RestaurantAdmin admin,
          List<DocumentSnapshot<Map<String, dynamic>>> restaurantAdmins,
          GeoPoint currentGeoPoint,
          double radius) async {
    final QuerySnapshot<Map<String, dynamic>> currentResUser = await _firestore
        .collection('restaurantAdmins')
        .where('userId', isEqualTo: admin.userId)
        .get();

    final QuerySnapshot<Map<String, dynamic>> nearbyRestaurants =
        await currentResUser.docs[0].reference.collection("restaurants").get();

    final List<DocumentSnapshot<Map<String, dynamic>>> matches = [];

    for (final DocumentSnapshot<Map<String, dynamic>> restaurantAdminData
        in restaurantAdmins) {
      final GeoPoint adminLocation =
          restaurantAdminData['location'] as GeoPoint;
      final double adminLatitude = adminLocation.latitude;
      final double adminLongitude = adminLocation.longitude;

      final double distance = Geolocator.distanceBetween(
        currentGeoPoint.latitude,
        currentGeoPoint.longitude,
        adminLatitude,
        adminLongitude,
      );

      if (distance <= radius) {
        final matching = filterDocsByMatchingEmail(
            nearbyRestaurants.docs, restaurantAdminData["email"]);
        if (matching.isEmpty && admin.email != restaurantAdminData["email"]) {
          restaurantAdminData.reference.update({"distance": distance});
          matches.add(restaurantAdminData);
        }
      }
    }
    return matches;
  }

  // add matched restaurants to subcollection
  void addMatchesToSubcollection(
      List<DocumentSnapshot<Map<String, dynamic>>> matches,
      CollectionReference<Map<String, dynamic>> subcollectionRef) {
    for (final DocumentSnapshot<Map<String, dynamic>> restaurantAdminData
        in matches) {
      subcollectionRef.add({
        'name': restaurantAdminData['username'],
        'location': restaurantAdminData['location'],
        "distance": restaurantAdminData["distance"],
        "logo": restaurantAdminData["logo"],
        "email": restaurantAdminData["email"],
        "description": restaurantAdminData["description"],
      });
      // if (kDebugMode) print("doneeeeeeeeeeee");
    }
  }

  // check (by email) if the restaurant is already there in the sub collection
  List<DocumentSnapshot<Map<String, dynamic>>> filterDocsByMatchingEmail(
    List<DocumentSnapshot<Map<String, dynamic>>> documents,
    String emailToMatch,
  ) {
    return documents.where((doc) {
      final String? docEmail = doc.data()?['email'];
      return docEmail != null && docEmail == emailToMatch;
    }).toList();
  }

  // FIND NEARBY RESTAURANTS FROM GMAPS
  // Future<List<Map<String, dynamic>>> findNearbyRestaurantsFromGMaps(
  //     GeoPoint userLocation) async {
  //   const apiKey = 'AIzaSyCFjwZlIFKLNkiMyTEe64xr_EhcLcNR9kM';
  //   const radius = '1000';
  //   const type = 'restaurant';

  //   final response = await http.get(
  //     Uri.parse('https://maps.googleapis.com/maps/api/place/nearbysearch/json?'
  //         'location=${userLocation.latitude},${userLocation.longitude}&'
  //         'radius=$radius&'
  //         'type=$type&'
  //         'key=$apiKey'),
  //   );

  //   if (response.statusCode == 200) {
  //     final data = json.decode(response.body);
  //     final results = data['results'];

  //     List<Map<String, dynamic>> restaurantsList = [];

  //     for (var result in results) {
  //       Map<String, dynamic> restaurantMap = {
  //         'name': result['name'],
  //         'description': result['types'],
  //         'location': {
  //           'latitude': result['geometry']['location']['lat'],
  //           'longitude': result['geometry']['location']['lng'],
  //         },
  //         'vicinity': result['vicinity'],
  //         'user_ratings_total': result['user_ratings_total'],
  //         'rating': result['rating'],
  //         'icon': result['icon'],
  //         'place_id': result['place_id'],
  //       };

  //       restaurantsList.add(restaurantMap);
  //     }
  //     print(restaurantsList.length);
  //     print(restaurantsList[0]);

  //     return restaurantsList;
  //   } else {
  //     throw Exception('Failed to load nearby restaurants');
  //   }
  // }

  // Future<void> saveNearbyRestaurantsToFirebase(
  //     String email, List<Map<String, dynamic>> nearbyRestaurants) async {
  //   try {
  //     print("here");
  //     for (final Map<String, dynamic> restaurantData in nearbyRestaurants) {
  //       final double latitude = restaurantData['location']['latitude'];
  //       final double longitude = restaurantData['location']['longitude'];

  //       final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
  //           .collection('restaurantAdmins')
  //           .where('email', isEqualTo: email)
  //           .where('restaurants', arrayContains: {
  //         'location': {'latitude': latitude, 'longitude': longitude}
  //       }).get();

  //       print(snap.docs.length);

  //       if (snap.docs.isNotEmpty) {
  //         final DocumentSnapshot<Map<String, dynamic>> restaurantAdminData =
  //             snap.docs[0];

  //         final CollectionReference<Map<String, dynamic>> restaurantsRef =
  //             restaurantAdminData.reference.collection('restaurants');

  //         await restaurantsRef.add(restaurantData);
  //       } else {
  //         // Handle the case where no matching restaurant is found in Firebase
  //         print(
  //             'No matching restaurant found for location: $latitude, $longitude');
  //         // You can choose to skip it or handle it differently
  //       }
  //     }
  //   } catch (e) {
  //     throw Exception('Failed to save nearby restaurants: $e');
  //   }
  // }

  // GET ADDONS OF A RESTAURANT
  Future<List<AddonItemWithId>> getADDON(String userId) async {

    try {
      print("here 1");
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      print("here 2");
      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> menuItems = snap.docs[0];

        final CollectionReference<Map<String, dynamic>> menuRef =
        menuItems.reference.collection('Addons');

        print("here 3");
        final QuerySnapshot<Map<String, dynamic>> menuSnap =
        await menuRef.get();

        print("here 4");
        final List<AddonItemWithId> menuItemsList = menuSnap.docs.map((menuDoc) {
          final Map<String, dynamic> menuData = menuDoc.data();
          // final dynamic itemId = menuData['addonId'];

          // final String itemIdString =
          // itemId is int ? itemId.toString() : itemId;
          print("here 6");
          return AddonItemWithId.fromMap(menuData);
        }).toList();

        print("here 7");
        return menuItemsList;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch menu: $e');
    }
  }

  // GET MENU OF A RESTAURANT
  Future<List<ProductItem>> getMenu(String userId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> menuItems = snap.docs[0];

        final CollectionReference<Map<String, dynamic>> menuRef =
            menuItems.reference.collection('items');

        final QuerySnapshot<Map<String, dynamic>> menuSnap =
            await menuRef.get();

        final List<ProductItem> menuItemsList = menuSnap.docs.map((menuDoc) {
          final Map<String, dynamic> menuData = menuDoc.data();
          final dynamic itemId = menuData['itemId'];

          final String itemIdString =
              itemId is int ? itemId.toString() : itemId;

          return ProductItem.fromMap(menuData..['itemId'] = itemIdString);
        }).toList();

        return menuItemsList;
      } else {
        return [];
      }
    } catch (e) {
      throw Exception('Failed to fetch menu: $e');
    }
  }

  // UPDATE DISCOUNT & DISCOUNTED PRICE
  Future<void> updateItemDiscounts(
      String userId, List<String> itemIds, String discount) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantDoc =
            snap.docs[0];
        final CollectionReference<Map<String, dynamic>> menuRef =
            restaurantDoc.reference.collection('items');

        final DateTime currentTime = DateTime.now();

        for (String itemId in itemIds) {
          final QuerySnapshot<Map<String, dynamic>> itemQuery =
              await menuRef.where('itemId', isEqualTo: itemId).get();

          if (itemQuery.docs.isNotEmpty) {
            final DocumentReference<Map<String, dynamic>> itemDocRef =
                itemQuery.docs[0].reference;

            final Map<String, dynamic> prices =
                Map<String, dynamic>.from(itemQuery.docs[0]['prices']);

            // final String firstSize = prices.keys.firstWhere(
            //     (size) => true);
            final originalPrice = prices.values.firstWhere((price) => true);

            final double discountedPrice = originalPrice -
                (originalPrice *
                    (double.parse(discount.replaceAll('%', "").trim()) / 100));

            await itemDocRef.update({
              'discount': discount,
              'discountedPrice': discountedPrice,
              'lastUpdated': Timestamp.fromDate(currentTime),
            });
          }
        }
      }
    } catch (e, stk) {
      // if (kDebugMode) print(stk);
      throw Exception('Failed to update item discounts: $e');
    }
  }

  // CLEAR DISCOUNTS
  Future<void> clearItemDiscounts(String userId, List<String> itemIds) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantDoc =
            snap.docs[0];
        final CollectionReference<Map<String, dynamic>> menuRef =
            restaurantDoc.reference.collection('items');

        for (String itemId in itemIds) {
          final QuerySnapshot<Map<String, dynamic>> itemQuery =
              await menuRef.where('itemId', isEqualTo: itemId).get();

          if (itemQuery.docs.isNotEmpty) {
            final DocumentReference<Map<String, dynamic>> itemDocRef =
                itemQuery.docs[0].reference;

            final Map<String, dynamic> prices =
                Map<String, dynamic>.from(itemQuery.docs[0]['prices']);

            final originalPrice = prices.values.first;

            await itemDocRef.update({
              'discount': '0%',
              'discountedPrice': originalPrice,
              'lastUpdated': FieldValue.delete(),
            });
          }
        }
      }
    } catch (e, stk) {
      // if (kDebugMode) print(stk);
      throw Exception('Failed to clear item discounts: $e');
    }
  }

  // get top most discount item
  Future<Map<String, dynamic>> getItemWithTopDiscount() async {
    Map<String, dynamic>? topDiscountItem;

    try {
      final QuerySnapshot<Map<String, dynamic>> restaurantSnap =
          await _firestore.collection('restaurantAdmins').get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> restaurantDoc
          in restaurantSnap.docs) {
        final CollectionReference<Map<String, dynamic>> menuRef =
            restaurantDoc.reference.collection('items');

        final QuerySnapshot<Map<String, dynamic>> itemsSnap =
            await menuRef.get();

        for (QueryDocumentSnapshot<Map<String, dynamic>> itemDoc
            in itemsSnap.docs) {
          final dynamic discountField = itemDoc.data()['discount'];
          final String discount = discountField ?? "0%";

          if (topDiscountItem == null ||
              _compareDiscounts(discount, topDiscountItem['discount'])) {
            topDiscountItem = {
              'itemId': itemDoc['itemId'],
              'itemName': itemDoc['name'],
              'discount': discount,
              'restaurantName': restaurantDoc['username'],
            };
          }
        }
      }
    } catch (e, stk) {
      // if (kDebugMode) print(stk);
      throw Exception('Failed to retrieve item with top discount: $e');
    }

    return topDiscountItem ?? {};
  }

  bool _compareDiscounts(String discount1, String discount2) {
    final double percentage1 = double.tryParse(discount1.replaceAll('%', ''))!;
    final double percentage2 = double.tryParse(discount2.replaceAll('%', ''))!;

    return percentage1 > percentage2;
  }

  // MAKE ITEM FREE
  Future<void> makeItemFree(
      String userId, String itemId, Map<String, dynamic> giftItem) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantDoc =
            snap.docs[0];
        final CollectionReference<Map<String, dynamic>> menuRef =
            restaurantDoc.reference.collection('items');

        final DateTime currentTime = DateTime.now();

        final QuerySnapshot<Map<String, dynamic>> itemQuery =
            await menuRef.where('itemId', isEqualTo: itemId).get();

        if (itemQuery.docs.isNotEmpty) {
          final DocumentReference<Map<String, dynamic>> itemDocRef =
              itemQuery.docs[0].reference;

          await itemDocRef.update({
            'free': giftItem,
            'lastUpdated': Timestamp.fromDate(currentTime),
          });
        }
      }
    } catch (e, stk) {
      // if (kDebugMode) print(stk);
      throw Exception('Failed to update item discounts: $e');
    }
  }

  // REMOVE FREE ITEM
  Future<void> clearFreeItem(String userId, String itemId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantDoc =
            snap.docs[0];
        final CollectionReference<Map<String, dynamic>> menuRef =
            restaurantDoc.reference.collection('items');

        final QuerySnapshot<Map<String, dynamic>> itemQuery =
            await menuRef.where('itemId', isEqualTo: itemId).get();

        if (itemQuery.docs.isNotEmpty) {
          final DocumentReference<Map<String, dynamic>> itemDocRef =
              itemQuery.docs[0].reference;

          Map<String, dynamic> data = {
            'free': FieldValue.delete(),
          };

          itemDocRef.update(data).then((_) {
            // if (kDebugMode) print("Field deleted successfully");
          }).catchError((error) {
            if (kDebugMode) print("Error deleting field: $error");
          });
        }
      }
    } catch (e, stk) {
      // if (kDebugMode) print(stk);
      throw Exception('Failed to clear item discounts: $e');
    }
  }

  // GET CLIENTS BASED ON REWARDS SENT
  Future<List<Map<String, dynamic>>> getClientsWithSentRewards(
    String restaurantId,
  ) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> clientsSnapshot =
          await _firestore
              .collection('clients')
              .where('orderedFrom', arrayContains: restaurantId)
              .get();

      List<String> clientEmails = clientsSnapshot.docs.map((doc) {
        return doc.id;
      }).toList();

      if (clientEmails.isNotEmpty) {
        final QuerySnapshot<Map<String, dynamic>> postsSnapshot =
            await _firestore
                .collection('posts')
                .where('senderEmail', whereIn: clientEmails)
                .get();

        List<Map<String, dynamic>> postsList = postsSnapshot.docs.map((doc) {
          final Map<String, dynamic> postData = doc.data();
          return {
            'sentOn': postData['sentOn'],
            'senderEmail': postData['senderEmail'],
            'sentTo': postData['sentTo'],
            'photo': postData['photo'],
            'sender': postData['sender'],
            'type': postData['type'],
          };
        }).toList();

        postsList.sort((a, b) {
          return b['sentOn'].compareTo(a['sentOn']);
        });

        return postsList;
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch clients with sent rewards: $e');
    }
  }

  // GET ALL ORDERS
  Future<List<OrderModel>> getOrdersForRestaurant(String restaurantId) async {
    try {
      final QuerySnapshot querySnapshot = await _firestore
          .collection('orders')
          .where('restaurantId', isEqualTo: restaurantId)
          .get();

      final List<OrderModel> orders = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return OrderModel.fromMap(data);
      }).toList();

      orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      return orders;
    } catch (error) {
      throw Exception('Failed to fetch orders: $error');
    }
  }

  // UPDATE ORDER STATUS
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore
          .collection('orders')
          .doc(orderId)
          .update({'status': newStatus});
    } catch (error) {
      throw Exception('Failed to update order status: $error');
    }
  }

  // TOTAL SALES
  Future<double> calculateTotalOrderAmount(String resId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> orderDocs = await _firestore
          .collection('orders')
          .where('restaurantId', isEqualTo: resId)
          .get();

      final totalAmountList = orderDocs.docs
          .where((orderDoc) => orderDoc.data().containsKey('totalPrice'))
          .map((orderDoc) => (orderDoc.data()['totalPrice'] as num).toDouble())
          .toList();

      double totalAmount = totalAmountList.fold(0.0, (a, b) => a + b);

      return totalAmount;
    } catch (e) {
      if (kDebugMode) print('Error calculating total order amount: $e');
      return 0.0;
    }
  }

  bool checkDate(String dateString , String type){
    try {
      DateTime date = DateFormat("yyyy-MM-dd hh:mm a").parse(dateString);

      // Get today's date
      DateTime now = DateTime.now();
      DateTime today = DateTime(now.year, now.month, now.day);

      // Check if the date is today
      if(type == "today"){
        return date.year == today.year && date.month == today.month && date.day == today.day;
      }
      else if(type == "weekly"){
        return date.isAfter(today.subtract(Duration(days: 7)));
      }
      else if(type == "monthly"){
        return date.isAfter(today.subtract(Duration(days: 30)));
      }
      else{
        return true;
      }
    } catch (e) {
      print("Error parsing the date: $e");
      return false; // Return false if there's an error parsing the date
    }
  }

  Future<double> calculateTotalOrder(String resId, String timeFrame) async {
    try {

      final QuerySnapshot<Map<String, dynamic>> orderDocs = await _firestore
          .collection('orders')
          .where('restaurantId', isEqualTo: resId)
          .get();

      final totalAmountList = orderDocs.docs
          .where((orderDoc) => orderDoc.data().containsKey('totalPrice'))
          .where((orderDoc) =>
               checkDate(orderDoc.data()['time'] , timeFrame))
          .map((orderDoc) => (orderDoc.data()['totalPrice'] as num).toDouble())
          .toList();

      double totalAmount = totalAmountList.fold(0.0, (a, b) => a + b);

      return totalAmount;
    } catch (e) {
      if (kDebugMode) print('Error calculating total order amount: $e');
      return 0.0;
    }
  }


// TOP SELLERS
  Future<List<Map<String, dynamic>>> findTopSalesRestaurants(int limit) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> restaurantDocs =
          await _firestore.collection('restaurantAdmins').get();

      final List<QueryDocumentSnapshot<Map<String, dynamic>>> restaurants =
          restaurantDocs.docs;

      final List<Map<String, dynamic>> topRestaurants = [];

      final Map<String, double> restaurantSales = {};

      for (final restaurantDoc in restaurants) {
        final String restaurantId = restaurantDoc.id;

        final double totalSales = await calculateTotalOrderAmount(restaurantId);

        restaurantSales[restaurantId] = totalSales;
      }

      restaurants.sort(
          (a, b) => restaurantSales[b.id]!.compareTo(restaurantSales[a.id]!));

      for (final restaurantDoc in restaurants.take(limit)) {
        final data = restaurantDoc.data();
        final restaurantInfo = {
          'username': data['username'],
          'logo': data['logo'],
        };
        topRestaurants.add(restaurantInfo);
      }

      return topRestaurants;
    } catch (e) {
      if (kDebugMode) print('Error finding top sales restaurants: $e');
      return [];
    }
  }

  // NO. OF CLIENTS
  Future<int> fetchUserCount() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> clientsDocs =
          await _firestore.collection('clients').get();
      return clientsDocs.size;
    } catch (e) {
      return 0;
    }
  }

  // NO. OF CLIENTS
  Future<int> fetchClientCount(String restaurantId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('clients').get();

      final List<DocumentSnapshot<Map<String, dynamic>>> documentsWithoutField =
          querySnapshot.docs.where((docSnapshot) {
        final Map<String, dynamic> docData = docSnapshot.data();
        return docData.containsKey('orderedFrom') &&
            docData['orderedFrom'].contains(restaurantId);
      }).toList();

      // if (kDebugMode) print("______________________________________________");
      // if (kDebugMode) print(documentsWithoutField.length);

      return documentsWithoutField.length;
    } catch (e) {
      if (kDebugMode) print('Error: $e');
      return 0;
    }
  }

  // CONNECTED WITH IN 1 KM

  Future<int> fetchUsersWithin1KM(RestaurantAdmin admin) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance.collection('clients').get();

      GeoPoint? resAddress = admin.location;
      List<DocumentSnapshot> documents = querySnapshot.docs;

      List<DocumentSnapshot> clientsWithin1KM = [];

      for (var document in documents) {
        Map<String, dynamic>? documentData =
            document.data() as Map<String, dynamic>?;
        GeoPoint? clientAddress = documentData?['location'];

        if (clientAddress != null && resAddress != null) {
          double distance = Geolocator.distanceBetween(
            resAddress.latitude,
            resAddress.longitude,
            clientAddress.latitude,
            clientAddress.longitude,
          );

          if (distance <= 1000) {
            clientsWithin1KM.add(document);
          }
        }
      }

      // Return the length of the list of clients within 1 km.
      return clientsWithin1KM.length;
    } catch (e) {
      if (kDebugMode) print('Error: $e');
      return 0;
    }
  }

  // NO. OF NON CLIENTS
  // Future<int> fetchNonClientCount() async {
  //   try {
  //     final QuerySnapshot<Map<String, dynamic>> querySnapshot =
  //         await FirebaseFirestore.instance.collection('clients').get();

  //     final List<DocumentSnapshot<Map<String, dynamic>>> documentsWithoutField =
  //         querySnapshot.docs.where((docSnapshot) {
  //       final Map<String, dynamic> docData = docSnapshot.data();
  //       return !docData.containsKey('orderedFrom');
  //     }).toList();

  //     if (kDebugMode) print("______________________________________________");
  //     if (kDebugMode) print(documentsWithoutField.length);

  //     return documentsWithoutField.length;
  //   } catch (e) {
  //     if (kDebugMode) print('Error: $e');
  //     return 0;
  //   }
  // }

  // ADD NEW ADDON
  Future<void> addADDON(String userId, AddonItem newAddon) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantDoc =
        snap.docs[0];
        final CollectionReference<Map<String, dynamic>> menuRef =
        restaurantDoc.reference.collection('Addons');

        // Add the new item to the 'items' subcollection
        final DocumentReference<Map<String, dynamic>> newItemRef =
        await menuRef.add(newAddon.toMap());

        // Update the 'itemId' field with the document ID
        await newItemRef.update({'addonId': newItemRef.id});
      } else {
        throw Exception('Restaurant not found.');
      }
    } catch (e) {
      throw Exception('Failed to add Addon : $e');
    }
  }

  // DELETE ADDON
  Future<void> deleteADDON(String userId, String itemId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantDoc =
        snap.docs[0];
        final CollectionReference<Map<String, dynamic>> menuRef =
        restaurantDoc.reference.collection('Addons');

        // Query and find the item with the given itemId
        final QuerySnapshot<Map<String, dynamic>> itemSnap =
        await menuRef.where('addonId', isEqualTo: itemId).get();

        if (itemSnap.docs.isNotEmpty) {
          final DocumentSnapshot<Map<String, dynamic>> itemDoc =
          itemSnap.docs[0];

          // Delete the item document
          await itemDoc.reference.delete();
        } else {
          throw Exception('Item not found in the menu.');
        }
      } else {
        throw Exception('Restaurant not found.');
      }
    } catch (e) {
      throw Exception('Failed to delete item from the menu: $e');
    }
  }

  // UPDATE ADDON
  Future<void> updateADDON(String userId,String addonID, AddonItemWithId addon,) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantDoc =
        snap.docs[0];
        final CollectionReference<Map<String, dynamic>> menuRef =
        restaurantDoc.reference.collection('Addons');

        final DocumentReference<Map<String, dynamic>> itemRef =
        menuRef.doc(addonID);

        await itemRef.update(addon.toMap());
      } else {
        throw Exception('Restaurant not found.');
      }
    } catch (e) {
      throw Exception('Failed to update item in the menu: $e');
    }
  }

  // ADD NEW ITEM TO MENU
  Future<void> addItemToMenu(String userId, ProductItem newItem) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantDoc =
            snap.docs[0];
        final CollectionReference<Map<String, dynamic>> menuRef =
            restaurantDoc.reference.collection('items');

        // Add the new item to the 'items' subcollection
        final DocumentReference<Map<String, dynamic>> newItemRef =
            await menuRef.add(newItem.toMap());

        // Update the 'itemId' field with the document ID
        await newItemRef.update({'itemId': newItemRef.id});
      } else {
        throw Exception('Restaurant not found.');
      }
    } catch (e) {
      throw Exception('Failed to add item to the menu: $e');
    }
  }

  // DELETE ITEM FROM MENU
  Future<void> deleteItemFromMenu(String userId, String itemId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantDoc =
            snap.docs[0];
        final CollectionReference<Map<String, dynamic>> menuRef =
            restaurantDoc.reference.collection('items');

        // Query and find the item with the given itemId
        final QuerySnapshot<Map<String, dynamic>> itemSnap =
            await menuRef.where('itemId', isEqualTo: itemId).get();

        if (itemSnap.docs.isNotEmpty) {
          final DocumentSnapshot<Map<String, dynamic>> itemDoc =
              itemSnap.docs[0];

          // Delete the item document
          await itemDoc.reference.delete();
        } else {
          throw Exception('Item not found in the menu.');
        }
      } else {
        throw Exception('Restaurant not found.');
      }
    } catch (e) {
      throw Exception('Failed to delete item from the menu: $e');
    }
  }

  // UPDATE MENU ITEM
  Future<void> updateMenuItem(String userId, ProductItem updatedItem) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
          .collection('restaurantAdmins')
          .where('userId', isEqualTo: userId)
          .get();

      if (snap.docs.isNotEmpty) {
        final DocumentSnapshot<Map<String, dynamic>> restaurantDoc =
            snap.docs[0];
        final CollectionReference<Map<String, dynamic>> menuRef =
            restaurantDoc.reference.collection('items');

        final DocumentReference<Map<String, dynamic>> itemRef =
            menuRef.doc(updatedItem.itemId);

        await itemRef.update(updatedItem.toMap());
      } else {
        throw Exception('Restaurant not found.');
      }
    } catch (e) {
      throw Exception('Failed to update item in the menu: $e');
    }
  }

  // UPLOAD IMG TO FIREBASE
  Future uploadImageToFirebase({File? imgPath}) async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(imgPath!);
    return uploadTask.then((TaskSnapshot storageTaskSnapshot) {
      return storageTaskSnapshot.ref.getDownloadURL();
    }, onError: (e) {
      throw Exception(e.toString());
    });
  }

  // UPDATE USER LOCATION
  Future<void> updateResLocation(
      String resId, double latitude, double longitude) async {
    try {
      final resDocRef = _firestore.collection('restaurantAdmins').doc(resId);
      final newLocation = GeoPoint(latitude, longitude);
      await resDocRef.update({'location': newLocation});
      // if (kDebugMode) print('Location updated successfully.');
    } catch (e) {
      if (kDebugMode) print('Error updating location: $e');
    }
  }

  Future<List<String>> getTopTwoSchoolNames() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final CollectionReference clientsCollection =
        firestore.collection('clients');

    final QuerySnapshot clientsSnapshot = await clientsCollection.get();
    final Map<String, int> schoolNameCount = {};

    for (var doc in clientsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final schoolName = data['schoolName'] as String;

      schoolNameCount[schoolName] = (schoolNameCount[schoolName] ?? 0) + 1;
    }

    final List<String> sortedSchoolNames = schoolNameCount.keys.toList()
      ..sort((a, b) => schoolNameCount[b]!.compareTo(schoolNameCount[a]!));

    return sortedSchoolNames.take(2).toList();
  }

  Future<List<Map<String, dynamic>>> getTopUsersBySales(
      String restaurantId) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> ordersSnapshot =
          await _firestore
              .collection('orders')
              .where('restaurantId', isEqualTo: restaurantId)
              .get();

      final Map<String, double> userSalesMap = {};

      for (var doc in ordersSnapshot.docs) {
        final String userId = doc['clientId'];
        final double totalPrice = doc['totalPrice'];

        if (userSalesMap.containsKey(userId)) {
          double currSales = userSalesMap[userId]!;
          userSalesMap[userId] = currSales + totalPrice;
        } else {
          userSalesMap[userId] = totalPrice;
        }
      }

      final sortedUsers = userSalesMap.keys.toList()
        ..sort((a, b) => userSalesMap[b]!.compareTo(userSalesMap[a]!));

      final topUsers = sortedUsers.take(5).toList();

      final usersData = await fetchUsersData(topUsers);

      return usersData;
    } catch (e) {
      throw Exception('Failed to fetch top users by sales with photos: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsersData(
      List<String> userIds) async {
    try {
      final List<Map<String, dynamic>> usersData = [];

      for (var userId in userIds) {
        final DocumentSnapshot<Map<String, dynamic>> userSnapshot =
            await _firestore.collection('clients').doc(userId).get();

        if (userSnapshot.exists) {
          final Map<String, dynamic> userData = userSnapshot.data()!;
          final String userName = userData['userName'];
          final String userPhoto = userData['photo'] ?? "";

          usersData.add({
            'userName': userName,
            'photo': userPhoto,
          });
        }
      }

      return usersData;
    } catch (e) {
      throw Exception('Failed to fetch user data with photos: $e');
    }
  }
}
