import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:paraiso/screens/checkout.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import '../cart_constants.dart';
import '../controllers/cart_controller.dart';
import '../controllers/customer_controller.dart';
import '../routes/routes_constants.dart';
import 'myOrders_Screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<String> restaurants = [];

  String selectedVal = 'Empty Cart';

  bool isChecked = false;

  String selectedTime = "Sélectionner l'heure";

  List<Map<String, dynamic>> cartItems = [];

  bool isLoading = false;

  List<Map<String, dynamic>> itemsList = [];

  Future<void> getCartDetails() async {
    if (kDebugMode) print("getCartDetails");
    final myData = Provider.of<CartNotifier>(context, listen: false);
    await myData.loadCartFromSharedPreferences();
    final data = myData.cartItems;
    if (kDebugMode) print("____________________");
    if (kDebugMode) print(data);
    cartItems = data;
    for (var restaurant in data) {
      restaurants.add(restaurant["restaurantName"]);
    }
    if (kDebugMode) print(restaurants);

    setState(() {
      if (restaurants.isNotEmpty) {
        selectedVal = restaurants[0];
      }
    });
  }

  void getItemsByRestaurantId(String restaurantName) {
    itemsList.clear();

    for (var restaurant in cartItems) {
      if (restaurant["restaurantName"] == restaurantName) {
        List<dynamic> items = restaurant["items"];
        for (var item in items) {
          itemsList.add(item);
        }
      }
    }
  }

  double getTotalPrice() {
    double totalPrice = 0.0;
    for (var item in itemsList) {
      Map<String, dynamic> selectedAddons = item["addOns"];

      double sum = 0.0;
      selectedAddons.forEach((key, value) {
        value.forEach((element) {
          sum += double.parse(element["price"]);
        });
      });

      totalPrice += item["itemPrice"] * item["itemQuantity"];
      totalPrice += sum;
    }

    totalPrice = double.parse(totalPrice.toStringAsFixed(3));
    return totalPrice;
  }

  int getTotalRewards() {
    int totalRewards = 0;

    for (var item in itemsList) {
      totalRewards += int.parse(
          (int.parse(item["itemReward"]) * item["itemQuantity"]).toString());
    }
    return totalRewards;
  }

  void orderPlaced() {
    final myData = Provider.of<CartNotifier>(context, listen: false);
    myData.deleteRestaurant(selectedVal);
    Navigator.pop(context);
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.r),
              ),
              backgroundColor: softBlack,
              content: VStack(crossAlignment: CrossAxisAlignment.center, [
                12.verticalSpace,
                SvgPicture.asset("assets/images/order placed.svg"),
                30.verticalSpace,
                Text(AppLocalizations.of(context)!.orderPlaced,
                    style: context.headlineSmall?.copyWith(
                      color: onPrimaryColor,
                    )),
                Text(AppLocalizations.of(context)!.orderSuccessMsg,
                    textAlign: TextAlign.center, style: context.titleLarge)
              ]),
              actions: [
                PrimaryButton(
                  icon: Icons.arrow_forward_ios,
                  onPressed: () {
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MyOrdersScreen()));
                  },
                  child: AutoSizeText(
                    AppLocalizations.of(context)!.orderStatus,
                    style: TextStyle(
                      color: const Color(0xFFE4E4E4),
                      fontSize: 18.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ));
    // getCartDetails();
    // getItemsByRestaurantId(selectedVal);
    setState(() {});
  }

  void handleDelete(String itemId) {
    itemsList.removeWhere((item) => item['itemId'] == itemId);
    setState(() {});
  }

  Future<void> placeOrder() async {
    if (selectedTime == "Sélectionner l'heure") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.plzSelectTimeFirst),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      if (selectedVal == "Empty Cart" || itemsList.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context)!.cartIsEmpty,
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        setState(() {
          isLoading = true;
        });

        List<Map<String, dynamic>> myItems = [];

        for (Map<String, dynamic> item in itemsList) {
          myItems.add({
            "id": item["itemId"],
            "name": item["itemName"],
            "price": item["itemPrice"].toStringAsFixed(2),
            "quantity": item["itemQuantity"],
            "size": item["itemSize"],
            "addOns": item["addOns"],
          });
        }

        String restaurantImage() {
          String image = "";
          for (var restaurant in cartItems) {
            if (restaurant["restaurantName"] == selectedVal) {
              image = restaurant["restaurantImage"];
            }
          }
          return image;
        }

        String restaurantId() {
          String id = "";
          for (var restaurant in cartItems) {
            if (restaurant["restaurantName"] == selectedVal) {
              id = restaurant["restaurantId"];
            }
          }
          return id;
        }

        final customerController =
            Provider.of<CustomerController>(context, listen: false);
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        final String? email = prefs.getString('currentCustomerEmail');
        final String? userName = prefs.getString('currentCustomerUserName');

        Map<String, dynamic> orderData = {
          "clientId": email,
          "items": myItems,
          "photo": customerController.user['photo'] ?? "",
          "time": selectedTime,
          "restaurantId": restaurantId(),
          "restaurantName": selectedVal,
          "status": "In Progress",
          "totalPrice": getTotalPrice(),
          "userName": userName,
        };

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => Checkout(
                orderData: orderData,
              ),
            ),
          );
        }

        // final myCall = MyCustomerCalls();
        // await myCall.placeOrder(orderData);

        // String id = restaurantId();

        // final myData = Get.find<CartController>();
        // myData.deleteRestaurant(id);

        // final myCall1 = CustomerAuthRep();

        // await myCall1.addRestaurantOrder(id);

        // int coconutCount = getTotalRewards();
        // String resImage = restaurantImage();

        // if (kDebugMode) print("coconutCount : $coconutCount");
        // if (kDebugMode) print("resImage : $resImage");

        // await myCall1.addRewards(id, selectedVal, resImage, coconutCount);

        // setState(() {
        //   isLoading = false;
        // });

        // orderPlaced();
      }
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   getCartDetails();
  //   print("from init");
  //   print(selectedVal);
  //   getItemsByRestaurantId(selectedVal);
  // }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    await getCartDetails();
    getItemsByRestaurantId(selectedVal);
  }

  void _setTime() async {
    final now = DateTime.now();
    final minimumTime = now.add(const Duration(minutes: 15));

    DateTime initialTime = minimumTime;
    if (initialTime.minute % 10 != 0) {
      final minutesToAdd = 10 - (initialTime.minute % 10);
      initialTime = initialTime.add(Duration(minutes: minutesToAdd));
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: neutralColor,
          title: Center(
              child: Text(
            AppLocalizations.of(context)!.selectPickupTime,
          )),
          content: Container(
            height: 200.h,
            width: 300.w,
            color: softBlack,
            child: CupertinoDatePicker(
              use24hFormat: true,
              backgroundColor: Colors.transparent,
              mode: CupertinoDatePickerMode.time,
              initialDateTime: DateTime.now().add(
                Duration(minutes: 15 - DateTime.now().minute % 15),
              ),
              minuteInterval: 15,
              onDateTimeChanged: (DateTime newDateTime) {
                String formattedDate =
                    DateFormat("yyyy-MM-dd HH:mm").format(newDateTime);
                setState(() {
                  selectedTime = formattedDate;
                });
              },
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: softBlack,
                foregroundColor: onPrimaryColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: onPrimaryColor,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(AppLocalizations.of(context)!.submit),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartNotifier>(context);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: neutralColor,
          leading: IconButton(
            icon: Container(
                height: 53.h,
                width: 53.w,
                decoration: BoxDecoration(
                    color: softBlack, borderRadius: BorderRadius.circular(50)),
                padding: EdgeInsets.only(left: 10.w),
                child: const Icon(Icons.arrow_back_ios)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Center(
            child: Text(
              AppLocalizations.of(context)!.cart,
              style: textStyleWhite25700,
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text(AppLocalizations.of(context)!.clearCart),
                        content: Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: Text(
                              AppLocalizations.of(context)!
                                  .areYouSureToClearTheCart,
                              style: textStyleWhite20700),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 25.w),
                        actions: [
                          TextButton(
                            child: Text(AppLocalizations.of(context)!.cancel),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text(AppLocalizations.of(context)!.clear),
                            onPressed: () {
                              final myData = Provider.of<CartNotifier>(context,
                                  listen: false);
                              myData.clearList();
                              Navigator.pop(context);
                              Navigator.pop(context);
                              // context.go(AppRouteConstants.homeRoute);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                icon: Icon(Icons.delete, color: dangerColor)),
            5.horizontalSpace,
          ],
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 25.w),
          child: Column(
            children: [
              SizedBox(height: 23.h),
              MyDropDownList1(
                hint: selectedVal,
                selectedValue: selectedVal,
                items: restaurants,
                onChanged: (value) {
                  setState(() {
                    selectedVal = value!;
                    getItemsByRestaurantId(selectedVal);
                  });
                },
              ),
              SizedBox(height: 12.h),
              if (itemsList.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10.w),
                    Text(AppLocalizations.of(context)!.longPressOnItemToDelete,
                        style: textStyleWhite16400.copyWith(fontSize: 12.sp)),
                    Icon(Icons.delete_forever, size: 15.sp),
                  ],
                ),
              SizedBox(height: 20.h),
              SizedBox(
                height: 466.h,
                child: ListView.builder(
                    itemCount: itemsList.length,
                    itemBuilder: (context, index) => Column(
                          children: [
                            GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onLongPress: () {
                                handleDelete(itemsList[index]['itemId']);
                              },
                              child: MyCartTile(
                                  itemReward: itemsList[index]['itemReward'],
                                  itemName: itemsList[index]['itemName'],
                                  itemPrice: itemsList[index]['itemPrice']
                                      .toStringAsFixed(2)
                                      .toString(),
                                  itemQuantity: itemsList[index]['itemQuantity']
                                      .toString(),
                                  itemSize: itemsList[index]['itemSize'],
                                  itemImage: itemsList[index]['itemImage'],
                                  onIncrement: () async {
                                    await cartProvider.updateQuantity(
                                        itemsList[index]['itemQuantity'] + 1,
                                        itemsList[index]['itemName'],
                                        itemsList[index]['itemSize']);
                                  },
                                  onDecrement: () async {
                                    if (itemsList[index]['itemQuantity'] > 1) {
                                      await cartProvider.updateQuantity(
                                          itemsList[index]['itemQuantity'] - 1,
                                          itemsList[index]['itemName'],
                                          itemsList[index]['itemSize']);
                                    }
                                  }),
                            ),
                            SizedBox(height: 30.h)
                          ],
                        )),
              ),
              SizedBox(height: 10.h),
              Container(
                width: 380.w,
                // height: 167.h,
                decoration: BoxDecoration(
                  color: softBlack,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 30.h, vertical: 20.h),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.foodPickupTime,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textStyleWhite16700,
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              _setTime();
                            },
                            child: Text(
                              selectedTime,
                              style: textStyleWhite16400.copyWith(
                                  color: const Color(0xFF2F58CD)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  getTotalPrice().toString(),
                                  style: textStyleWhite30700,
                                ),
                                Text(
                                  '€',
                                  style: textStyleWhite20700,
                                ),
                              ],
                            ),
                            Text(
                              '  ${AppLocalizations.of(context)!.totalPrice}',
                              style: textStyleWhite16700,
                            ),
                            if (getTotalRewards() != 0)
                              Row(
                                children: [
                                  Text(
                                    "${AppLocalizations.of(context)!.rewards}: ${getTotalRewards().toString()} ",
                                    style: textStyleWhite16700.copyWith(
                                        fontSize: 10.sp),
                                  ),
                                  SvgPicture.asset(
                                    "assets/images/Food Filter_OBJECTS_458_13901.svg",
                                    width: 10.w,
                                    height: 10.h,
                                  ),
                                ],
                              ),
                          ],
                        ),
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () async {
                            if (SharedPreferencesHelper.getCustomerType() !=
                                'guest') {
                              final customerController =
                                  Provider.of<CustomerController>(context,
                                      listen: false);
                              await customerController.getCurrentUser();
                              if (isLoading == false) {
                                placeOrder();
                              }
                            } else {
                              context.push(AppRouteConstants.loginRoute);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            width: 180.w,
                            height: 52.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF2F58CD),
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                            child: Center(
                              child: isLoading
                                  ? Transform.scale(
                                      scale: 0.5,
                                      child: const CircularProgressIndicator(
                                          color: Colors.white))
                                  : Text(
                                      AppLocalizations.of(context)!.placeOrder,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: textStyleWhite18700,
                                    ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25.h),
            ],
          ),
        ));
  }
}
