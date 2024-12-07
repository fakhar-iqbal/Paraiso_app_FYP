import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paraiso/controllers/categories_controller.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:provider/provider.dart';

class SortByDistanceChip extends StatelessWidget {
  final int index;
  final String name;

  const SortByDistanceChip({Key? key, required this.index, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoriesProvider>(context);
    return ElevatedButton(
      onPressed: () {
        if (categoryProvider.activeChip == index) {
          categoryProvider.setActiveChip(100);
          categoryProvider.setSelectedCategory('');
        } else {
          categoryProvider.setActiveChip(index);
          categoryProvider.setSelectedCategory(name);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: softBlack,
        foregroundColor: onNeutralColor,
        disabledBackgroundColor: softBlack,
        textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
        side: BorderSide(
          color: categoryProvider.activeChip == index ? primaryColor : softBlack,
          width: 1,
        ),
        shape: const StadiumBorder(),
        minimumSize: Size(100.w, 60.h),
      ),
      child: AutoSizeText(name),
    );
  }
}
