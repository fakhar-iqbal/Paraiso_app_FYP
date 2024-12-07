import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:velocity_x/velocity_x.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return VxBox(
      child: Column(
        children: [
          32.verticalSpace,
          // 'Settings'.text.xl2.bold.make(),
        ],
      ),
    ).make();
  }
}
