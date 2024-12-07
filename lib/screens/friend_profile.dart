import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paraiso/routes/router.dart';
import 'package:paraiso/screens/send_gifts.dart';
import 'package:velocity_x/velocity_x.dart';

import '../util/theme/theme_constants.dart';
import '../widgets/profile_res_tile.dart';

class FriendProfile extends StatelessWidget {
  final Map<String, dynamic> user;
  const FriendProfile({Key? key, required this.user}) : super(key: key);

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
              decoration: BoxDecoration(
                  color: softBlack, borderRadius: BorderRadius.circular(50.r)),
              padding: EdgeInsets.only(left: 10.w),
              child: const Icon(Icons.arrow_back_ios)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            user['userName'],
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
          Row(
            children: [
              CircleAvatar(
                radius: 40.r,
                backgroundImage: NetworkImage(user['photo'] != null &&
                        user['photo'] != ""
                    ? user['photo']
                    : "https://firebasestorage.googleapis.com/v0/b/paraiso-a6ec6.appspot.com/o/dummy_profile.png?alt=media&token=1d8ab187-9695-4450-a03c-a5dda90b7ece"),
              ),
              17.horizontalSpace,
              VStack([
                Text(
                  user['userName'],
                  style: TextStyle(
                    color: const Color(0xFFE4E4E4),
                    fontSize: 20.sp,
                    fontFamily: 'Recoleta',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                5.verticalSpace,
                Text(
                  user['schoolName'],
                  style: TextStyle(
                    color: const Color(0xFFE4E4E4),
                    fontSize: 18.sp,
                    fontFamily: 'Recoleta',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                15.verticalSpace,
                GestureDetector(
                  onTap: () {
                    AppRouter.rootNavigatorKey.currentState!.push(
                      MaterialPageRoute(
                        builder: (context) => SendGifts(
                          user: user,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 150.w,
                    height: 35.32,
                    decoration: ShapeDecoration(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(
                            width: 0.50, color: Color(0xFF2F58CD)),
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.sendRewards,
                          style: const TextStyle(
                            color: Color(0xFF2F58CD),
                            fontSize: 14,
                            fontFamily: 'Recoleta',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        5.horizontalSpace,
                        const Icon(
                          Icons.arrow_forward_ios,
                          color: Color(0xFF2F58CD),
                          size: 13,
                        )
                      ],
                    ),
                  ),
                ),
              ]),
            ],
          ).pLTRB(25.w, 0.h, 25.w, 25.h),
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
                    'Paraiso',
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
                  13.verticalSpace,
                ]),
                Row(children: [
                  Text(
                    user['rewards'].toString(),
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
          //   restaurant  card 1
          SizedBox(
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
        ],
      ),
    );
  }
}

List<dynamic> getTop2RestaurantsWithMostCoconuts(
    Map<String, dynamic> userObject) {
  try {
    final List<dynamic> restaurantRewards =
        userObject['restaurantRewards'] ?? [];
    restaurantRewards.sort((a, b) => b['Coconut'].compareTo(a['Coconut']));
    final List<dynamic> top2Restaurants = (restaurantRewards.take(2).toList());
    return top2Restaurants;
  } catch (e) {
    throw Exception('Failed to get top 2 restaurants: $e');
  }
}
