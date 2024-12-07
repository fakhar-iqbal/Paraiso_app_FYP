import 'package:flutter/material.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';

import '../repositories/customer_firebase_calls.dart';

class RestaurantsWithDiscountController with ChangeNotifier {
  final MyCustomerCalls _repo = MyCustomerCalls();

  List<Map<String, dynamic>> _restaurants = [];
  bool _loading = false;
  bool get loading => _loading;

  List<Map<String, dynamic>> get restaurants => _restaurants;

  Future<void> getRestaurantsWithDiscounts() async {
    _loading = true;
    // notifyListeners();
    final res = SharedPreferencesHelper.getCustomerType() == 'guest'
        ? await _repo.getRestaurantsWithDiscountsForGuest()
        : await _repo.getRestaurantsWithDiscounts();
    final uniqueRestaurants = res.toSet().toList();
    print('restaurantDiscount');
    _loading = false;
    _restaurants = uniqueRestaurants;
    notifyListeners();
  }
}
