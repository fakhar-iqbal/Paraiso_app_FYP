import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:velocity_x/velocity_x.dart';

import '../util/theme/theme_constants.dart';

class NormalAppbar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final bool? hasSearchIcon;

  const NormalAppbar({Key? key, this.title, this.hasSearchIcon})
      : super(key: key);

  @override
  State<NormalAppbar> createState() => _NormalAppbarState();

  @override
  Size get preferredSize => Size.fromHeight(78.h);
}

class _NormalAppbarState extends State<NormalAppbar> {
  var actions = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.hasSearchIcon != null && widget.hasSearchIcon!) {
      actions.add(
        Container(
          margin: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: SvgPicture.asset("assets/icons/search.svg"),
            onPressed: () {},
          ).wh(53.w, 53.h).box.color(softBlack).roundedFull.make(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Container(
            height: 53.h,
            width: 53.h,
            decoration: BoxDecoration(
                color: softBlack, borderRadius: BorderRadius.circular(50)),
            padding: EdgeInsets.only(left: 10.w),
            child: const Icon(Icons.arrow_back_ios)),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      centerTitle: true,
      title: widget.title != null
          ? Center(
              child: Text(
                widget.title!,
                style: TextStyle(
                  color: white,
                  fontSize: 25.sp,
                  fontFamily: 'Recoleta',
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : const Text(""),
      actions: [
        ...actions,
        25.horizontalSpace,
      ],
    );
  }

  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(60.h);
}
