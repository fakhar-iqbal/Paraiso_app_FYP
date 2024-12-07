import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paraiso/screens/Restaurant/Main/RHomeView.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FriendsTile extends StatelessWidget {
  final String friendName;
  final String sentFoodImage;
  final String sentTo;
  final String location;
  final String time;
  final String friendImage;

  const FriendsTile({Key? key, required this.friendName, required this.sentFoodImage, required this.sentTo, required this.location, required this.time, required this.friendImage}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String rewardImg = pickImage(sentFoodImage);
    return Container(
      margin: EdgeInsets.fromLTRB(25.w, 0.h, 20.w, 15.h),
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: Color(0xFFF3EEDD),
          width: 1.w,
        ),
      ),
      width: context.screenWidth,
      child: HStack(alignment: MainAxisAlignment.start, [
        CircleAvatar(
          radius: 35.r,
          backgroundColor: softBlack,
          backgroundImage: NetworkImage(
            "https://img.lovepik.com/free-png/20220413/lovepik-creative-c4d-black-gold-gift-box-gift-stereo-icon-png-image_wh1200.png",
          ),
        ),
        14.horizontalSpace,
        VStack(alignment: MainAxisAlignment.center, [
          VxTextBuilder(
            "Gift pack",
          )
              .textStyle(
                Theme.of(context).textTheme.titleMedium!,
              )
              .bold
              .color(white)
              .make(),
          4.verticalSpace,
          // friendName.text. .make(),

          SizedBox(
            width: 200.w,
            // Theme(
            // data: ThemeData(
            //   textTheme: TextTheme(
            //     titleSmall: TextStyle(fontSize: 20.sp, color: white),
            //   ),
            // ),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: white, fontSize: 13.sp),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    "A user gifted ",
                    maxLines: 2,
                  ),
                  Baseline(
                    baseline: 20.h,
                    baselineType: TextBaseline.alphabetic,
                    child: rewardImg.contains(".svg")
                        ? SvgPicture.asset(rewardImg, height: 18.h)
                        : Image.asset(
                            rewardImg,
                            width: 27.w,
                            height: 27.h,
                          ),
                  ),

                  Text(
                    "  ${AppLocalizations.of(context)!.to}  ",
                    maxLines: 2,
                  ),
                  Text(
                    sentTo,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700, color: primaryColor),
                    maxLines: 2,
                  ),
                  //at
                  // Text(
                  //   " at ",
                  //   maxLines: 2,
                  // ),
                  // Text(
                  //   location,
                  //   style: Theme.of(context)
                  //       .textTheme
                  //       .titleSmall!
                  //       .copyWith(fontWeight: FontWeight.w700, color: white),
                  //   maxLines: 2,
                  // ),
                ],
              ),
            ),
          ),
        ]),
        const Spacer(),
        "🎁".text.color(onNeutralColor).make(),
        
        
      ]),
    );
  }
}

class FriendRewardFrmRestaurantTile extends StatelessWidget {
  final String userName;
  final String sentFoodImage;
  final String restaurant;
  final String location;
  final String time;
  final String friendImage;
  final String itemOrdered;

  const FriendRewardFrmRestaurantTile({
    Key? key,
    required this.userName,
    this.sentFoodImage = "Coconut",
    required this.restaurant,
    required this.location,
    required this.time,
    required this.friendImage,
    required this.itemOrdered,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // String rewardImg = pickImage(sentFoodImage);
    return Container(
      margin: EdgeInsets.fromLTRB(25.w, 0.h, 20.w, 15.h),
      padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: Color(0xFFF3EEDD),
          width: 1.w,
        ),
      ),
      width: context.screenWidth,
      child: HStack(alignment: MainAxisAlignment.start, [
        CircleAvatar(
          radius: 35.r,
          backgroundColor: softBlack,
          backgroundImage: NetworkImage(
            "https://th.bing.com/th/id/OIP.jJI3bTJ-diLfKDHb9-vwmwHaE8?rs=1&pid=ImgDetMain",
          ),
        ),
        14.horizontalSpace,
        VStack(alignment: MainAxisAlignment.center, [
          VxTextBuilder(
            itemOrdered,
          )
              .textStyle(
                Theme.of(context).textTheme.titleMedium!,
              )
              .bold
              .color(white)
              .make(),
          4.verticalSpace,
          // friendName.text. .make(),

          SizedBox(
            width: 200.w,
            // Theme(
            // data: ThemeData(
            //   textTheme: TextTheme(
            //     titleSmall: TextStyle(fontSize: 20.sp, color: white),
            //   ),
            // ),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: white, fontSize: 13.sp),
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    "Someone Ordered ",
                    maxLines: 2,
                  ),
                  Text(
                    itemOrdered,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700, color: primaryColor),
                    maxLines: 2,
                  ),
                  Text(
                    " ${AppLocalizations.of(context)!.from} ",
                    maxLines: 2,
                  ),
                  Text(
                    restaurant,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w700, color: primaryColor),
                    maxLines: 2,
                  ),
                  //at
                  // Text(
                  //   " at ",
                  //   maxLines: 2,
                  // ),
                  // Text(
                  //   location,
                  //   style: Theme.of(context)
                  //       .textTheme
                  //       .titleSmall!
                  //       .copyWith(fontWeight: FontWeight.w700, color: white),
                  //   maxLines: 2,
                  // ),
                ],
              ),
            ),
          ),
        ]),
        const Spacer(),
        "🔥".text.color(onNeutralColor).make(),
      ]),
    );
  }
}
