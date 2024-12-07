import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paraiso/controllers/Restaurants/orders_controller.dart';
import 'package:paraiso/models/order_model.dart';
import 'package:provider/provider.dart';

import '../../../controllers/Restaurants/res_auth_controller.dart';
import '../../../util/app_constants.dart';
import '../../../widgets/restaurant_tile.dart';
import '../../custom_drawer.dart';

class ROrderView extends StatefulWidget {
  const ROrderView({Key? key}) : super(key: key);

  @override
  State<ROrderView> createState() => _ROrderViewState();
}

class _ROrderViewState extends State<ROrderView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late OrdersController _ordersController;
  late AuthController _authController;

  @override
  void didChangeDependencies() async {
    _authController = Provider.of<AuthController>(context, listen: false);
    _ordersController = Provider.of<OrdersController>(context, listen: false);
    await _ordersController.fetchOrders(_authController.user!);
    super.didChangeDependencies();
  }

  String inProgress = 'Today';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(scaffoldKey: _scaffoldKey),
      body: Consumer<OrdersController>(
        builder: (context, value, child) {
          final orders = value.orders
              .where((order) =>
                  order.status !=
                  AppConstants.orderStatuses[OrderStatus.declined])
              .toList();

          final List<OrderModel> fulfilledOrders = orders
              .where((order) =>
                  order.status ==
                  AppConstants.orderStatuses[OrderStatus.fulfilled])
              .toList();
          final List<OrderModel> inProgressOrders = orders
              .where((order) =>
                  order.status ==
                  AppConstants.orderStatuses[OrderStatus.inProgress])
              .toList();
          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                              _authController.user!.logo,
                              fit: BoxFit.cover,
                            )),
                          ),
                        ),
                        Expanded(
                          child: Image.asset(
                            'assets/images/paraiso_logo.png',
                            height: 35.h,
                            width: 35.w,
                          ),
                        ),
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
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.inProgress,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 23.sp),
                      ),
                      // DropdownButton(
                      //     items: ['Today', 'Weekly', 'Monthly']
                      //         .map((e) => DropdownMenuItem(
                      //               value: e,
                      //               child: Text(e),
                      //             ))
                      //         .toList(),
                      //     value: inProgress,
                      //     style: TextStyle(
                      //         fontSize: 12.sp, fontWeight: FontWeight.w400),
                      //     icon: Icon(
                      //       Icons.keyboard_arrow_down,
                      //       size: 20.sp,
                      //     ),
                      //     padding: EdgeInsets.zero,
                      //     underline: Container(),
                      //     onChanged: (val) {
                      //       setState(() {
                      //         inProgress = val!;
                      //       });
                      //     })
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  SizedBox(
                    height: 280.h,
                    child: inProgressOrders.isEmpty
                        ? Center(
                            child:
                                Text(AppLocalizations.of(context)!.noOrdersYet))
                        : RefreshIndicator(
                            onRefresh: () async {
                              await _ordersController
                                  .fetchOrders(_authController.user!);
                            },
                            child: ListView.builder(
                                itemCount: inProgressOrders.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  final itemText = inProgressOrders[index]
                                      .items
                                      .map((item) =>
                                          '${item['quantity']} ${item['name']}')
                                      .join(', ');
                                  final addOnsText =
                                      inProgressOrders[index].items.map((item) {
                                    if (item['addOns'] != null &&
                                        item['addOns'].isNotEmpty) {
                                      // final addOnNames = item['addOns']
                                      //     .map((addOn) => "${addOn['name']}")
                                      //     .join(', ');

                                      final addOnNames = "";

                                      return addOnNames;
                                    } else {
                                      return "";
                                    }
                                  }).join('');

                                  final List<
                                      String> itemTextPopUp = inProgressOrders[
                                          index]
                                      .items
                                      .map((item) =>
                                          '${item['quantity']} ${item['name']}')
                                      .toList();

                                  return GestureDetector(
                                    onTap: () {
                                      openOrderRequest(
                                        inProgressOrders[index],
                                        inProgressOrders[index].userName,
                                        inProgressOrders[index].photo,
                                        inProgressOrders[index].orderId,
                                        itemTextPopUp,
                                        _authController,
                                        value,
                                        true,
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 12.h),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.w, vertical: 18.h),
                                      decoration: BoxDecoration(
                                        color: Color.fromRGBO(160, 193, 184, 1),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                        border: Border.all(
                                            color: Color.fromRGBO(
                                                243, 238, 221, 1),
                                            width: 1.w),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 40.r,
                                                  backgroundColor:
                                                      Colors.white54,
                                                  backgroundImage: NetworkImage(
                                                      inProgressOrders[index]
                                                          .photo),
                                                ),
                                                SizedBox(
                                                  width: 15.w,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        inProgressOrders[index]
                                                            .userName,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 16.sp),
                                                      ),
                                                      SizedBox(
                                                        height: 5.h,
                                                      ),
                                                      Text(
                                                        itemText,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Colors.black,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 13.sp),
                                                      ),
                                                      5.verticalSpace,
                                                      Wrap(
                                                        children: [
                                                          Text(
                                                            "${AppLocalizations.of(context)!.pickup}: ",
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize:
                                                                    13.sp),
                                                          ),
                                                          Text(
                                                            inProgressOrders[
                                                                    index]
                                                                .time,
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize:
                                                                    13.sp),
                                                          ),
                                                        ],
                                                      ),
                                                      // addOnsText == ""
                                                      //     ? const SizedBox
                                                      //         .shrink()
                                                      //     : Wrap(
                                                      //         children: [
                                                      //           5.verticalSpace,
                                                      //           Text(
                                                      //             "${AppLocalizations.of(context)!.addons}: ",
                                                      //             maxLines: 2,
                                                      //             style: TextStyle(
                                                      //                 color: Colors
                                                      //                     .white,
                                                      //                 fontWeight:
                                                      //                     FontWeight
                                                      //                         .w600,
                                                      //                 fontSize:
                                                      //                     13.sp),
                                                      //           ),
                                                      //           Text(
                                                      //             addOnsText,
                                                      //             maxLines: 2,
                                                      //             style: TextStyle(
                                                      //                 color: Colors
                                                      //                     .black,
                                                      //                 fontWeight:
                                                      //                     FontWeight
                                                      //                         .w400,
                                                      //                 fontSize:
                                                      //                     13.sp),
                                                      //           ),
                                                      //         ],
                                                      //       ),
                                                      // inProgressOrders[index]
                                                      //             .instructions ==
                                                      //         ""
                                                      //     ? const SizedBox
                                                      //         .shrink()
                                                      //     : Wrap(
                                                      //         children: [
                                                      //           5.verticalSpace,
                                                      //           Text(
                                                      //             "${AppLocalizations.of(context)!.instructions}: ",
                                                      //             maxLines: 3,
                                                      //             overflow:
                                                      //                 TextOverflow
                                                      //                     .ellipsis,
                                                      //             style: TextStyle(
                                                      //                 color: Colors
                                                      //                     .black,
                                                      //                 fontWeight:
                                                      //                     FontWeight
                                                      //                         .w600,
                                                      //                 fontSize:
                                                      //                     13.sp),
                                                      //           ),
                                                      //           // Text(
                                                      //           //   inProgressOrders[
                                                      //           //           index]
                                                      //           //       .instructions,
                                                      //           //   maxLines: 3,
                                                      //           //   overflow:
                                                      //           //       TextOverflow
                                                      //           //           .ellipsis,
                                                      //           //   style: TextStyle(
                                                      //           //       color: Colors
                                                      //           //           .white,
                                                      //           //       fontWeight:
                                                      //           //           FontWeight
                                                      //           //               .w400,
                                                      //           //       fontSize:
                                                      //           //           13.sp),
                                                      //           // ),
                                                      //         ],
                                                      //       ),
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
                                            formatTimeDifference(
                                                inProgressOrders[index]
                                                    .timestamp
                                                    .toDate()),
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.fulfilled,
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 23.sp),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  SizedBox(
                    height: 280.h,
                    child: fulfilledOrders.isEmpty
                        ? Center(
                            child:
                                Text(AppLocalizations.of(context)!.noOrdersYet))
                        : RefreshIndicator(
                            onRefresh: () async {
                              await _ordersController
                                  .fetchOrders(_authController.user!);
                            },
                            child: ListView.builder(
                                itemCount: fulfilledOrders.length,
                                shrinkWrap: true,
                                padding: EdgeInsets.zero,
                                itemBuilder: (context, index) {
                                  final itemText = fulfilledOrders[index]
                                      .items
                                      .map((item) =>
                                          '${item['quantity']} ${item['name']}')
                                      .join(', ');
                                  // final addOnsText =
                                  //     fulfilledOrders[index].items.map((item) {
                                  //   if (item['addOns'] != null &&
                                  //       item['addOns'].isNotEmpty) {
                                  //     final addOnNames = item['addOns']
                                  //         .map((addOn) => "${addOn['name']}")
                                  //         .join(', ');
                                  //
                                  //     return addOnNames;
                                  //   } else {
                                  //     return "";
                                  //   }
                                  // }).join('');

                                  // final List<String> itemTextPopUp =
                                  //     fulfilledOrders[index]
                                  //         .items
                                  //         .map((item) =>
                                  //             '${item['quantity']} ${item['name']}')
                                  //         .toList();

                                  return GestureDetector(
                                    onTap: () {
                                      // openOrderRequest(
                                      //   fulfilledOrders[index].userName,
                                      //   fulfilledOrders[index].photo,
                                      //   fulfilledOrders[index].orderId,
                                      //   itemTextPopUp,
                                      //   _authController,
                                      //   value,
                                      //   true,
                                      // );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 12.h),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 15.w, vertical: 18.h),
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            210, 118, 133, 1),
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                        border: Border.all(
                                            color: const Color.fromRGBO(
                                                243, 238, 221, 1),
                                            width: 1.w),
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                CircleAvatar(
                                                  radius: 40.r,
                                                  backgroundColor:
                                                      Colors.white54,
                                                  backgroundImage: NetworkImage(
                                                      fulfilledOrders[index]
                                                          .photo),
                                                ),
                                                SizedBox(
                                                  width: 15.w,
                                                ),
                                                Expanded(
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        fulfilledOrders[index]
                                                            .userName,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w700,
                                                            fontSize: 16.sp),
                                                      ),
                                                      SizedBox(
                                                        height: 5.h,
                                                      ),
                                                      Text(
                                                        itemText,
                                                        maxLines: 2,
                                                        style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 13.sp),
                                                      ),
                                                      5.verticalSpace,
                                                      Wrap(
                                                        children: [
                                                          Text(
                                                            "${AppLocalizations.of(context)!.pickup}: ",
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize:
                                                                    13.sp),
                                                          ),
                                                          Text(
                                                            fulfilledOrders[
                                                                    index]
                                                                .time,
                                                            maxLines: 2,
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize:
                                                                    13.sp),
                                                          ),
                                                        ],
                                                      ),
                                                      // addOnsText == ""
                                                      //     ? const SizedBox.shrink()
                                                      //     : Wrap(
                                                      //         children: [
                                                      //           5.verticalSpace,
                                                      //           Text(
                                                      //             "${AppLocalizations.of(context)!.addons}: ",
                                                      //             maxLines: 2,
                                                      //             style: TextStyle(
                                                      //                 color: Colors
                                                      //                     .white,
                                                      //                 fontWeight:
                                                      //                     FontWeight
                                                      //                         .w600,
                                                      //                 fontSize:
                                                      //                     13.sp),
                                                      //           ),
                                                      //           Text(
                                                      //             addOnsText,
                                                      //             maxLines: 2,
                                                      //             style: TextStyle(
                                                      //                 color: Colors
                                                      //                     .white,
                                                      //                 fontWeight:
                                                      //                     FontWeight
                                                      //                         .w400,
                                                      //                 fontSize:
                                                      //                     13.sp),
                                                      //           ),
                                                      //         ],
                                                      //       ),
                                                      // fulfilledOrders[index]
                                                      //             .instructions ==
                                                      //         ""
                                                      //     ? const SizedBox.shrink()
                                                      //     : Wrap(
                                                      //         children: [
                                                      //           5.verticalSpace,
                                                      //           Text(
                                                      //             "${AppLocalizations.of(context)!.instructions}: ",
                                                      //             maxLines: 3,
                                                      //             overflow:
                                                      //                 TextOverflow
                                                      //                     .ellipsis,
                                                      //             style: TextStyle(
                                                      //                 color: Colors
                                                      //                     .white,
                                                      //                 fontWeight:
                                                      //                     FontWeight
                                                      //                         .w600,
                                                      //                 fontSize:
                                                      //                     13.sp),
                                                      //           ),
                                                      //           Text(
                                                      //             fulfilledOrders[
                                                      //                     index]
                                                      //                 .instructions,
                                                      //             maxLines: 3,
                                                      //             overflow:
                                                      //                 TextOverflow
                                                      //                     .ellipsis,
                                                      //             style: TextStyle(
                                                      //                 color: Colors
                                                      //                     .white,
                                                      //                 fontWeight:
                                                      //                     FontWeight
                                                      //                         .w400,
                                                      //                 fontSize:
                                                      //                     13.sp),
                                                      //           ),
                                                      //         ],
                                                      //       ),
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
                                            formatTimeDifference(
                                                fulfilledOrders[index]
                                                    .timestamp
                                                    .toDate()),
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 12.sp),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  openOrderRequest(
    dynamic allData,
    String username,
    String photo,
    String orderId,
    List<String> items,
    AuthController authController,
    OrdersController ordersController,
    bool inProgress,
  ) {
    showDialog(
        context: context,
        builder: (context) {
          return Wrap(
            runAlignment: WrapAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 60.w),
                    padding: EdgeInsets.only(
                        top: 50.h, bottom: 20.h, left: 12.w, right: 12.w),
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(53, 53, 53, 1),
                        borderRadius: BorderRadius.circular(12.r)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(username,
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 25.sp,
                                    color: Colors.grey.shade400)),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10.h, horizontal: 10.h),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color.fromRGBO(30, 30, 30, 1),
                                width: 1.0,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            height: items.length <= 3
                                ? items.length * 100.h
                                : 150.h,
                            // width: 150.w,
                            child: ListView.builder(
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                dynamic parsedData =
                                    allData.items[index]['addOns'];

                                List<String> itemAddons = [];

                                print("Parsed Data: $parsedData");

                                if (parsedData.isNotEmpty &&
                                    parsedData != null) {
                                  parsedData.forEach((key, value) {
                                    value.forEach((item) {
                                      itemAddons.add(
                                          "${item['qty']} ${item['name']}");
                                    });
                                  });
                                }

                                return Container(
                                  child: Column(children: [
                                    Row(
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            color: const Color.fromRGBO(
                                                243, 238, 221, 1),
                                            borderRadius:
                                                BorderRadius.circular(10.r),
                                          ),
                                          margin: EdgeInsets.symmetric(
                                              horizontal: 5.w, vertical: 2.h),
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5.w, vertical: 6.h),
                                          child: SizedBox(
                                            width: 80.w,
                                            child: Text(
                                              items[index],
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 12.sp,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                        10.horizontalSpace,
                                        SizedBox(
                                          width: 150.w,
                                          child: Wrap(
                                            direction: Axis.horizontal,
                                            alignment: WrapAlignment.start,
                                            spacing: 5.w,
                                            runSpacing: 5.w,
                                            children: List.generate(
                                                itemAddons.length, (index1) {
                                              return GestureDetector(
                                                behavior:
                                                    HitTestBehavior.translucent,
                                                onTap: () {
                                                  var data = allData
                                                      .items[index]['addOns'];
                                                  print(data);
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 5.w),
                                                  child:
                                                      Text(itemAddons[index1]),
                                                ),
                                              );
                                            }),
                                          ),
                                        )
                                      ],
                                    ),
                                    if (items.length - 1 != index)
                                      Divider(
                                        color: Colors.grey.shade400,
                                        thickness: 1,
                                      )
                                  ]),
                                );
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 5.h),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 10.h),
                                    decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            255, 97, 84, 1),
                                        borderRadius:
                                            BorderRadius.circular(8.r)),
                                    child: Center(
                                      child: Text(items[index],
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 13.sp,
                                              color: Colors.white)),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        20.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  "Heure de collecte: ",
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16.sp),
                                ),
                                Text(
                                  allData.time,
                                  maxLines: 2,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w400,
                                      fontSize: 15.sp),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 20.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            MaterialButton(
                              onPressed: () async {
                                await ordersController.updateOrderStatus(
                                    orderId,
                                    AppConstants
                                        .orderStatuses[OrderStatus.declined]!);
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                                ordersController
                                    .fetchOrders(authController.user!);
                              },
                              height: 30.h,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              color: Colors.grey.shade700,
                              child: Text(AppLocalizations.of(context)!.decline,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.sp,
                                      color: Colors.grey.shade400)),
                            ),
                            SizedBox(
                              width: 10.w,
                            ),
                            MaterialButton(
                              onPressed: () {
                                inProgress
                                    ? ordersController.updateOrderStatus(
                                        orderId,
                                        AppConstants.orderStatuses[
                                            OrderStatus.fulfilled]!)
                                    : ordersController.updateOrderStatus(
                                        orderId,
                                        AppConstants.orderStatuses[
                                            OrderStatus.inProgress]!);
                                Navigator.pop(context);
                                ordersController
                                    .fetchOrders(authController.user!);
                              },
                              height: 30.h,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.r),
                              ),
                              color: const Color(0xFF2F58CD),
                              child: Text(
                                  inProgress
                                      ? AppLocalizations.of(context)!.fulfilled
                                      : AppLocalizations.of(context)!.accept,
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.sp,
                                      color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -40.h,
                    child: CircleAvatar(
                      radius: 40.r,
                      backgroundColor: Colors.white54,
                      backgroundImage: NetworkImage(photo),
                    ),
                  ),
                ],
              )
            ],
          );
        });
  }
}
