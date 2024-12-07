import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:velocity_x/velocity_x.dart';

import '../repositories/customer_firebase_calls.dart';
import '../routes/routes_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class OrderStatus extends StatefulWidget {
  final String restaurantName;
  final String restaurantId;
  final String restaurantImage;
  final int orderStatus;
  final String restaurantAddress;
  final String prepDelay;
  final String workingHrs;
  const OrderStatus(
      {Key? key,
      this.restaurantName = 'no name',
      this.restaurantId = '123',
      this.restaurantImage = 'ss',
      this.prepDelay = '45 minutes',
      this.workingHrs = '2.0 Hours',
      this.restaurantAddress = "1500 Broadway, New York, NY 10036",
      this.orderStatus = 0})
      : super(key: key);

  @override
  State<OrderStatus> createState() => _OrderStatusState();
}

class _OrderStatusState extends State<OrderStatus> {
  bool isLoading = false;
  bool reviewed = false;

  final TextEditingController reviewMessageController = TextEditingController();

  int rating = 2;

  Future<void> addReview() async {
    final mycall = MyCustomerCalls();
    Navigator.pop(context);
    setState(() {
      isLoading = true;
    });
    await mycall.postReview(widget.restaurantId, widget.restaurantName, rating, reviewMessageController.text);

    setState(() {
      isLoading = false;
      reviewed = true;
    });
  }

  Future<void> getReviewStatus() async {
    final mycall = MyCustomerCalls();
    final status = await mycall.reviewExists(widget.restaurantId);

    setState(() {
      reviewed = status;
    });
  }

