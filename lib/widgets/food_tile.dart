import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:velocity_x/velocity_x.dart';

class FoodTile extends StatelessWidget {
  final String foodName;
  final String foodImage;
  final String restaurantName;
  final String restaurantId;
  final String restaurantImage;
  final String restaurantDistance;
  final String discountPercentage;
  final List<dynamic> addOns;
  final Map<String, dynamic> itemData;
  final int othersOrdered;
  final String? imgOthers1;
  final String? imgOthers2;
  final String? imgOthers3;

  const FoodTile(
      {Key? key,
      required this.foodName,
      required this.restaurantName,
      required this.restaurantDistance,
      required this.discountPercentage,
      required this.othersOrdered,
      required this.restaurantImage,
      this.imgOthers1,
      this.imgOthers2,
      this.imgOthers3,
      required this.foodImage,
      required this.restaurantId,
      required this.addOns,
      required this.itemData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15.w, 12.h, 20.w, 12.h),
      margin: EdgeInsets.fromLTRB(25.w, 0.h, 20.w, 15.h),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: const Color(0xFFF3EEDD),
          width: 1.w,
        ),
      ),
      child: HStack(
          alignment: MainAxisAlignment.start,
          axisSize: MainAxisSize.max,
          [
            Container(
              width: 97.w,
              height: 97.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(foodImage),
                  fit: BoxFit.cover,
                ),
                borderRadius: BorderRadius.circular(22.r),
              ),
            ),
            15.horizontalSpace,
            VStack([
              // FIRST ROW
              foodName.text
                  .textStyle(
                    Theme.of(context).textTheme.titleMedium!,
                  )
                  .bold
                  .make(),
              3.verticalSpace,
              //SECOND ROW
              HStack(
                  alignment: MainAxisAlignment.spaceBetween,
                  axisSize: MainAxisSize.max,
                  [
                    Image.network(
                      restaurantImage,
                      width: 33.w,
                      height: 33.h,
                    ),
                    9.horizontalSpace,
                    // 2 COLUMN 2nd ROW
                    VStack([
                      SizedBox(
                        width: 120.w,
                        child: Text(
                          restaurantName,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: onPrimaryColor,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                        ),
                      ),
                      Text(
                        "$restaurantDistance km",
                        style: context.textTheme.bodySmall!.copyWith(
                          color: onPrimaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    ]),
                    const Spacer(),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: discountPercentage.text
                          .textStyle(
                            Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: const Color(0xff4CE480),
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                          )
                          .make(),
                    )
                  ]).wh(210.w, 40.h),
              8.verticalSpace,
              // 2nd column LAST ROW
              HStack([
                // OTHERS IMAGES
                ZStack([
                  Image.asset(
                    "assets/images/$imgOthers1",
                    width: 19.w,
                    height: 19.w,
                  ),
                  Positioned(
                    left: 9.w,
                    child: Image.asset(
                      "assets/images/$imgOthers2",
                      width: 19.w,
                      height: 19.w,
                    ),
                  ),
                  Positioned(
                    left: 18.w,
                    child: Image.asset(
                      "assets/images/$imgOthers3",
                      width: 19.w,
                      height: 19.w,
                    ),
                  ),
                ]).w(40.w),
                5.horizontalSpace,
                Text(
                  "$othersOrdered",
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: onPrimaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * .4,
                  child: Text(
                    " ${AppLocalizations.of(context)!.othersHaveAlsoOrdered}",
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: onPrimaryColor,
                          overflow: TextOverflow.ellipsis,
                          fontSize: 12.sp,
                        ),
                  ),
                ),
              ]),
            ]),
          ]).w(350.w),
    ).w(1.sw).hPCT(context: context, heightPCT: 16).onTap(() {
      itemData.update('lastUpdated', (value) => value.toString());
      GoRouter.of(context).push(Uri(path: '/placeOrder', queryParameters: {
        "restaurantId": restaurantId,
        "restaurantName": restaurantName,
        "restaurantImage": restaurantImage,
        "itemData": jsonEncode(itemData),
        "addOns": jsonEncode(addOns),
      }).toString());
      // context.push((context) => PlaceOrder(
      //       restaurantName: restaurantName,
      //       restaurantId: restaurantId,
      //       restaurantImage: restaurantImage,
      //       foodItem: itemData,
      //       addOns: addOns,
      //     ));
    });
    //   123
  }
}
