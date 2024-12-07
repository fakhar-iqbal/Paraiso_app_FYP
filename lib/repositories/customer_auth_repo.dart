import 'package:bcrypt/bcrypt.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerAuthRep {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'clients';
  final String _key = 'my_super_secret_key_123456789012';

  Future<String> signUp(
      {required String email,
      required String password,
      required String name,
      required String schoolName,
      required Position? position,
      String phoneNumber = '',
      required int rewards}) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> user =
          await _firestore.collection(_collection).doc(email).get();
      if (user.exists) {
        return 'Email already exists';
      } else {
        final encryptedPassword = encryptPassword(password);
        await _firestore.collection(_collection).doc(email).set({
          'userName': name,
          'password': encryptedPassword,
          'schoolName': schoolName,
          'location': GeoPoint(position!.latitude, position.longitude),
          'phoneNumber': phoneNumber,
          'photo': "",
          "rewards": rewards
        });
        await SharedPreferencesHelper.saveUserLocation(
            position.latitude, position.longitude);
        await SharedPreferencesHelper.saveCustomerEmail(email);
        await _saveUser(email, name, schoolName, rewards);
        return 'User added';
      }
    } catch (e) {
      return 'Error : $e';
    }
  }

  Future<void> addRestaurantOrder(String restaurantId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('currentCustomerEmail');
    if (email != null) {
      final DocumentSnapshot<Map<String, dynamic>> user =
          await _firestore.collection(_collection).doc(email).get();
      if (user.exists) {
        if (user.data()!["orderedFrom"] == null) {
          await _firestore.collection(_collection).doc(email).update({
            'orderedFrom': [restaurantId]
          });
          return;
        }
        List<dynamic> existingRestaurants = user.data()!["orderedFrom"];
        bool foundMatchingItem = false;
        for (var item in existingRestaurants) {
          if (item == restaurantId) {
            foundMatchingItem = true;
            break;
          }
        }
        if (!foundMatchingItem) {
          existingRestaurants.add(restaurantId);
        }
        await _firestore
            .collection(_collection)
            .doc(email)
            .update({'orderedFrom': existingRestaurants});
      }
      // await _saveUser(email,);
    }
  }

  Future<void> addRewards(
    String restaurantId,
    String restaurantName,
    String restaurantLogo,
    String itemName,
    int numCoconuts,
  ) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? email = prefs.getString('currentCustomerEmail');

      if (email != null) {
        final DocumentSnapshot<Map<String, dynamic>> user =
            await _firestore.collection(_collection).doc(email).get();

        if (user.data()!['rewards'] != null) {
          final num rewards = user.data()!['rewards'];

          await _firestore.collection(_collection).doc(email).update({
            'rewards': rewards + numCoconuts,
          });
        } else {
          await _firestore.collection(_collection).doc(email).update({
            'rewards': numCoconuts,
          });
        }

        if (user.data()!['restaurantRewards'] != null) {
          final restaurantRewards = user.data()!['restaurantRewards'];

          bool foundMatchingItem = false;
          for (var item in restaurantRewards) {
            if (item['restaurantId'] == restaurantId) {
              item['Coconut'] += numCoconuts;
              foundMatchingItem = true;
              break;
            }
          }
          if (!foundMatchingItem) {
            restaurantRewards.add({
              'restaurantId': restaurantId,
              'restaurantName': restaurantName,
              'restaurantLogo': restaurantLogo,
              'Coconut': numCoconuts,
            });
          }
          await _firestore.collection(_collection).doc(email).update({
            'restaurantRewards': restaurantRewards,
          });
        } else {
          await _firestore.collection(_collection).doc(email).update({
            'restaurantRewards': [
              {
                'restaurantId': restaurantId,
                'restaurantName': restaurantName,
                'restaurantLogo': restaurantLogo,
                'Coconut': numCoconuts,
              }
            ],
          });
        }
        Map<String, dynamic> postData = {
          'user': user.data()!['userName'],
          'photo': user.data()!['photo'] ?? "",
          'orderTime': FieldValue.serverTimestamp(),
          'restaurantName': restaurantName,
          'itemName': itemName,
          'type': "order",
        };

        await _firestore.collection('posts').add(postData);
      }
    } catch (e) {
      print("Error: $e");
    }
  }

  Future<String> signIn(String email, String password) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> user =
          await _firestore.collection(_collection).doc(email).get();
      if (!user.exists) {
        return 'Email does not exist';
      } else {
        final encryptedPassword = user.data()!['password'];
        print(encryptedPassword);

        // print("testsss1  : ${user.data()!['schoolName']}");
        // print("testsss2  :  ${user.data()!['userName']}");
        // print("testsss2  :  ${user.data()!['rewards']}");
        if (BCrypt.checkpw(password, encryptedPassword)) {
          await _saveUser(
              email,
              user.data()!['userName'],
              user.data()!['schoolName'],
              user.data()!['rewards'] is int
                  ? user.data()!['rewards']
                  : (user.data()!['rewards'] is double
                      ? user.data()!['rewards'].toInt()
                      : int.parse(user.data()!['rewards'])));
          return 'Login successful';
        } else {
          return 'Incorrect password';
        }
      }
    } catch (e) {
      return 'Error : $e';
    }
  }

  Future<void> updateUser(String schoolName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('currentCustomerEmail');
    if (email != null) {
      await _firestore
          .collection(_collection)
          .doc(email)
          .update({'schoolName': schoolName});
      // await _saveUser(email,);
    }
  }

  Future<void> updateUserStripeCustomerId(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('currentCustomerEmail');
    if (email != null) {
      await _firestore
          .collection(_collection)
          .doc(email)
          .update({'stripeCustomerID': id});
      // await _saveUser(email,);
    }
  }

  Future<void> updateUserAddress(Position position) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('currentCustomerEmail');
    if (email != null) {
      await _firestore.collection(_collection).doc(email).update(
          {'location': GeoPoint(position.latitude, position.longitude)});
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
      Map<String, dynamic> data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('currentCustomerEmail');
    if (email != null) {
      await _firestore.collection(_collection).doc(email).update(data);
      final newUser = await _firestore.collection(_collection).doc(email).get();
      await _saveUser(
          email,
          newUser.data()?['userName'],
          newUser.data()?['schoolName'],
          newUser.data()?['rewards'] is double
              ? newUser.data()!['rewards'].toInt()
              : newUser.data()!['rewards']);
      return newUser.data()!;
    }
    return {};
  }

  Future<bool> isLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('currentCustomerEmail');
    return email != null;
  }

  Future<void> signOut() async {
    await _clearUser();
    // print('signout successful');
  }

  String encryptPassword(String password) {
    const customSalt = '\$2a\$10\$CwTycUXWue0Thq9StjUM0u';
    final hash = BCrypt.hashpw(password, customSalt);
    return hash;
  }

  Future<void> _saveUser(
      String email, String userName, String schoolName, int coconuts) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('currentCustomerEmail', email);
    await prefs.setString('currentCustomerUserName', userName);
    await prefs.setString('currentCustomerSchoolName', schoolName);
    await prefs.setInt('currentCustomerCoconuts', coconuts);
  }

  Future<void> _clearUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('currentCustomerEmail');
    await prefs.remove('currentCustomerUserName');
    await prefs.remove('currentCustomerSchoolName');
    await prefs.remove('currentCustomerCoconuts');
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? email = prefs.getString('currentCustomerEmail');
    final String? userName = prefs.getString('currentCustomerUserName');
    final String? schoolName = prefs.getString('currentCustomerSchoolName');
    final int? coconuts = prefs.getInt('currentCustomerCoconuts');
    return {
      'email': email!,
      'userName': userName!,
      'schoolName': schoolName!,
      'coconuts': coconuts!,
    };
  }

  Future<Map<String, dynamic>> getCurrentUserFromFirebase() async {
    if (SharedPreferencesHelper.getCustomerType() != 'guest') {
      final email = SharedPreferencesHelper.getCustomerEmail();
      final userFromFb =
          await _firestore.collection("clients").doc(email).get();
      return userFromFb.data()!;
    }
    return {};
  }

  Future<bool> deleteUserFromFirebase() async {
    try {
      final CollectionReference clientsCollection =
          _firestore.collection('clients');
      final email = SharedPreferencesHelper.getCustomerEmail();
      QuerySnapshot subcollectionSnapshot =
          await clientsCollection.doc(email).collection('restaurants').get();
      for (QueryDocumentSnapshot doc in subcollectionSnapshot.docs) {
        await doc.reference.delete();
      }

      await clientsCollection.doc(email).delete();
      return true;
    } catch (e) {
      return false;
    }
  }
}
