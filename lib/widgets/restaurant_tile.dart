import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:velocity_x/velocity_x.dart';

class RestaurantTile extends StatelessWidget {
  final String restaurantID;
  final String restaurantName;
  final String restaurantDescription;
  final String restaurantAddress;
  final String distance;
  final String image;
  final bool isOnlineImage;
  final String? email;
  final bool isAvailable;
  final bool isClosed;

  const RestaurantTile(
      {Key? key,
      required this.restaurantName,
      required this.restaurantDescription,
      required this.restaurantAddress,
      required this.distance,
      required this.image,
      this.isOnlineImage = false,
      this.restaurantID = "",
      this.email,
      this.isAvailable = true,
      this.isClosed = false})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isClosed) {
          return;
        }
        print('Restaurant ID: $restaurantID');
        GoRouter.of(context)
            .push(Uri(path: '/restaurantDetails', queryParameters: {
          "email": email ?? "",
          "restaurantID": restaurantID,
          "restaurantName": restaurantName,
          "restaurantDescription": restaurantDescription,
          "restaurantAddress": restaurantAddress,
          "distance": distance,
          "image": image,
          "isAvailable": isAvailable.toString(),
          "isOnlineImage": isOnlineImage.toString(),
        }).toString());
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(25.w, 0.h, 25.w, 15.h),
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 27.w, 18.h),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: Color(0xFFF3EEDD),
            width: 1.w,
          ),
        ),
        width: context.screenWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (isClosed)
              Container(
                width: 60.w,
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(5.h),
                ),
                child: Center(
                  child: Text(
                    "Closed",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                  ),
                ),
              ),
            HStack(alignment: MainAxisAlignment.start, [
              isOnlineImage
                  ? Container(
                      width: 73.w,
                      height: 73.h,
                      decoration: ShapeDecoration(
                        shape: ContinuousRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0)),
                        color: Colors.white,
                        image: DecorationImage(
                          image: NetworkImage(image),
                          fit: BoxFit.contain,
                        ),
                      ),
                      // child: Image.network(
                      //   image,
                      //   width: 73.w,
                      //   height: 73.h,
                      // ),
                    )
                  : Image.asset(
                      "assets/images/$image",
                      width: 73.w,
                      height: 73.h,
                    ),
              14.horizontalSpace,
              VStack(alignment: MainAxisAlignment.center, [
                SizedBox(
                  width: 190.w,
                  child: VxTextBuilder(
                    restaurantName,
                  )
                      .textStyle(
                        Theme.of(context).textTheme.titleMedium!,
                      )
                      .bold
                      .ellipsis
                      .make(),
                ),
                4.verticalSpace,
                // restaurantName.text. .make(),

                SizedBox(
                  width: 190.w,
                  child: AutoSizeText(
                    restaurantDescription,
                    maxLines: 2,
                  ),
                )
              ]),
              const Spacer(),
              // distance.text.color(onNeutralColor).make(),
              const Icon(Icons.circle, color: Colors.green, size: 10),  
            ]),
          ],
        ),
      ),
    );
    // ListTile(
    //   title: restaurantName.text.make(),
    //   subtitle: restaurantDescription.text.color(onNeutralColor).make(),
    //   leading: CircleAvatar(child: Image.asset("assets/images/$image")),
    //   trailing: distance.text.color(onNeutralColor).make(),
    // )
    //     .box
    //     .color(softBlack)
    //     .roundedLg
    //     .margin(
    //       const EdgeInsets.symmetric(
    //         vertical: 5,
    //         horizontal: 10,
    //       ),
    //     )
    //     .make()
    //     .wh(
    //       context.screenWidth,
    //       context.percentHeight * 0.10515,
    //     );
  }
}

String formatTimeDifference(DateTime lastUpdated) {
  final DateTime now = DateTime.now();
  final Duration difference = now.difference(lastUpdated);

  if (difference.inMinutes < 1) {
    return '1 m';
  } else if (difference.inHours < 1) {
    final minutes = difference.inMinutes;
    return '$minutes m';
  } else if (difference.inDays < 1) {
    final hours = difference.inHours;
    return '$hours h';
  } else {
    final days = difference.inDays;
    return '$days d';
  }
}
