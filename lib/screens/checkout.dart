// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:paraiso/screens/customer_basic_profile.dart';
import 'package:paraiso/screens/order_status.dart';
import 'package:paraiso/util/location/user_location.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../controllers/Restaurants/menu_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/customer_controller.dart';
import '../controllers/rewards_controller.dart';
import '../repositories/customer_auth_repo.dart';
import '../repositories/customer_firebase_calls.dart';
import '../util/local_storage/shared_preferences_helper.dart';
import '../widgets/primary_button.dart';

class Checkout extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final bool? free;
  const Checkout({Key? key, required this.orderData, this.free = false})
      : super(key: key);

  @override
  State<Checkout> createState() => _CheckoutState();
}

class _CheckoutState extends State<Checkout> {
  final TextEditingController instructionsController = TextEditingController();

  List<String> restaurants = [];

  String selectedVal = 'Empty Cart';

  bool isChecked = false;

  String selectedTime = "Select Time";

  dynamic cartItems;

  bool isLoading = false;

  List<dynamic> itemsList = [];
  late RewardsController _rewardsController;
  late MenuItemsController _menuItemsController;

  void getCartDetails() {
    final myData = Provider.of<CartNotifier>(context, listen: false);
    final data = myData.cartItems;
    cartItems = data;
    for (var restaurant in data) {
      restaurants.add(restaurant["restaurantName"]);
    }

    setState(() {
      if (restaurants.isNotEmpty) {
        selectedVal = restaurants[0];
      }
    });
  }

  void getItemsByRestaurantId(String restaurantName) {
    itemsList.clear();

    cartItems.forEach((restaurant) {
      if (restaurant["restaurantName"] == restaurantName) {
        itemsList.addAll(restaurant["items"]);
      }
    });
  }

