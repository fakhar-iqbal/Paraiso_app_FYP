// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:paraiso/routes/routes_constants.dart';
// import 'package:paraiso/util/theme/theme_constants.dart';
// import 'package:provider/provider.dart';
// import 'package:velocity_x/velocity_x.dart';

// import '../controllers/bottom_navbar_controller.dart';

// class BottomNavBar extends StatefulWidget {
//   const BottomNavBar({super.key});

//   @override
//   State<BottomNavBar> createState() => _BottomNavBarState();
// }

// // class _BottomNavBarState extends State<BottomNavBar> implements PreferredSizeWidget {
// class _BottomNavBarState extends State<BottomNavBar> {

//   // @override
//   // Size get preferredSize => Size.fromHeight(60.h);
//   @override
//   Widget build(BuildContext context) {
//     final bottomNavBarNotifier = Provider.of<BottomNavBarNotifier>(context);
//     return Row(
//       mainAxisSize: MainAxisSize.max,
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         32.horizontalSpace,
//         Expanded(
//           child: Padding(
//             padding:  EdgeInsets.symmetric(horizontal: 10.w),
//             child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onTap: () {
//                 bottomNavBarNotifier.updateSelectedIndex(0);
//                 context.go(AppRouteConstants.homeRoute);
//               },
//               child: customIcon(icon: "assets/icons/home.svg", activeIndex: 0, currentIndex: bottomNavBarNotifier.selectedIndex, size: 25.w),
//             ),
//           ),
//         ),
//         Expanded(
//           child: Padding(
//             padding:  EdgeInsets.symmetric(horizontal: 10.w),
//             child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onTap: () {
//                 bottomNavBarNotifier.updateSelectedIndex(1);
//                 context.go(AppRouteConstants.restaurantsRoute);
//               },
//               child: customIcon(icon: "assets/icons/restaurants.svg", currentIndex: bottomNavBarNotifier.selectedIndex, activeIndex: 1),
//             ),
//           ),
//         ),
//         Expanded(
//           child: Padding(
//             padding:  EdgeInsets.symmetric(horizontal: 10.w),
//             child: GestureDetector(
//               behavior: HitTestBehavior.translucent,
//               onTap: () {
//                 bottomNavBarNotifier.updateSelectedIndex(2);
//                 context.go(AppRouteConstants.profileRoute);
//               },
//               child: customIcon(icon: "assets/icons/friends.svg", currentIndex: bottomNavBarNotifier.selectedIndex, activeIndex: 2),
//             ),
//           ),
//         ),
//         // Expanded(
//         //   child: GestureDetector(
//         //       onTap: () {
//         //         setState(() {
//         //           selectedIndex = 2;
//         //         });
//         //         context.go(AppRouteConstants.settingsRoute);
//         //       },
//         //       child: customIcon(
//         //           icon: "assets/icons/settings.svg", activeIndex: 2)),
//         // ),
//         32.horizontalSpace,
//       ],
//     )
//         .box
//         .color(softBlack)
//         .customRounded(const BorderRadius.all(Radius.circular(50)))
//         .make()
//         .wh(385.w, 100.h)
//         // .pSymmetric(h: 20.w, v: 10.h)
//         .marginSymmetric(
//           horizontal: 25.w,
//           vertical: 25.h,
//         );
//   }

//   Widget customIcon({required String icon, required int activeIndex, required currentIndex, double? size}) {
//     return SvgPicture.asset(
//       icon,
//       color: activeIndex == currentIndex ? const Color(0xFF2F58CD) : Colors.grey,
//       width: size ?? 28.w,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/routes/routes_constants.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../controllers/bottom_navbar_controller.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

// class _BottomNavBarState extends State<BottomNavBar> implements PreferredSizeWidget {
class _BottomNavBarState extends State<BottomNavBar> {

