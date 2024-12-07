import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paraiso/screens/friend_profile.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/profile_res_tile.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';
import '../controllers/customer_controller.dart';
import '../controllers/rewards_controller.dart';
import '../repositories/customer_auth_repo.dart';
import '../util/local_storage/shared_preferences_helper.dart';
import 'customer_basic_profile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  String name = '';
  String email = '';
  String schoolName = '';
  int coconuts = 0;
  String phone = '';
  String? photo;
  Map<String, dynamic> user = {};
  late RewardsController _rewardsController;

  Future<void> getCurrentUser() async {
    final currentUser = await CustomerAuthRep().getCurrentUser();
    user = await CustomerAuthRep().getCurrentUserFromFirebase();
    setState(() {
      name = user['userName']!;
      email = currentUser['email'];
      schoolName = user['schoolName']!;
      coconuts = user['rewards'] is double ? user['rewards'].toInt() : (user['rewards'] is String ? int.parse(user['rewards']) : user['rewards']);
      phone = user['phoneNumber'];
      photo = user['photo'];
    });
  }

  @override
  void didChangeDependencies() async {
    final email = SharedPreferencesHelper.getCustomerEmail();
    _rewardsController = Provider.of<RewardsController>(context, listen: false);
    await _rewardsController.getRewards(email!);
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    final top2Restaurants = getTop2RestaurantsWithMostCoconuts(user);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: neutralColor,
        leading: IconButton(
          icon: Container(
              height: 53.h,
              width: 53.h,
              decoration: BoxDecoration(color: softBlack, borderRadius: BorderRadius.circular(50)),
              padding: EdgeInsets.only(left: 10.w),
              child: const Icon(Icons.arrow_back_ios)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.profile,
            style: TextStyle(
              color: const Color(0xFFE4E4E4),
              fontSize: 25.sp,
              fontFamily: 'Recoleta',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        actions: [
          44.horizontalSpace,
        ],
      ),
      body: ListView(
        children: [
          18.verticalSpace,
          GestureDetector(
            onTap: () async {
              final customerController = Provider.of<CustomerController>(context, listen: false);
              await customerController.getCurrentUser();
              if (mounted) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const CustomerBasicProfile()));
              }
            },
            child: Row(
              children: [
                CircleAvatar(
                  radius: 40.r,
                  backgroundImage: photo != "" && photo != null ? NetworkImage(photo!) : null,
                ),
                17.horizontalSpace,
                VStack([
                  Text(
                    name,
                    style: TextStyle(
                      color: const Color(0xFFE4E4E4),
                      fontSize: 20.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  5.verticalSpace,
                  Text(
                    // 'Mason High School',
                    schoolName,
                    style: TextStyle(
                      color: const Color(0xFFE4E4E4),
                      fontSize: 18.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w400,
                    ),
                  )
                ]),
              ],
            ).pLTRB(25.w, 0.h, 25.w, 25.h),
          ),
          17.verticalSpace,
          Divider(
            color: softGray,
            thickness: .5.h,
            // indent: 25,
            // endIndent: 25,
          ),
          22.verticalSpace,

          //   2nd row
          Container(
            margin: EdgeInsets.fromLTRB(25.w, 0.h, 25.w, 0.h),
            padding: EdgeInsets.all(25.w),
            width: 380.w,
            decoration: BoxDecoration(
              color: softBlack,
              borderRadius: BorderRadius.circular(22.h),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(
                    'paraiso',
                    style: TextStyle(
                      color: const Color(0xFFE4E4E4),
                      fontSize: 24.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    AppLocalizations.of(context)!.totalCoconuts,
                    style: TextStyle(
                      color: const Color(0xFFBDBDBD),
                      fontSize: 15.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ]),
                Row(children: [
                  Text(
                    _rewardsController.rewards is double ? _rewardsController.rewards.toInt().toString() : _rewardsController.rewards.toString(),
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: const Color(0xFFE4E4E4),
                      fontSize: 20.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  7.horizontalSpace,
                  SvgPicture.asset(
                    'assets/images/Food Filter_OBJECTS_458_13901.svg',
                    width: 37.w,
                  )
                ])
              ],
            ),
          ),
          25.verticalSpace,
          //   3rd row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.restaurantRewards,
                style: TextStyle(
                  color: const Color(0xFFE4E4E4),
                  fontSize: 23.sp,
                  fontFamily: 'Recoleta',
                  fontWeight: FontWeight.w400,
                ),
              ),
              Text(
                AppLocalizations.of(context)!.seeAll,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: const Color(0xFFBDBDBD),
                  fontSize: 16.sp,
                  fontFamily: 'Recoleta',
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ).pLTRB(25.w, 0.h, 25.w, 0.h),
          10.verticalSpace,
          user == {}
              ? const CircularProgressIndicator()
              : SizedBox(
                  height: MediaQuery.sizeOf(context).height * .3,
                  child: ListView.builder(
                    itemCount: top2Restaurants.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ProfileResTile(
                            image: top2Restaurants[index]['restaurantLogo'] ?? "",
                            title: top2Restaurants[index]['restaurantName'],
                            amount: top2Restaurants[index]['Coconut'],
                          ),
                          //   restaurant  card 2
                          10.verticalSpace,
                        ],
                      );
                    },
                  ),
                ),
          25.verticalSpace,
          // Text(
          //   'Daily Rewards',
          //   style: TextStyle(
          //     color: const Color(0xFFE4E4E4),
          //     fontSize: 23.sp,
          //     fontFamily: 'Recoleta',
          //     fontWeight: FontWeight.w400,
          //   ),
          // ).pLTRB(25.w, 0.h, 25.w, 0.h),
          // 22.verticalSpace,
          //   Last row
          // Container(
          //   margin: EdgeInsets.fromLTRB(25.w, 0.h, 25.w, 0.h),
          //   padding: EdgeInsets.all(25.w),
          //   width: 380.w,
          //   decoration: BoxDecoration(
          //     color: softBlack,
          //     borderRadius: BorderRadius.circular(22.h),
          //   ),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     crossAxisAlignment: CrossAxisAlignment.center,
          //     children: [
          //       // btn
          //       Row(
          //         mainAxisAlignment: MainAxisAlignment.center,
          //         children: [
          //           SvgPicture.asset(
          //             'assets/images/gift box.svg',
          //             width: 81.w,
          //           ),
          //         ],
          //       ).wPCT(context: context, widthPCT: 28),

          //       Column(children: [
          //         Text(
          //           'Rewards Available',
          //           style: TextStyle(
          //             color: const Color(0xFFE4E4E4),
          //             fontSize: 18.sp,
          //             fontFamily: 'Recoleta',
          //             fontWeight: FontWeight.w400,
          //           ),
          //         ),
          //         13.verticalSpace,
          //         Container(
          //           width: 136,
          //           height: 35.32,
          //           decoration: ShapeDecoration(
          //             shape: RoundedRectangleBorder(
          //               side: const BorderSide(
          //                   width: 0.50, color: Color(0xFFFF6154)),
          //               borderRadius: BorderRadius.circular(100),
          //             ),
          //           ),
          //           child: Row(
          //             mainAxisAlignment: MainAxisAlignment.center,
          //             children: [
          //               Text(
          //                 'Get Rewards',
          //                 style: TextStyle(
          //                   color: const Color(0xFFFF6154),
          //                   fontSize: 13.sp,
          //                   fontFamily: 'Recoleta',
          //                   fontWeight: FontWeight.w400,
          //                 ),
          //               ),
          //               5.horizontalSpace,
          //               const Icon(
          //                 Icons.arrow_forward_ios,
          //                 color: Color(0xFFFF6154),
          //                 size: 13,
          //               )
          //             ],
          //           ),
          //         ).onTap(() async {
          //           String? rewardImg;
          //           final rewardsStatus = await rewardsController.claimRewards(
          //               SharedPreferencesHelper.getCustomerEmail()!);
          //           if (rewardsStatus["type"] ==
          //               AppConstants.giftItems[GiftItems.coconut]) {
          //             rewardImg =
          //                 "assets/images/Food Filter_OBJECTS_458_13901.svg";
          //           } else if (rewardsStatus["type"] ==
          //               AppConstants.giftItems[GiftItems.burger]) {
          //             rewardImg =
          //                 "assets/images/Send Gifts_burger 1_346_10807.png";
          //           } else if (rewardsStatus["type"] ==
          //               AppConstants.giftItems[GiftItems.pizza]) {
          //             rewardImg = "assets/images/send_pizza.png";
          //           } else if (rewardsStatus["type"] ==
          //               AppConstants.giftItems[GiftItems.float]) {
          //             rewardImg =
          //                 "assets/images/Send Gifts_float 1_352_11143.png";
          //           } else if (rewardsStatus["type"] ==
          //               AppConstants.giftItems[GiftItems.buritto]) {
          //             rewardImg =
          //                 "assets/images/Send Gifts_buritto 1_352_11140.png";
          //           } else {
          //             rewardImg =
          //                 "assets/images/Send Gifts_ice cream 1_352_11144.png";
          //           }
          //           if (mounted) {
          //             rewardsStatus["status"]
          //                 ? showDialog(
          //                     context: context,
          //                     builder: (BuildContext context) {
          //                       return AlertDialog(
          //                         shape: RoundedRectangleBorder(
          //                           borderRadius: BorderRadius.circular(22.r),
          //                         ),
          //                         backgroundColor: softBlack,
          //                         content: VStack(
          //                             crossAlignment: CrossAxisAlignment.center,
          //                             [
          //                               12.verticalSpace,
          //                               Stack(
          //                                 children: [
          //                                   SvgPicture.asset(
          //                                     "assets/images/confetti.svg",
          //                                     width: 287.w,
          //                                     height: 176.h,
          //                                   ),
          //                                   Positioned(
          //                                     top: 62,
          //                                     right: 79,
          //                                     child: SvgPicture.asset(
          //                                       "assets/images/gift_wrap.svg",
          //                                       width: 128.w,
          //                                     ),
          //                                   )
          //                                 ],
          //                               ).h(233.h),
          //                               30.verticalSpace,
          //                               Text(
          //                                 'Congratulations!',
          //                                 style: TextStyle(
          //                                   color: white,
          //                                   fontSize: 30.sp,
          //                                   fontFamily: 'Recoleta',
          //                                   fontWeight: FontWeight.w400,
          //                                 ),
          //                               ),
          //                               Row(
          //                                 mainAxisAlignment:
          //                                     MainAxisAlignment.center,
          //                                 children: [
          //                                   Text.rich(
          //                                     TextSpan(
          //                                       children: [
          //                                         TextSpan(
          //                                           text: 'You have won',
          //                                           style: TextStyle(
          //                                             color: white,
          //                                             fontSize: 20,
          //                                             fontFamily: 'Recoleta',
          //                                             fontWeight:
          //                                                 FontWeight.w400,
          //                                           ),
          //                                         ),
          //                                         TextSpan(
          //                                           text: '  ',
          //                                           style: TextStyle(
          //                                             fontSize: 20.sp,
          //                                             fontFamily: 'Recoleta',
          //                                             fontWeight:
          //                                                 FontWeight.w700,
          //                                           ),
          //                                         ),
          //                                         TextSpan(
          //                                           text:
          //                                               '${rewardsStatus["tokens"]} ',
          //                                           style: TextStyle(
          //                                             fontSize: 20.sp,
          //                                             fontFamily: 'Recoleta',
          //                                             fontWeight:
          //                                                 FontWeight.w700,
          //                                           ),
          //                                         ),
          //                                       ],
          //                                     ),
          //                                   ),
          //                                   rewardImg != null &&
          //                                           rewardImg.contains(".svg")
          //                                       ? SvgPicture.asset(
          //                                           rewardImg,
          //                                           width: 40.w,
          //                                         )
          //                                       : const SizedBox.shrink(),
          //                                   rewardImg != null &&
          //                                           rewardImg.contains(".png")
          //                                       ? Image.asset(
          //                                           rewardImg,
          //                                           width: 50.w,
          //                                         )
          //                                       : const SizedBox.shrink(),
          //                                 ],
          //                               )
          //                             ]),
          //                         actions: [
          //                           Center(
          //                             child: Container(
          //                               width: 136.w,
          //                               height: 45.h,
          //                               decoration: ShapeDecoration(
          //                                 shape: RoundedRectangleBorder(
          //                                   side: const BorderSide(
          //                                       width: 0.50,
          //                                       color: Color(0xFFFF6154)),
          //                                   borderRadius:
          //                                       BorderRadius.circular(100),
          //                                 ),
          //                               ),
          //                               child: Center(
          //                                 child: Text(
          //                                   'Claim Reward',
          //                                   style: TextStyle(
          //                                     color: const Color(0xFFFF6154),
          //                                     fontSize: 13.sp,
          //                                     fontFamily: 'Recoleta',
          //                                     fontWeight: FontWeight.w400,
          //                                   ),
          //                                 ),
          //                               ),
          //                             ).onTap(() {
          //                               Navigator.pop(context);
          //                             }),
          //                           )
          //                         ],
          //                       );
          //                     })
          //                 : ScaffoldMessenger.of(context).showSnackBar(
          //                     SnackBar(
          //                       backgroundColor: primaryColor,
          //                       content: const Text(
          //                         "Cannot claim rewards yet. Please wait for 24 hours.",
          //                         style: TextStyle(
          //                             color: Colors.white,
          //                             fontFamily: "Recoleta"),
          //                       ),
          //                     ),
          //                   );
          //           }
          //         }),
          //       ]),
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }
}

class DialogTile extends StatelessWidget {
  final int number;
  final String image;
  final String text;

  const DialogTile({super.key, required this.number, required this.text, required this.image});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Image.asset(image, width: 50.w),
                Text(
                  number.toString(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontFamily: 'Recoleta',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ).w(40.w),
            Text(
              text,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 20.sp,
                fontFamily: 'Recoleta',
                fontWeight: FontWeight.w400,
              ),
            )
          ],
        ),
        8.verticalSpace,
        Divider(
          color: softGray,
          thickness: .5.h,
        ).w(282.w),
      ],
    ).wh(292.w, 75);
  }
}
