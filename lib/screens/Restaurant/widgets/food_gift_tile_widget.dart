import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../../util/theme/theme_constants.dart';

class FoodGiftTileWidget extends StatefulWidget {
  final String image;
  final bool toggled;
  final Function(bool) onSelect;

  const FoodGiftTileWidget(
      {super.key,
      required this.image,
      required this.onSelect,
      required this.toggled});

  @override
  State<FoodGiftTileWidget> createState() => _FoodGiftTileWidgetState();
}

class _FoodGiftTileWidgetState extends State<FoodGiftTileWidget> {
  @override
  Widget build(BuildContext context) {
    // on tap at end
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 150.h,
        minHeight: 150.h,
      ),
      child: Container(
        width: 119.w,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(22),
            ),
            side: BorderSide(
                width: widget.toggled ? 1.5 : .5,
                strokeAlign: BorderSide.strokeAlignCenter,
                color: widget.toggled ? primaryColor : softGray),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.image.contains(".svg")
                ? SvgPicture.asset(
                    'assets/images/${widget.image}',
                    width: 37.w,
                  )
                : Image.asset(
                    "assets/images/${widget.image}",
                    width: 78.h,
                    height: 78.h,
                  ),
          ],
        ),
      ).onTap(() {
        widget.onSelect(widget.toggled);
        setState(() {});
      }),
    );
  }
}