  // @override
  // Size get preferredSize => Size.fromHeight(60.h);
  @override
  Widget build(BuildContext context) {
    final bottomNavBarNotifier = Provider.of<BottomNavBarNotifier>(context);
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        32.horizontalSpace,
        // Expanded(
        //   child: Padding(
        //     padding:  EdgeInsets.symmetric(horizontal: 10.w),
        //     child: GestureDetector(
        //       behavior: HitTestBehavior.translucent,
        //       onTap: () {
        //         bottomNavBarNotifier.updateSelectedIndex(0);
        //         context.go(AppRouteConstants.homeRoute);
        //       },
        //       child: customIcon(icon: "assets/icons/home.svg", activeIndex: 0, currentIndex: bottomNavBarNotifier.selectedIndex, size: 25.w),
        //     ),
        //   ),
        // ),
        Expanded(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.w),
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        bottomNavBarNotifier.updateSelectedIndex(0);
        context.go(AppRouteConstants.homeRoute);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensures the column doesn't take unnecessary space
        mainAxisAlignment: MainAxisAlignment.center, // Centers the items vertically
        children: [
          customIcon(
            icon: "assets/icons/home.svg",
            activeIndex: 0,
            currentIndex: bottomNavBarNotifier.selectedIndex,
            size: 25.w,
          ),
          SizedBox(height: 5.h), // Adds spacing between the icon and text
          Text(
            "Home",
            style: TextStyle(
              fontSize: 12.sp, // Adjust the text size
              color: bottomNavBarNotifier.selectedIndex == 0
                  ? Colors.blue // Active color
                  : Colors.grey, // Inactive color
            ),
          ),
        ],
      ),
    ),
  ),
),

        // Expanded(
        //   child: Padding(
        //     padding:  EdgeInsets.symmetric(horizontal: 10.w),
        //     child: GestureDetector(
        //       behavior: HitTestBehavior.translucent,
        //       onTap: () {
        //         bottomNavBarNotifier.updateSelectedIndex(1);
        //         context.go(AppRouteConstants.restaurantsRoute);
        //       },
        //       child: customIcon(icon: "assets/icons/restaurants.svg", currentIndex: bottomNavBarNotifier.selectedIndex, activeIndex: 1),
        //     ),
        //   ),
        // ),
        Expanded(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.w),
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        bottomNavBarNotifier.updateSelectedIndex(1);
        context.go(AppRouteConstants.restaurantsRoute);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensures the column takes only necessary space
        mainAxisAlignment: MainAxisAlignment.center, // Centers icon and text vertically
        children: [
          customIcon(
            icon: "assets/icons/restaurants.svg",
            currentIndex: bottomNavBarNotifier.selectedIndex,
            activeIndex: 1,
          ),
          SizedBox(height: 5.h), // Adds spacing between the icon and the text
          Text(
            "Categories",
            style: TextStyle(
              fontSize: 12.sp, // Adjust text size as needed
              color: bottomNavBarNotifier.selectedIndex == 1
                  ? Colors.blue // Active color
                  : Colors.grey, // Inactive color
            ),
          ),
        ],
      ),
    ),
  ),
),

        // Expanded(
        //   child: Padding(
        //     padding:  EdgeInsets.symmetric(horizontal: 10.w),
        //     child: GestureDetector(
        //       behavior: HitTestBehavior.translucent,
        //       onTap: () {
        //         bottomNavBarNotifier.updateSelectedIndex(2);
        //         context.go(AppRouteConstants.profileRoute);
        //       },
        //       child: customIcon(icon: "assets/icons/friends.svg", currentIndex: bottomNavBarNotifier.selectedIndex, activeIndex: 2),
        //     ),
        //   ),
        // ),
        Expanded(
  child: Padding(
    padding: EdgeInsets.symmetric(horizontal: 10.w),
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        bottomNavBarNotifier.updateSelectedIndex(2);
        context.go(AppRouteConstants.profileRoute);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ensures minimal space is taken
        mainAxisAlignment: MainAxisAlignment.center, // Aligns icon and text vertically
        children: [
          customIcon(
            icon: "assets/icons/friends.svg",
            currentIndex: bottomNavBarNotifier.selectedIndex,
            activeIndex: 2,
          ),
          SizedBox(height: 5.h), // Adds spacing between the icon and text
          Text(
            "Friends",
            style: TextStyle(
              fontSize: 12.sp, // Adjust the size of the text
              color: bottomNavBarNotifier.selectedIndex == 2
                  ? Colors.blue // Active color for selected tab
                  : Colors.grey, // Inactive color for unselected tabs
            ),
          ),
        ],
      ),
    ),
  ),
),

        // Expanded(
        //   child: GestureDetector(
        //       onTap: () {
        //         setState(() {
        //           selectedIndex = 2;
        //         });
        //         context.go(AppRouteConstants.settingsRoute);
        //       },
        //       child: customIcon(
        //           icon: "assets/icons/settings.svg", activeIndex: 2)),
        // ),
        32.horizontalSpace,
      ],
    )
        .box
        .color(softBlack)
        .customRounded(const BorderRadius.all(Radius.circular(50)))
        .make()
        .wh(385.w, 100.h)
        // .pSymmetric(h: 20.w, v: 10.h)
        .marginSymmetric(
          horizontal: 25.w,
          vertical: 25.h,
        );
  }

  Widget customIcon({required String icon, required int activeIndex, required currentIndex, double? size}) {
    return SvgPicture.asset(
      icon,
      color: activeIndex == currentIndex ? const Color(0xFF2F58CD) : Colors.grey,
      width: size ?? 28.w,
    );
  }
}
