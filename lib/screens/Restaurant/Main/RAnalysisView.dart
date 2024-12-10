import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:paraiso/controllers/Restaurants/orders_controller.dart';
import 'package:provider/provider.dart';

import '../../../controllers/Restaurants/clients_controller.dart';
import '../../../controllers/Restaurants/clients_count_provider.dart';
import '../../../controllers/Restaurants/menu_controller.dart';
import '../../../controllers/Restaurants/res_auth_controller.dart';
import '../../../repositories/res_post_repo.dart';
import '../../custom_drawer.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RAnalysisView extends StatefulWidget {
  const RAnalysisView({Key? key}) : super(key: key);

  @override
  State<RAnalysisView> createState() => _RAnalysisViewState();
}

class _RAnalysisViewState extends State<RAnalysisView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String inProgress = "Tout";

  late OrdersController _ordersController;
  late AuthController _authController;
  late ClientsController _clientsController;
  late ClientCountProvider _clientsCountProvider;
  late MenuItemsController _menuController;
  

  @override
  void didChangeDependencies() async {
    _authController = Provider.of<AuthController>(context, listen: false);
    _ordersController = Provider.of<OrdersController>(context, listen: false);
    _clientsController = Provider.of<ClientsController>(context, listen: false);
    _menuController = Provider.of<MenuItemsController>(context, listen: false);
    _clientsCountProvider = Provider.of<ClientCountProvider>(context, listen: false);
    await _ordersController.fetchOrders(_authController.user!);
    await _ordersController.calculateTotalSales(_authController.user!);
    await _clientsController.fetchTopSchools();
    await _clientsController.fetchTopCustomers(_authController.user!.userId);
    await _menuController.getItemWithTopMostDiscount();
    await _clientsCountProvider.fetchClientsCount(_authController.user!.userId);
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    // inProgress = AppLocalizations.of(context)!.today;
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(scaffoldKey: _scaffoldKey),
      body: Consumer<OrdersController>(
        builder: (context, ordersC, child) {

          int totalOrders=ordersC.orders.length;
          double totalSales=ordersC.totalSales;

          if(inProgress == AppLocalizations.of(context)!.today) {
            totalOrders = ordersC.todayOrdersLength ;
            totalSales = ordersC.todaySales;
          }
          else if(inProgress == AppLocalizations.of(context)!.weekly) {
            totalOrders = ordersC.weeklyOrdersLength ;
            totalSales = ordersC.weeklySales;
          }
          else if(inProgress == AppLocalizations.of(context)!.monthly) {
            totalOrders = ordersC.monthlyOrdersLength;
            totalSales = ordersC.monthlySales;
          }

          return Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: SingleChildScrollView(
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
                            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color.fromRGBO(53, 53, 53, 1), width: 2.w)),
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
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(53, 53, 53, 1), image: DecorationImage(image: AssetImage('assets/icons/notification.png'))),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.analysisTitle,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 23.sp),
                      ),
                      // DropdownButton(
                      //     // items: [AppLocalizations.of(context)!.all,AppLocalizations.of(context)!.today, AppLocalizations.of(context)!.weekly, AppLocalizations.of(context)!.monthly]
                      //     //     .map((e) => DropdownMenuItem(
                      //     //           value: e,
                      //     //           child: Text(e),
                      //     //         ))
                      //     //     .toList(),
                      //     items: ["Tout","Aujourd'hui", "Hebdomadaire", "Mensuel"]
                      //         .map((e) => DropdownMenuItem(
                      //       value: e,
                      //       child: Text(e),
                      //     ))
                      //         .toList(),
                      //     value: inProgress,
                      //     style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
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
                    height: 20.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _analysisBox(AppLocalizations.of(context)!.totalSalesLabel, '${totalSales.toStringAsFixed(1)}€'),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Expanded(
                        child: _analysisBox(AppLocalizations.of(context)!.totalOrdersLabel, totalOrders),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: _analysisBox(AppLocalizations.of(context)!.storeVisitsLabel, _clientsCountProvider.usersCount.toString()),
                      ),
                      SizedBox(
                        width: 20.w,
                      ),
                      Expanded(
                        child: _analysisBox(
                          AppLocalizations.of(context)!.averageBucketLabel,
                          ordersC.orders.isNotEmpty ? double.parse((totalSales / totalOrders).toString()).toStringAsFixed(2) : "0",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Row(
                    children: [
                      // Expanded(
                      //   child: _analysisBox(AppLocalizations.of(context)!.conversionsLabel, _clientsCountProvider.clientCount.toString()),
                      // ),
                      // SizedBox(
                      //   width: 20.w,
                      // ),
                      Expanded(
                        child: _analysisBox(AppLocalizations.of(context)!.newCustomerLabel, _clientsCountProvider.clientCount.toString()),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.topCustomersLabel,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 23.sp),
                      ),
                      Text(
                        AppLocalizations.of(context)!.seeAll,
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 16.sp),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 15.h,
                  ),
                  Consumer<ClientsController>(
                    builder: (context, value, child) {
                      return value.topCustomers.isEmpty
                          ? Text(AppLocalizations.of(context)!.noCustomerYet)
                          : SizedBox(
                              height: 130.h,
                              child: ListView.builder(
                                  itemCount: value.topCustomers.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    return Container(
                                      width: 120.w,
                                      margin: EdgeInsets.only(right: 10.w),
                                      decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(
                                              value.topCustomers[index]['photo'] != null && value.topCustomers[index]['photo'] != ""
                                                  ? value.topCustomers[index]['photo']
                                                  : "https://firebasestorage.googleapis.com/v0/b/paraiso-a6ec6.appspot.com/o/dummy_profile.png?alt=media&token=1d8ab187-9695-4450-a03c-a5dda90b7ece",
                                            ),
                                          ),
                                          borderRadius: BorderRadius.circular(20.r),
                                          color: Colors.white70),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                              padding: EdgeInsets.symmetric(vertical: 5.h),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20.r), bottomRight: Radius.circular(20.r)),
                                                color: Colors.black.withOpacity(0.3),
                                              ),
                                              child: Center(
                                                  child: Text(
                                                value.topCustomers[index]['userName'],
                                                style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700),
                                              ))),
                                        ],
                                      ),
                                    );
                                  }),
                            );
                    },
                  ),
                  SizedBox(
                    height: 25.h,
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     Text(
                  //       'Top Sellers',
                  //       style: TextStyle(
                  //           color: Colors.white,
                  //           fontWeight: FontWeight.w700,
                  //           fontSize: 23.sp),
                  //     ),
                  //     Text(
                  //       'See All',
                  //       style: TextStyle(
                  //           color: Colors.white70,
                  //           fontWeight: FontWeight.w400,
                  //           fontSize: 16.sp),
                  //     ),
                  //   ],
                  // ),
                  // Consumer<TopSellersController>(
                  //   builder: (context, topSellersC, child) {
                  //     return SizedBox(
                  //       height: topSellersC.topSellers.length > 1
                  //           ? 120.h * 2
                  //           : 120.h,
                  //       child: ListView.builder(
                  //         physics: const NeverScrollableScrollPhysics(),
                  //         itemCount: topSellersC.topSellers.length > 1
                  //             ? 2
                  //             : (topSellersC.topSellers.isNotEmpty ? 1 : 0),
                  //         itemBuilder: (context, index) {
                  //           return Container(
                  //             width: MediaQuery.of(context).size.width,
                  //             margin: EdgeInsets.only(bottom: 10.w),
                  //             padding: EdgeInsets.symmetric(
                  //                 vertical: 5.h, horizontal: 20.w),
                  //             decoration: BoxDecoration(
                  //               borderRadius: BorderRadius.circular(20.r),
                  //               color: const Color.fromRGBO(53, 53, 53, 1),
                  //             ),
                  //             child: Row(
                  //               children: [
                  //                 Container(
                  //                   height: 80.h,
                  //                   width: 80.w,
                  //                   decoration: BoxDecoration(
                  //                       shape: BoxShape.circle,
                  //                       border: Border.all(
                  //                           color: const Color.fromRGBO(
                  //                               53, 53, 53, 1),
                  //                           width: 2.w)),
                  //                   child: Image.network(
                  //                       topSellersC.topSellers[index]["logo"]),
                  //                 ),
                  //                 SizedBox(
                  //                   width: 20.w,
                  //                 ),
                  //                 Text(
                  //                   topSellersC.topSellers[index]["username"],
                  //                   style: TextStyle(
                  //                       color: Colors.white70,
                  //                       fontSize: 18.sp,
                  //                       fontWeight: FontWeight.w400),
                  //                 ),
                  //               ],
                  //             ),
                  //           );
                  //         },
                  //       ),
                  //     );
                  //   },
                  // ),
                  // SizedBox(
                  //   height: 30.h,
                  // ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.topSchoolsLabel,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 23.sp),
                      ),
                      Text(
                        AppLocalizations.of(context)!.seeAll,
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 16.sp),
                      ),
                    ],
                  ),
                  Consumer<ClientsController>(
                    builder: (context, value, child) {
                      return SizedBox(
                        height: value.topSchools.length > 1 ? 100.h * 2 : 100.h,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: value.topSchools.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: MediaQuery.of(context).size.width,
                              margin: EdgeInsets.only(bottom: 10.w),
                              padding: EdgeInsets.symmetric(vertical: 25.h),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20.r),
                                color: const Color.fromRGBO(53, 53, 53, 1),
                              ),
                              child: Center(
                                  child: Text(
                                value.topSchools[index],
                                style: TextStyle(color: Colors.white70, fontSize: 18.sp, fontWeight: FontWeight.w400),
                              )),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.topActionsLabel,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 23.sp),
                      ),
                      Text(
                        AppLocalizations.of(context)!.seeAll,
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w400, fontSize: 16.sp),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  Consumer<MenuItemsController>(
                    builder: (context, value, child) {
                      final discount = value.topMostDiscountItem['discount'];
                      final item = value.topMostDiscountItem['itemName'];
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        margin: EdgeInsets.only(bottom: 10.w),
                        padding: EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          color: const Color.fromRGBO(53, 53, 53, 1),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.discountOfferLabel,
                              style: TextStyle(color: Colors.white70, fontSize: 18.sp, fontWeight: FontWeight.w700),
                            ),
                            Text(
                              '$discount ${AppLocalizations.of(context)!.discountOn} $item',
                              style: TextStyle(color: Colors.white70, fontSize: 15.sp, fontWeight: FontWeight.w400),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  //TODO: FREE PRODUCT ACTION
                  // Container(
                  //   width: MediaQuery.of(context).size.width,
                  //   padding:
                  //       EdgeInsets.symmetric(vertical: 25.h, horizontal: 20.w),
                  //   decoration: BoxDecoration(
                  //     borderRadius: BorderRadius.circular(20.r),
                  //     color: const Color.fromRGBO(53, 53, 53, 1),
                  //   ),
                  //   child: Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         'Free Product',
                  //         style: TextStyle(
                  //             color: Colors.white70,
                  //             fontSize: 18.sp,
                  //             fontWeight: FontWeight.w700),
                  //       ),
                  //       Text(
                  //         'Order Midnight deal and get free Regular fries..',
                  //         style: TextStyle(
                  //             color: Colors.white70,
                  //             fontSize: 15.sp,
                  //             fontWeight: FontWeight.w400),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _analysisBox(txt1, txt2) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: Color(0xFFF3EEDD),
          width: 1.w,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$txt1',
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.sp, color: Colors.white70),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.h, bottom: 20.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('$txt2', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 25.sp, color: Colors.white)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
