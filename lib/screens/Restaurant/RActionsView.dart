import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:paraiso/controllers/Restaurants/res_auth_controller.dart';
import 'package:paraiso/screens/Restaurant/RMenuView.dart';
import 'package:paraiso/screens/Restaurant/RProductsView.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../controllers/Restaurants/menu_controller.dart';
import '../../util/theme/theme_constants.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/svgtextfield.dart';

class RActionsView extends StatefulWidget {
  const RActionsView({Key? key}) : super(key: key);

  @override
  State<RActionsView> createState() => _RActionsViewState();
}

class _RActionsViewState extends State<RActionsView> {
  bool isDiscount = true;
  String discountTxt = '';
  String selectedItem = "";
  int selectedTileIndex = -1;
  String menutxt = 'Tous les articles';
  String? selectedMenuItem;

  TextEditingController amountController = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // menutxt = AppLocalizations.of(context)!.allItemsLabel;
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Column(
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
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.fromRGBO(53, 53, 53, 1)),
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
                      AppLocalizations.of(context)!.actions,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 23.sp),
                    ),
                    const Spacer(),
                    const Spacer()
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 30.h),
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(53, 53, 53, 1),
                        borderRadius: BorderRadius.circular(40.r),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  isDiscount = true;
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 40.w, vertical: 15.h),
                                decoration: BoxDecoration(
                                  color: isDiscount == true
                                      ? const Color(0xFF2F58CD)
                                      : const Color.fromRGBO(53, 53, 53, 1),
                                  borderRadius: BorderRadius.circular(40.r),
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!.discount,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp),
                                ),
                              )),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                isDiscount = false;
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 40.w, vertical: 15.h),
                              decoration: BoxDecoration(
                                color: isDiscount == false
                                    ? const Color(0xFF2F58CD)
                                    : const Color.fromRGBO(53, 53, 53, 1),
                                borderRadius: BorderRadius.circular(40.r),
                              ),
                              child: Text(
                                AppLocalizations.of(context)!.freeProductLabel,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: isDiscount ? 60.h : 20.h,
                ),
                Text(
                  isDiscount
                      ? AppLocalizations.of(context)!.selectAmountLabel
                      : AppLocalizations.of(context)!.selectProductLabel,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 25.sp),
                ),
                SizedBox(
                  height: isDiscount ? 50.h : 1.h,
                ),
                isDiscount == false
                    ? Consumer<MenuItemsController>(
                        builder: (context, value, child) {
                          final products = value.menu;
                          final productsToDisplay =
                              filterMenuItemsByCategory(products, menutxt);

                          Set<String> uniqueCategories = <String>{};
                          for (var product in products) {
                            uniqueCategories.add(product.type);
                          }
                          List<String> categoriesWithProducts =
                              uniqueCategories.toList();
                          categoriesWithProducts.insert(0, 'Tous les articles');

                          return Container(
                            // height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width,
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // DropdownButton(
                                //     items: [
                                //       'All Items',
                                //       'Drinks',
                                //       'Fast Food',
                                //       'Sweets',
                                //       '+ Add New'
                                //     ]
                                //         .map((e) => DropdownMenuItem(
                                //               value: e,
                                //               child: Text(e),
                                //             ))
                                //         .toList(),
                                //     value: menutxt,
                                //     style: TextStyle(
                                //         fontSize: 12.sp,
                                //         fontWeight: FontWeight.w400),
                                //     icon: Icon(
                                //       Icons.keyboard_arrow_down,
                                //       size: 20.sp,
                                //     ),
                                //     padding: EdgeInsets.zero,
                                //     underline: Container(),
                                //     onChanged: (val) {
                                //       if (val != '+ Add New') {
                                //         setState(() {
                                //           menutxt = val!;
                                //         });
                                //       }
                                //     }),
                                DropdownButton(
                                  items: categoriesWithProducts
                                      .map((e) => DropdownMenuItem(
                                            value: e,
                                            child: Text(e),
                                          ))
                                      .toList(),
                                  value: menutxt,
                                  style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w400),
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
                                  height: 10.h,
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * .47,
                                  child: ListView.builder(
                                      itemCount: productsToDisplay.length,
                                      shrinkWrap: true,
                                      padding: EdgeInsets.zero,
                                      itemBuilder: (context, index) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (selectedMenuItem ==
                                                  productsToDisplay[index]
                                                      .name) {
                                                selectedMenuItem = "";
                                              } else {
                                                selectedMenuItem =
                                                    productsToDisplay[index]
                                                        .name;
                                              }
                                            });

                                            selectedItem =
                                                productsToDisplay[index].itemId;
                                          },
                                          child: MenuItemTile(
                                            name: productsToDisplay[index].name,
                                            type: productsToDisplay[index].type,
                                            price:
                                                '${productsToDisplay[index].discountedPrice}€',
                                            photo:
                                                productsToDisplay[index].photo,
                                            isSelected: selectedMenuItem ==
                                                productsToDisplay[index].name,
                                          ),
                                        );
                                      }),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    // ? GridView(
                    //     scrollDirection: Axis.vertical,
                    //     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    //       crossAxisCount: 3,
                    //       crossAxisSpacing: 11.w,
                    //       mainAxisSpacing: 16.5.h,
                    //       childAspectRatio: 0.95,
                    //     ),
                    //     children: [
                    //       FoodGiftTileWidget(
                    //         image: "Send Gifts_burger 1_346_10807.png",
                    //         onSelect: (selected) {
                    //           if (selectedTileIndex == 0) {
                    //             setState(() {
                    //               selectedItem = "";
                    //               selectedTileIndex = -1;
                    //             });
                    //           } else {
                    //             setState(() {
                    //               selectedItem =
                    //                   AppConstants.giftItems[GiftItems.burger]!;
                    //               selectedTileIndex = 0;
                    //             });
                    //           }
                    //         },
                    //         toggled: selectedTileIndex == 0,
                    //       ),
                    //       FoodGiftTileWidget(
                    //         image: "send_pizza.png",
                    //         onSelect: (selected) {
                    //           if (selectedTileIndex == 1) {
                    //             setState(() {
                    //               selectedItem = "";
                    //               selectedTileIndex = -1;
                    //             });
                    //           } else {
                    //             setState(() {
                    //               selectedItem =
                    //                   AppConstants.giftItems[GiftItems.pizza]!;
                    //               selectedTileIndex = 1;
                    //             });
                    //           }
                    //         },
                    //         toggled: selectedTileIndex == 1,
                    //       ),
                    //       FoodGiftTileWidget(
                    //         image: "Food Filter_OBJECTS_458_13901.svg",
                    //         onSelect: (selected) {
                    //           if (selectedTileIndex == 2) {
                    //             setState(() {
                    //               selectedItem = "";
                    //               selectedTileIndex = -1;
                    //             });
                    //           } else {
                    //             setState(() {
                    //               selectedItem =
                    //                   AppConstants.giftItems[GiftItems.coconut]!;
                    //               selectedTileIndex = 2;
                    //             });
                    //           }
                    //         },
                    //         toggled: selectedTileIndex == 2,
                    //       ),
                    //       FoodGiftTileWidget(
                    //         image: "Send Gifts_float 1_352_11143.png",
                    //         onSelect: (selected) {
                    //           if (selectedTileIndex == 3) {
                    //             setState(() {
                    //               selectedItem = "";
                    //               selectedTileIndex = -1;
                    //             });
                    //           } else {
                    //             setState(() {
                    //               selectedItem =
                    //                   AppConstants.giftItems[GiftItems.float]!;
                    //               selectedTileIndex = 3;
                    //             });
                    //           }
                    //         },
                    //         toggled: selectedTileIndex == 3,
                    //       ),
                    //       FoodGiftTileWidget(
                    //         image: "Send Gifts_buritto 1_352_11140.png",
                    //         onSelect: (selected) {
                    //           if (selectedTileIndex == 4) {
                    //             setState(() {
                    //               selectedItem = "";
                    //               selectedTileIndex = -1;
                    //             });
                    //           } else {
                    //             setState(() {
                    //               selectedItem =
                    //                   AppConstants.giftItems[GiftItems.buritto]!;
                    //               selectedTileIndex = 4;
                    //             });
                    //           }
                    //         },
                    //         toggled: selectedTileIndex == 4,
                    //       ),
                    //       FoodGiftTileWidget(
                    //         image: "Send Gifts_ice cream 1_352_11144.png",
                    //         onSelect: (selected) {
                    //           if (selectedTileIndex == 5) {
                    //             setState(() {
                    //               selectedItem = "";
                    //               selectedTileIndex = -1;
                    //             });
                    //           } else {
                    //             setState(() {
                    //               selectedItem =
                    //                   AppConstants.giftItems[GiftItems.icecream]!;
                    //               selectedTileIndex = 5;
                    //             });
                    //           }
                    //         },
                    //         toggled: selectedTileIndex == 5,
                    //       ),
                    //     ],
                    //   ).pLTRB(25.w, 0.h, 25.w, 16.h).h(350.h)
                    : Column(
                        children: [
                          Row(
                            children: [
                              _selectAmount('10%'),
                              SizedBox(
                                width: 10.w,
                              ),
                              _selectAmount('20%'),
                              SizedBox(
                                width: 10.w,
                              ),
                              _selectAmount('30%'),
                              SizedBox(
                                width: 10.w,
                              ),
                              _selectAmount('40%'),
                            ],
                          ),
                          SizedBox(
                            height: 10.h,
                          ),
                          Row(
                            children: [
                              _selectAmount('50%'),
                              SizedBox(
                                width: 10.w,
                              ),
                              _selectAmount('60%'),
                              SizedBox(
                                width: 10.w,
                              ),
                              _selectAmount('70%'),
                              SizedBox(
                                width: 10.w,
                              ),
                              _selectAmount('80%'),
                            ],
                          ),
                        ],
                      ),
                SizedBox(
                  height: isDiscount ? 60.h : 20.h,
                ),
                Consumer<MenuItemsController>(
                  builder: (context, value, child) {
                    return MaterialButton(
                      onPressed: () {
                        if (isDiscount) {
                          if (discountTxt != "") {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RProductsView(
                                          discount: discountTxt,
                                          // giftItem: const {},
                                          // isDiscount: isDiscount,
                                        )));
                          }
                        } else {
                          if (selectedItem != "") {
                            final authController = Provider.of<AuthController>(
                                context,
                                listen: false);
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(22.r),
                                      ),
                                      backgroundColor: softBlack,
                                      content: SingleChildScrollView(
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              12.verticalSpace,
                                              Text(
                                                  AppLocalizations.of(context)!
                                                      .chooseAmountOfCoconuts,
                                                  style: context.headlineSmall
                                                      ?.copyWith(
                                                    color: onPrimaryColor,
                                                  )),
                                              Form(
                                                key: formKey,
                                                onChanged: () {
                                                  formKey.currentState!
                                                      .validate();
                                                },
                                                child: Center(
                                                  child: SvgTextField(
                                                    hintText:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .amount,
                                                    controller:
                                                        amountController,
                                                    validator: (value) {
                                                      if (value!.isEmpty) {
                                                        return AppLocalizations
                                                                .of(context)!
                                                            .pleaseEnterAmount;
                                                      }
                                                      if (!value.isNum) {
                                                        return AppLocalizations
                                                                .of(context)!
                                                            .pleaseEnterAValidNumber;
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ]),
                                      ),
                                      actions: [
                                        PrimaryButton(
                                          icon: Icons.arrow_forward_ios,
                                          onPressed: () async {
                                            if (formKey.currentState!
                                                .validate()) {
                                              await value.setFreeItem(
                                                  authController.user!,
                                                  selectedItem, {
                                                "Coconut": double.parse(
                                                    amountController.text)
                                              });
                                              if (mounted) {
                                                Navigator.pop(context);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    backgroundColor:
                                                        primaryColor,
                                                    content: Center(
                                                      child: Text(
                                                        "Item set free for ${amountController.text} coconuts",
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontFamily:
                                                                "Recoleta"),
                                                      ),
                                                    ),
                                                    duration: const Duration(
                                                        seconds: 3),
                                                  ),
                                                );
                                              }
                                              amountController.clear();
                                              selectedMenuItem = '';
                                              selectedItem = '';
                                            }
                                          },
                                          child: value.setFreeItemLoader
                                              ? const CircularProgressIndicator()
                                              : Text(
                                                  AppLocalizations.of(context)!
                                                      .done,
                                                  style: TextStyle(
                                                    color:
                                                        const Color(0xFFE4E4E4),
                                                    fontSize: 18.sp,
                                                    fontFamily: 'Recoleta',
                                                    fontWeight: FontWeight.w700,
                                                  ),
                                                  maxLines: 1,
                                                ),
                                        ),
                                      ],
                                    ));
                          }
                        }
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
                            Text(AppLocalizations.of(context)!.continueText,
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.sp,
                                    color: Colors.white)),
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
                    );
                  },
                ),
                SizedBox(
                  height: 15.h,
                ),
                Consumer<MenuItemsController>(
                  builder: (context, value, child) {
                    return MaterialButton(
                      onPressed: () async {
                        if (isDiscount) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const RProductsView(
                                        discount: "",
                                        // giftItem: const {},
                                        // isDiscount: isDiscount,
                                      )));
                        } else {
                          if (selectedItem == "") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: primaryColor,
                                content: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .pleaseChooseAnItem,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Recoleta"),
                                  ),
                                ),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          } else {
                            final authController = Provider.of<AuthController>(
                                context,
                                listen: false);

                            await value.clearFreeItem(
                                authController.user!, selectedItem);

                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: primaryColor,
                                  content: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .clearedFreeItem,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: "Recoleta"),
                                    ),
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                              selectedItem = '';
                              selectedMenuItem = '';
                            }
                          }
                        }
                      },
                      height: 30.h,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      color: const Color(0xFF2F58CD),
                      child: SizedBox(
                        width: 225.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            value.clearFreeItemLoader
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    isDiscount
                                        ? AppLocalizations.of(context)!
                                            .clearDiscount
                                        : AppLocalizations.of(context)!
                                            .clearFreeItem,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18.sp,
                                        color: Colors.white)),
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
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectAmount(txt) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (discountTxt == txt) {
            setState(() {
              discountTxt = '';
            });
          } else {
            setState(() {
              discountTxt = txt;
            });
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 35.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18.r),
            color: discountTxt == txt
                ? const Color(0xFF2F58CD)
                : const Color.fromRGBO(53, 53, 53, 1),
          ),
          child: Center(
            child: Text(
              '$txt',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontSize: 18.sp),
            ),
          ),
        ),
      ),
    );
  }
}

class MenuItemTile extends StatefulWidget {
  final String name;
  final String type;
  final String price;
  final String photo;
  final bool isSelected;

  const MenuItemTile({
    Key? key,
    required this.name,
    required this.type,
    required this.price,
    required this.photo,
    required this.isSelected,
  }) : super(key: key);

  @override
  State<MenuItemTile> createState() => _MenuItemTileState();
}

class _MenuItemTileState extends State<MenuItemTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
      decoration: ShapeDecoration(
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(
            Radius.circular(22),
          ),
          side: BorderSide(
              width: widget.isSelected ? 1.5 : .5,
              strokeAlign: BorderSide.strokeAlignCenter,
              color: widget.isSelected ? primaryColor : softGray),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: Colors.white54,
            backgroundImage: NetworkImage(widget.photo),
          ),
          SizedBox(
            width: 20.w,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.name,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18.sp),
                ),
                Text(
                  widget.type,
                  maxLines: 2,
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 13.sp),
                ),
                SizedBox(
                  height: 5.h,
                ),
                Row(
                  children: [
                    Text(
                      widget.price,
                      maxLines: 2,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 18.sp),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
