// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:paraiso/controllers/customer_controller.dart';
// import 'package:paraiso/screens/user_profile.dart';
// import 'package:paraiso/widgets/home_chips_row.dart';
// import 'package:paraiso/widgets/nav_bottom_bar.dart';
// import 'package:provider/provider.dart';

// import '../controllers/bottom_navbar_controller.dart';
// import '../repositories/customer_auth_repo.dart';
// import '../routes/routes_constants.dart';
// import '../util/local_storage/shared_preferences_helper.dart';
// import '../util/theme/theme_constants.dart';
// import '../widgets/app_bar_custom.dart';
// import 'myCart_Screen.dart';
// import 'myOrders_Screen.dart';

// class ScaffoldWithNav extends StatefulWidget {
//   final Widget child;

//   const ScaffoldWithNav({Key? key, required this.child}) : super(key: key);

//   @override
//   State<ScaffoldWithNav> createState() => _ScaffoldWithNavState();
// }

// class _ScaffoldWithNavState extends State<ScaffoldWithNav> {
//   final GlobalKey<ScaffoldState> _customerScaffoldKey =
//       GlobalKey<ScaffoldState>();

//   String photo = '';
//   // late UserProfileProvider userProfileProvider;

//   Future<void> getCurrentUser() async {
//     final user = await CustomerAuthRep().getCurrentUserFromFirebase();
//     setState(() {
//       photo = user['photo'] ?? "";
//     });
//   }

//   @override
//   void didChangeDependencies() async {
//     // userProfileProvider = Provider.of<UserProfileProvider>(context);
//     // await userProfileProvider.getCurrentUserFromFirebase();
//     print('SharedPreferencesHelper.getCustomerType()');
//     print(SharedPreferencesHelper.getCustomerType());
//     if (SharedPreferencesHelper.getCustomerType() == 'guest') {
//       print(1111111111111111168);
//       await getCurrentUser();
//     }
//     // SharedPreferencesHelper.getCustomerType() == 'guest'
//     //     ? null
//     //     : ;
//     super.didChangeDependencies();
//   }

//   @override
//   void initState() {
//     super.initState();
//     // put any controllers inside scaffold with nav that need
//     // to be accessed cross routes
//     SharedPreferencesHelper.getCustomerType() == 'guest'
//         ? null
//         : getCurrentUser();
//     HomeChipsController myHomeChipsController = Get.put(HomeChipsController());
//   }

//   void _closeDrawer() {
//     _customerScaffoldKey.currentState!.openEndDrawer();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final customerController = Provider.of<CustomerController>(context);
//     final bottomNavBarNotifier =
//         Provider.of<BottomNavBarNotifier>(context, listen: false);
//     return Scaffold(
//       key: _customerScaffoldKey,
//       drawer: Drawer(
//         width: 250.w,
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               duration: const Duration(seconds: 1),
//               child: Center(
//                 child: CircleAvatar(
//                   radius: 100.r,
//                   backgroundColor: softBlack,
//                   backgroundImage: customerController.user['photo'] != "" &&
//                           customerController.user['photo'] != null
//                       ? NetworkImage(customerController.user['photo'])
//                       : const NetworkImage(
//                           "https://beforeigosolutions.com/wp-content/uploads/2021/12/dummy-profile-pic-300x300-1.png"),
//                 ),
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.person, color: Colors.white),
//               title: Text(
//                 AppLocalizations.of(context)!.profile,
//               ),
//               onTap: () {
//                 _closeDrawer();
//                 SharedPreferencesHelper.getCustomerType() != 'guest'
//                     ? Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => const UserProfile()))
//                     : context.push(AppRouteConstants.loginRoute);
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.shopping_cart, color: Colors.white),
//               title: Text(
//                 AppLocalizations.of(context)!.cart,
//               ),
//               onTap: () {
//                 _closeDrawer();
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const CartScreen()));
//               },
//             ),
//             ListTile(
//               leading: const Icon(Icons.shopping_bag, color: Colors.white),
//               title: Text(
//                 AppLocalizations.of(context)!.orders,
//               ),
//               onTap: () {
//                 _closeDrawer();
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => const MyOrdersScreen()));
//               },
//             ),
//             SharedPreferencesHelper.getCustomerType() == 'guest'
//                 ? SizedBox()
//                 : ListTile(
//                     leading:
//                         const Icon(Icons.logout_outlined, color: Colors.white),
//                     title: Text(
//                       AppLocalizations.of(context)!.signOut,
//                     ),
//                     onTap: () async {
//                       _closeDrawer();
//                       bottomNavBarNotifier.updateSelectedIndex(0);
//                       await SharedPreferencesHelper.deleteCustomerEmail();
//                       await CustomerAuthRep().signOut();
//                       if (mounted) {
//                         context
//                             .pushReplacement(AppRouteConstants.getStartedRoute);
//                       }
//                     },
//                   ),
//             SharedPreferencesHelper.getCustomerType() == 'guest'
//                 ? 340.verticalSpace
//                 : 300.verticalSpace,
//             ListTile(
//               title: const Text(
//                 "Contactez-nous: 06.47.47.13.64",
//               ),
//               onTap: () async {
//                 _closeDrawer();
//                 bottomNavBarNotifier.updateSelectedIndex(0);
//                 await SharedPreferencesHelper.deleteCustomerEmail();
//                 await CustomerAuthRep().signOut();
//                 if (mounted) {
//                   context.pushReplacement(AppRouteConstants.getStartedRoute);
//                 }
//               },
//             ),
//           ],
//         ),
//       ),
//       appBar: AppBarCustom(
//         scaffoldKey: _customerScaffoldKey,
//         photo: customerController.user['photo'] ??
//             "https://t3.ftcdn.net/jpg/05/16/27/58/240_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg",
//       ),
//       extendBodyBehindAppBar: true,
//       extendBody: true,
//       body: widget.child,
//       bottomNavigationBar: const BottomNavBar(),
//     );
//   }
// }

