import 'dart:math';

import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/app_constants.dart';
import '../util/local_storage/shared_preferences_helper.dart';
import 'customer_auth_repo.dart';

class MyCustomerCalls {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<DocumentSnapshot>> getRestaurantAdmins() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection("restaurantAdmins").get();
      final List<DocumentSnapshot> docs = snapshot.docs;
      return docs;
    } catch (e) {
      if (kDebugMode) print(e);
      return [];
    }
  }

  Future<DocumentSnapshot> getRestaurantAdminById(String resId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection("restaurantAdmins")
          .where(FieldPath.documentId, isEqualTo: resId)
          .get();
      final List<DocumentSnapshot> docs = snapshot.docs;
      return docs.first;
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }

  Future<String> getCurrentUser() async {
    // final currentUser = await CustomerAuthRep().getCurrentUser();
    final user = await CustomerAuthRep().getCurrentUserFromFirebase();
    final schoolName = user['schoolName']!;
    return schoolName ?? 'ABC Schools';
  }

  Future<List<Map<String, dynamic>>> getFriends(String email) async {
    try {
      String school = await getCurrentUser();
      final QuerySnapshot<Map<String, dynamic>> allUsers = await _firestore
          .collection('clients')
          .where(FieldPath.documentId, isNotEqualTo: email)
          .where("schoolName", isEqualTo: school)
          .get();

      final List<Map<String, dynamic>> friendsList =
          allUsers.docs.map((friendDoc) {
        final Map<String, dynamic> userData = friendDoc.data();
        userData['email'] = friendDoc.id;
        return userData;
      }).toList();

      const int maxFriends = 10;
      final List<Map<String, dynamic>> limitedFriends =
          friendsList.take(maxFriends).toList();

      return limitedFriends;
    } catch (e) {
      throw Exception('Failed to fetch friends: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getEmails() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> allUsers =
          await _firestore.collection('clients').get();
      final QuerySnapshot<Map<String, dynamic>> allRestaurantUsers =
          await _firestore.collection('restaurantAdmins').get();

      final List<Map<String, dynamic>> friendsList =
          allUsers.docs.map((friendDoc) {
        final Map<String, dynamic> userData = {};
        userData['id'] = friendDoc.id;
        userData['email'] = friendDoc.id;
        userData['userType'] = 'clients';
        return userData;
      }).toList();

      final List<Map<String, dynamic>> restaurantList =
          allRestaurantUsers.docs.map((friendDoc) {
        final Map<String, dynamic> userData = {};
        userData['id'] = friendDoc.id;
        userData['email'] = friendDoc['email'];
        userData['userType'] = 'restaurantAdmins';
        return userData;
      }).toList();

      friendsList.addAll(restaurantList);

      return friendsList;
    } catch (e) {
      throw Exception('Failed to fetch friends: $e');
    }
  }

  String encryptPassword(String password) {
    const customSalt = '\$2a\$10\$CwTycUXWue0Thq9StjUM0u';
    final hash = BCrypt.hashpw(password, customSalt);
    return hash;
  }

  Future<void> changePassword(
      {required String userType,
      required String userId,
      required String password}) async {
    final encryptedPassword = encryptPassword(password);
    print(encryptedPassword);
    await _firestore
        .collection(userType)
        .doc(userId)
        .update({'password': encryptedPassword});
  }

  Future<List<QueryDocumentSnapshot>> getOrders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('currentCustomerEmail');

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection("orders")
          .where("clientId", isEqualTo: email)
          .get();

      final List<QueryDocumentSnapshot> docs = snapshot.docs;

      docs.sort((a, b) {
        Timestamp timestampA = a['timestamp'] as Timestamp;
        Timestamp timestampB = b['timestamp'] as Timestamp;
        return timestampB.seconds.compareTo(timestampA.seconds);
      });

      return docs;
    } catch (e) {
      if (kDebugMode) print(e);
      return [];
    }
  }

  Future<bool> reviewExists(String restaurantId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('currentCustomerEmail');
    if (email != null) {
      bool exists = false;

      CollectionReference userReviewsRef =
          FirebaseFirestore.instance.collection('userReviews');

      // Check if a document with the same userID and restaurantId exists
      await userReviewsRef
          .where('userID', isEqualTo: email)
          .where('restaurantId', isEqualTo: restaurantId)
          .get()
          .then((QuerySnapshot querySnapshot) {
        if (querySnapshot.docs.isEmpty) {
          // If no matching document exists, add the review to Firestore
          exists = false;
          return false;
        } else {
          exists = true;
          return true;
        }
      });
      return exists;
    }
    return false;
  }

  Future<void> postReview(String restaurantId, String restaurantName,
      int starCounts, String reviewMessage) async {
    // Create a reference to the userReviews collection
    CollectionReference userReviewsRef =
        FirebaseFirestore.instance.collection('userReviews');

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('currentCustomerEmail');
    final String? userName = prefs.getString('currentCustomerUserName');

    // Check if a document with the same userID and restaurantId exists
    userReviewsRef
        .where('userID', isEqualTo: email)
        .where('restaurantId', isEqualTo: restaurantId)
        .get()
        .then((QuerySnapshot querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        // If no matching document exists, add the review to Firestore
        userReviewsRef.add({
          'userID': email,
          "userName": userName,
          'photo': '',
          'restaurantId': restaurantId,
          'restaurantName': restaurantName,
          'starCounts': starCounts,
          'reviewMessage': reviewMessage,
        }).then((value) {
          if (kDebugMode) print('iddss Review added successfully!');
        }).catchError((error) {
          if (kDebugMode) print(' iddss Failed to add review: $error');
        });
      } else {
        if (kDebugMode) {
          print(' iddss Review already exists for this user and restaurant!');
        }
      }
    }).catchError((error) {
      if (kDebugMode) print(' iddss Failed to check existing reviews: $error');
    });
  }

