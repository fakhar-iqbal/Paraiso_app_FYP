import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:paraiso/widgets/home_chip.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeChipsController extends GetxController {
  var activeChip = 0.obs;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    //   load from storage
    GetStorage storage = GetStorage();
    activeChip.value = storage.read('activeChip') ?? 0;
  }

  @override
  void onClose() {
    // save to storage
    GetStorage storage = GetStorage();
    storage.write('activeChip', activeChip.value);
    super.onClose();
  }

  void setActiveChip(int index) {
    activeChip.value = index;
  }
}

class HomeChipsRow extends StatefulWidget {
  const HomeChipsRow({super.key});

  @override
  State<HomeChipsRow> createState() => _HomeChipsRowState();
}

class _HomeChipsRowState extends State<HomeChipsRow> {
  @override
  Widget build(BuildContext context) {
    return HStack(alignment: MainAxisAlignment.spaceBetween, axisSize: MainAxisSize.max, [
      20.horizontalSpace,
      const HomeChip(name: 'Restaurants', index: 0,iconName: 'restaurantTab.png'),
      20.horizontalSpace,
      const HomeChip(name: "Trends", index: 1),
      // 14.horizontalSpace,
      // const HomeChip(name: 'All', index: 2),
    ]).scrollHorizontal().wh(380.w, 60.h).centered();
  }
}
