import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InviteScreen extends StatefulWidget {
  const InviteScreen({Key? key}) : super(key: key);

  @override
  State<InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<InviteScreen> {
  Future<void> shareOptions() async {
    try {
      await Share.share('check out my website https://example.com', subject: 'Look what I made!');
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            AppLocalizations.of(context)!.inviteFriends,
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
          100.verticalSpace,
          Center(
            child: SvgPicture.asset(
              "assets/images/invite group.svg",
              fit: BoxFit.contain,
              width: 300,
            ),
          ),
          24.verticalSpace,
          Center(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: AppLocalizations.of(context)!.youCanInviteOnly,
                    style: TextStyle(
                      color: const Color(0xFFBDBDBD),
                      fontSize: 20.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: ' ${AppLocalizations.of(context)!.threeFriends}',
                    style: TextStyle(
                      color: const Color(0xFF2F58CD),
                      fontSize: 20.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          60.verticalSpace,
          Text(
            AppLocalizations.of(context)!.inviteVia,
            style: TextStyle(
              color: const Color(0xFFE4E4E4),
              fontSize: 23.sp,
              fontFamily: 'Recoleta',
              fontWeight: FontWeight.w700,
            ),
          ).pLTRB(25.w, 0.h, 0.w, 0.h),
          16.verticalSpace,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ShareTile(
                name: AppLocalizations.of(context)!.copyLink,
                image: "Link.svg",
                color: const Color(0xFF353535),
              ).onTap(() {
                shareOptions();
              }),
              const ShareTile(
                name: "Facebook",
                image: "facebook.svg",
                color: Color(0xFF3B5998),
              ).onTap(() {
                shareOptions();
              }),
              //wa
              const ShareTile(
                name: "WhatsApp",
                image: "whatsapp.svg",
                color: Color(0xFF25D366),
              ).onTap(() {
                shareOptions();
              }),
              //mail, phone
              const ShareTile(
                name: "Mail",
                image: "mail.svg",
                color: Color(0xFF0971BD),
              ).onTap(() {
                shareOptions();
              }),
              const ShareTile(
                name: "Phone",
                image: "phone.svg",
                color: Color(0xFF6FD454),
              ).onTap(() {
                shareOptions();
              }),
            ],
          ).pLTRB(5.w, 0.h, 0.w, 0.h),
        ],
      ),
    );
  }
}

class ShareTile extends StatelessWidget {
  final String name;
  final String image;
  final Color color;

  const ShareTile({
    Key? key,
    required this.name,
    required this.image,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        //   round icon
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: SvgPicture.asset(
              "assets/images/$image",
              fit: BoxFit.contain,
              width: 50.w,
            ),
          ),
        ),
        7.verticalSpace,
        Text(
          name,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFFBDBDBD),
            fontSize: 13.sp,
            fontFamily: 'Recoleta',
            fontWeight: FontWeight.w400,
          ),
        )
      ],
    );
  }
}
