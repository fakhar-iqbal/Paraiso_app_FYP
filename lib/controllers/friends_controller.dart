import 'package:flutter/material.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';

import '../repositories/customer_auth_repo.dart';
import '../repositories/customer_firebase_calls.dart';

class FriendsController with ChangeNotifier {
  final MyCustomerCalls _repo = MyCustomerCalls();

  List<Map<String, dynamic>> _friendsList = [];
  List<Map<String, dynamic>?> _friendsWithRewards = [];
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get friendsList => _friendsList;
  List<Map<String, dynamic>?> get friendsWithRewards => _friendsWithRewards;

  Future<void> getFriends(String email) async {
    if (SharedPreferencesHelper.getCustomerType() != 'guest') {
      _isLoading = true;
      notifyListeners();
      final friends = await _repo.getFriends(email);
      _friendsList = friends;
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getFriendsWithRewards({bool letLoading = true}) async {
    if (SharedPreferencesHelper.getCustomerType() != 'guest') {
      if (letLoading) {
        _isLoading = true;
      }
      final customerAuth = CustomerAuthRep();
      final currentCustomer = await customerAuth.getCurrentUser();
      String email = currentCustomer['email'];
      getFriends(email);
      final friends = await _repo.getPostsAndSort();
      _friendsWithRewards = friends;
      _isLoading = false;
      notifyListeners();
    }
  }
}
