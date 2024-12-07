import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppLogo extends StatelessWidget {
  final double height;
  final double width;

  const AppLogo({Key? key, required this.height, required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      "assets/images/paraiso_logo.svg",
      // color:Colors.green,
      fit: BoxFit.contain,
      height: height.h,
      width: width.w,
    );
  }
}
