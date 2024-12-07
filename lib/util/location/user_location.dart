import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart' as permission;

import '../../models/client_model.dart';
import '../../models/restaurant_admin_model.dart';

class UserLocation {
  Future<Position?> requestLocationPermission() async {


    permission.PermissionStatus status =
        await permission.Permission.location.status;
        
    while (!status.isGranted) {
      if (status.isDenied) {
        status = await permission.Permission.location.request();
      } else if (status.isPermanentlyDenied) {
        // Handle the case where location permission is permanently denied.
        // For example, you can show a dialog explaining why you need the permission.
        // You can open app settings so that the user can manually grant the permission.
        // For now, we'll break out of the loop.
        break;
      }
    }

    if (status.isGranted) {
      return await getUserLocation();
    } else {
      // Handle the case where permission is not granted.
      return null;
    }
  }

  Future<Position?> getUserLocation() async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      if (kDebugMode) print('Error getting location: $e');
      return null;
    }
  }

  Future<String> getAddress(double latitude, double longitude) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude);
    Placemark place = placemarks.first;
    String address =
        "${place.street}, ${place.locality}, ${place.administrativeArea}, ${place.country}";
    return address;
    // print("Address: $address");
  }

  num calculateDistanceAndReturnEstimateTravelTime(
      RestaurantAdmin admin, Client client) {
    final double distance = Geolocator.distanceBetween(
      admin.location!.latitude,
      admin.location!.longitude,
      client.location!.latitude,
      client.location!.longitude,
    );
    return estimateTravelTime(distance, 45);
  }

  num estimateTravelTime(
      double distanceInMeters, double averageSpeedKmPerHour) {
    final averageSpeedMetersPerMinute = averageSpeedKmPerHour * 1000 / 60;

    final travelTimeMinutes = distanceInMeters / averageSpeedMetersPerMinute;

    return travelTimeMinutes < 1.0 ? 2 : travelTimeMinutes.ceil();
  }
}
