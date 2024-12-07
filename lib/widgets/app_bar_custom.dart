import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:velocity_x/velocity_x.dart';

import '../screens/myOrders_Screen.dart';

class AppBarCustom extends StatefulWidget implements PreferredSizeWidget {
  final scaffoldKey;
  final String photo;
  const AppBarCustom({super.key, this.scaffoldKey, required this.photo});

  @override
  State<AppBarCustom> createState() => _AppBarCustomState();

  @override
  Size get preferredSize => Size.fromHeight(78.h);
}

class _AppBarCustomState extends State<AppBarCustom> {
  // AppBarItem

  // @override
  // void didChangeDependencies() async {
  //   final currUser = Provider.of<CustomerController>(context,listen: false);
  //   await currUser.getCurrentUser();
  //   print("userrrrrrrrrrrrrrrrr");
  //   print(currUser.user);
  //   print(currUser.user['photo']);
  //   super.didChangeDependencies();
  // }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: Size.fromHeight(60.h),
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        // elevation: 0.0,
        leadingWidth: 100.w,
        leading: CircleAvatar(
          radius: 50.r,
          backgroundColor: softBlack,
          backgroundImage:
              widget.photo != "" ? NetworkImage(widget.photo) : null,
        ).onTap(
          () {
            //user_profile
            Scaffold.of(context).openDrawer();
          },
        ),
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/paraiso_logo.png',
              height: 30.h,
              width: 37.w,
            ),
            10.horizontalSpace,
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyOrdersScreen()));
                  },
                ).wh(53.w, 53.h),
                //! A RED DOT ON TOP OF NOTIFICATION ICON
                Positioned(
                  top: 10.h,
                  right: 15.h,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(47, 88, 205, 1),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ).box.color(softBlack).roundedFull.make(),
          ),
        ],
      ),
    );
  }
}
