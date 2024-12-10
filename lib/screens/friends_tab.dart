import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paraiso/routes/router.dart';
import 'package:paraiso/screens/friend_profile.dart';
import 'package:paraiso/screens/invite_screen.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:velocity_x/velocity_x.dart';

import '../controllers/friends_controller.dart';
import '../repositories/customer_auth_repo.dart';

class FriendsTab extends StatefulWidget {
  const FriendsTab({super.key});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  late FriendsController _friendsController;
  final customerAuth = CustomerAuthRep();

  @override
  void didChangeDependencies() async {
    print(SharedPreferencesHelper.getCustomerType());
    if (SharedPreferencesHelper.getCustomerType() != 'guest') {
      _friendsController =
          Provider.of<FriendsController>(context, listen: false);
      final currentCustomer = await customerAuth.getCurrentUser();
      final email = currentCustomer['email'];
      await _friendsController.getFriends(email);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   backgroundColor: neutralColor,
      //   leading: IconButton(
      //     icon: Container(
      //         height: 53.h,
      //         width: 53.w,
      //         decoration: BoxDecoration(
      //             color: softBlack, borderRadius: BorderRadius.circular(50)),
      //         padding: EdgeInsets.only(left: 10.w),
      //         child: const Icon(Icons.arrow_back_ios)),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      //   title: SvgPicture.asset(
      //     'assets/images/paraiso_logo.svg',
      //     width: 37.w,
      //     height: 30.h,
      //   ),
      //   centerTitle: true,
      // ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        child: ListView(
          physics: const ClampingScrollPhysics(),
          children: [
            // invite
            Container(
              margin: EdgeInsets.fromLTRB(25.w, 0.h, 25.w, 0.h),
              padding: EdgeInsets.symmetric(horizontal: 33.w, vertical: 25.h),
              width: 380.w,
              decoration: BoxDecoration(
                color: Color(0xFF2A2A2A),
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: Color(0xFFF3EEDD),
                  width: 1.w,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SvgPicture.asset(
                    "assets/images/Friends_Users_280_6467.svg",
                    fit: BoxFit.contain,
                    width: 45.5.w,
                  ),
                  GestureDetector(
                    onTap: () {
                      // push a material page route
                      AppRouter.rootNavigatorKey.currentState!.push(
                        MaterialPageRoute(
                          builder: (context) => const InviteScreen(),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.inviteFriends,
                          style: TextStyle(
                            color: const Color(0xFFBDBDBD),
                            fontSize: 20.sp,
                            fontFamily: 'Recoleta',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        14.horizontalSpace,
                        Icon(
                          Icons.arrow_forward_ios,
                          color: softGray,
                          size: 25.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            10.verticalSpace,
            // Container(
            //   margin: EdgeInsets.fromLTRB(25.w, 0.h, 25.w, 0.h),
            //   padding: EdgeInsets.symmetric(horizontal: 33.w, vertical: 15.h),
            //   width: 380.w,
            //   decoration: BoxDecoration(
            //     color: Color(0xFF2A2A2A),
            //     borderRadius: BorderRadius.circular(22.r),
            //     border: Border.all(
            //       color: Color(0xFFF3EEDD),
            //       width: 1.w,
            //     ),
            //   ),
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       Icon(
            //         Icons.link,
            //         color: const Color(0xFFBDBDBD),
            //         size: 35.sp,
            //       ),
            //       GestureDetector(
            //         onTap: () {
            //           final Uri url = Uri.parse(
            //               'https://www.getparaiso.com/f/2ba798fe-db6f-4e40-9c69-0295552961ec');
            //           Future<void> _launchUrl() async {
            //             if (!await launchUrl(url)) {
            //               throw Exception('Could not launch $url');
            //             }
            //           }

            //           _launchUrl();
            //         },
            //         child: Row(
            //           children: [
            //             Text(
            //               "Programme de parrainage",
            //               style: TextStyle(
            //                 color: const Color(0xFFBDBDBD),
            //                 fontSize: 19.sp,
            //                 fontFamily: 'Recoleta',
            //                 fontWeight: FontWeight.w400,
            //               ),
            //             ),
            //             14.horizontalSpace,
            //             Icon(
            //               Icons.arrow_forward_ios,
            //               color: softGray,
            //               size: 25.sp,
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            20.verticalSpace,

            //friends list
            Text(
              AppLocalizations.of(context)!.friendsList,
              style: TextStyle(
                color: const Color(0xFFE4E4E4),
                fontSize: 23.sp,
                fontFamily: 'Recoleta',
                fontWeight: FontWeight.w700,
              ),
            ).px(33.w),

            20.verticalSpace,

            //   friends tiles
            Consumer<FriendsController>(
              builder: (context, value, child) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * .45,
                  child: ListView.builder(
                    itemCount: value.friendsList.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          FriendTile(
                              user: value.friendsList[index],
                              name: value.friendsList[index]['userName'],
                              image: value.friendsList[index]['photo'] !=
                                          null &&
                                      value.friendsList[index]['photo'] != ""
                                  ? value.friendsList[index]['photo']
                                  : "https://firebasestorage.googleapis.com/v0/b/paraiso-a6ec6.appspot.com/o/dummy_profile.png?alt=media&token=1d8ab187-9695-4450-a03c-a5dda90b7ece"),
                          10.verticalSpace,
                        ],
                      );
                    },
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}

class FriendTile extends StatelessWidget {
  final Map<String, dynamic> user;
  final String name;
  final String image;

  // final bool isOnline;

  const FriendTile({
    Key? key,
    required this.name,
    required this.image,
    required this.user,
    // required this.isOnline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(25.w, 0.h, 25.w, 15.h),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      width: 380.w,
      // height: 90.h,
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: Color(0xFFF3EEDD),
          width: 1.w,
        ),
      ),
      child: Row(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30.r,
                backgroundImage: NetworkImage(image),
              ),
              14.horizontalSpace,
              Text(
                name,
                style: TextStyle(
                  color: const Color(0xFFE4E4E4),
                  fontSize: 18.sp,
                  fontFamily: 'Recoleta',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          // isOnline
          //     ? Container(
          //         width: 10.w,
          //         height: 10.h,
          //         decoration: BoxDecoration(
          //           color: Color(0xFF00FF00),
          //           borderRadius: BorderRadius.circular(50.h),
          //         ),
          //       )
          //     : Container(
          //         width: 10.w,
          //         height: 10.h,
          //         decoration: BoxDecoration(
          //           color: Color(0xFFBDBDBD),
          //           borderRadius: BorderRadius.circular(50.h),
          //         ),
          //       ),
        ],
      ),
    ).onTap(() {
      // push a material page route
      AppRouter.rootNavigatorKey.currentState!.push(
        MaterialPageRoute(
          builder: (context) => FriendProfile(
            user: user,
          ),
        ),
      );
    });
  }
}