  double getTotalPrice() {
    double totalPrice = 0.0;

    for (var item in itemsList) {
      totalPrice += item["itemPrice"] * item["itemQuantity"];
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

  void updateQuantity(dynamic quantity, String itemName, String itemSize) {
    for (var item in itemsList) {
      if (item["itemName"] == itemName && item["itemSize"] == itemSize) {
        item["itemQuantity"] = quantity;
      }
    }
    setState(() {});
  }

  void orderPlaced(Map<String, dynamic> data) {
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
                    data['prepDelay'] =
                        data['prepDelay'] == null || data['prepDelay'] == ""
                            ? "45 minutes"
                            : data['prepDelay'];
                    data['workingHrs'] =
                        data['workingHrs'] == null || data['workingHrs'] == ""
                            ? "24Hrs"
                            : data['workingHrs'];
                    Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => OrderStatus(
                                  restaurantAddress: data['address'],
                                  prepDelay: data['prepDelay'],
                                  workingHrs: data['workingHrs'],
                                )));
                  },
                  child: Text(
                    AppLocalizations.of(context)!.orderProgress,
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

  Future<bool> paymentOptions() async {
    bool status = false;

    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Center(child: Text("Méthodes de paiement")),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () async {
                    final res = await makePayment(
                      amount: "${widget.orderData['totalPrice']}"
                          .replaceAll(".", "")
                          .trim(),
                      isNewMethod: true,
                    );
                    status = res;
                    if (mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 5.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: primaryColor),
                      color: primaryColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: const Color(0xFFE4E4E4),
                          size: 25.sp,
                        ),
                        20.horizontalSpace,
                        Text('Payer avec de nouveaux détails',
                            style: TextStyle(
                              color: const Color(0xFFE4E4E4),
                              fontSize: 15.sp,
                              fontFamily: 'Recoleta',
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ),
                10.verticalSpace,
                Text("Cartes enregistrées",
                    style: TextStyle(
                      color: const Color(0xFFE4E4E4),
                      fontSize: 18.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w600,
                    )),
                10.verticalSpace,
                if (userPaymentMethods.length == 0)
                  Center(
                    child: Text("No saved cards",
                        style: TextStyle(
                          color: const Color(0xFFE4E4E4),
                          fontSize: 15.sp,
                          fontFamily: 'Recoleta',
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                SizedBox(
                  height: 300.h,
                  width: 300.w,
                  child: ListView.builder(
                    itemCount: userPaymentMethods.length,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () async {
                          print(userPaymentMethods[index]['id']);
                          final res1 = await makePayment(
                            amount: "${widget.orderData['totalPrice']}"
                                .replaceAll(".", "")
                                .trim(),
                            isNewMethod: false,
                            paymentMethodID: userPaymentMethods[index]['id'],
                          );
                          status = res1;
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 25.w, vertical: 10.h),
                          margin: EdgeInsets.only(bottom: 10.h),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: primaryColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "**** **** **** ${userPaymentMethods[index]['card']['last4']}",
                                    style: TextStyle(
                                      color: const Color(0xFFE4E4E4),
                                      fontSize: 18.sp,
                                      fontFamily: 'Recoleta',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    "Expiry: ${userPaymentMethods[index]['card']['exp_month']}/${userPaymentMethods[index]['card']['exp_year']}",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 16.sp,
                                      fontFamily: 'Recoleta',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                              Container(
                                width: 60.w,
                                height: 40.h,
                                decoration: BoxDecoration(
                                  color: primaryColor,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 5.w, vertical: 5.h),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      userPaymentMethods[index]['card']
                                          ['brand'],
                                      style: TextStyle(
                                        color: const Color(0xFFE4E4E4),
                                        fontSize: 18.sp,
                                        fontFamily: 'Recoleta',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        });

    return status;
  }

  void handleDelete(String itemId) {
    itemsList.removeWhere((item) => item['itemId'] == itemId);
    setState(() {});
  }

  String userName = '';
  String userEmail = '';
  String userStripID = '';
  dynamic userPaymentMethods = [];

  Future<void> getCurrentUserDetails() async {
    final email = SharedPreferencesHelper.getCustomerEmail();
    final data = await CustomerAuthRep().getCurrentUserFromFirebase();

    //check user is a stripe customer if not create a stripe customer
    print("test 1");
    if (data['stripeCustomerID'] == null || data['stripeCustomerID'] == "") {
      print("test 2");

      final customerId = await createCustomer(
          userEmail: email ?? "example@gmail.com", userName: data['userName']);
      await CustomerAuthRep().updateUserStripeCustomerId(customerId);
      userStripID = customerId;
    } else {
      userStripID = data['stripeCustomerID'];
    }

    // get customer payment methods
    final paymentMethods = await getPaymentMethod(customerId: userStripID);

    print("paymentMethods: $paymentMethods");

    for (var paymentMethod in paymentMethods['data']) {
      if (userPaymentMethods.isEmpty) {
        userPaymentMethods.add(paymentMethod);
      }
      for (var savedPayments in userPaymentMethods) {
        if (savedPayments['card']['last4'] != paymentMethod['card']['last4']) {
          userPaymentMethods.add(paymentMethod);
        }
      }
    }

    setState(() {
      userName = data['userName']!;
      userEmail = email ?? "";
    });
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    getCurrentUserDetails();
  }

  @override
  void initState() {
    super.initState();
    getCartDetails();
    getItemsByRestaurantId(widget.orderData['restaurantName']);
  }

  Map<String, dynamic>? paymentIntentData;

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> items = widget.orderData['items'];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: neutralColor,
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
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.checkout,
            style: TextStyle(
              color: const Color(0xFFE4E4E4),
              fontSize: 25.sp,
              fontFamily: 'Recoleta',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        actions: [
          44.horizontalSpace,
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: MediaQuery.sizeOf(context).height * .05,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart,
                size: 25.0,
                color: primaryColor,
              ),
              Text(
                " ${AppLocalizations.of(context)!.myOrder}",
                style: TextStyle(
                  color: const Color(0xFFE4E4E4),
                  fontSize: 20.sp,
                  fontFamily: 'Recoleta',
                  fontWeight: FontWeight.w700,
                ),
              )
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 50.h),
            height: MediaQuery.sizeOf(context).height * .5,
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${items[index]['name']}   (${items[index]['quantity']})",
                          style: TextStyle(
                            color: const Color(0xFFE4E4E4),
                            fontSize: 18.sp,
                            fontFamily: 'Recoleta',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        widget.free == true
                            ? Row(
                                children: [
                                  Text(
                                    '${items[index]['price'] is double ? items[index]['price'].toInt() : items[index]['price']}  ',
                                    // '${items[index]['price']}  ',
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
                              )
                            : Text(
                                "${items[index]['price']}€",
                                style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 18.sp,
                                  fontFamily: 'Recoleta',
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                      ],
                    ),
                    // SizedBox(
                    //   height: MediaQuery.sizeOf(context).height * .005,
                    // ),
                    // const Divider(
                    //   height: 5.0,
                    // ),
                    // index == items.length - 1
                    //     ? const Divider(
                    //         height: 3.0,
                    //       )
                    //     : const SizedBox.shrink(),
                    5.verticalSpace,
                    widget.orderData['items'][index]['addOns'].isNotEmpty
                        ? SizedBox(
                            height: widget.orderData['items'][index]['addOns']
                                    .length *
                                40.h,
                            child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: widget
                                  .orderData['items'][index]['addOns'].length,
                              itemBuilder: (context, addOnsIndex) {
                                String addOnName = widget
                                    .orderData['items'][index]['addOns'].keys
                                    .toList()[addOnsIndex];
                                double addOnPrice = double.parse(
                                    widget.orderData['items'][index]['addOns']
                                        [addOnName][0]['price']);

                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      addOnName,
                                      style: TextStyle(
                                        color: const Color(0xFFE4E4E4),
                                        fontSize: 18.sp,
                                        fontFamily: 'Recoleta',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      "$addOnPrice€",
                                      style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 18.sp,
                                        fontFamily: 'Recoleta',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  ],
                                );
                              },
                            ),
                          )
                        : SizedBox.shrink(),

                    const Divider(
                      height: 5.0,
                    ),
                    index == items.length - 1
                        ? Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.subtotal,
                                    style: TextStyle(
                                      color: const Color(0xFFE4E4E4),
                                      fontSize: 18.sp,
                                      fontFamily: 'Recoleta',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  widget.free == true
                                      ? Row(
                                          children: [
                                            Text(
                                              '${items[index]['price'] is double ? items[index]['price'].toInt() : items[index]['price']}  ',
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
                                        )
                                      : Text(
                                          "${widget.orderData['totalPrice']}€",
                                          style: TextStyle(
                                            color: primaryColor,
                                            fontSize: 18.sp,
                                            fontFamily: 'Recoleta',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.tax,
                                    style: TextStyle(
                                      color: const Color(0xFFE4E4E4),
                                      fontSize: 18.sp,
                                      fontFamily: 'Recoleta',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    widget.free == true ? "---" : "0€",
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 18.sp,
                                      fontFamily: 'Recoleta',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0.w),
            child: Consumer<CustomerController>(
              builder: (context, customerController, child) {
                if (customerController.user.isEmpty) {
                  return CircularProgressIndicator(color: primaryColor);
                } else {
                  GeoPoint location = customerController.user['location'];

                  double latitude = location.latitude;
                  double longitude = location.longitude;

                  return FutureBuilder<String>(
                    future: UserLocation().getAddress(latitude, longitude),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                            height: 80,
                            width: 80,
                            child:
                                CircularProgressIndicator(color: primaryColor));
                      } else if (snapshot.hasError) {
                        return Text(
                            "Couldn't fetch address: ${snapshot.error}");
                      } else {
                        String userAddress = snapshot.data ?? "Unknown Address";
                        return SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.2,
                          child: Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: primaryColor,
                                size: 30.h,
                              ),
                              8.horizontalSpace,
                              Expanded(
                                child: Text(
                                  userAddress,
                                  softWrap: true,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                  ),
                                ),
                              ),
                              5.horizontalSpace,
                              InkWell(
                                onTap: () async {
                                  final customerController =
                                      Provider.of<CustomerController>(context,
                                          listen: false);
                                  await customerController.getCurrentUser();
                                  if (mounted) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CustomerBasicProfile(),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  AppLocalizations.of(context)!.change,
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
          25.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0.w),
            child: TextField(
              controller: instructionsController,
              maxLines: 2,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                hintText: AppLocalizations.of(context)!.anySpecialInstructions,
                hintStyle: Theme.of(context).textTheme.bodyLarge,
                border: const OutlineInputBorder(),
              ),
              onChanged: (text) {
                // Handle the user's input here
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 50.0.w, vertical: 25.0.h),
            child: GestureDetector(
              onTap: () async {},
              child: PrimaryButton(
                child: isLoading
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : widget.free == true
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${AppLocalizations.of(context)!.purchase}${widget.orderData['totalPrice'] is double ? widget.orderData['totalPrice'].toInt() : widget.orderData['totalPrice']}  ',
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
                          )
                        : AutoSizeText(
                            "${AppLocalizations.of(context)!.purchase}${widget.orderData['totalPrice']}€",
                            style: TextStyle(
                              color: const Color(0xFFE4E4E4),
                              fontSize: 18.sp,
                              fontFamily: 'Recoleta',
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                          ),
                onPressed: () async {
                  final myData =
                      Provider.of<CartNotifier>(context, listen: false);
                  if (widget.free == true) {
                    setState(() {
                      isLoading = true;
                    });
                    final myCall = MyCustomerCalls();
                    final success =
                        await myCall.placeFreeOrder(widget.orderData);
                    final res = await myCall.getRestaurantAdminById(
                        widget.orderData['restaurantId']);
                    if (!success) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Center(
                              child: Text(
                                AppLocalizations.of(context)!
                                    .youDontHaveEnoughCoconuts,
                                style: context.bodyLarge,
                              ),
                            ),
                            duration: const Duration(seconds: 2),
                            backgroundColor: primaryColor,
                          ),
                        );
                      }
                    }
                    setState(() {
                      isLoading = false;
                    });
                    if (isLoading == false && success == true) {
                      orderPlaced(res.data() as Map<String, dynamic>);
                    }
                  } else {
                    setState(() {
                      isLoading = true;
                    });

                    final paymentStatus = await paymentOptions();

                    // final paymentStatus = await makePayment(
                    //   amount: "${widget.orderData['totalPrice']}".replaceAll(".", "").trim(),
                    // );

                    if (paymentStatus == true) {
                      String restaurantImage() {
                        String image = "";
                        cartItems.forEach((restaurant) {
                          if (restaurant["restaurantName"] == selectedVal) {
                            image = restaurant["restaurantImage"];
                          }
                        });
                        return image;
                      }

                      if (instructionsController.text != "") {
                        widget.orderData.update(
                          "instructions",
                          (value) => instructionsController.text,
                          ifAbsent: () => instructionsController.text,
                        );
                      }

                      final myCall = MyCustomerCalls();
                      await myCall.placeOrder(widget.orderData);
                      final res = await myCall.getRestaurantAdminById(
                          widget.orderData['restaurantId']);

                      int coconutCount = getTotalRewards();
                      String resImage = restaurantImage();

                      myData.deleteRestaurant(widget.orderData['restaurantId']);

                      final myCall1 = CustomerAuthRep();

                      await myCall1
                          .addRestaurantOrder(widget.orderData['restaurantId']);

                      if (kDebugMode) print("coconutCount : $coconutCount");
                      if (kDebugMode) print("resImage : $resImage");

                      await myCall1.addRewards(
                          widget.orderData['restaurantId'],
                          widget.orderData['restaurantName'],
                          resImage,
                          widget.orderData['items'][0]['name'],
                          coconutCount);

                      setState(() {
                        isLoading = false;
                      });
                      if (isLoading == false) {
                        orderPlaced(res.data() as Map<String, dynamic>);
                      }
                    } else {
                      setState(() {
                        isLoading = false;
                      });
                    }
                  }
                },
              ).wh(100.w, 45.h),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> makePayment(
      {required String amount,
      bool isNewMethod = true,
      String paymentMethodID = ""}) async {
    try {
      bool paymentSucceed = false;

      paymentIntentData = await createPaymentIntent(
          amount: amount,
          // currency: 'USD',
          currency: 'EUR',
          isNewMethod: isNewMethod,
          paymentMethodID: paymentMethodID);

      if (!isNewMethod) {
        if (paymentIntentData == "error") {
          paymentSucceed = false;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  AppLocalizations.of(context)!.paymentUnsuccessful,
                  style: context.bodyLarge,
                ),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: primaryColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Center(
                child: Text(
                  AppLocalizations.of(context)!.paidSuccessfully,
                  style: context.bodyLarge,
                ),
              ),
              duration: const Duration(seconds: 2),
              backgroundColor: primaryColor,
            ),
          );
          paymentSucceed = true;
        }
      }

      print('paymentIntentData: $paymentIntentData');

      if (isNewMethod) {
        // for real stripe account
        // await Stripe.instance.initPaymentSheet(
        //   paymentSheetParameters: SetupPaymentSheetParameters(
        //       setupIntentClientSecret: dotenv.env['STRIPE_SECRET'],
        //       paymentIntentClientSecret: paymentIntentData!['client_secret'],
        //       customFlow: false,
        //       merchantDisplayName: "Paraiso"),
        // );

        //for test Stripe Account
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
              setupIntentClientSecret: "pk_test_51OAzOaBv5r2e0H1dyPNETX31O9rsaIpZLpoRuWnjLWzVbleyjIfG2tdFDOrie18giCmF4jaadcy0n18zsaIbdozU002Tqqb68X",
              paymentIntentClientSecret:paymentIntentData!['client_secret'],
              customFlow: false,
              merchantDisplayName: "Paraiso"),
        );

        final paymentSuccess = await displayPaymentSheet();
        if (paymentSuccess) {
          paymentSucceed = true;
        }
      }

      return paymentSucceed;
    } catch (e, s) {
      if (kDebugMode) print('Payment exception: $e $s');
      return false;
    }
  }

  Future<bool> displayPaymentSheet() async {
    Completer<bool> completer = Completer<bool>();

    try {
      await Stripe.instance.presentPaymentSheet().then((newValue) {
        if (kDebugMode)
          print('Payment intentssss11: ${paymentIntentData!['id']}');
        if (kDebugMode) {
          print('Payment intentssss22: ${paymentIntentData!['client_secret']}');
        }
        if (kDebugMode) {
          print(
              'Payment intentsssssssssssssssss33: ${paymentIntentData!['amount']}');
          print(
              'Payment intentsss method: ${paymentIntentData!['payment_method']}');
          print(
              'Payment intentsss method: ${paymentIntentData!['payment_method_options']}');
          print(
              'Payment intentsss method: ${paymentIntentData!['payment_method_types']}');
        }
        if (kDebugMode)
          print('Payment intentssssssssssss4: $paymentIntentData');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                AppLocalizations.of(context)!.paidSuccessfully,
                style: context.bodyLarge,
              ),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: primaryColor,
          ),
        );

        paymentIntentData = null;
        completer.complete(true);
      }).onError((error, stackTrace) {
        if (kDebugMode) {
          print('Exception/DISPLAYPAYMENTSHEET==> $error $stackTrace');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                AppLocalizations.of(context)!.paymentUnsuccessful,
                style: context.bodyLarge,
              ),
            ),
            duration: const Duration(seconds: 2),
            backgroundColor: primaryColor,
          ),
        );
        completer.complete(false);
      });
    } on StripeException catch (e) {
      if (kDebugMode) print('Exception/DISPLAYPAYMENTSHEET==> $e');
      showDialog(
          context: context,
          builder: (_) => AlertDialog(
                content: Text(AppLocalizations.of(context)!.cancelled),
              ));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              AppLocalizations.of(context)!.paymentUnsuccessful,
              style: context.bodyLarge,
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: primaryColor,
        ),
      );
      completer.complete(false);
    } catch (e) {
      if (kDebugMode) print('$e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              AppLocalizations.of(context)!.paymentUnsuccessful,
              style: context.titleSmall,
            ),
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: primaryColor,
        ),
      );
      completer.complete(false);
    }

    return completer.future;
  }

  createPaymentIntent(
      {required String amount,
      required String currency,
      String paymentMethodID = '',
      bool isNewMethod = true}) async {
    try {
      Map<String, dynamic> body = {};

      if (isNewMethod) {
        body = {
          'amount': calculateAmount(amount),
          'currency': currency,
          'payment_method_types[]': 'card',
          'setup_future_usage': 'off_session',
          'customer': userStripID,
        };
      } else {
        body = {
          'amount': calculateAmount(amount),
          'currency': currency,
          'payment_method_types[]': 'card',
          'setup_future_usage': 'off_session',
          'customer': userStripID,
          'payment_method': paymentMethodID,
          'confirm': 'true',
        };
      }

      // for real stripe account
      // var response = await http.post(
      //   Uri.parse('https://api.stripe.com/v1/payment_intents'),
      //   body: body,
      //   headers: {
      //     'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
      //     'Content-Type': 'application/x-www-form-urlencoded',
      //   },
      // );

      //for test stripe account
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer sk_test_51OAzOaBv5r2e0H1d0DJbmYby7jBSyvYhpFnADcgrSQS0uYT8IcI6jvitt1bkmD8Q1fUMCQLXItb3zEm4xCOyi5E300NNZqaiJO',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (kDebugMode) {
        print('Create Intent response: ${response.body.toString()}');
      }
      return jsonDecode(response.body);
    } catch (err) {
      if (kDebugMode) print('Error charging user: ${err.toString()}');
      return "error";
    }
  }

  Future<String> createCustomer(
      {required String userName, required String userEmail}) async {
    try {
      Map<String, dynamic> body = {
        'name': userName,
        'email': userEmail,
      };
      // for real
      // var response = await http.post(
      //   Uri.parse('https://api.stripe.com/v1/customers'),
      //   body: body,
      //   headers: {
      //     'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
      //     'Content-Type': 'application/x-www-form-urlencoded',
      //   },
      // );
      // for test
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/customers'),
        body: body,
        headers: {
          'Authorization': 'Bearer sk_test_51OAzOaBv5r2e0H1d0DJbmYby7jBSyvYhpFnADcgrSQS0uYT8IcI6jvitt1bkmD8Q1fUMCQLXItb3zEm4xCOyi5E300NNZqaiJO',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      final result = jsonDecode(response.body);
      final customerId = result['id'];
      if (kDebugMode) {
        print(
            'Create Customer response 111111111: ${response.body.toString()}');
      }
      return customerId;
    } catch (err) {
      if (kDebugMode)
        print('Create Customer Error1111111111 : ${err.toString()}');
      return '';
    }
  }

  Future<dynamic> getPaymentMethod({required String customerId}) async {
    try {
      // for real
      // var response = await http.get(
      //   Uri.parse(
      //       'https://api.stripe.com/v1/customers/$customerId/payment_methods'),
      //   headers: {
      //     'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET']}',
      //     'Content-Type': 'application/x-www-form-urlencoded',
      //   },
      // );
      // for test
      var response = await http.get(
        Uri.parse('https://api.stripe.com/v1/customers/$customerId/payment_methods'),
        headers: {
          'Authorization': 'Bearer sk_test_51OAzOaBv5r2e0H1d0DJbmYby7jBSyvYhpFnADcgrSQS0uYT8IcI6jvitt1bkmD8Q1fUMCQLXItb3zEm4xCOyi5E300NNZqaiJO',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );
      if (kDebugMode) {
        print('Create Customer response 111111111: ${response.body.toString()}');
      }
      return jsonDecode(response.body);
    } catch (err) {
      if (kDebugMode)
        print('Create Customer Error1111111111 : ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    // final a = (int.parse(amount)) * 100;
    final a = (int.parse(amount)) * 10;
    return a.toString();
  }
}
