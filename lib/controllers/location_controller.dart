import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../models/restaurant_admin_model.dart';
import '../repositories/res_post_repo.dart';
import '../util/local_storage/shared_preferences_helper.dart';
import '../util/location/user_location.dart';

class LocationProvider with ChangeNotifier {
  final RestaurantPostRepo _repo = RestaurantPostRepo();
  final UserLocation _userLoc = UserLocation();
  Position? _userLocation;
  bool _isLoading = false;
  bool _updatedSharedPref = false;
  bool get isLoading => _isLoading;
  bool get updatedSharedPref => _updatedSharedPref;

  Position? get userLocation => _userLocation;

  Future<void> getUserLocation() async {
    _isLoading = true;
    notifyListeners();
    final loc = await _userLoc.requestLocationPermission();
    if (loc != null) {
      await SharedPreferencesHelper.saveUserLocation(
          loc.latitude, loc.longitude);
      _updatedSharedPref = true;
      notifyListeners();
    }
    _userLocation = loc;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateResLocation(
      RestaurantAdmin admin, double latitude, double longitude) async {
    await _repo.updateResLocation(admin.userId, latitude, longitude);
    await SharedPreferencesHelper.updateUserLocation(latitude, longitude);
    notifyListeners();
  }
}
