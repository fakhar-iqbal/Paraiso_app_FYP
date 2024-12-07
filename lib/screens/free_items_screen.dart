import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../controllers/Restaurants/menu_controller.dart';
import '../controllers/customer_controller.dart';
import '../util/theme/theme_constants.dart';
import 'checkout.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FreeItemsScreen extends StatefulWidget {
  final String restaurantName;
  final String image;
  final String restaurantID;
  final num userRewards;
  const FreeItemsScreen({Key? key, required this.restaurantName, required this.image, required this.restaurantID, required this.userRewards}) : super(key: key);

  @override
  State<FreeItemsScreen> createState() => _FreeItemsScreenState();
}

class _FreeItemsScreenState extends State<FreeItemsScreen> {
  String menutxt = 'All Items';

  @override
  Widget build(BuildContext context) {
    menutxt = AppLocalizations.of(context)!.allItemsLabel;
    return Consumer<MenuItemsController>(
      builder: (context, value, child) {
        final products = value.menu;
        // final productsToDisplay = filterMenuItemsByCategory(products, menutxt);
        final filteredProducts = products.where((product) {
          return product.free.containsKey("Coconut") && product.free["Coconut"] > 0;
        }).toList();

        filteredProducts.sort((a, b) => a.free["Coconut"].compareTo(b.free["Coconut"]));

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
                      AppLocalizations.of(context)!.freeItems,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 23.sp),
                    ),
                    const Spacer(),
                    const Spacer()
                  ],
                ),
                SizedBox(
                  height: 30.h,
                ),
                // DropdownButton(
                //     items: [
                //       'All Items',
                //       'Drinks',
                //       'Fast Food',
                //       'Sweets',
                //     ]
                //         .map((e) => DropdownMenuItem(
                //               value: e,
                //               child: Text(e),
                //             ))
                //         .toList(),
                //     value: menutxt,
                //     style:
                //         TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w400),
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
                // SizedBox(
                //   height: 20.h,
                // ),
                ListView.builder(
                    itemCount: filteredProducts.length,
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          if (filteredProducts[index].free["Coconut"] > widget.userRewards) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: primaryColor,
                                content: Center(
                                  child: Text(
                                    AppLocalizations.of(context)!.youDontHaveEnoughCoconuts,
                                    style: const TextStyle(color: Colors.white, fontFamily: "Recoleta"),
                                  ),
                                ),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          } else {
                            final customerController = Provider.of<CustomerController>(context, listen: false);
                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                            final String? email = prefs.getString('currentCustomerEmail');
                            final String? userName = prefs.getString('currentCustomerUserName');

                            String formattedDate = DateFormat("yyyy-MM-dd hh:mm a").format(DateTime.now());

                            Map<String, dynamic> orderData = {
                              "clientId": email,
                              "items": [
                                {
                                  "id": filteredProducts[index].itemId,
                                  "name": filteredProducts[index].name,
                                  "price": filteredProducts[index].free["Coconut"],
                                  "quantity": 1,
                                  "size": '',
                                  "addOns": [],
                                }
                              ],
                              "photo": customerController.user['photo'] ?? "",
                              "time": formattedDate,
                              "restaurantId": widget.restaurantID,
                              "restaurantName": widget.restaurantName,
                              "status": "In Progress",
                              "totalPrice": filteredProducts[index].free["Coconut"],
                              "userName": userName,
                            };

                            if (mounted) {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Checkout(
                                            free: true,
                                            orderData: orderData,
                                          )));
                            }
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h).copyWith(right: 30.w),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(53, 53, 53, 1),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30.r,
                                backgroundColor: Colors.white54,
                                backgroundImage: NetworkImage(filteredProducts[index].photo),
                              ),
                              SizedBox(
                                width: 20.w,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      filteredProducts[index].name,
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 18.sp),
                                    ),
                                    Text(
                                      filteredProducts[index].type,
                                      maxLines: 2,
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 13.sp),
                                    ),
                                    SizedBox(
                                      height: 5.h,
                                    ),
                                    // Row(
                                    //   children: [
                                    //     Text(
                                    //       '\$${filteredProducts[index].discountedPrice}',
                                    //       maxLines: 2,
                                    //       style: TextStyle(
                                    //           color: Colors.white,
                                    //           fontWeight: FontWeight.w700,
                                    //           fontSize: 18.sp),
                                    //     ),
                                    //     SizedBox(
                                    //       width: 30.h,
                                    //     ),
                                    //     MaterialButton(
                                    //       onPressed: () {},
                                    //       height: 50.h,
                                    //       padding: EdgeInsets.zero,
                                    //       shape: RoundedRectangleBorder(
                                    //           borderRadius:
                                    //               BorderRadius.circular(12.r),
                                    //           side: BorderSide(
                                    //             color: Colors.grey.shade700,
                                    //           )),
                                    //       child: Row(
                                    //         mainAxisAlignment:
                                    //             MainAxisAlignment.center,
                                    //         children: [
                                    //           Text(
                                    //             '+1',
                                    //             style: TextStyle(
                                    //                 color: Colors.white,
                                    //                 fontWeight: FontWeight.w400,
                                    //                 fontSize: 15.sp),
                                    //           ),
                                    //           SizedBox(
                                    //             width: 6.w,
                                    //           ),
                                    //           Image.asset(
                                    //               'assets/icons/objects.png')
                                    //         ],
                                    //       ),
                                    //     )
                                    //   ],
                                    // )
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${filteredProducts[index].free["Coconut"] is double ? filteredProducts[index].free["Coconut"].toInt() : filteredProducts[index].free["Coconut"]}  ',
                                    style: TextStyle(
                                      color: const Color(0xFFE4E4E4),
                                      fontSize: 22.sp,
                                      fontFamily: 'Recoleta',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  SvgPicture.asset(
                                    'assets/images/Food Filter_OBJECTS_458_13901.svg',
                                    width: 25.w,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
              ],
            ),
          ),
        );
      },
    );
  }
}

// List<ProductItem> filterMenuItemsByCategory(
//     List<ProductItem> allItems, String category) {
//   if (category == 'All Items') {
//     return allItems;
//   } else {
//     return allItems.where((item) => item.type == category).toList();
//   }
// }
