import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/home_chips_row.dart';

class HomeChip extends StatelessWidget {
  final String name;
  final int index;
  final String iconName;

  const HomeChip({super.key, required this.name, required this.index,  this.iconName= 'friendsTab.png'});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Get.find<HomeChipsController>().setActiveChip(index);
        },
        child: Container(
          width: 150.w,
          height: 50.h,
          decoration: BoxDecoration(
            color: Get.find<HomeChipsController>().activeChip.value == index
                ? Colors.white
                : softBlack,
            border: Border.all(
              color: Colors.white,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(30.0),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/$iconName',
                width: 20.w,
                height: 20.h,
                color: Get.find<HomeChipsController>().activeChip.value == index
                    ? Colors.black
                    : Colors.white,
              ),
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,
                  color: Get.find<HomeChipsController>().activeChip.value == index
                      ? Colors.black
                      : Colors.white,
                ),
              )

              // TextButton(
              //   onPressed: () {
              //     switch (index) {
              //       case 0:
              //         Get.find<HomeChipsController>().setActiveChip(index);
              //         break;
              //       case 1:
              //         Get.find<HomeChipsController>().setActiveChip(index);
              //         break;
              //       case 2:
              //         Get.find<HomeChipsController>().setActiveChip(index);
              //         break;
              //       default:
              //         Get.find<HomeChipsController>().setActiveChip(index);
              //     }
              //   },
              //   style: TextButton.styleFrom(
              //     padding: const EdgeInsets.all(0),
              //     primary: onNeutralColor,
              //     textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
              //       fontWeight: FontWeight.w700,
              //       color: Get.find<HomeChipsController>().activeChip.value == index
              //           ? Colors.red
              //           : Colors.white,
              //     ),
              //   ),
              //   child: AutoSizeText(name,style: Theme.of(context).textTheme.titleMedium?.copyWith(
              //     color: Get.find<HomeChipsController>().activeChip.value == index
              //         ? Colors.black
              //         : Colors.white,
              //   )),
              // ),
            ],
          ),
        ),
      ),

    );
  }

//   @override
//   Widget build(BuildContext context) {
//     return Obx(
//       () => ChoiceChip(
//         label: AutoSizeText(name),
//         labelPadding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//         selected: Get.find<HomeChipsController>().activeChip.value == index,
//         onSelected: (bool selected) {
//           switch (index) {
//             case 0:
//               Get.find<HomeChipsController>().setActiveChip(index);
//               break;
//             case 1:
//               Get.find<HomeChipsController>().setActiveChip(index);
//               break;
//             case 2:
//               Get.find<HomeChipsController>().setActiveChip(index);
//               break;
//           }
//         },
//         showCheckmark: false,
//         backgroundColor: softBlack,
//         selectedColor: softBlack,
//         labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
//               fontWeight: FontWeight.w700,
//               color: Get.find<HomeChipsController>().activeChip.value == index
//                   ? onNeutralColor
//                   : null,
//             ),
//         shape: StadiumBorder(
//           side: BorderSide(
//             color: Get.find<HomeChipsController>().activeChip.value == index
//                 ? primaryColor
//                 : Colors.transparent,
//             width: Get.find<HomeChipsController>().activeChip.value == index
//                 ? 5
//                 : 0,
//           ),
//         ),
//       ),
//     );
//   }
}