// class CustomAppBarDelegate extends SliverPersistentHeaderDelegate {
//   final double minHeight;
//   final double maxHeight;
//   final Widget child;

//   CustomAppBarDelegate({
//     required this.minHeight,
//     required this.maxHeight,
//     required this.child,
//   });

//   @override
//   double get minExtent => minHeight;

//   @override
//   double get maxExtent => maxHeight;

//   @override
//   Widget build(
//       BuildContext context, double shrinkOffset, bool overlapsContent) {
//     return SizedBox.expand(child: child);
//   }

//   @override
//   bool shouldRebuild(CustomAppBarDelegate oldDelegate) {
//     return maxHeight != oldDelegate.maxHeight ||
//         minHeight != oldDelegate.minHeight ||
//         child != oldDelegate.child;
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/controllers/customer_controller.dart';
import 'package:paraiso/screens/camera_screen.dart';
import 'package:paraiso/screens/chatbot.dart';
import 'package:paraiso/screens/route_ordering_screen.dart';
import 'package:paraiso/screens/user_profile.dart';
import 'package:paraiso/widgets/home_chips_row.dart';
import 'package:paraiso/widgets/nav_bottom_bar.dart';
import 'package:provider/provider.dart';

import '../controllers/bottom_navbar_controller.dart';
import '../repositories/customer_auth_repo.dart';
import '../routes/routes_constants.dart';
import '../util/local_storage/shared_preferences_helper.dart';
import '../util/theme/theme_constants.dart';
import '../widgets/app_bar_custom.dart';
import 'myCart_Screen.dart';

class ScaffoldWithNav extends StatefulWidget {
  final Widget child;

  const ScaffoldWithNav({Key? key, required this.child}) : super(key: key);

  @override
  State<ScaffoldWithNav> createState() => _ScaffoldWithNavState();
}

class _ScaffoldWithNavState extends State<ScaffoldWithNav> {
  final GlobalKey<ScaffoldState> _customerScaffoldKey =
      GlobalKey<ScaffoldState>();

  String photo = '';
  // late UserProfileProvider userProfileProvider;

  Future<void> getCurrentUser() async {
    final user = await CustomerAuthRep().getCurrentUserFromFirebase();
    setState(() {
      photo = user['photo'] ?? "";
    });
  }

