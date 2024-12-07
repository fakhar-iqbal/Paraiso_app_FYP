import 'package:flutter/material.dart';
import 'package:paraiso/repositories/customer_auth_repo.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';

class CustomerController with ChangeNotifier {
  final CustomerAuthRep _repo = CustomerAuthRep();

  Map<String, dynamic> _user = {};
  Map<String, dynamic> get user => _user;
  bool _loading = false;
  bool get loading => _loading;

  Future<void> getCurrentUser() async {
    if (SharedPreferencesHelper.getCustomerType() == 'guest') {
      _loading = true;
      // notifyListeners();
      final currUser = await _repo.getCurrentUserFromFirebase();
      _user = currUser;
      print('currentUser');
      _loading = false;
      notifyListeners();
    }
  }
}
