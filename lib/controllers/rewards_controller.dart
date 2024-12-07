import 'package:flutter/material.dart';

import '../repositories/customer_firebase_calls.dart';

class RewardsController with ChangeNotifier {
  final MyCustomerCalls _repo = MyCustomerCalls();

  num _rewards = 0;
  bool _isLoading = false;

  bool get isLoading => _isLoading;
  num get rewards => _rewards;

  // Future<Map<String, dynamic>> claimRewards(String email) async {
  //   _isLoading = true;
  //   notifyListeners();
  //   final rewardsClaimed = await _repo.claimRewards(email);
  //   // await SharedPreferencesHelper.updateUserLocation(latitude, longitude);
  //   _isLoading = false;
  //   notifyListeners();
  //   return rewardsClaimed;
  // }

  Future<void> getRewards(String email) async {
    _isLoading = true;
    final userRewards = await _repo.getRewards(email);
    _rewards = userRewards;
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> sendRewards(
    String currentUserEmail,
    String recipientEmail,
    String rewardType,
    int rewardAmount,
  ) async {
    _isLoading = true;
    notifyListeners();
    final sentRewards = await _repo.sendRewards(
      currentUserEmail,
      recipientEmail,
      rewardType,
      rewardAmount,
    );
    _isLoading = false;
    notifyListeners();
    return sentRewards;
  }
}
