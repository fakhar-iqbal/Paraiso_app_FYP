import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:velocity_x/velocity_x.dart';

class OrderAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String foodName;
  final String foodPrice;

  const OrderAppBar({Key? key, required this.foodName, required this.foodPrice}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      // for transparency
      leading: IconButton(
        icon: Container(
            height: 53.h,
            width: 53.h,
            decoration: BoxDecoration(color: softBlack, borderRadius: BorderRadius.circular(50)),
            padding: EdgeInsets.only(left: 10.w),
            child: const Icon(Icons.arrow_back_ios)),
        onPressed: () {
          GoRouter.of(context).pop();
        },
      ),
      centerTitle: true,
      title: VStack(crossAlignment: CrossAxisAlignment.center, [
        //   txt

        Text(
          foodName,
          style: TextStyle(
            color: white,
            fontSize: 25.sp,
            fontFamily: 'Recoleta',
            fontWeight: FontWeight.w700,
          ),
        ),
        HStack([
          Text(foodPrice, style: context.textTheme.titleMedium!),
          3.horizontalSpace,
          Text(
            '€',
            style: TextStyle(
              color: white,
              fontSize: 25.sp,
              fontFamily: 'Recoleta',
              fontWeight: FontWeight.w700,
            ),
          ),
        ]),

        //   more text
      ]),
      toolbarHeight: 139.h,
      backgroundColor: Colors.transparent,
      actions: [
        IconButton(
          icon: Container(
              height: 53.h,
              width: 53.h,
              decoration: BoxDecoration(color: softBlack, borderRadius: BorderRadius.circular(50)),
              padding: EdgeInsets.only(right: 10.w),
              child: const Icon(Icons.notifications_none)),
          onPressed: () {
            // context.go('/menu');
          },
        )
      ],
    );
  }
}
