import 'package:flutter/material.dart';
import 'package:paraiso/models/restaurant_admin_model.dart';
import 'package:paraiso/repositories/res_post_repo.dart';

import '../../models/product_item.dart';

class AddOnController with ChangeNotifier {
  final RestaurantPostRepo _repo = RestaurantPostRepo();
  List<AddonItemWithId> _addons = [];


  List<AddonItemWithId> get addons => _addons;

  Future<void> fetchADDON(String userId) async {
    final addonList = await _repo.getADDON(userId);
    _addons = addonList;
    notifyListeners();
  }


  Future<void> removeADDON(String userId, String itemId) async {
    await _repo.deleteADDON(userId, itemId);
    notifyListeners();
  }

}
