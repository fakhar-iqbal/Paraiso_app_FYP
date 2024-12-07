import 'package:flutter/material.dart';
import 'package:paraiso/models/restaurant_admin_model.dart';
import 'package:paraiso/repositories/res_post_repo.dart';

class ClientsController with ChangeNotifier {
  final RestaurantPostRepo _repo = RestaurantPostRepo();
  List<Map<String, dynamic>> _clients = [];
  List<String> _topSchools = [];
  List<Map<String, dynamic>> _topCustomers = [];

  List<Map<String, dynamic>> get clients => _clients;
  List<String> get topSchools => _topSchools;
  List<Map<String, dynamic>> get topCustomers => _topCustomers;

  Future<void> fetchClients(RestaurantAdmin admin) async {
    final clientsData = await _repo.getClientsWithSentRewards(admin.userId);
    _clients = clientsData;
    notifyListeners();
  }

  Future<void> fetchTopSchools() async {
    final schools = await _repo.getTopTwoSchoolNames();
    _topSchools = schools;
    notifyListeners();
  }

  Future<void> fetchTopCustomers(String restaurantId) async {
    final customers = await _repo.getTopUsersBySales(restaurantId);
    _topCustomers = customers;
    notifyListeners();
  }
}