// get current restaurant's menu
  Future<List<DocumentSnapshot>> getItems(String restaurantAdminId) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('restaurantAdmins')
        .doc(restaurantAdminId)
        .collection('items')
        .get();
    final List<DocumentSnapshot> docs = snapshot.docs;
    return docs;
  }

  // get current restaurant's menu
  Future<List<DocumentSnapshot>> getItemsbyEmail(String email) async {
    List<DocumentSnapshot> items = [];
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restaurantAdmins')
        .where('email', isEqualTo: email)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot snapshot = querySnapshot.docs.first;
      final itemDocs = await snapshot.reference.collection("items").get();
      items = itemDocs.docs;
    }
    return items;
  }

  Future<List<DocumentSnapshot>> getRestaurants(
      String restaurantAdminId) async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('restaurantAdmins')
        .doc(restaurantAdminId)
        .collection('restaurants')
        .get();
    final List<DocumentSnapshot> docs = snapshot.docs;
    return docs;
  }

  Future<Map<String, dynamic>> getRestaurantById(
      String restaurantAdminId) async {
    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('restaurantAdmins')
        .doc(restaurantAdminId)
        .get();
    final restaurant = snapshot.data() as Map<String, dynamic>;
    return restaurant;
  }

  Future<Map<String, dynamic>?> getRestaurantByEmail(String email) async {
    final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('restaurantAdmins')
        .where('email', isEqualTo: email)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      final DocumentSnapshot snapshot = querySnapshot.docs.first;
      final restaurant = snapshot.data() as Map<String, dynamic>;
      return restaurant;
    } else {
      return null;
    }
  }

  // place order
  Future<void> placeOrder(Map<String, dynamic> data) async {
    CollectionReference ordersRef =
        FirebaseFirestore.instance.collection("orders");
    DocumentReference newOrderRef = ordersRef.doc();
    Map<String, dynamic> newOrderData =
        data.containsKey("instructions") && data['instructions'] != ""
            ? {
                "clientId": data['clientId'],
                "items": data['items'],
                "instructions": data['instructions'],
                "orderId": newOrderRef.id,
                "photo": data['photo'],
                "time": data['time'],
                "restaurantId": data['restaurantId'],
                "restaurantName": data['restaurantName'],
                "status": data['status'],
                "totalPrice": data['totalPrice'],
                "userName": data['userName'],
                "timestamp": FieldValue.serverTimestamp(),
              }
            : {
                "clientId": data['clientId'],
                "items": data['items'],
                "orderId": newOrderRef.id,
                "photo": data['photo'],
                "time": data['time'],
                "restaurantId": data['restaurantId'],
                "restaurantName": data['restaurantName'],
                "status": data['status'],
                "totalPrice": data['totalPrice'],
                "userName": data['userName'],
                "timestamp": FieldValue.serverTimestamp(),
              };

    await newOrderRef.set(newOrderData);
  }

  // place free order
  Future<bool> placeFreeOrder(Map<String, dynamic> data) async {
    CollectionReference ordersRef =
        FirebaseFirestore.instance.collection("orders");
    DocumentReference newOrderRef = ordersRef.doc();

    Map<String, dynamic> newOrderData = {
      "clientId": data['clientId'],
      "items": data['items'],
      "orderId": newOrderRef.id,
      "photo": data['photo'],
      "time": data['time'],
      "restaurantId": data['restaurantId'],
      "restaurantName": data['restaurantName'],
      "status": data['status'],
      "totalPrice": data['totalPrice'],
      "userName": data['userName'],
      "timestamp": FieldValue.serverTimestamp(),
      "freeOrder": true,
    };

    final DocumentReference userDocRef =
        _firestore.collection('clients').doc(data['clientId']);
    final DocumentSnapshot userDoc = await userDocRef.get();

    if (userDoc.exists) {
      if ((userDoc.data() as Map<String, dynamic>?)?['rewards'] >=
          data['totalPrice']) {
        final num currentRewards =
            (userDoc.data() as Map<String, dynamic>?)?['rewards'] ?? 0;

        final num updatedRewards = currentRewards - data['totalPrice'];

        Map<String, dynamic> postData = {
          'user': data['userName'],
          'photo': data['photo'] ?? "",
          'orderTime': FieldValue.serverTimestamp(),
          'restaurantName': data['restaurantName'],
          'itemName': data['items'][0]['name'],
          'type': "order",
        };

        await _firestore.collection('posts').add(postData);

        await userDocRef.update({'rewards': updatedRewards});
        await newOrderRef.set(newOrderData);
        return true;
      } else {
        return false;
      }
    } else {
      throw Exception('User not found');
    }
  }

  Future<void> refreshNearbyRestaurants() async {
    final email = SharedPreferencesHelper.getCustomerEmail();
    final DocumentSnapshot<Map<String, dynamic>> currentUser =
        await _firestore.collection('clients').doc(email).get();

    final GeoPoint currentGeoPoint = GeoPoint(
      currentUser.data()!["location"].latitude,
      currentUser.data()!["location"].longitude,
    );

    final QuerySnapshot<Map<String, dynamic>> nearbyRestaurants =
        await currentUser.reference.collection("restaurants").get();

    Set<String> uniqueEmails = <String>{};

    for (final DocumentSnapshot<Map<String, dynamic>> restaurant
        in nearbyRestaurants.docs) {
      final String resEmail = restaurant['email'];

      if (!uniqueEmails.contains(resEmail)) {
        uniqueEmails.add(resEmail);

        final QuerySnapshot<Map<String, dynamic>> matchingAdmins =
            await _firestore
                .collection('restaurantAdmins')
                .where('email', isEqualTo: resEmail)
                .get();

        if (matchingAdmins.docs.isNotEmpty) {
          final DocumentSnapshot<Map<String, dynamic>> adminDocument =
              matchingAdmins.docs.first;

          final double adminLatitude = adminDocument['location'].latitude;
          final double adminLongitude = adminDocument['location'].longitude;

          final double distance = Geolocator.distanceBetween(
            currentGeoPoint.latitude,
            currentGeoPoint.longitude,
            adminLatitude,
            adminLongitude,
          );

          await restaurant.reference.update({
            'distance': distance,
            'address': adminDocument['address'],
            'category': adminDocument['category'],
            'description': adminDocument['description'],
            'name': adminDocument['username'],
            'logo': adminDocument['logo']
          });
        } else {
          await restaurant.reference.delete();
        }
      } else {
        await restaurant.reference.delete();
      }
    }
  }

  Future<void> refreshNearbyRestaurantsForGuest(GeoPoint location) async {
    print('latitude in function refresh');
    print(location.latitude);
    final GeoPoint currentGeoPoint = location;
    const double maxDistance =
        5000; // Maximum distance in meters for nearby restaurants

    final QuerySnapshot<Map<String, dynamic>> nearbyRestaurants =
        await FirebaseFirestore.instance.collection("restaurantAdmins").get();

    for (final DocumentSnapshot<Map<String, dynamic>> restaurant
        in nearbyRestaurants.docs) {
      final GeoPoint restaurantLocation = restaurant['location'];

      final double distance = Geolocator.distanceBetween(
        currentGeoPoint.latitude,
        currentGeoPoint.longitude,
        restaurantLocation.latitude,
        restaurantLocation.longitude,
      );

      if (distance <= maxDistance) {
        // Restaurant is within the maximum distance, update its details
        await restaurant.reference.update({
          'distance': distance,
          'address': restaurant['address'],
          'category': restaurant['category'],
          'description': restaurant['description'],
          'name': restaurant['username'],
          'logo': restaurant['logo']
        });
      } else {
        // Restaurant is beyond the maximum distance, delete it
        // await restaurant.reference.delete();
        print('else run');
      }
    }
  }

  Future<void> fetchAndSaveNearbyRestaurants() async {
    try {
      // all restaurants
      final QuerySnapshot<Map<String, dynamic>> restaurantAdminsSnap =
          await _firestore.collection('restaurantAdmins').get();

      // current user email
      final email = SharedPreferencesHelper.getCustomerEmail();

      // current user
      final DocumentSnapshot<Map<String, dynamic>> currentResUser =
          await _firestore.collection('clients').doc(email).get();

      // current user's location
      final GeoPoint currentGeoPoint = GeoPoint(
        currentResUser.data()!["location"].latitude,
        currentResUser.data()!["location"].longitude,
      );

      final List<Map<String, dynamic>> matchedRestaurants1000 =
          await searchRestaurantsWithinRadius(
              email!, restaurantAdminsSnap.docs, currentGeoPoint, 1000);

      if (matchedRestaurants1000.length < 10) {
        final List<Map<String, dynamic>> matchedRestaurants10000 =
            await searchRestaurantsWithinRadius(
                email, restaurantAdminsSnap.docs, currentGeoPoint, 10000);

        if (matchedRestaurants10000.length < 10) {
          final List<Map<String, dynamic>> matchedRestaurants50000 =
              await searchRestaurantsWithinRadius(
                  email, restaurantAdminsSnap.docs, currentGeoPoint, 50000);

          final List<Map<String, dynamic>> allMatches = [
            ...matchedRestaurants1000,
            ...matchedRestaurants10000,
            ...matchedRestaurants50000,
          ];

          final Set<String> addedEmails = {};
          final List<Map<String, dynamic>> deduplicatedMatches =
              deduplicateMatches(allMatches, addedEmails);

          addMatchesToSubcollection(deduplicatedMatches,
              currentResUser.reference.collection('restaurants'));
        } else {
          addMatchesToSubcollection(matchedRestaurants10000,
              currentResUser.reference.collection('restaurants'));
        }
      } else {
        addMatchesToSubcollection(matchedRestaurants1000,
            currentResUser.reference.collection('restaurants'));
      }
    } catch (e) {
      throw Exception('Failed to fetch and save nearby restaurants: $e');
    }
  }

  Future<void> fetchAndSaveNearbyRestaurantsForGuest(GeoPoint location) async {
    print('latitude in function fetch');
    print(location.latitude);
    try {
      // all restaurants
      final QuerySnapshot<Map<String, dynamic>> restaurantAdminsSnap =
          await _firestore.collection('restaurantAdmins').get();

      // // current user email
      // final email = SharedPreferencesHelper.getCustomerEmail();
      //
      // // current user
      // final DocumentSnapshot<Map<String, dynamic>> currentResUser =
      //     await _firestore.collection('clients').doc(email).get();

      // current user's location
      final GeoPoint currentGeoPoint = GeoPoint(
        location.latitude,
        location.longitude,
      );

      final List<Map<String, dynamic>> matchedRestaurants1000 =
          await searchRestaurantsForGuest(currentGeoPoint, 1000);

      if (matchedRestaurants1000.length < 10) {
        final List<Map<String, dynamic>> matchedRestaurants10000 =
            await searchRestaurantsForGuest(currentGeoPoint, 10000);

        if (matchedRestaurants10000.length < 10) {
          final List<Map<String, dynamic>> matchedRestaurants50000 =
              await searchRestaurantsForGuest(currentGeoPoint, 50000);

          final List<Map<String, dynamic>> allMatches = [
            ...matchedRestaurants1000,
            ...matchedRestaurants10000,
            ...matchedRestaurants50000,
          ];

          final Set<String> addedEmails = {};
          final List<Map<String, dynamic>> deduplicatedMatches =
              deduplicateMatches(allMatches, addedEmails);

          // addMatchesToSubcollection(deduplicatedMatches,
          //     currentResUser.reference.collection('restaurants'));
        } else {
          // addMatchesToSubcollection(matchedRestaurants10000,
          //     currentResUser.reference.collection('restaurants'));
        }
      } else {
        // addMatchesToSubcollection(matchedRestaurants1000,
        //     currentResUser.reference.collection('restaurants'));
      }
    } catch (e) {
      throw Exception(
          'Failed to fetch and save nearby restaurants for guests: $e');
    }
  }

  // remove duplicates if any
  List<Map<String, dynamic>> deduplicateMatches(
      List<Map<String, dynamic>> matches, Set<String> addedEmails) {
    final List<Map<String, dynamic>> deduplicatedMatches = [];

    for (final Map<String, dynamic> restaurantAdminData in matches) {
      final String email = restaurantAdminData["email"];
      if (!addedEmails.contains(email)) {
        deduplicatedMatches.add(restaurantAdminData);
        addedEmails.add(email);
      }
    }

    return deduplicatedMatches;
  }

  // search restaurants with in specified radius
  Future<List<Map<String, dynamic>>> searchRestaurantsWithinRadius(
      String email,
      List<DocumentSnapshot<Map<String, dynamic>>> restaurantAdmins,
      GeoPoint currentGeoPoint,
      double radius) async {
    final DocumentSnapshot<Map<String, dynamic>> currentResUser =
        await _firestore.collection('clients').doc(email).get();

    final QuerySnapshot<Map<String, dynamic>> nearbyRestaurants =
        await currentResUser.reference.collection("restaurants").get();

    if (kDebugMode) print(nearbyRestaurants.docs.length);

    final List<Map<String, dynamic>> matches = [];

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

        // if (matching.isEmpty && email != restaurantAdminData["email"]) {
        if (matching.isEmpty) {
          final updatedData =
              Map<String, dynamic>.from(restaurantAdminData.data() ?? {});
          updatedData["distance"] = distance;
          matches.add(updatedData);
        }
      }
    }
    return matches;
  }

  Future<List<Map<String, dynamic>>> searchRestaurantsForGuest(
      GeoPoint currentGeoPoint, double radius) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    final QuerySnapshot<Map<String, dynamic>> restaurantAdminsSnapshot =
        await _firestore.collection("restaurantAdmins").get();

    final List<Map<String, dynamic>> nearbyRestaurants = [];

    for (final DocumentSnapshot<Map<String, dynamic>> restaurantAdminData
        in restaurantAdminsSnapshot.docs) {
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
        nearbyRestaurants.add({
          ...?restaurantAdminData.data(),
          "distance": distance,
        });
      }
    }
    nearbyRestaurants.sort((a, b) => a['distance'].compareTo(b['distance']));
    return nearbyRestaurants.take(10).toList();
  }

  // add matched restaurants to subcollection
  void addMatchesToSubcollection(List<Map<String, dynamic>> matches,
      CollectionReference<Map<String, dynamic>> subcollectionRef) {
    for (final Map<String, dynamic> restaurantAdminData in matches) {
      // print("*********************");
      // print(restaurantAdminData);
      subcollectionRef.add({
        'id': restaurantAdminData['userId'],
        'name': restaurantAdminData['username'],
        'category': restaurantAdminData['category'],
        'location': restaurantAdminData['location'],
        "distance": restaurantAdminData["distance"],
        "address": restaurantAdminData["address"],
        "logo": restaurantAdminData["logo"],
        "email": restaurantAdminData["email"],
        "description": restaurantAdminData["description"],
      });
      if (kDebugMode) print("doneeeeeeeeeeee");
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

  // get restaurants based on discount (live feed)
  Future<List<Map<String, dynamic>>> getRestaurantsWithDiscounts() async {
    final restaurantAdminsCollection =
        _firestore.collection('restaurantAdmins');
    final clientsCollection = _firestore.collection('clients');

    final List<Map<String, dynamic>> restaurants = [];

    try {
      final email = SharedPreferencesHelper.getCustomerEmail();

      final currentRestaurantQuery = await clientsCollection.doc(email).get();

      if (currentRestaurantQuery.exists) {
        // Get the current restaurant data
        // final currentRestaurantData = currentRestaurantQuery.data();

        final restaurantAdminsQuery = await restaurantAdminsCollection.get();

        // Fetch nearby restaurants in the current restaurant
        final nearbyRestaurants = await currentRestaurantQuery.reference
            .collection("restaurants")
            .get();

        for (final restaurantDocument in nearbyRestaurants.docs) {
          final restaurantData = restaurantDocument.data();

          // Find a matching main restaurant by email
          final matchingMainRestaurant =
              restaurantAdminsQuery.docs.firstWhereOrNull(
            (mainDoc) => mainDoc.data()['email'] == restaurantData['email'],
          );

          final restaurantId = matchingMainRestaurant?.id;
          final restaurantName = matchingMainRestaurant?.data()['username'];
          final restaurantLogo = matchingMainRestaurant?.data()['logo'];
          final restaurantAddress = matchingMainRestaurant?.data()['address'];
          final openingHours = matchingMainRestaurant?.data()['openingHrs'];

          final restaurantMenu =
              await matchingMainRestaurant?.reference.collection("items").get();

          if (restaurantMenu != null) {
            for (final itemDocument in restaurantMenu.docs) {
              final itemData = itemDocument.data();

              if (itemData['discount'] != '0%' &&
                  itemData.containsKey("lastUpdated")) {
                restaurants.add({
                  'restaurantId': restaurantId,
                  'restaurantName': restaurantName,
                  'restaurantLogo': restaurantLogo,
                  'restaurantAddress': restaurantAddress,
                  'itemName': itemData['name'],
                  'discount': itemData['discount'],
                  'lastUpdated': itemData['lastUpdated'],
                  "availability": itemData["availability"],
                  "openingHrs": openingHours,
                });
              }
            }
          }
        }

        // Sort the restaurants by "lastUpdated" in descending order
        restaurants
            .sort((a, b) => b['lastUpdated'].compareTo(a['lastUpdated']));

        return restaurants.take(10).toList();
      } else {
        // Handle the case when the current restaurant is not found
        return [];
      }
    } catch (error) {
      rethrow;
    }
  }

  // get restaurant based on discount for guest (live feed)
  Future<List<Map<String, dynamic>>>
      getRestaurantsWithDiscountsForGuest() async {
    final restaurantAdminsCollection =
        _firestore.collection('restaurantAdmins');

    final List<Map<String, dynamic>> restaurants = [];

    try {
      final restaurantAdminsQuery = await restaurantAdminsCollection.get();

      for (final mainDoc in restaurantAdminsQuery.docs) {
        final restaurantId = mainDoc.id;
        final restaurantName = mainDoc.data()['username'];
        final restaurantLogo = mainDoc.data()['logo'];
        final restaurantAddress = mainDoc.data()['address'];
        final workingHrs = mainDoc.data()['workingHrs'];

        final restaurantMenu =
            await mainDoc.reference.collection("items").get();

        for (final itemDocument in restaurantMenu.docs) {
          final itemData = itemDocument.data();

          if (itemData['discount'] != '0%' &&
              itemData.containsKey("lastUpdated")) {
            restaurants.add({
              'restaurantId': restaurantId,
              'restaurantName': restaurantName,
              'restaurantLogo': restaurantLogo,
              'restaurantAddress': restaurantAddress,
              'itemName': itemData['name'],
              'itemId': itemData['itemId'],
              'discount': itemData['discount'],
              'lastUpdated': itemData['lastUpdated'],
              "availability": itemData["availability"],
              "workingHrs": workingHrs,
            });
          }
        }
      }

      // Sort the restaurants by "lastUpdated" in descending order
      restaurants.sort((a, b) => b['lastUpdated'].compareTo(a['lastUpdated']));

      return restaurants.take(10).toList();
    } catch (error) {
      rethrow;
    }
  }

  // get restaurants based on distance
  Future<List<Map<String, dynamic>>> getRestaurantsByDistance() async {
    final clientsCollection = _firestore.collection('clients');

    final List<Map<String, dynamic>> restaurants = [];

    try {
      final email = SharedPreferencesHelper.getCustomerEmail();

      final currentUserDocument = await clientsCollection.doc(email).get();

      if (currentUserDocument.exists) {
        final nearbyRestaurants =
            await currentUserDocument.reference.collection("restaurants").get();

        for (final restaurantDocument in nearbyRestaurants.docs) {
          final restaurantData = restaurantDocument.data();

          if (restaurantData.containsKey('distance') &&
              (restaurantData['distance'] < 50000)) {
            restaurants.add({
              'id': restaurantData['id'],
              'name': restaurantData['name'],
              'category': restaurantData['category'],
              'distance': restaurantData['distance'],
              'address': restaurantData['address'],
              'email': restaurantData['email'],
              'logo': restaurantData['logo'],
              'description': restaurantData['description'],
              "availability": restaurantData["availability"],
            });
          }
        }

        restaurants.sort((a, b) => a['distance'].compareTo(b['distance']));

        return restaurants.take(10).toList();
      } else {
        // Handle the case when the current user is not found
        return [];
      }
    } catch (error, stk) {
      if (kDebugMode) print(stk);
      if (kDebugMode) print('Error fetching restaurants by distance: $error');
      rethrow;
    }
  }

  //get restaurants based on distance for guests
  Future<List<Map<String, dynamic>>> getRestaurantsByDistanceForGuest() async {
    final restaurantsCollection = _firestore.collection('restaurantAdmins');

    final List<Map<String, dynamic>> restaurants = [];

    try {
      final nearbyRestaurants = await restaurantsCollection.get();

      for (final restaurantDocument in nearbyRestaurants.docs) {
        final restaurantData = restaurantDocument.data();

        if (restaurantData.containsKey('distance') &&
            (restaurantData['distance'] < 50000)) {
          restaurants.add({
            'userId': restaurantData['userId'],
            'name': restaurantData['username'] ?? 'abc',
            'description': restaurantData['description'],
            'category': restaurantData['category'],
            'distance': restaurantData['distance'],
            'address': restaurantData['address'],
            'email': restaurantData['email'],
            'logo': restaurantData['logo'],
          });
        }
      }
      restaurants.sort((a, b) => a['distance'].compareTo(b['distance']));
      return restaurants.take(10).toList();
    } catch (error, stk) {
      if (kDebugMode) print(stk);
      if (kDebugMode) print(error.toString());
      if (kDebugMode) {
        print('Error fetching restaurants by distance for guest: $error');
      }
      rethrow;
    }
  }

  // get items based on discount
  Future<List<Map<String, dynamic>>> getItemsByDiscount() async {
    try {
      final email = SharedPreferencesHelper.getCustomerEmail();

      final currentUserDocument =
          await _firestore.collection('clients').doc(email).get();

      if (!currentUserDocument.exists) {
        // Handle the case when the current user is not found
        return [];
      }

      // Fetch the emails from the sub-collection "restaurants"
      final restaurantsQuery =
          await currentUserDocument.reference.collection("restaurants").get();

      final List<dynamic> restaurantEmails =
          restaurantsQuery.docs.map((doc) => doc.data()['email']).toList();

      if (restaurantEmails.isEmpty) return [];

      // Fetch items from the "restaurantAdmins" collection where email matches
      final restaurantAdminsQuery = await _firestore
          .collection('restaurantAdmins')
          .where('email', whereIn: restaurantEmails)
          .get();

      final ordersQuery = await _firestore
          .collection('orders')
          .where('clientId', isNotEqualTo: email)
          .get();

      final List<Map<String, dynamic>> items = [];

      for (final restaurantAdminDocument in restaurantAdminsQuery.docs) {
        final restaurantId = restaurantAdminDocument.id;
        final restaurantName = restaurantAdminDocument.data()['username'];
        final restaurantLogo = restaurantAdminDocument.data()['logo'];

        final mainResEmail = restaurantAdminDocument.data()['email'];

        final distance = restaurantsQuery.docs
            .firstWhere((element) => element.data()['email'] == mainResEmail)
            .data()['distance'];

        // Fetch items from the sub-collection "items" of the matched restaurant
        final restaurantItemsQuery =
            await restaurantAdminDocument.reference.collection("items").get();

        for (final itemDocument in restaurantItemsQuery.docs) {
          final itemData = itemDocument.data();

          if (itemData['lastUpdated'] != null) {
            Timestamp timestamp = itemData['lastUpdated'];
            DateTime dateTime = timestamp.toDate();

            String iso8601String = dateTime.toIso8601String();

            itemData['lastUpdated'] = iso8601String;
          } else {
            DateTime currentTime = DateTime.now();
            String iso8601String = currentTime.toIso8601String();
            itemData['lastUpdated'] = iso8601String;
          }

          if (itemData['discount'] != null &&
              itemData['discount'].endsWith('%') &&
              itemData['discount'] != '0%') {
            items.add({
              'restaurantId': restaurantId,
              'restaurantName': restaurantName,
              'restaurantLogo': restaurantLogo,
              'itemName': itemData['name'],
              'itemPhoto': itemData['photo'],
              'discount': itemData['discount'],
              'addOns': itemData['addOns'] ?? [],
              'distance': distance,
              'itemData': itemData,
              "availability": itemData["availability"],
              'userOrderCount': ordersQuery.docs
                  .where((element) => element
                      .data()['items']
                      .any((item) => item['name'] == itemData['name']))
                  .length,
            });
          }
        }
      }

      // Sort the items by "discount" in ascending order
      items.sort((a, b) => b['discount'].compareTo(a['discount']));

      return items;
    } catch (error) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getItemsByDiscountForGuest() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> restaurantAdminsQuery =
          await _firestore.collection('restaurantAdmins').get();

      final List<QuerySnapshot<Map<String, dynamic>>> itemsQueries = [];
      final List<String> restaurantIds = [];

      for (final restaurantDoc in restaurantAdminsQuery.docs) {
        final String restaurantId = restaurantDoc.id;
        restaurantIds.add(restaurantId);
        final QuerySnapshot<Map<String, dynamic>> itemsQuery = await _firestore
            .collection('restaurantAdmins')
            .doc(restaurantId)
            .collection('items')
            .where('discount', isNotEqualTo: '0%')
            .where('discount', isNotEqualTo: null)
            .get();
        itemsQueries.add(itemsQuery);
      }

      final List<Map<String, dynamic>> items = [];

      for (int i = 0; i < itemsQueries.length; i++) {
        for (final itemDocument in itemsQueries[i].docs) {
          final itemData = itemDocument.data();
          final String restaurantId = restaurantIds[i];
          final restaurantDoc = await _firestore
              .collection('restaurantAdmins')
              .doc(restaurantId)
              .get();
          final restaurantData = restaurantDoc.data();
          print('itemData111111111111111111111111111111111');
          print(itemData);
          items.add({
            'restaurantId': restaurantId,
            'restaurantName': restaurantData!['username'],
            'restaurantLogo': restaurantData['logo'],
            'itemName': itemData['name'],
            'itemPhoto': itemData['photo'],
            'discount': itemData['discount'],
            'addOns': itemData['addOns'] ?? [],
            'distance': restaurantData['distance'],
            'itemData': itemData,
            'availability': itemData['availability'],
            'userOrderCount':
                1, // Placeholder for user order count, you can implement this if needed
          });
        }
      }

      // Sort the items by "discount" in ascending order
      items.sort((a, b) => b['discount'].compareTo(a['discount']));

      return items;
    } catch (error) {
      print(error.toString());
      return [];
    }
  }

  Future<Map<String, dynamic>> claimRewards(String email) async {
    final Random random = Random();
    final String selectedReward = AppConstants.giftItems[
        GiftItems.values[random.nextInt(AppConstants.giftItems.length)]]!;

    final int tokens = random.nextInt(5) + 1;

    final DateTime currentTime = DateTime.now();

    final DocumentReference userDocRef =
        _firestore.collection('clients').doc(email);
    final DocumentSnapshot userDoc = await userDocRef.get();

    if (userDoc.exists) {
      final Map<String, dynamic> userData =
          userDoc.data() as Map<String, dynamic>;

      final Map<String, dynamic> currentRewards = userData['rewards'] ?? {};

      final Timestamp? lastUpdatedTimestamp = userData['rewardsLastUpdated'];
      if (lastUpdatedTimestamp != null) {
        final DateTime lastUpdatedTime = lastUpdatedTimestamp.toDate();
        final Duration timeDifference = currentTime.difference(lastUpdatedTime);

        if (timeDifference.inHours >= 24) {
          currentRewards[selectedReward] =
              (currentRewards[selectedReward] ?? 0) + tokens;

          await userDocRef.update({
            'rewards': currentRewards,
            "rewardsLastUpdated": Timestamp.fromDate(currentTime)
          });
          return {
            "tokens": tokens,
            "type": selectedReward,
            "status": true,
          };
        } else {
          // Handle case where 24 hours have not passed
          if (kDebugMode) {
            print("Cannot claim rewards yet. Please wait for 24 hours.");
          }
          return {
            "tokens": tokens,
            "type": selectedReward,
            "status": false,
          };
        }
      } else {
        currentRewards[selectedReward] =
            (currentRewards[selectedReward] ?? 0) + tokens;

        await userDocRef.update({
          'rewards': currentRewards,
          "rewardsLastUpdated": Timestamp.fromDate(currentTime)
        });
        return {
          "tokens": tokens,
          "type": selectedReward,
          "status": true,
        };
      }
    } else {
      return {
        "tokens": tokens,
        "type": selectedReward,
        "status": true,
      };
    }
  }

  // get user rewards
  Future<num> getRewards(String email) async {
    try {
      final DocumentReference userDocRef =
          _firestore.collection('clients').doc(email);
      final DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        final Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;

        final num currentRewards = userData['rewards'] is String
            ? int.parse(userData['rewards'])
            : userData['rewards'] ?? 0;

        return currentRewards;
      } else {
        // Handle the case where the user document does not exist
        return 0;
      }
    } catch (e) {
      throw Exception('Failed to fetch rewards: $e');
    }
  }

  // send rewards to friends
  Future<bool> sendRewards(
    String currentUserEmail,
    String recipientEmail,
    String rewardType,
    int rewardAmount,
  ) async {
    try {
      final DocumentReference currentUserRef =
          _firestore.collection('clients').doc(currentUserEmail);

      final DocumentReference recipientUserRef =
          _firestore.collection('clients').doc(recipientEmail);

      final DocumentSnapshot currentUserDoc = await currentUserRef.get();
      final DocumentSnapshot recipientUserDoc = await recipientUserRef.get();

      if (currentUserDoc.exists && recipientUserDoc.exists) {
        final Map<String, dynamic> currentUserData =
            currentUserDoc.data() as Map<String, dynamic>;

        final Map<String, dynamic> recipientUserData =
            recipientUserDoc.data() as Map<String, dynamic>;

        final num currentUserRewards = currentUserData['rewards'] ?? 0;

        final num recipientUserRewards = recipientUserData['rewards'] ?? 0;

        final DateTime currentTime = DateTime.now();

        final Map<String, dynamic> rewardShare = {
          'sender': currentUserData['userName'],
          'senderEmail': currentUserDoc.id,
          'photo': currentUserData['photo'],
          'sentOn': Timestamp.fromDate(currentTime),
          'sentTo': recipientUserData['userName'],
          'type': "reward",
        };

        await currentUserRef.update({
          'rewards': currentUserRewards - rewardAmount,
        });
        await recipientUserRef
            .update({'rewards': recipientUserRewards + rewardAmount});
        await _firestore.collection('posts').add(rewardShare);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      if (kDebugMode) print('Failed to send rewards: $e');
      return false;
    }
  }

  // get clients who have shared rewards
  Future<List<Map<String, dynamic>>> getPostsAndSort() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> postsSnapshot =
          await _firestore.collection('posts').get();

      final List<Map<String, dynamic>> postsList = [];

      for (var doc in postsSnapshot.docs) {
        final Map<String, dynamic> postData = doc.data();

        if (postData['type'] == 'reward') {
          final rewardData = {
            'sentOn': (postData['sentOn'] as Timestamp).toDate(),
            'sentTo': postData['sentTo'],
            'photo': postData['photo'],
            'sender': postData['sender'],
            'type': 'reward',
            "senderEmail": postData['senderEmail'],
          };
          postsList.add(rewardData);
        } else if (postData['type'] == 'order') {
          final orderData = {
            'orderTime': (postData['orderTime'] as Timestamp).toDate(),
            'restaurantName': postData['restaurantName'],
            'itemName': postData['itemName'],
            'user': postData['user'],
            'photo': postData['photo'],
            'type': 'order',
            "senderEmail": postData['senderEmail'],
          };
          postsList.add(orderData);
        }
      }

      postsList.sort((a, b) {
        final DateTime timeA = a['type'] == 'reward'
            ? (a['sentOn'] as DateTime)
            : (a['orderTime'] as DateTime);

        final DateTime timeB = b['type'] == 'reward'
            ? (b['sentOn'] as DateTime)
            : (b['orderTime'] as DateTime);

        return timeB.compareTo(timeA);
      });

      return postsList;
    } catch (e) {
      throw Exception('Failed to fetch and sort posts: $e');
    }
  }
}
