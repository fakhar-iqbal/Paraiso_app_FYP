import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:paraiso/controllers/sort_by_distance_controller.dart';
import 'package:paraiso/screens/discount_sort_list.dart';
import 'package:paraiso/screens/distance_sort_list.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:provider/provider.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:velocity_x/velocity_x.dart';

import '../controllers/categories_controller.dart';
import '../controllers/customer_controller.dart';
import '../repositories/customer_firebase_calls.dart';
import '../util/location/user_location.dart';
import '../widgets/primary_button.dart';
import 'customer_basic_profile.dart';

class FoodRestaurantsTab extends StatefulWidget {
  const FoodRestaurantsTab({super.key});

  @override
  State<FoodRestaurantsTab> createState() => _FoodRestaurantsTabState();
}

class _FoodRestaurantsTabState extends State<FoodRestaurantsTab> {
  int foodIndex = 1;

  bool _isActive = false;

  void locationPopup() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.r),
              ),
              backgroundColor: softBlack,
              content: VStack(
                crossAlignment: CrossAxisAlignment.center,
                [
                  5.verticalSpace,
                  Text(
                    AppLocalizations.of(context)!.confirmYourLocation,
                    style: context.titleLarge?.copyWith(
                      color: onPrimaryColor,
                    ),
                  ),
                  30.verticalSpace,
                  SharedPreferencesHelper.getCustomerType() == 'guest'
                      ? Consumer(
                          builder: (context, customerController, child) {
                            GeoPoint location = GeoPoint(
                                currentPosition!.latitude,
                                currentPosition!.longitude);
                            print('location guest');
                            print(location);
                            double latitude = location.latitude;
                            double longitude = location.longitude;

                            return FutureBuilder<String>(
                              future: UserLocation()
                                  .getAddress(latitude, longitude),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(
                                      height: 80.h,
                                      width: 80.w,
                                      child: CircularProgressIndicator(
                                          color: primaryColor));
                                } else if (snapshot.hasError) {
                                  return Text(
                                      "Couldn't fetch address: ${snapshot.error}");
                                } else {
                                  String userAddress =
                                      snapshot.data ?? "Unknown Address";
                                  return SizedBox(
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: primaryColor,
                                          size: 30.h,
                                        ),
                                        8.horizontalSpace,
                                        Expanded(
                                          child: Text(
                                            userAddress,
                                            softWrap: true,
                                            maxLines: 3,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                            ),
                                          ),
                                        ),
                                        51.horizontalSpace,
                                        InkWell(
                                          onTap: () async {
                                            final customerController =
                                                Provider.of<CustomerController>(
                                                    context,
                                                    listen: false);
                                            await customerController
                                                .getCurrentUser();
                                            if (mounted) {
                                              Navigator.pop(context);
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const CustomerBasicProfile(),
                                                ),
                                              );
                                            }
                                          },
                                          child: Text(
                                            AppLocalizations.of(context)!
                                                .change,
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  );
                                }
                              },
                            );
                          },
                        )
                      : Consumer<CustomerController>(
                          builder: (context, customerController, child) {
                            if (customerController.user.isEmpty) {
                              return CircularProgressIndicator(
                                  color: primaryColor);
                            } else {
                              GeoPoint location =
                                  customerController.user['location'];
                              print('location');
                              print(location);
                              double latitude = location.latitude;
                              double longitude = location.longitude;

                              return FutureBuilder<String>(
                                future: UserLocation()
                                    .getAddress(latitude, longitude),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return SizedBox(
                                        height: 80.h,
                                        width: 80.w,
                                        child: CircularProgressIndicator(
                                            color: primaryColor));
                                  } else if (snapshot.hasError) {
                                    return Text(
                                        "Couldn't fetch address: ${snapshot.error}");
                                  } else {
                                    String userAddress =
                                        snapshot.data ?? "Unknown Address";
                                    return SizedBox(
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_rounded,
                                            color: primaryColor,
                                            size: 30.h,
                                          ),
                                          8.horizontalSpace,
                                          Expanded(
                                            child: Text(
                                              userAddress,
                                              softWrap: true,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14.sp,
                                              ),
                                            ),
                                          ),
                                          51.horizontalSpace,
                                          InkWell(
                                            onTap: () async {
                                              final customerController =
                                                  Provider.of<
                                                          CustomerController>(
                                                      context,
                                                      listen: false);
                                              await customerController
                                                  .getCurrentUser();
                                              if (mounted) {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const CustomerBasicProfile(),
                                                  ),
                                                );
                                              }
                                            },
                                            child: Text(
                                              AppLocalizations.of(context)!
                                                  .change,
                                              style: TextStyle(
                                                color: primaryColor,
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    );
                                  }
                                },
                              );
                            }
                          },
                        ),
                ],
              ),
              actions: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PrimaryButton(
                      icon: Icons.arrow_forward_ios,
                      onPressed: () async {
                        // final resByDist = Provider.of<SortByDistanceController>(
                        //     context,
                        //     listen: false);
                        // await resByDist.getRestaurantsByDistance();
                        setState(() {
                          _isActive = !_isActive;
                        });
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.confirm,
                        style: TextStyle(
                          color: const Color(0xFFE4E4E4),
                          fontSize: 16.sp,
                          fontFamily: 'Recoleta',
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ));
  }

  Position? currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      currentPosition = await getCurrentLocation();
      _currentAddress = await getAddressFromCoordinates(currentPosition!);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> getAddressFromCoordinates(Position position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
    } catch (e) {
      return "Address not found";
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: ListView(physics: const NeverScrollableScrollPhysics(), children: [
        GestureDetector(
          child: ToggleSwitch(
            minWidth: 150.w,
            minHeight: 55.h,
            cornerRadius: 50.0,
            activeBgColors: [
              [primaryColor],
              [primaryColor]
            ],
            activeFgColor: onNeutralColor,
            inactiveBgColor: softBlack,
            inactiveFgColor: onNeutralColor,
            initialLabelIndex: foodIndex,
            totalSwitches: 2,
            labels: [
              AppLocalizations.of(context)!.distance,
              AppLocalizations.of(context)!.discount
            ],
            customTextStyles: [
              TextStyle(
                fontSize: 16.sp,
                color: onPrimaryColor,
                fontWeight: FontWeight.w700,
              ),
              TextStyle(
                fontSize: 16.sp,
                color: onPrimaryColor,
                fontWeight: FontWeight.w700,
              ),
            ],
            radiusStyle: true,
            onToggle: (index) async {
              if (kDebugMode) print('switched to: $index');
              setState(() {
                foodIndex = index!;
              });
              final resByDist =
                  Provider.of<SortByDistanceController>(context, listen: false);
              final currentUserController =
                  Provider.of<CustomerController>(context, listen: false);
              final categoryProvider =
                  Provider.of<CategoriesProvider>(context, listen: false);
              categoryProvider.setActiveChip(100);
              categoryProvider.setSelectedCategory("");
              if (SharedPreferencesHelper.getCustomerType() == 'guest') {
                print('refresh near by rest');
                await MyCustomerCalls().refreshNearbyRestaurantsForGuest(
                    GeoPoint(
                        currentPosition!.latitude, currentPosition!.longitude));
              } else {
                await currentUserController.getCurrentUser();
                await MyCustomerCalls().refreshNearbyRestaurants();
              }

              if (index == 0) {
                await resByDist.getRestaurantsByDistance();
                locationPopup();
              }
            },
          )
              .w(
                308.w,
              )
              .centered(),
        ),
        IndexedStack(
          index: foodIndex,
          children: const [
            DistanceSortList(),
            DiscountSortList(),
          ],
        ),
      ]),
    );

    // return GestureDetector(
    //   onTap: _toggleSwitch,
    //   child: Container(
    //     width: 70,
    //     height: 35,
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(20),
    //       color: _isActive ? Colors.blue : Colors.grey,
    //     ),
    //     child: AnimatedContainer(
    //       duration: Duration(milliseconds: 200),
    //       curve: Curves.easeInOut,
    //       margin: EdgeInsets.only(left: _isActive ? 35 : 0),
    //       width: 30,
    //       height: 30,
    //       decoration: BoxDecoration(
    //         borderRadius: BorderRadius.circular(15),
    //         color: Colors.white,
    //       ),
    //     ),
    //   ),
    // );
  }
}
