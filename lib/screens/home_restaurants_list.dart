import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
import 'package:paraiso/widgets/restaurant_tile.dart';
import 'package:provider/provider.dart';

import '../controllers/customer_controller.dart';
import '../controllers/restaurants_with_discount_controller.dart';
import '../controllers/sort_by_distance_controller.dart';
import '../repositories/customer_firebase_calls.dart';

class HomeRestaurantsList extends StatefulWidget {
  const HomeRestaurantsList({Key? key}) : super(key: key);

  @override
  State<HomeRestaurantsList> createState() => _HomeRestaurantsListState();
}

class _HomeRestaurantsListState extends State<HomeRestaurantsList> {
  @override
  void initState() {
    final resByDist =
        Provider.of<SortByDistanceController>(context, listen: false);

    final currentUserController =
        Provider.of<CustomerController>(context, listen: false);

    final restController =
        Provider.of<RestaurantsWithDiscountController>(context, listen: false);
    scheduleMicrotask(() {
      currentUserController.getCurrentUser();

      MyCustomerCalls().refreshNearbyRestaurants();

      resByDist.getRestaurantsByDistance();

      restController.getRestaurantsWithDiscounts();
    });

    super.initState();
  }

  RestaurantsWithDiscountController? restController;

  bool getCloseStatus1(dynamic restaurant) {
    if (restaurant['openingHrs'] == null) {
      return true;
    }

    if (!restaurant['openingHrs'].contains("-")) {
      return true;
    }

    if (restaurant['openingHrs'].contains("mardi")) {
      return true;
    }

    print(restaurant['openingHrs']);

    final openTime = restaurant['openingHrs'].split("-")[0];
    final closeTime = restaurant['openingHrs'].split("-")[1];

    print("Open Time: $openTime");
    print("Close Time: $closeTime");

    final format = DateFormat('hh:mm');
    final startTime = format.parse(openTime);
    final endTime = format.parse(closeTime);
    final checkTime = DateFormat('hh:mm').format(DateTime.now());
    final check = format.parse(checkTime);

    if (startTime.isBefore(endTime)) {
      return check.isAfter(startTime) && check.isBefore(endTime);
    } else {
      final endOfDay = endTime.add(const Duration(days: 1));
      return check.isAfter(startTime) || check.isBefore(endOfDay);
    }
  }

  bool getCloseStatus(dynamic restaurant) {
    if (restaurant['openingHrs'] == null) {
      return false;
    }

    if (!restaurant['openingHrs'].contains("-")) {
      return false;
    }

    final openTime = restaurant['openingHrs'].split("-")[0];
    final closeTime = restaurant['openingHrs'].split("-")[1];

    final format = DateFormat('HH:mm');
    final startTime = format.parse(openTime);
    final endTime = format.parse(closeTime);
    final checkTime = format.parse(DateFormat('HH:mm').format(DateTime.now()));

    print("Start Time: $startTime");
    print("End Time: $endTime");
    print("Check Time: $checkTime");

    if (startTime.isBefore(endTime)) {
      return checkTime.isAfter(startTime) && checkTime.isBefore(endTime);
    } else {
      final endOfDay = endTime.add(const Duration(days: 1));
      return checkTime.isAfter(startTime) || checkTime.isBefore(endOfDay);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resByDist =
        Provider.of<SortByDistanceController>(context, listen: false);

    final currentUserController =
        Provider.of<CustomerController>(context, listen: false);

    final restController =
        Provider.of<RestaurantsWithDiscountController>(context, listen: false);
    return resByDist.loading ||
            currentUserController.loading ||
            restController.loading
        ? const Center(child: CircularProgressIndicator())
        : Consumer<RestaurantsWithDiscountController>(
            builder: (context, value, child) {
              return Column(
                children: [
                  value.restaurants.isEmpty
                      ? Center(
                          child: Text(AppLocalizations.of(context)!
                              .noNearbyRestaurantsFound))
                      : SizedBox(
                          width: double.infinity,
                          height: 580.h,
                          child: RefreshIndicator(
                            onRefresh: () async {
                              if (SharedPreferencesHelper.getCustomerType() ==
                                  'guest') {
                                await MyCustomerCalls()
                                    .refreshNearbyRestaurantsForGuest(GeoPoint(
                                        SharedPreferencesHelper.getCurrentLat()!
                                            .toDouble(),
                                        SharedPreferencesHelper.getCurrentLng()!
                                            .toDouble()));
                                await value.getRestaurantsWithDiscounts();
                              } else {
                                await MyCustomerCalls()
                                    .refreshNearbyRestaurants();
                                await value.getRestaurantsWithDiscounts();
                              }
                            },
                            child: ListView.builder(
                              itemCount: value.restaurants.length,
                              itemBuilder: (context, index) {
                                print('loop active');
                                final Timestamp lastUpdatedTimestamp =
                                    value.restaurants[index]['lastUpdated'];
                                final DateTime lastUpdated =
                                    lastUpdatedTimestamp.toDate();
                                final formattedTimeDifference =
                                    formatTimeDifference(lastUpdated);
                                bool isClosed =
                                    getCloseStatus(value.restaurants[index]);
                                return RestaurantTile(
                                  isClosed:
                                      !getCloseStatus(value.restaurants[index]),
                                  isAvailable: value.restaurants[index]
                                          ['availability'] ??
                                      true,
                                  restaurantID: value.restaurants[index]
                                      ['restaurantId'],
                                  restaurantName: value.restaurants[index]
                                      ['restaurantName'],
                                  restaurantAddress: value.restaurants[index]
                                          ['restaurantAddress'] ??
                                      "Unknown",
                                  restaurantDescription:
                                      '${value.restaurants[index]["discount"]} ${AppLocalizations.of(context)!.discountOn} ${value.restaurants[index]['itemName']}',
                                  distance: formattedTimeDifference,
                                  image: value.restaurants[index]
                                      ['restaurantLogo'],
                                  isOnlineImage: true,
                                );
                              },
                            ),
                          ),
                        ),
                ],
              );
            },
          );
  }
}
