// import 'package:flutter/material.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
// import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:paraiso/controllers/Restaurants/AddOnController.dart';
// import 'package:paraiso/controllers/cart_controller.dart';
// import 'package:paraiso/controllers/user_profile_provider.dart';
// import 'package:paraiso/routes/router.dart';
// import 'package:paraiso/setup.dart';
// import 'package:paraiso/util/theme/theme.dart';
// import 'package:provider/provider.dart';

// import 'controllers/Restaurants/clients_controller.dart';
// import 'controllers/Restaurants/clients_count_provider.dart';
// import 'controllers/Restaurants/image_provider.dart';
// import 'controllers/Restaurants/menu_controller.dart';
// import 'controllers/Restaurants/nearby_restaurants_controller.dart';
// import 'controllers/Restaurants/orders_controller.dart';
// import 'controllers/Restaurants/res_auth_controller.dart';
// import 'controllers/Restaurants/top_sellers_controller.dart';
// import 'controllers/bottom_navbar_controller.dart';
// import 'controllers/categories_controller.dart';
// import 'controllers/customer_controller.dart';
// import 'controllers/friends_controller.dart';
// import 'controllers/location_controller.dart';
// import 'controllers/profile_pic_controller.dart';
// import 'controllers/restaurants_with_discount_controller.dart';
// import 'controllers/rewards_controller.dart';
// import 'controllers/sort_by_distance_controller.dart';

// void main() async {
//   await initializePreConfig();
//   runApp(
//     const MyApp(),
//   );
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthController()),
//         ChangeNotifierProvider(create: (_) => CartNotifier()),
//         ChangeNotifierProvider(create: (_) => UserProfileProvider()),
//         ChangeNotifierProvider(create: (_) => NearbyRestaurantsController()),
//         ChangeNotifierProvider(create: (_) => ClientsController()),
//         ChangeNotifierProvider(create: (_) => BottomNavBarNotifier()),
//         ChangeNotifierProvider(create: (_) => OrdersController()),
//         ChangeNotifierProvider(create: (_) => ClientCountProvider()),
//         ChangeNotifierProvider(create: (_) => MenuItemsController()),
//         ChangeNotifierProvider(create: (_) => AddOnController()),
//         ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
//         ChangeNotifierProvider(create: (_) => TopSellersController()),
//         ChangeNotifierProvider(create: (_) => LocationProvider()),
//         ChangeNotifierProvider(create: (_) => RewardsController()),
//         ChangeNotifierProvider(create: (_) => FriendsController()),
//         ChangeNotifierProvider(create: (_) => ProfilePicController()),
//         ChangeNotifierProvider(create: (_) => CustomerController()),
//         ChangeNotifierProvider(create: (_) => SortByDistanceController()),
//         ChangeNotifierProvider(create: (_) => CategoriesProvider()),
//         ChangeNotifierProvider(
//             create: (_) => RestaurantsWithDiscountController()),
//       ],
//       child: MaterialApp.router(
//           title: 'paraiso',
//           locale: const Locale("en"),
//           debugShowCheckedModeBanner: false,
//           routerConfig: AppRouter.router,
//           localizationsDelegates: const [
//             AppLocalizations.delegate,
//             GlobalMaterialLocalizations.delegate,
//             GlobalWidgetsLocalizations.delegate,
//             GlobalCupertinoLocalizations.delegate,
//           ],
//           supportedLocales: const [
//             Locale("en"),
//             Locale("fr"),
//           ],
//           builder: (ctx, child) {
//             ScreenUtil.init(ctx,
//                 designSize: const Size(430, 932),
//                 minTextAdapt: true,
//                 splitScreenMode: true);
//             return Theme(
//               data: darkTheme,
//               child: child!,
//             );
//           }),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paraiso/controllers/Restaurants/AddOnController.dart';
import 'package:paraiso/controllers/cart_controller.dart';
import 'package:paraiso/controllers/user_profile_provider.dart';
import 'package:paraiso/routes/router.dart';
import 'package:paraiso/setup.dart';
import 'package:paraiso/util/theme/theme.dart';
import 'package:provider/provider.dart';

import 'controllers/Restaurants/clients_controller.dart';
import 'controllers/Restaurants/clients_count_provider.dart';
import 'controllers/Restaurants/image_provider.dart';
import 'controllers/Restaurants/menu_controller.dart';
import 'controllers/Restaurants/nearby_restaurants_controller.dart';
import 'controllers/Restaurants/orders_controller.dart';
import 'controllers/Restaurants/res_auth_controller.dart';
import 'controllers/bottom_navbar_controller.dart';
import 'controllers/categories_controller.dart';
import 'controllers/customer_controller.dart';
import 'controllers/friends_controller.dart';
import 'controllers/location_controller.dart';
import 'controllers/profile_pic_controller.dart';
import 'controllers/restaurants_with_discount_controller.dart';
import 'controllers/rewards_controller.dart';
import 'controllers/sort_by_distance_controller.dart';

void main() async {
  await initializePreConfig();
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Gemini with your API key
  await Gemini.init(apiKey: 'AIzaSyAL3pMvjx2SxQGlQIpyP86kMUNBVIfNxTU');
  
  runApp(
    const MyApp(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => CartNotifier()),
        ChangeNotifierProvider(create: (_) => UserProfileProvider()),
        ChangeNotifierProvider(create: (_) => NearbyRestaurantsController()),
        ChangeNotifierProvider(create: (_) => ClientsController()),
        ChangeNotifierProvider(create: (_) => BottomNavBarNotifier()),
        ChangeNotifierProvider(create: (_) => OrdersController()),
        ChangeNotifierProvider(create: (_) => ClientCountProvider()),
        ChangeNotifierProvider(create: (_) => MenuItemsController()),
        ChangeNotifierProvider(create: (_) => AddOnController()),
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        // ChangeNotifierProvider(create: (_) => TopSellersController()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => RewardsController()),
        ChangeNotifierProvider(create: (_) => FriendsController()),
        ChangeNotifierProvider(create: (_) => ProfilePicController()),
        ChangeNotifierProvider(create: (_) => CustomerController()),
        ChangeNotifierProvider(create: (_) => SortByDistanceController()),
        ChangeNotifierProvider(create: (_) => CategoriesProvider()),
        ChangeNotifierProvider(
            create: (_) => RestaurantsWithDiscountController()),
      ],
      child: MaterialApp.router(
          title: 'paraiso',
          locale: const Locale("en"),
          debugShowCheckedModeBanner: false,
          routerConfig: AppRouter.router,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale("en"),
            Locale("fr"),
          ],
          builder: (ctx, child) {
            ScreenUtil.init(ctx,
                designSize: const Size(430, 932),
                minTextAdapt: true,
                splitScreenMode: true);
            return Theme(
              data: darkTheme,
              child: child!,
            );
          }),
    );
  }
}
