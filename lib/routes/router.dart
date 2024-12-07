import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/routes/routes_constants.dart';
import 'package:paraiso/screens/create_profile_email.dart';
import 'package:paraiso/screens/create_profile_name.dart';
import 'package:paraiso/screens/create_profile_password.dart';
import 'package:paraiso/screens/create_profile_phone.dart';
import 'package:paraiso/screens/create_profile_school_name.dart';
import 'package:paraiso/screens/food_restaurants_tab.dart';
import 'package:paraiso/screens/friends_tab.dart';
import 'package:paraiso/screens/get_started_screen.dart';
import 'package:paraiso/screens/home_tab_view.dart';
import 'package:paraiso/screens/login_screen.dart';
import 'package:paraiso/screens/place_order.dart';
import 'package:paraiso/screens/restaurant_details_screen.dart';
import 'package:paraiso/screens/scaffold_with_nav.dart';
import 'package:paraiso/screens/settings_tab.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';

import '../screens/Restaurant/Main/RMainView.dart';
import '../screens/Restaurant/RSignInView.dart';

String getInitialLocation() {
  SharedPreferencesHelper.deleteUserSignupChoice();
  return SharedPreferencesHelper.getUserSignupChoice() == "restaurant"
      ? AppRouteConstants.restaurantLogin
      : (SharedPreferencesHelper.getUserSignupChoice() == "customer" ? AppRouteConstants.loginRoute : AppRouteConstants.getStartedRoute);
}

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> shellNavigatorKey = GlobalKey<NavigatorState>();

  static final GlobalKey<NavigatorState> thirdNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: getInitialLocation(),
    // initialLocation: AppRouteConstants.getStartedRoute,
    // wrap all in protected route where you can redefine the paid user login
    routes: [
      // "/" TOP LEVEL ROUTES MUST START WITH /, subroutes don't need /
      // define for / and redirect to /home/0
      GoRoute(
          path: "/",
          redirect: (BuildContext context, GoRouterState state) {
            return AppRouteConstants.homeRoute;
          }),

      ShellRoute(
        //subroute's navigator key must be same as the subroute's parent navigator
        //key or null
        navigatorKey: shellNavigatorKey,
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return ScaffoldWithNav(
            //   can use ProtectedRoute.checkAuth(child: child) instead of the below
            //   if with Bloc where the current context less method won't work
            child: child,
            // bottomNavigationBar: Builder(builder: (_) {
            //   return const BottomNavBar(
            //     selectedIndex: 0,
            //   );
            // })
          );

          // Could have checked if the current route is in the hiddenNavBarRoutes list
          //bool showNavBar = !Get.find<BottomNavController>().hiddenNavBarRoutes.contains(state.path);
        },
        routes: <RouteBase>[
          //   for home screen
          // "/home"
          GoRoute(path: "/home", builder: (context, state) => const HomeTabView(), routes: <RouteBase>[
            GoRoute(path: "0", pageBuilder: (context, state) => const NoTransitionPage(child: HomeTabView()), routes: const <RouteBase>[
              //       go route inside a shell route
              // "/home/0/"
              // "/home/0/restaurants"
              // GoRoute(
              //   path: "restaurants",
              //   pageBuilder: (context, state) =>
              //       NoTransitionPage(child: HomeTabView()),
              // ),
              // // "/home/0/friends"
              // GoRoute(
              //   path: "friends",
              //   pageBuilder: (context, state) => NoTransitionPage(
              //       child: HomeTabView(
              //           path: state.uri.path,
              //           child: const FriendsList())),
              // ),
              // // "/home/0/all"
              // GoRoute(
              //   path: "all",
              //   pageBuilder: (context, state) => NoTransitionPage(
              //       child: HomeTabView(
              //           path: state.uri.path,
              //           child: const RestaurantsList())),
              // ),
            ]),
            GoRoute(path: "1", pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const FoodRestaurantsTab())),
            GoRoute(
              path: "2",
              pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const FriendsTab()),
            ),
            GoRoute(path: "3", pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: const SettingsTab())),
          ]),
          // without the appbar and navbar wrapper
          // GoRoute(
          //   path: "/home/:tab",
          //   builder: (context, state) {
          //     int tab = int.parse(state.pathParameters['tab']!);
          //     switch (tab) {
          //       case 0:
          //         return const HomeTab();
          //       case 1:
          //         return const FoodRestaurantsTab();
          //       case 2:
          //         return const ProfileTab();
          //       case 3:
          //         return const SettingsTab();
          //       default:
          //         return const HomeTab();
          //     }
          //   },
          // ),

          // we need to wrap with material page if we don't want the appbar and btm bar from home using pagebuilder
        ],
      ),
      //Displayed on the Root navigator
      // "/get_started"
      GoRoute(
        parentNavigatorKey: rootNavigatorKey,
        path: AppRouteConstants.getStartedRoute,
        // we need to wrap with material page if we don't want the appbar and btm bar from home
        //
        pageBuilder: (context, state) => const MaterialPage(
          child: GetStartedScreen(),
        ),
      ),

      GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.createProfileName, pageBuilder: (context, state) => const MaterialPage(child: CreateProfileName())),

      GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.createProfileEmail, pageBuilder: (context, state) => const NoTransitionPage(child: CreateProfileEmail())),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.createProfilePassword, pageBuilder: (context, state) => const NoTransitionPage(child: CreateProfilePassword())),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.createProfilePhone, pageBuilder: (context, state) => const NoTransitionPage(child: CreateProfilePhone())),
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.createProfileSchoolName, pageBuilder: (context, state) => const NoTransitionPage(child: CreateProfileSchoolName())),

      GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: AppRouteConstants.placeOrder,
          pageBuilder: (context, state) {
            var restaurantId = state.uri.queryParameters['restaurantId']!;
            var restaurantName = state.uri.queryParameters['restaurantName']!;
            var restaurantImage = state.uri.queryParameters['restaurantImage']!;
            var addOns = state.uri.queryParameters['addOns']!;
            var itemData = state.uri.queryParameters['itemData']!;
            return NoTransitionPage(
                child: PlaceOrder(
              restaurantName: restaurantName, // you could take id here
              restaurantId: restaurantId,
              restaurantImage: restaurantImage,
              foodItem: jsonDecode(itemData) as Map<String, dynamic>,
              addOns: jsonDecode(addOns) as List<dynamic>,
            ));
          }),

      // RESTAURANT ROUTES
      GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: AppRouteConstants.restaurantDetails,
          pageBuilder: (context, state) {
            var restaurantId = state.uri.queryParameters['restaurantID']!;
            var restaurantName = state.uri.queryParameters['restaurantName']!;
            var restaurantAddress = state.uri.queryParameters['restaurantAddress']!;
            var restaurantEmail = state.uri.queryParameters['email']!;
            // var restaurantDescription =
            //     state.uri.queryParameters['restaurantDescription']!;
            // var distance = state.uri.queryParameters['distance']!;
            var image = state.uri.queryParameters['image']!;
            var isOnlineImage = state.uri.queryParameters['isOnlineImage']!;
            var isAvailable = state.uri.queryParameters['isAvailable']!;
            return NoTransitionPage(
                child: RestaurantDetailsScreen(
                  isAvailable: isAvailable == "true",
              restaurantName: restaurantName, // you could take id here
              restaurantEmail: restaurantEmail,
              restaurantAddress: restaurantAddress,
              image: image,
              isOnlineImage: isOnlineImage,
              restaurantID: restaurantId, //remove this
            ));
          }),

      // RESTAURANT LOGIN
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.restaurantLogin, pageBuilder: (context, state) => const MaterialPage(child: RSignInView())),

      // RESTAURANT HOME
      GoRoute(parentNavigatorKey: rootNavigatorKey, path: AppRouteConstants.restaurantHome, pageBuilder: (context, state) => const MaterialPage(child: RMainView())),

      // LOGIN
      GoRoute(
          parentNavigatorKey: rootNavigatorKey,
          path: AppRouteConstants.loginRoute,
          pageBuilder: (context, state) {
            // if user accidentally goes to login page and already logged in, redirect to home page
            return const MaterialPage(child: LoginScreen()); // TODO: comment this line
            // TODO: RE IMPLEMENT THIS
            // if (!Get.find<AuthController>().getIsLoggedIn &&
            //     state.path != AppRouteConstants.loginRoute) {
            //   // assign if paid user or not in after logging in successfully finishes
            //   return const MaterialPage(child: LoginScreen());
            // } else {
            //   return const MaterialPage(child: GetStartedScreen());
            // }
          }),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      if (kDebugMode) print("ROUTER URI: ${state.uri}");
      // redirect automatically to login if not logged in
      //TODO: uncomment the redirect line and remove the print
      // return redirectBasedOnLogin(state);
    },
  );
}

String? redirectBasedOnLogin(GoRouterState state) {
  // if not logged in and not on login page, redirect to login page
  // if user accidentally is able to access a route not supposed to access without login
  // can be a check implemented if a paid user tried to access a paid feature or not
  // Get.find<AuthController>().isLoggedIn.value == true && Get.find<AuthController>().isPremiumUser.value == false
  // TODO: RE IMPLEMENT THIS
  // if (!Get.find<AuthController>().getIsLoggedIn &&
  //     state.path != AppRouteConstants.loginRoute) {
  //   print("ROUTER: NOT LOGGED IN");
  //   // print("redirect to login");

  //   return AppRouteConstants.loginRoute;
  // }
}
