import 'package:flutter/material.dart';

import '../repositories/customer_auth_repo.dart';

class UserProfileProvider with ChangeNotifier {
  Map<String, dynamic> _currentUser = {};

  Map<String, dynamic> get currentUser => _currentUser;

  Future<void> getCurrentUserFromFirebase() async {
    final user = await CustomerAuthRep().getCurrentUserFromFirebase();
    _currentUser = user;
    notifyListeners();
  }
}