  @override
  void initState() {
    super.initState();
    getReviewStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          30.verticalSpace,
          OrderStatusTile(icon: "restaurant location", title: AppLocalizations.of(context)!.pickupLocation, subtitle: widget.restaurantAddress),
          OrderStatusTile(icon: "Order Status_Timer_412_5964", title: AppLocalizations.of(context)!.preparingDelay, subtitle: widget.prepDelay),
          OrderStatusTile(icon: "clock", title: AppLocalizations.of(context)!.workingHours, subtitle: widget.workingHrs),
          50.verticalSpace,
          Text(
            AppLocalizations.of(context)!.orderProgress,
            style: context.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).pLTRB(25.w, 0.h, 0.w, 0.h),
          27.verticalSpace,
          Visibility(
            visible: widget.orderStatus != 404,
            replacement: Column(children: [
              Row(
                children: [
                  Center(
                    child: Container(
                      width: 42.h,
                      height: 42.h,
                      decoration: BoxDecoration(
                        color: context.primaryColor,
                        borderRadius: BorderRadius.circular(50.h),
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                  13.horizontalSpace,
                  Text(AppLocalizations.of(context)!.decline, style: context.bodyLarge),
                ],
              ).pOnly(left: 42.w),
              185.verticalSpace,
            ]),
            child: Column(
              children: [
                Row(
                  children: [
                    //   checkmar svg
                    const StatusBubble(isCompleted: true),
                    13.horizontalSpace,
                    Text(AppLocalizations.of(context)!.pending, style: context.bodyLarge),
                  ],
                ).pOnly(left: 42.w),
                4.verticalSpace,
                const StatusLine(isCompleted: true),
                4.verticalSpace,
                Row(
                  children: [
                    //   checkmark svg
                    StatusBubble(isCompleted: widget.orderStatus >= 1 ? true : false),
                    13.horizontalSpace,
                    Text(AppLocalizations.of(context)!.inProgress, style: context.bodyLarge),
                  ],
                ).pOnly(left: 42.w),
                4.verticalSpace,
                StatusLine(isCompleted: widget.orderStatus >= 1 ? true : false),
                4.verticalSpace,
                Row(
                  children: [
                    // grey circle with whitish checkmark in center
                    StatusBubble(isCompleted: widget.orderStatus == 2 ? true : false),
                    13.horizontalSpace,
                    Text(AppLocalizations.of(context)!.readyForPickup, style: context.bodyLarge),
                  ],
                ).pOnly(left: 42.w),
              ],
            ),
          ),
          20.verticalSpace,
          GestureDetector(
            onTap: () {
              if (reviewed == false) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          actionsOverflowButtonSpacing: 0.w,
                          scrollable: true,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22.r),
                          ),
                          backgroundColor: const Color.fromRGBO(42, 42, 42, 1),
                          content: VStack(crossAlignment: CrossAxisAlignment.center, [
                            12.verticalSpace,
                            Text(AppLocalizations.of(context)!.rateYourExperience,
                                style: context.headlineSmall?.copyWith(
                                  color: onPrimaryColor,
                                )),
                            30.verticalSpace,
                            Container(
                              width: 81.w,
                              height: 81.h,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: const CircleBorder(),
                                image: DecorationImage(image: Image.network(widget.restaurantImage).image),
                              ),
                            ),
                            15.horizontalSpace,
                            Text(widget.restaurantName,
                                style: context.headlineSmall?.copyWith(
                                  color: onPrimaryColor,
                                )),
                            20.verticalSpace,
                            RatingBar.builder(
                              initialRating: 2,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: false,
                              itemCount: 5,
                              itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  this.rating = rating.toInt();
                                });
                              },
                            ),
                            20.verticalSpace,
                            SizedBox(
                              width: 319.w,
                              child: TextField(
                                onChanged: (value) {
                                  setState(() {
                                    reviewMessageController.text = value;
                                  });
                                },
                                minLines: 3,
                                maxLines: 8,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                                  hintText: AppLocalizations.of(context)!.leaveAMessageOptional,
                                  hintStyle: context.bodyMedium,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(1.r),
                                    borderSide: BorderSide(
                                      color: context.primaryColor,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20.r),
                                    borderSide: const BorderSide(
                                      color: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                          actions: [
                            Container(
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: context.primaryColor,
                                borderRadius: BorderRadius.circular(22.r),
                              ),
                              child: Center(
                                child: isLoading
                                    ? Transform.scale(scale: 0.5, child: const CircularProgressIndicator(color: Colors.white))
                                    : AutoSizeText(
                                        AppLocalizations.of(context)!.rateNow,
                                        style: TextStyle(
                                          color: const Color(0xFFE4E4E4),
                                          fontSize: 18.sp,
                                          fontFamily: 'Recoleta',
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                      ),
                              ),
                            ).onTap(() {
                              addReview();
                            }),
                            20.verticalSpace,
                            Container(
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: const Color(0xFF353535),
                                borderRadius: BorderRadius.circular(22.r),
                              ),
                              child: Center(
                                child: AutoSizeText(
                                  AppLocalizations.of(context)!.maybeLater,
                                  style: TextStyle(
                                    color: const Color(0xFFE4E4E4),
                                    fontSize: 18.sp,
                                    fontFamily: 'Recoleta',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ).onTap(() {
                              context.pushReplacement(AppRouteConstants.homeRoute);
                            }),
                          ],
                        ));
              }
            },
            child: Container(
              height: 50.h,
              width: 100.w,
              margin: EdgeInsets.symmetric(horizontal: 100.w, vertical: 40.h),
              decoration: BoxDecoration(
                color: context.primaryColor,
                borderRadius: BorderRadius.circular(22.r),
              ),
              child: Center(
                child: isLoading
                    ? Transform.scale(scale: 0.5, child: const CircularProgressIndicator(color: Colors.white))
                    : reviewed
                        ? AutoSizeText(
                            AppLocalizations.of(context)!.reviewedPlaced,
                            style: TextStyle(
                              color: const Color(0xFFE4E4E4),
                              fontSize: 18.sp,
                              fontFamily: 'Recoleta',
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                          )
                        : AutoSizeText(
                            AppLocalizations.of(context)!.giveReview,
                            style: TextStyle(
                              color: const Color(0xFFE4E4E4),
                              fontSize: 18.sp,
                              fontFamily: 'Recoleta',
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                          ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class OrderStatusTile extends StatelessWidget {
  final String icon;
  final String title;
  final String subtitle;

  const OrderStatusTile({Key? key, required this.icon, required this.title, required this.subtitle}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      style: ListTileStyle.list,
      tileColor: softBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22.h),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 5.h),
      leading: SvgPicture.asset(
        'assets/images/$icon.svg',
        width: 30.w,
      ),
      title: Text(
        title,
        style: context.titleLarge!.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(subtitle, style: context.bodyLarge),
    ).w(380.w).marginSymmetric(horizontal: 25.w, vertical: 10.h);
  }
}

class StatusBubble extends StatelessWidget {
  final bool isCompleted;
  const StatusBubble({Key? key, required this.isCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return isCompleted
        ? SvgPicture.asset(
            'assets/images/order placed.svg',
            height: 42.h,
            width: 42.h,
          )
        : Center(
            child: Container(
              width: 42.h,
              height: 42.h,
              decoration: BoxDecoration(
                color: softGray,
                borderRadius: BorderRadius.circular(50.h),
              ),
              child: Icon(
                Icons.check,
                color: softGray,
                size: 25,
              ),
            ),
          );
  }
}

class StatusLine extends StatelessWidget {
  final bool isCompleted;
  const StatusLine({Key? key, required this.isCompleted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 4.w,
        height: 40.h,
        color: isCompleted ? context.primaryColor : softBlack,
      ).pOnly(left: 55.w),
    );
  }
}
