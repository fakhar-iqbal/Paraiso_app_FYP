import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';

class SizedIcons extends StatelessWidget {
  final double? height;
  final double? width;
  final String svgPath;
  final double? scale;
  final Color color;

  const SizedIcons(
      {Key? key,
      this.height,
      this.width,
      required this.svgPath,
      this.scale,
      this.color = const Color(0xFFBDBDBD)})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return scale != null
        ? Transform.scale(
            scale: scale,
            child: SizedBox(
                height: height ?? height?.h,
                width: width ?? width?.w,
                child: SvgPicture.asset(
                  svgPath,
                  fit: BoxFit.contain,
                  color: color,
                  theme: SvgTheme(currentColor: color),
                  // fit: BoxFit.scaleDown
                )),
          )
        : SizedBox(
            height: height ?? height?.h,
            width: width ?? width?.w,
            child: SvgPicture.asset(
              svgPath,
              color: color,
              fit: BoxFit.contain,
              theme: SvgTheme(currentColor: color),
            ));
  }
}
