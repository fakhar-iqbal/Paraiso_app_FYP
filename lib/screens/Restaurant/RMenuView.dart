
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paraiso/screens/Restaurant/RAddItemView.dart';
import 'package:paraiso/screens/Restaurant/REditItemView.dart';
import 'package:provider/provider.dart';

import '../../controllers/Restaurants/menu_controller.dart';
import '../../controllers/Restaurants/res_auth_controller.dart';
import '../../models/product_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RMenuView extends StatefulWidget {
  const RMenuView({Key? key}) : super(key: key);

  @override
  State<RMenuView> createState() => _RMenuViewState();
}

class _RMenuViewState extends State<RMenuView> {
  String menutxt = 'Tous les articles';

  @override
  void didChangeDependencies() async {
    final menuItemsController = Provider.of<MenuItemsController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);
    await menuItemsController.fetchMenu(authController.user!.userId);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // menutxt = 'Tous les articles';
    // menutxt = AppLocalizations.of(context)!.allItemsLabel;
    return Consumer<MenuItemsController>(
      builder: (context, value, child) {
        final products = value.menu;
        final productsToDisplay = filterMenuItemsByCategory(products, menutxt);

        Set<String> uniqueCategories = <String>{};
        for (var product in products) {
          uniqueCategories.add(product.type);
        }
        List<String> categoriesWithProducts = uniqueCategories.toList();
        categoriesWithProducts.insert(0, 'Tous les articles');

        return Scaffold(
          body: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 50.h,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        height: 50.h,
                        width: 50.w,
                        margin: EdgeInsets.only(right: 5.w),
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(53, 53, 53, 1)),
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.only(left: 8.w),
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 20.sp,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      AppLocalizations.of(context)!.menu,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 23.sp),
                    ),
                    const Spacer(),
                    const Spacer()
                  ],
                ),
                SizedBox(
                  height: 30.h,
                ),
                DropdownButton(
                  items: categoriesWithProducts
                      .map((e) => DropdownMenuItem(
                    value: e,
                    child: Text(e),
                  ))
                      .toList(),
                  value: menutxt,
                  style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    size: 20.sp,
                  ),
                  padding: EdgeInsets.zero,
                  underline: Container(),
                  onChanged: (val) {
                    setState(() {
                      menutxt = val!;
                    });
                  },
                ),
                SizedBox(
                  height: 20.h,
                ),
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * .72,
                  child: ListView.builder(
                      itemCount: productsToDisplay.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => REditItemView(
                                      product: productsToDisplay[index],
                                    )));
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(22.r),
                              border: Border.all(
                                color: Color(0xFFF3EEDD),
                                width: 1.w,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 30.r,
                                  backgroundColor: Colors.white54,
                                  backgroundImage: NetworkImage(productsToDisplay[index].photo),
                                ),
                                SizedBox(
                                  width: 20.w,
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        productsToDisplay[index].name,
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18.sp),
                                      ),
                                      Text(
                                        productsToDisplay[index].type,
                                        maxLines: 2,
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 13.sp),
                                      ),
                                      SizedBox(
                                        height: 5.h,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            '${productsToDisplay[index].discountedPrice.toStringAsFixed(1)}€',
                                            maxLines: 2,
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18.sp),
                                          ),
                                          SizedBox(
                                            width: 30.h,
                                          ),
                                          MaterialButton(
                                            onPressed: () {},
                                            height: 50.h,
                                            padding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12.r),
                                                side: BorderSide(
                                                  color: Colors.grey.shade700,
                                                )),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  '+1',
                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 15.sp),
                                                ),
                                                SizedBox(
                                                  width: 6.w,
                                                ),
                                                Image.asset('assets/icons/objects.png')
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                ),
              ],
            ),
          ),
          floatingActionButton: SizedBox(
            height: 60.h,
            width: 55.w,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RAddItemView()));
              },
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFF2F58CD),
              elevation: 0.0,
              child: const Icon(Icons.add),
            ),
          ),
        );
      },
    );
  }
}

List<ProductItem> filterMenuItemsByCategory(List<ProductItem> allItems, String category) {
  print("category: $category");
  if (category == 'Tous les articles') {
    print("All items");
    return allItems;
  } else {
    print("selected items");
    return allItems.where((item) => item.type == category).toList();
  }
}

