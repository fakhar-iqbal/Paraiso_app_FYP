import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paraiso/controllers/Restaurants/menu_controller.dart';
import 'package:provider/provider.dart';

import '../../controllers/Restaurants/res_auth_controller.dart';
import '../../models/product_item.dart';
import '../../util/theme/theme_constants.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RProductsView extends StatefulWidget {
  final String discount;
  // final Map<String, dynamic> giftItem;
  // final bool isDiscount;
  const RProductsView({
    Key? key,
    required this.discount,
    // required this.giftItem,
    // required this.isDiscount,
  }) : super(key: key);

  @override
  State<RProductsView> createState() => _RProductsViewState();
}

class _RProductsViewState extends State<RProductsView> {
  List<ProductItem> selectedProducts = [];
  bool isAllSelect = false;

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context, listen: false);
    return Consumer<MenuItemsController>(
      builder: (context, value, child) {
        final products = value.menu;
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
                      AppLocalizations.of(context)!.products,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: "Recoleta", fontSize: 23.sp),
                    ),
                    const Spacer(),
                    const Spacer()
                  ],
                ),
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    selectedProducts.isEmpty
                        ? Text(
                            AppLocalizations.of(context)!.selectProducts,
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: "Recoleta", fontSize: 23.sp),
                          )
                        : RichText(
                            text: TextSpan(children: [
                            TextSpan(
                              text: isAllSelect == false ? '${selectedProducts.length.toString().length == 1 ? '0${selectedProducts.length}' : selectedProducts.length}' : '',
                              style: TextStyle(color: const Color(0xFF2F58CD), fontWeight: FontWeight.w700, fontFamily: "Recoleta", fontSize: 23.sp),
                            ),
                            TextSpan(
                              text: ' ${isAllSelect == false ? '' : '${AppLocalizations.of(context)!.all} '}${AppLocalizations.of(context)!.productsSelected}',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: "Recoleta", fontSize: 23.sp),
                            ),
                          ])),
                    selectedProducts.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                isAllSelect = !isAllSelect;
                              });

                              if (isAllSelect == true) {
                                setState(() {
                                  selectedProducts.clear();
                                  selectedProducts.addAll(products);
                                });
                              } else {
                                setState(() {
                                  selectedProducts.clear();
                                });
                              }
                            },
                            child: Icon(
                              Icons.list,
                              color: isAllSelect == false ? Colors.white70 : const Color(0xFF2F58CD),
                            ),
                          )
                        : Container()
                  ],
                ),
                SizedBox(
                  height: 20.h,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: ListView.builder(
                      itemCount: products.length,
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              if (selectedProducts.contains(products[index])) {
                                selectedProducts.remove(products[index]);
                              } else {
                                selectedProducts.add(products[index]);
                              }
                            });
                          },
                          child: Container(
                            margin: EdgeInsets.only(bottom: index == products.length ? 0 : 12.h),
                            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                            decoration: BoxDecoration(
                                color: const Color.fromRGBO(53, 53, 53, 1),
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: selectedProducts.contains(products[index]) ? const Color(0xFF2F58CD) : Colors.transparent)),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 30.r,
                                        backgroundColor: Colors.white54,
                                        backgroundImage: NetworkImage(products[index].photo),
                                      ),
                                      SizedBox(
                                        width: 20.w,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              products[index].name,
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontFamily: "Recoleta", fontSize: 16.sp),
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                            Text(
                                              '${products[index].discountedPrice.toString()}€',
                                              maxLines: 2,
                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontFamily: "Recoleta", fontSize: 13.sp),
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 10.w,
                                ),
                                selectedProducts.contains(products[index])
                                    ? Container(
                                        height: 20.h,
                                        width: 20.w,
                                        decoration: const BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF2F58CD)),
                                        child: Center(
                                          child: Icon(
                                            Icons.done,
                                            size: 15.sp,
                                            color: Colors.black,
                                          ),
                                        ),
                                      )
                                    : Container()
                              ],
                            ),
                          ),
                        );
                      }),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MaterialButton(
                      onPressed: () {
                        // if (widget.isDiscount) {
                        if (selectedProducts.isNotEmpty || isAllSelect != false) {
                          if (widget.discount == "") {
                            value.clearDiscount(authController.user!, selectedProducts.map((e) => e.itemId).toList());
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: primaryColor,
                                content: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.discountCleared,
                                    style: const TextStyle(fontFamily: "Recoleta", color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            value.setDiscount(authController.user!, selectedProducts.map((e) => e.itemId).toList(), widget.discount);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: primaryColor,
                                content: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.discountSet,
                                    style: const TextStyle(fontFamily: "Recoleta", color: Colors.white),
                                  ),
                                ),
                              ),
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: primaryColor,
                              content: Center(
                                child: Text(
                                  AppLocalizations.of(context)!.pleaseSelectProduct,
                                  style: const TextStyle(fontFamily: "Recoleta", color: Colors.white),
                                ),
                              ),
                            ),
                          );
                        }
                        // } else {
                        // if (widget.giftItem.isEmpty) {
                        //   value.clearFreeItem(authController.user!,
                        //       selectedProducts.map((e) => e.itemId).toList());
                        // } else {
                        //   if (selectedProducts.length > 1) {
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(
                        //         backgroundColor: primaryColor,
                        //         content: const Center(
                        //           child: Text(
                        //             'You can make only 1 product free.',
                        //             style: TextStyle(
                        //                 fontFamily: "Recoleta",
                        //                 color: Colors.white),
                        //           ),
                        //         ),
                        //       ),
                        //     );
                        //   } else if (selectedProducts.isEmpty) {
                        //     ScaffoldMessenger.of(context).showSnackBar(
                        //       SnackBar(
                        //         backgroundColor: primaryColor,
                        //         content: const Center(
                        //           child: Text(
                        //             'Please select a product to continue.',
                        //             style: TextStyle(
                        //                 fontFamily: "Recoleta",
                        //                 color: Colors.white),
                        //           ),
                        //         ),
                        //       ),
                        //     );
                        //   } else {
                        //     value.setFreeItem(authController.user!,
                        //         selectedProducts.first.itemId, widget.giftItem);
                        //     Navigator.pop(context);
                        //   }
                        // }
                        // }
                      },
                      height: 30.h,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      color: const Color(0xFF2F58CD),
                      child: SizedBox(
                        width: 120.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(AppLocalizations.of(context)!.done, style: TextStyle(fontWeight: FontWeight.w700, fontFamily: "Recoleta", fontSize: 18.sp, color: Colors.white)),
                            SizedBox(
                              width: 10.w,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 18.sp,
                              color: Colors.white,
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
