import 'package:flutter/material.dart';
import 'package:paraiso/models/restaurant_admin_model.dart';
import 'package:paraiso/repositories/res_post_repo.dart';

import '../../models/product_item.dart';

class MenuItemsController with ChangeNotifier {
  final RestaurantPostRepo _repo = RestaurantPostRepo();
  List<ProductItem> _menu = [];
  Map<String, dynamic> _topMostDiscountItem = {};

  bool _setFreeItemLoader = false;
  bool get setFreeItemLoader => _setFreeItemLoader;

  bool _addItemLoader = false;
  bool get addItemLoader => _addItemLoader;

  bool _clearFreeItemLoader = false;
  bool get clearFreeItemLoader => _clearFreeItemLoader;

  List<ProductItem> get menu => _menu;
  Map<String, dynamic> get topMostDiscountItem => _topMostDiscountItem;

  Future<void> fetchMenu(String userId) async {
    final menuItems = await _repo.getMenu(userId);
    _menu = menuItems;
    notifyListeners();
  }

  Future<void> setDiscount(
      RestaurantAdmin admin, List<String> itemIds, String discount) async {
    await _repo.updateItemDiscounts(admin.userId, itemIds, discount);
    notifyListeners();
  }

  Future<void> clearDiscount(
      RestaurantAdmin admin, List<String> itemIds) async {
    await _repo.clearItemDiscounts(admin.userId, itemIds);
    notifyListeners();
  }

  Future<void> getItemWithTopMostDiscount() async {
    final item = await _repo.getItemWithTopDiscount();
    _topMostDiscountItem = item;
    notifyListeners();
  }

  Future<void> setFreeItem(RestaurantAdmin admin, String itemId,
      Map<String, dynamic> giftItem) async {
    _setFreeItemLoader = true;
    notifyListeners();
    await _repo.makeItemFree(admin.userId, itemId, giftItem);
    _setFreeItemLoader = false;
    notifyListeners();
  }

  Future<void> clearFreeItem(RestaurantAdmin admin, String itemIds) async {
    _clearFreeItemLoader = true;
    notifyListeners();
    await _repo.clearFreeItem(admin.userId, itemIds);
    _clearFreeItemLoader = false;
    notifyListeners();
  }

  Future<void> addItem(RestaurantAdmin admin, ProductItem newItem) async {
    _addItemLoader = true;
    await _repo.addItemToMenu(admin.userId, newItem);
    _addItemLoader = false;
    notifyListeners();
  }

  Future<void> removeItem(RestaurantAdmin admin, String itemId) async {
    await _repo.deleteItemFromMenu(admin.userId, itemId);
    notifyListeners();
  }

  Future<void> updateItem(RestaurantAdmin admin, ProductItem newItem) async {
    await _repo.updateMenuItem(admin.userId, newItem);
    notifyListeners();
  }
}
