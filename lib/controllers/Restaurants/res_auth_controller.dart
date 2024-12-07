import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/restaurant_admin_model.dart';
import '../../repositories/res_auth_repo.dart';
import '../../util/local_storage/shared_preferences_helper.dart';

class AuthController with ChangeNotifier {
  final AuthRepository _authRepository = AuthRepository();
  RestaurantAdmin? _user;
  User? _anonymousUser;
  bool _isLoading = false;

  RestaurantAdmin? get user => _user;
  User? get anonymousUser => _anonymousUser;
  bool get isLoading => _isLoading;

  Future<void> signIn(String email, String password, bool rememberMe) async {
    _isLoading = true;
    final user = await _authRepository.signInUserWithEmailAndPassword(email: email, password: password);
    if (user != null) {
      SharedPreferencesHelper.saveResEmail(user.email);
      if (rememberMe) SharedPreferencesHelper.saveCurrentUser(user.username);
      _user = user;
      notifyListeners();
    } else {
      _user = null;
      notifyListeners();
      // Handle failed sign-in (e.g., show a snackbar)
    }
    _isLoading = false;
  }

  Future<void> signInAnonymously() async {
    final user = await _authRepository.signInAnonymously();
    if (user != null) {
      _anonymousUser = user;
      notifyListeners();
    } else {
      _anonymousUser = null;
      notifyListeners();
      // Handle failed sign-in (e.g., show a snackbar)
    }
  }

  Future<void> updateRes(String userId, Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();
    final res = await _authRepository.updateRestaurant(userId, data);
    _user = res;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authRepository.logout();
    await SharedPreferencesHelper.deleteCurrentUser();
    await SharedPreferencesHelper.deleteResEmail();
    notifyListeners();
  }

  Future<void> deleteAccount() async {
    await _authRepository.deleteRestaurant();
    await SharedPreferencesHelper.deleteCurrentUser();
    await SharedPreferencesHelper.deleteResEmail();
    notifyListeners();
  }

  // Add other authentication methods here (sign-up, sign-out, etc.)
}