  @override
  void didChangeDependencies() async {
    // userProfileProvider = Provider.of<UserProfileProvider>(context);
    // await userProfileProvider.getCurrentUserFromFirebase();
    print('SharedPreferencesHelper.getCustomerType()');
    print(SharedPreferencesHelper.getCustomerType());
    if (SharedPreferencesHelper.getCustomerType() == 'guest') {
      print(1111111111111111111);
      await getCurrentUser();
    }
    // SharedPreferencesHelper.getCustomerType() == 'guest'
    //     ? null
    //     : ;
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    // put any controllers inside scaffold with nav that need
    // to be accessed cross routes
    SharedPreferencesHelper.getCustomerType() == 'guest'
        ? null
        : getCurrentUser();
    HomeChipsController myHomeChipsController = Get.put(HomeChipsController());
  }

  void _closeDrawer() {
    _customerScaffoldKey.currentState!.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final customerController = Provider.of<CustomerController>(context);
    final bottomNavBarNotifier =
        Provider.of<BottomNavBarNotifier>(context, listen: false);
    return Scaffold(
      key: _customerScaffoldKey,
      drawer: Drawer(
        width: 250.w,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              duration: const Duration(seconds: 1),
              child: Center(
                child: CircleAvatar(
                  radius: 100.r,
                  backgroundColor: softBlack,
                  backgroundImage: customerController.user['photo'] != "" &&
                          customerController.user['photo'] != null
                      ? NetworkImage(customerController.user['photo'])
                      : const NetworkImage(
                          "https://beforeigosolutions.com/wp-content/uploads/2021/12/dummy-profile-pic-300x300-1.png"),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person, color: Colors.white),
              title: Text(
                AppLocalizations.of(context)!.profile,
              ),
              onTap: () {
                _closeDrawer();
                SharedPreferencesHelper.getCustomerType() != 'guest'
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const UserProfile()))
                    : context.push(AppRouteConstants.loginRoute);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart, color: Colors.white),
              title: Text(
                AppLocalizations.of(context)!.cart,
              ),
              onTap: () {
                _closeDrawer();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CartScreen()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.shopping_bag, color: Colors.white),
              title: Text(
                AppLocalizations.of(context)!.orders,
              ),
              onTap: () {
                _closeDrawer();
              },
            ),
            SharedPreferencesHelper.getCustomerType() == 'guest'
                ? SizedBox()
                : ListTile(
                    leading:
                        const Icon(Icons.logout_outlined, color: Colors.white),
                    title: Text(
                      AppLocalizations.of(context)!.signOut,
                    ),
                    onTap: () async {
                      _closeDrawer();
                      bottomNavBarNotifier.updateSelectedIndex(0);
                      await SharedPreferencesHelper.deleteCustomerEmail();
                      await CustomerAuthRep().signOut();
                      if (mounted) {
                        context
                            .pushReplacement(AppRouteConstants.getStartedRoute);
                      }
                    },
                  ),
            SharedPreferencesHelper.getCustomerType() == 'guest'
                ? 340.verticalSpace
                : 300.verticalSpace,
            ListTile(
              title: const Text(
                "Contactez-nous: 06.47.47.13.64",
              ),
              onTap: () async {
                _closeDrawer();
                bottomNavBarNotifier.updateSelectedIndex(0);
                await SharedPreferencesHelper.deleteCustomerEmail();
                await CustomerAuthRep().signOut();
                if (mounted) {
                  context.pushReplacement(AppRouteConstants.getStartedRoute);
                }
              },
            ),
          ],
        ),
      ),
      appBar: AppBarCustom(
        scaffoldKey: _customerScaffoldKey,
        photo: customerController.user['photo'] ??
            "https://t3.ftcdn.net/jpg/05/16/27/58/240_F_516275801_f3Fsp17x6HQK0xQgDQEELoTuERO4SsWV.jpg",
      ),
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: widget.child,
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min, // Adjust height dynamically
        children: [
          FloatingActionButton(
            heroTag: "location ", // Unique heroTag for each FAB
            onPressed: () {
              // Add camera navigation logic
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      RouteOrderingModule(), // Replace with your screen
                ),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.route_outlined),
          ),
          SizedBox(height: 16.h), // Space between the two buttons
          FloatingActionButton(
            heroTag: "chat_icon_button", // Unique heroTag for each FAB
            onPressed: () {
              // Add navigation logic
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      FoodChatbot(), // Replace with your screen
                ),
              );
            },
            backgroundColor: Colors.blue,
            child: const Icon(Icons.chat),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

class CustomAppBarDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  CustomAppBarDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(CustomAppBarDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}
