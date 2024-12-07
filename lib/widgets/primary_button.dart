import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:line_icons/line_icon.dart';
import 'package:paraiso/util/theme/theme_constants.dart';

class PrimaryButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final IconData? icon;
  final bool enabled;
  final bool? isPrimary;
  final Color? color;

  const PrimaryButton({Key? key, required this.onPressed, required this.child, this.icon, this.enabled = true, this.isPrimary = true, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return ElevatedButton(
          onPressed: enabled ? onPressed : null,
          // <-- Text
          style: ElevatedButton.styleFrom(
            backgroundColor: color ?? primaryColor,
            foregroundColor: onPrimaryColor,
            disabledBackgroundColor: softBlack,
            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            // TextStyle(
            //   fontSize: 18,
            //   fontWeight: FontWeight.w700,
            //   color: onNeutralColor,
            //   height: 24 / 18,
            // ),
            shape: const StadiumBorder(),
            minimumSize: Size(200.w, 60.h),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              child, // <-- Text
              const SizedBox(
                width: 5,
              ),
              // icon from svg

              LineIcon(
                icon!,
                size: 20.sp,
                color: onPrimaryColor,
                semanticLabel: "icon",
              ),
              // SvgPicture.asset(
              //   "assets/images/arrow_forward.svg",
              //   fit: BoxFit.contain,
              //   height: 14.h,
              //   width: 7.w,
              // ),
            ],
          ));
    }

    return ElevatedButton(
        onPressed: enabled ? onPressed : null,
        // <-- Text
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          disabledBackgroundColor: softBlack,
          textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          // TextStyle(
          //   fontSize: 18,
          //   fontWeight: FontWeight.w700,
          //   color: onNeutralColor,
          //   height: 24 / 18,
          // ),
          shape: const StadiumBorder(),
          minimumSize: Size(200.w, 60.h),
        ),
        child: child);
  }
}
