import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import '../../../controllers/Restaurants/clients_controller.dart';
import '../../../controllers/Restaurants/nearby_restaurants_controller.dart';
import '../../../controllers/Restaurants/res_auth_controller.dart';
import '../../../util/app_constants.dart';
import '../../../util/theme/theme_constants.dart';
import '../../custom_drawer.dart';

class RHomeView extends StatefulWidget {
  const RHomeView({Key? key}) : super(key: key);

  @override
  State<RHomeView> createState() => _RHomeViewState();
}

class _RHomeViewState extends State<RHomeView> {
  bool isClients = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    // final locationController =
    //     Provider.of<LocationProvider>(context, listen: false);

    final clientsProvider =
        Provider.of<ClientsController>(context, listen: false);

    final clients = clientsProvider.clients;

    final authController = Provider.of<AuthController>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(
        scaffoldKey: _scaffoldKey,
      ),
      body: Consumer<NearbyRestaurantsController>(
        builder: (context, value, child) {
          final nearbyRestaurants = value.restaurantsWithDiscount;

          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 40.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _scaffoldKey.currentState?.openDrawer();
                        },
                        child: Container(
                          height: 80.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: const Color.fromRGBO(53, 53, 53, 1),
                                  width: 2.w)),
                          child: ClipOval(
                              child: Image.network(
                            authController.user!.logo,
                            fit: BoxFit.cover,
                          )),
                        ),
                      ),
                      Expanded(
                        child: SvgPicture.asset(
                          'assets/images/paraiso_logo.svg',
                          width: 40.w,
                          height: 40.h,
                        ),
                      ),
                      Row(
                        children: [
                          // Container(
                          //   height: 60.h,
                          //   width: 60.w,
                          //   margin: EdgeInsets.only(right: 5.w),
                          //   decoration: const BoxDecoration(
                          //       shape: BoxShape.circle,
                          //       color: Color.fromRGBO(53, 53, 53, 1),
                          //       image: DecorationImage(
                          //           image:
                          //               AssetImage('assets/icons/order.png'))),
                          // ),
                          Container(
                            height: 60.h,
                            width: 60.w,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(53, 53, 53, 1),
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/icons/notification.png'))),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 30.h),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(53, 53, 53, 1),
                        borderRadius: BorderRadius.circular(40.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  isClients = false;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40.w, vertical: 15.h),
                                decoration: BoxDecoration(
                                  color: isClients == false
                                      ? const Color(0xFF2F58CD)
                                      : const Color.fromRGBO(53, 53, 53, 1),
                                  borderRadius: BorderRadius.circular(40.r),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.restaurants,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Recoleta",
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp),
                                ),
                              )),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  isClients = true;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40.w, vertical: 15.h),
                                decoration: BoxDecoration(
                                  color: isClients == true
                                      ? const Color(0xFF2F58CD)
                                      : const Color.fromRGBO(53, 53, 53, 1),
                                  borderRadius: BorderRadius.circular(40.r),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.clients,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Recoleta",
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp),
                                ),
                              )),
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .625,
                  child: isClients && clients.isEmpty
                      ? const Center(child: Text("No Client Updates Yet !"))
                      : isClients == false && nearbyRestaurants.isEmpty
                          ? const Center(child: Text("No Restaurants Yet !"))
                          : ListView.builder(
                              itemCount: isClients
                                  ? clients.length
                                  : nearbyRestaurants.length,
                              shrinkWrap: true,
                              padding: EdgeInsets.zero,
                              itemBuilder: (context, index) {
                                // final Timestamp lastUpdatedTimestamp =
                                //     nearbyRestaurants[index]['lastUpdated'];
                                // final DateTime lastUpdated =
                                //     lastUpdatedTimestamp.toDate();
                                // final formattedTimeDifference =
                                //     formatTimeDifference(lastUpdated);

                                return Container(
                                  margin: EdgeInsets.only(bottom: 12.h),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 15.w, vertical: 18.h),
                                  decoration: BoxDecoration(
                                    color: const Color.fromRGBO(53, 53, 53, 1),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 40.r,
                                              backgroundColor: Colors.white54,
                                              backgroundImage: NetworkImage(isClients
                                                  ? (clients[index]['photo'] !=
                                                              null &&
                                                          clients[index]
                                                                  ['photo'] !=
                                                              ""
                                                      ? clients[index]['photo']
                                                      : "https://firebasestorage.googleapis.com/v0/b/paraiso-a6ec6.appspot.com/o/dummy_profile.png?alt=media&token=1d8ab187-9695-4450-a03c-a5dda90b7ece")
                                                  : nearbyRestaurants[index]
                                                      ["restaurantLogo"]),
                                            ),
                                            SizedBox(
                                              width: 20.w,
                                            ),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    isClients
                                                        ? clients[index]
                                                            ['sender']
                                                        : nearbyRestaurants[
                                                                index]
                                                            ["restaurantName"],
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: "Recoleta",
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 16.sp),
                                                  ),
                                                  SizedBox(
                                                    height: 5.h,
                                                  ),
                                                  isClients == false
                                                      ? Text(
                                                          '${nearbyRestaurants[index]["discount"]} ${AppLocalizations.of(context)!.discountOn} ${nearbyRestaurants[index]['itemName']}',
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontFamily:
                                                                  "Recoleta",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 13.sp),
                                                        )
                                                      : SizedBox(
                                                          width: 200.w,
                                                          child:
                                                              DefaultTextStyle
                                                                  .merge(
                                                            style: TextStyle(
                                                                color: white,
                                                                fontSize:
                                                                    13.sp),
                                                            child: Wrap(
                                                              crossAxisAlignment:
                                                                  WrapCrossAlignment
                                                                      .center,
                                                              children: [
                                                                Text(
                                                                  "${AppLocalizations.of(context)!.sent}  ",
                                                                  maxLines: 2,
                                                                ),
                                                                Baseline(
                                                                  baseline:
                                                                      20.h,
                                                                  baselineType:
                                                                      TextBaseline
                                                                          .alphabetic,
                                                                  child: SvgPicture.asset(
                                                                      "assets/images/Food Filter_OBJECTS_458_13901.svg",
                                                                      height:
                                                                          18.h),
                                                                ),
                                                                const Text(
                                                                  "  à  ",
                                                                  maxLines: 2,
                                                                ),
                                                                Text(
                                                                  " ${clients[index]['sentTo']}",
                                                                  style: Theme.of(
                                                                          context)
                                                                      .textTheme
                                                                      .titleSmall!
                                                                      .copyWith(
                                                                          fontWeight: FontWeight
                                                                              .w700,
                                                                          color:
                                                                              primaryColor),
                                                                  maxLines: 2,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10.w,
                                      ),
                                      Text(
                                        isClients
                                            ? formatTimeDifference(
                                                clients[index]['sentOn']
                                                    .toDate())
                                            : formatTimeDifference(
                                                nearbyRestaurants[index]
                                                        ['lastUpdated']!
                                                    .toDate()),
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Recoleta",
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12.sp),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

String formatTimeDifference(DateTime lastUpdated) {
  final DateTime now = DateTime.now();
  final Duration difference = now.difference(lastUpdated);

  if (difference.inMinutes < 1) {
    return 'just now';
  } else if (difference.inHours < 1) {
    final minutes = difference.inMinutes;
    return '$minutes m';
  } else if (difference.inDays < 1) {
    final hours = difference.inHours;
    return '$hours h';
  } else {
    final days = difference.inDays;
    return '$days d';
  }
}

String pickImage(String giftType) {
  String rewardImg = '';
  if (giftType == AppConstants.giftItems[GiftItems.coconut]) {
    rewardImg = "assets/images/Food Filter_OBJECTS_458_13901.svg";
  } else if (giftType == AppConstants.giftItems[GiftItems.burger]) {
    rewardImg = "assets/images/Send Gifts_burger 1_346_10807.png";
  } else if (giftType == AppConstants.giftItems[GiftItems.pizza]) {
    rewardImg = "assets/images/send_pizza.png";
  } else if (giftType == AppConstants.giftItems[GiftItems.float]) {
    rewardImg = "assets/images/Send Gifts_float 1_352_11143.png";
  } else if (giftType == AppConstants.giftItems[GiftItems.buritto]) {
    rewardImg = "assets/images/Send Gifts_buritto 1_352_11140.png";
  } else {
    rewardImg = "assets/images/Send Gifts_ice cream 1_352_11144.png";
  }
  return rewardImg;
}
