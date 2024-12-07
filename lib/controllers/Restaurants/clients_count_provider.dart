import 'package:flutter/foundation.dart';
import 'package:paraiso/models/restaurant_admin_model.dart';

import '../../repositories/res_post_repo.dart';

class ClientCountProvider with ChangeNotifier {
  final RestaurantPostRepo _repo = RestaurantPostRepo();
  int _usersCount = 0;
  int _usersIn1KM = 0;
  // int _nonClientCount = 0;
  int _clientCount = 0;

  int get usersCount => _usersCount;
  int get clientCount => _clientCount;
  int get usersIn1KM => _usersIn1KM;
  // int get nonClientCount => _nonClientCount;

  Future<void> fetchUserCount(String restaurantId) async {
    final int noOfUsers = await _repo.fetchUserCount();
    _usersCount = noOfUsers;
    notifyListeners();
  }

  Future<void> fetchUsersWithin1KM(RestaurantAdmin admin) async {
    final int noOfUsers = await _repo.fetchUsersWithin1KM(admin);
    _usersIn1KM = noOfUsers;
    notifyListeners();
  }

  Future<void> fetchClientsCount(String restaurantId) async {
    final int noOfClients = await _repo.fetchClientCount(restaurantId);
    _clientCount = noOfClients;
    notifyListeners();
  }

  // Future<void> fetchNonClientCount(String restaurantId) async {
  //   final int noOfClients = await _repo.fetchNonClientCount();
  //   _nonClientCount = noOfClients;
  //   notifyListeners();
  // }
}
