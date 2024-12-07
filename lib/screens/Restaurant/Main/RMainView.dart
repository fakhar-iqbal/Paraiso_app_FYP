import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paraiso/controllers/Restaurants/clients_controller.dart';
import 'package:paraiso/screens/Restaurant/Main/RAnalysisView.dart';
import 'package:paraiso/screens/Restaurant/Main/RHomeView.dart';
import 'package:paraiso/screens/Restaurant/Main/RLiveView.dart';
import 'package:paraiso/screens/Restaurant/Main/ROrderView.dart';
import 'package:provider/provider.dart';

import '../../../controllers/Restaurants/clients_count_provider.dart';
import '../../../controllers/Restaurants/menu_controller.dart';
import '../../../controllers/Restaurants/nearby_restaurants_controller.dart';
import '../../../controllers/Restaurants/res_auth_controller.dart';

class RMainView extends StatefulWidget {
  const RMainView({Key? key}) : super(key: key);

  @override
  State<RMainView> createState() => _RMainViewState();
}

class _RMainViewState extends State<RMainView> {
  int _index = 0;
  final views = [const ROrderView(), const RHomeView(), const RLiveView(), const RAnalysisView()];

  late NearbyRestaurantsController _nearbyRestaurantsController;
  late ClientsController _clientsController;
  // late OrdersController _ordersController;
  late AuthController _authController;
  late ClientCountProvider _clientCountProvider;
  late MenuItemsController _menuItemsController;
  // late TopSellersController _topSellersController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _authController = Provider.of<AuthController>(context, listen: false);
    _nearbyRestaurantsController = Provider.of<NearbyRestaurantsController>(context, listen: false);
    _clientsController = Provider.of<ClientsController>(context, listen: false);
    // _ordersController = Provider.of<OrdersController>(context, listen: false);
    _clientCountProvider = Provider.of<ClientCountProvider>(context, listen: false);
    _menuItemsController = Provider.of<MenuItemsController>(context, listen: false);
    // _topSellersController =
    //     Provider.of<TopSellersController>(context, listen: false);

    if (_authController.user != null) {
      _nearbyRestaurantsController.fetchNearbyRestaurants(_authController.user!);
      // _nearbyRestaurantsController
      //     .fetchNearbyRestaurantsFromGMaps(_authController.user!);
      _clientsController.fetchClients(_authController.user!);
      // _ordersController.fetchOrders(_authController.user!);
      _clientCountProvider.fetchUserCount(_authController.user!.userId);
      _clientCountProvider.fetchClientsCount(_authController.user!.userId);
      _clientCountProvider.fetchUsersWithin1KM(_authController.user!);
      _menuItemsController.fetchMenu(_authController.user!.userId);
      // _topSellersController.fetchTopSellers();

      if (_nearbyRestaurantsController.nearbyRestaurantsList.length < 10) {
        _nearbyRestaurantsController.fetchAndSaveNearbyRestaurants(_authController.user!);
        _nearbyRestaurantsController.getRestaurantsWithDiscounts(_authController.user!);
      }
    }

    return Scaffold(
      body: views[_index],
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: 15.h, left: 30.w, right: 30.w),
        padding: EdgeInsets.symmetric(horizontal: 0.w, vertical: 25.h),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(53, 53, 53, 1),
          borderRadius: BorderRadius.circular(40.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _navigateToPage(0);
              },
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 40.w),
                child: Image.asset(
                  'assets/icons/order.png',
                  color: _index == 0 ? const Color(0xFF2F58CD) : Colors.white,
                ),
              ),
            ),
            // GestureDetector(
            //   onTap: () {
            //     _navigateToPage(1);
            //   },
            //   child: Image.asset(
            //     'assets/icons/orders.png',
            //     color: _index == 1 ? const Color(0xFF2F58CD) : Colors.white,
            //   ),
            // ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _navigateToPage(2);
              },
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 40.w),
                child: Image.asset(
                  'assets/icons/live.png',
                  color: _index == 2 ? const Color(0xFF2F58CD) : Colors.white,
                ),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                _navigateToPage(3);
              },
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 40.w),
                child: Image.asset(
                  'assets/icons/analysis.png',
                  color: _index == 3 ? const Color(0xFF2F58CD) : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToPage(int newIndex) {
    setState(() {
      _index = newIndex;
    });
  }
}
