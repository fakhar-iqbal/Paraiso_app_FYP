import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../util/local_storage/shared_preferences_helper.dart';

class CartNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> _restaurants = [];

  List<Map<String, dynamic>> get cartItems => _restaurants;
  int get cartItemsCount => _restaurants.length;

  Future<void> saveCartToSharedPreferences() async {
    final email = SharedPreferencesHelper.getCustomerEmail();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodedCart = json.encode(_restaurants);
    await prefs.setString(email!, encodedCart);
  }

  Future<void> loadCartFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final email = SharedPreferencesHelper.getCustomerEmail();
    String? cartData = prefs.getString(email!);

    if (cartData != null) {
      List<dynamic> decodedData = json.decode(cartData);

      List<Map<String, dynamic>> cartList = decodedData.map((item) => Map<String, dynamic>.from(item)).toList();

      _restaurants.assignAll(cartList);
    } else {
      _restaurants = [];
    }
  }

  Future<void> updateQuantity(dynamic quantity, String itemName, String itemSize) async {
    for (int i = 0; i < _restaurants.length; i++) {
      for (int j = 0; j < _restaurants[i]['items'].length; j++) {
        if (_restaurants[i]['items'][j]['itemName'] == itemName && _restaurants[i]['items'][j]['itemSize'] == itemSize) {
          _restaurants[i]['items'][j]['itemQuantity'] = quantity;
          await saveCartToSharedPreferences();
          notifyListeners();
          return;
        }
      }
    }
  }

  void addItem(
    String restaurantId,
    String restaurantName,
    String restaurantImage,
    String itemId,
    String itemImage,
    String itemName,
    double itemPrice,
    String itemReward,
    int itemQuantity,
    String itemSize,
    dynamic addOns,
  ) {
    bool restaurantExists = false;

    for (int i = 0; i < _restaurants.length; i++) {
      if (_restaurants[i]['restaurantId'] == restaurantId) {
        restaurantExists = true;

        bool itemExists = false;
        for (int j = 0; j < _restaurants[i]['items'].length; j++) {
          if (_restaurants[i]['items'][j]['itemName'] == itemName && _restaurants[i]['items'][j]['itemSize'] == itemSize) {
            itemExists = true;
            _restaurants[i]['items'][j]['itemQuantity'] += itemQuantity;
            break;
          }
        }

        if (!itemExists) {
          Map<String, dynamic> newItem = {
            'itemId': itemId,
            'itemName': itemName,
            'itemPrice': itemPrice,
            'itemQuantity': itemQuantity,
            'itemSize': itemSize,
            'itemImage': itemImage,
            'itemReward': itemReward,
            'addOns': addOns,
          };
          _restaurants[i]['items'].add(newItem);
        }
        break;
      }
    }

    if (!restaurantExists) {
      Map<String, dynamic> newRestaurant = {
        'restaurantId': restaurantId,
        'restaurantName': restaurantName,
        'restaurantImage': restaurantImage,
        'items': [
          {
            'itemId': itemId,
            'itemName': itemName,
            'itemPrice': itemPrice,
            'itemQuantity': itemQuantity,
            'itemSize': itemSize,
            'itemImage': itemImage,
            'itemReward': itemReward,
            'addOns': addOns,
          }
        ]
      };
      _restaurants.add(newRestaurant);
    }
    saveCartToSharedPreferences();
    notifyListeners();
  }

  List<Map<String, dynamic>> getItemsInRestaurant(String restaurantId) {
    for (int i = 0; i < _restaurants.length; i++) {
      if (_restaurants[i]['restaurantId'] == restaurantId) {
        return _restaurants[i]['items'];
      }
    }
    return [];
  }

  void clearList() {
    _restaurants.clear();
    saveCartToSharedPreferences();
    notifyListeners();
  }

  void deleteRestaurant(String restaurantId) {
    _restaurants.removeWhere((restaurant) => restaurant['restaurantId'] == restaurantId);
    saveCartToSharedPreferences();
    notifyListeners();
  }
}

class CartProvider extends StatelessWidget {
  final Widget child;

  CartProvider({required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartNotifier(),
      child: child,
    );
  }

  static CartNotifier of(BuildContext context, {bool listen = true}) {
    return Provider.of<CartNotifier>(context, listen: listen);
  }
}
