import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paraiso/screens/friends_list.dart';
import 'package:paraiso/screens/home_restaurants_list.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
import 'package:paraiso/widgets/home_chips_row.dart';

import '../repositories/customer_firebase_calls.dart';

class HomeTabView extends StatefulWidget {
  // final Widget child;
  // final String path;

  const HomeTabView({
    super.key,
    // required this.child,
    // required this.path
  });

  @override
  State<HomeTabView> createState() => _HomeTabViewState();
}

class _HomeTabViewState extends State<HomeTabView> {
  final myHomeChipsController = Get.find<HomeChipsController>();

  @override
  void initState() {
    super.initState();
    // _getCurrentLocation();
    getItems();
  }

  // Position? currentPosition;
  // String? _currentAddress;
  // void _getCurrentLocation() async {
  //   try {
  //     currentPosition = await getCurrentLocation();
  //     _currentAddress = await getAddressFromCoordinates(currentPosition!);
  //     print('currentPosition.latitude');
  //     print(currentPosition!.latitude);
  //     SharedPreferencesHelper.saveUserLocation(
  //         currentPosition!.latitude, currentPosition!.longitude);
  //     setState(() {});
  //   } catch (e) {
  //     print(e);
  //   }
  // }
  //
  // Future<Position> getCurrentLocation() async {
  //   bool serviceEnabled;
  //   LocationPermission permission;
  //
  //   serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //   if (!serviceEnabled) {
  //     throw 'Location services are disabled.';
  //   }
  //
  //   permission = await Geolocator.checkPermission();
  //   if (permission == LocationPermission.denied) {
  //     permission = await Geolocator.requestPermission();
  //     if (permission == LocationPermission.denied) {
  //       throw 'Location permissions are denied';
  //     }
  //   }
  //
  //   if (permission == LocationPermission.deniedForever) {
  //     throw 'Location permissions are permanently denied, we cannot request permissions.';
  //   }
  //
  //   return await Geolocator.getCurrentPosition();
  // }
  //
  // Future<String> getAddressFromCoordinates(Position position) async {
  //   try {
  //     SharedPreferencesHelper.saveUserLocation(
  //         position.latitude, position.latitude);
  //     print('user location get');
  //     List<Placemark> placemarks =
  //         await placemarkFromCoordinates(position.latitude, position.longitude);
  //     Placemark place = placemarks[0];
  //     return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
  //   } catch (e) {
  //     return "Address not found";
  //   }
  // }

  Future<void> getItems() async {
    final mydata = MyCustomerCalls();
    SharedPreferencesHelper.getCustomerType() == 'guest'
        ? await mydata.refreshNearbyRestaurantsForGuest(GeoPoint(
            SharedPreferencesHelper.getCurrentLat()!.toDouble(),
            SharedPreferencesHelper.getCurrentLng()!.toDouble()))
        : await mydata.refreshNearbyRestaurants();
    final data = await mydata.getRestaurantsByDistance();
    if (data.length < 10) {
      SharedPreferencesHelper.getCustomerType() == 'guest'
          ? await mydata.fetchAndSaveNearbyRestaurantsForGuest(GeoPoint(
              SharedPreferencesHelper.getCurrentLat()!.toDouble(),
              SharedPreferencesHelper.getCurrentLng()!.toDouble()))
          : await mydata.fetchAndSaveNearbyRestaurants();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      child: ListView(physics: const ClampingScrollPhysics(), children: [
        const HomeChipsRow(),
        21.verticalSpace,
        Obx(
          () => IndexedStack(
            index: myHomeChipsController.activeChip.value,
            children: const [
              // const HomeRestaurantsTab(),
              HomeRestaurantsList(),
              HomeFriendsList(),
              // HomeAllList(),
            ],
          ),
        ),
      ]),
    );
  }
}
