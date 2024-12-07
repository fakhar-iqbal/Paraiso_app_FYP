import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:paraiso/controllers/customer_controller.dart';
import 'package:paraiso/models/product_item.dart';
import 'package:paraiso/screens/myCart_Screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:expandable/expandable.dart';
import 'package:paraiso/widgets/icon_text_field.dart';
import 'package:paraiso/widgets/order_appbar.dart';
import 'package:paraiso/widgets/primary_button.dart';
import '../controllers/Restaurants/AddOnController.dart';
import '../controllers/Restaurants/res_auth_controller.dart';
import '../controllers/cart_controller.dart';
import '../util/theme/theme_constants.dart';
import 'checkout.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlaceOrder extends StatefulWidget {
  final String restaurantId;
  final String restaurantName;
  final String restaurantImage;
  final Map<String, dynamic> foodItem;
  final List<dynamic> addOns;
  const PlaceOrder({Key? key, required this.restaurantId, required this.restaurantName, required this.foodItem, required this.restaurantImage, required this.addOns}) : super(key: key);

  @override
  _PlaceOrderState createState() => _PlaceOrderState();
}

class _PlaceOrderState extends State<PlaceOrder> {
  PlaceOrderCategoriesController placeOrderCategoriesController = Get.put(PlaceOrderCategoriesController());
  int number = 1;
  dynamic itemSizes = ["Small", "Large", "Medium"];
  dynamic itemPrices = [];

  List<dynamic> addOnsToBuy = [];
  double addOnsToBuyPrice = 0;
  List<bool> addOnCheck = [];

  String selectedSize = '';
  Map<String, List<Map<String, String>>> selectedAddons = {};

  double totalAddonPrice = 0.0;

  @override
  void initState() {
    super.initState();
    itemSizes = widget.foodItem['sizes'];
    if (itemSizes.length > 0) {
      selectedSize = itemSizes[0];
    }
    setState(() {
      if(itemSizes[0] == "Petit" || itemSizes[0] == "Small" ){
        selectedSize = "Petit";
      }

      if(itemSizes[0] == "Moyen" || itemSizes[0] == "Medium"){
        selectedSize = "Moyen";
      }

      if(itemSizes[0] == "Grand" || itemSizes[0] == "Large"){
        selectedSize = "Grand";
      }
    });
    getCartDetails(selectedVal);
    getItemsByRestaurantId(selectedVal);
    getADDONSfromId();

  }



  ////////////////////////////////////////////////////////

  String getPriceTotoal(dynamic priceStr) {
    double discount = double.parse(widget.foodItem['discount'].toString().replaceAll("%", ""));
    double discountedPrice = double.parse(priceStr) - (double.parse(priceStr) * (discount / 100));
    String price1= (addOnsToBuy.isEmpty ? discountedPrice * number : (widget.foodItem['discountedPrice'] * number) + addOnsToBuyPrice).toString();
    String price2 = addOnsToBuyPrice.toString();
    String totalPrice= (double.parse(price1) + double.parse(price2)).toString();
    return totalPrice;
  }

  List<String> restaurants = [];
  List<AddonItemWithId> _myItemAddons = [];

  String selectedVal = 'Empty Cart';

  bool isChecked = false;

  String selectedTime = "Select Time";

  dynamic cartItems;

  bool isLoading = false;

  List<Map<String, dynamic>> itemsList = [];

  void getADDONSfromId() async {
    final addonItemsController = Provider.of<AddOnController>(context, listen: false);
    await addonItemsController.fetchADDON(widget.restaurantId);
    for (var element in addonItemsController.addons) {
      for (var item in widget.addOns) {
        if (element.addonId == item) {
          _myItemAddons.add(element);
        }
      }
    }
    setState(() {});
  }

  void getCartDetails(String resId) {
    final myData = Provider.of<CartNotifier>(context, listen: false);
    final data = myData.cartItems.where((element) => element["restaurantId"] == resId).toList();
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
      if (item["addOns"].isNotEmpty && item["addOns"][0]['name'] != "") {
        double addOnsPrice = 0.0;


    totalPrice += ((item["itemPrice"] * item["itemQuantity"]) + addOnsPrice);
      } else {
        totalPrice += item["itemPrice"] * item["itemQuantity"];
      }
    }

    double addOnsPrice1= selectedAddons.values
        .expand((addons) => addons)
        .map((addon) => addon['price'])
        .fold(0, (prev, price) => prev + (double.parse(price!)));

    addOnsPrice1 = double.parse(addOnsPrice1.toStringAsFixed(3));

    totalPrice = double.parse(totalPrice.toStringAsFixed(3));

    totalPrice += addOnsPrice1;

    addOnsToBuyPrice = addOnsPrice1;
    setState(() {});

    return totalPrice;
  }

  int getTotalRewards() {
    int totalRewards = 0;

    for (var item in itemsList) {
      totalRewards += int.parse(item["itemReward"].toString());
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

  void addToCartPopUp() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.r),
              ),
              backgroundColor: softBlack,
              content: VStack(crossAlignment: CrossAxisAlignment.center, [
                5.verticalSpace,
                SvgPicture.asset("assets/images/order placed.svg"),
                10.verticalSpace,
                Text(AppLocalizations.of(context)!.addToCart,
                    style: context.headlineSmall?.copyWith(
                      color: onPrimaryColor,
                    )),
              ]),
              actions: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PrimaryButton(
                      icon: Icons.arrow_forward_ios,
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const CartScreen()));
                      },
                      child: Text(
                        AppLocalizations.of(context)!.takeMeToCart,
                        style: TextStyle(
                          color: const Color(0xFFE4E4E4),
                          fontSize: 16.sp,
                          fontFamily: 'Recoleta',
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                      ),
                    ),
                    5.verticalSpace,
                    PrimaryButton(
                      icon: Icons.arrow_forward_ios,
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        AppLocalizations.of(context)!.continueShopping,
                        style: TextStyle(
                          color: const Color(0xFFE4E4E4),
                          fontSize: 15.sp,
                          fontFamily: 'Recoleta',
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ));

    setState(() {});
  }

  void handleDelete(String itemId) {
    itemsList.removeWhere((item) => item['itemId'] == itemId);
    setState(() {});
  }

  Future<void> placeOrder() async {
    if (selectedTime == AppLocalizations.of(context)!.selectTime) {
      _setTime();
    } else {
      if (selectedVal == AppLocalizations.of(context)!.emptyCart || itemsList.isEmpty) {
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

        for (var item in itemsList) {
          myItems.add({
            "id": item["itemId"],
            "name": item["itemName"],
            "price": item["itemPrice"],
            "quantity": item["itemQuantity"],
            "size": item["itemSize"],
            "addOns": item["addOns"],
          });
        }

        String restaurantImage() {
          String image = "";
          cartItems.forEach((restaurant) {
            if (restaurant["restaurantName"] == selectedVal) {
              image = restaurant["restaurantImage"];
            }
          });
          return image;
        }

        String restaurantId() {
          String id = "";
          cartItems.forEach((restaurant) {
            if (restaurant["restaurantName"] == selectedVal) {
              id = restaurant["restaurantId"];
            }
          });
          return id;
        }

        final customerController = Provider.of<CustomerController>(context, listen: false);
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
                      )));
        }
      }
    }
  }

  bool containsAllRequired(List<dynamic> list1, List<dynamic> list2) {
    final requiredItems = list1.where((item) => item['required'] == true).toList();

    return requiredItems.every((item) => list2.contains(item));
  }

  void _setTime() {
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
          title: Center(child: Text(AppLocalizations.of(context)!.selectPickupTime)),
          content: Container(
            height: 200.h,
            width: 300.w,
            color: softBlack,
            child: CupertinoDatePicker(
              use24hFormat: true,
              backgroundColor: Colors.transparent,
              mode: CupertinoDatePickerMode.time,
              initialDateTime: initialTime,
              minimumDate: minimumTime,
              minuteInterval: 10,
              onDateTimeChanged: (DateTime newDateTime) {
                DateTime dateTime = DateTime.parse(newDateTime.toString());
                String formattedDate = DateFormat("yyyy-MM-dd hh:mm a").format(dateTime);
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

  String getSizePrice(){
    String price = "";
    if(selectedSize == "Petit" || selectedSize == "Small" ){
      price = widget.foodItem["prices"]['Small'].toString();
    }

    if(selectedSize == "Moyen" || selectedSize == "Medium"){
      price = widget.foodItem["prices"]['Medium'].toString();
    }

    if(selectedSize == "Grand" || selectedSize == "Large"){
      price = widget.foodItem["prices"]['Large'].toString();
    }
    return price;
  }

  ///////////////////////////////////////////////////////

  @override
  Widget build(BuildContext context) {


    // itemSizes = [AppLocalizations.of(context)!.small, AppLocalizations.of(context)!.medium, AppLocalizations.of(context)!.large];
    itemSizes = itemSizes.map((size) {
      switch (size) {
        case "Small":
        case "Petit":
          return "Petit";
        case "Large":
        case "Grand":
          return "Grand";
        case "Medium":
        case "Moyen":
          return "Moyen";
        default:
          return "";
      }
    }).toList();
    selectedTime = AppLocalizations.of(context)!.selectTime;
    selectedVal = AppLocalizations.of(context)!.emptyCart;
    final double price = widget.foodItem["discountedPrice"] is int ? (widget.foodItem["discountedPrice"] as int).toDouble() : widget.foodItem["discountedPrice"];
    // final String priceStr = price.toStringAsFixed(2);
    final String priceStr = getSizePrice();

    return Scaffold(
      appBar: OrderAppBar(
        foodName: widget.foodItem['name'],
        foodPrice: priceStr,
      ),
      body: ListView(
        physics: const ClampingScrollPhysics(),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22.r),
            child: Image.network(
              widget.foodItem['photo'] ?? "",
              errorBuilder: (context, error, stackTrace) {
                return Center(child: Text(AppLocalizations.of(context)!.imgNotFound));
              },
              fit: BoxFit.contain,
            ),
          ).hPCT(context: context, heightPCT: 32).marginAll(25.w),
          //about Food,

          Text(
            AppLocalizations.of(context)!.aboutFood,
            style: context.titleLarge?.copyWith(color: onPrimaryColor, fontWeight: FontWeight.bold),
          ).pLTRB(25.w, 0.h, 25.h, 25.h),

          //description
          AutoSizeText(widget.foodItem['description'],
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: onPrimaryColor,
                      ),
                  maxLines: 2)
              .pLTRB(25.w, 0.h, 25.h, 25.h),
          //choose size
          HStack(
            alignment: MainAxisAlignment.spaceBetween,
            [
              Text(
                "${AppLocalizations.of(context)!.size} ",
                style: context.titleMedium?.copyWith(color: onPrimaryColor, fontWeight: FontWeight.bold),
              ),
              4.horizontalSpace,
              //  choice chips flutter material 3 multiple
              SizedBox(
                height: 55.h,
                width: 300.w,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: itemSizes.length,
                  itemBuilder: (context, index) => GestureDetector(
                    onTap: () {

                      setState(() {
                        selectedSize = itemSizes[index];
                      });


                      if(selectedSize == "Petit" || selectedSize == "Small" ){
                        print(widget.foodItem["prices"]['Small']);
                      }

                      if(selectedSize == "Moyen" || selectedSize == "Medium"){
                        print(widget.foodItem["prices"]['Medium']);
                      }

                      if(selectedSize == "Grand" || selectedSize == "Large"){
                        print(widget.foodItem["prices"]['Large']);
                      }

                    },
                    child: Container(
                      width: 90.w,
                      height: 55.h,
                      margin: EdgeInsets.only(right: 10.w),
                      decoration: BoxDecoration(
                        color: selectedSize == itemSizes[index] ? primaryColor : softBlack,
                        borderRadius: BorderRadius.circular(30.r),
                      ),
                      child: Center(child: AutoSizeText(itemSizes[index])),
                    ),
                  ),
                ),
              ),
            ],
          ).pLTRB(25.w, 0.h, 25.w, 25.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.quantity,
                style: context.titleMedium?.copyWith(color: onPrimaryColor, fontWeight: FontWeight.bold),
              ),
              //  choice chips flutter material 3 multiple
              HStack([
                //   minus btn
                ElevatedButton(
                    // no content padding style
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softBlack,
                      foregroundColor: onPrimaryColor,
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                    onPressed: () {
                      setState(() {
                        if (number > 1) {
                          number--;
                        }
                      });
                    },
                    child: const Icon(Icons.remove)),
                8.horizontalSpace,
                //   nmbr
                Text(
                  "$number",
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                8.horizontalSpace,
                //  plus button
                ElevatedButton(
                    // no content padding style
                    style: ElevatedButton.styleFrom(
                      backgroundColor: softBlack,
                      foregroundColor: onPrimaryColor,
                      padding: EdgeInsets.zero,
                      shape: const CircleBorder(),
                    ),
                    onPressed: () {
                      setState(() {
                        number++;
                      });
                    },
                    child: const Icon(Icons.add)),
              ])
            ],
          ).pLTRB(25.w, 0.h, 10.h, 25.h),
          //promo code
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppLocalizations.of(context)!.promoCode,
                style: context.titleMedium?.copyWith(color: onPrimaryColor, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: softBlack,
                  foregroundColor: onPrimaryColor,
                  padding: EdgeInsets.zero,
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  //dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return Theme(
                        data: Theme.of(context).copyWith(dialogBackgroundColor: Colors.orange),
                        child: AlertDialog(
                          title: Center(child: Text(AppLocalizations.of(context)!.enterPromoCode)),
                          content: CustomTextField(
                            hintText: AppLocalizations.of(context)!.enterPromoCode,
                          ),
                          actions: [
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: softBlack,
                                  foregroundColor: onPrimaryColor,
                                  // minimumSize: Size(112.w, 60.h),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(AppLocalizations.of(context)!.cancel)),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: onPrimaryColor,
                                  // minimumSize: Size(112.w, 60.h),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(AppLocalizations.of(context)!.submit)),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Text(
                  AppLocalizations.of(context)!.use,
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ).pLTRB(25.w, 0.h, 25.h, 8.h),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 10.w),
            child: ExpansionTile(
              childrenPadding: EdgeInsets.symmetric(horizontal: 20.w),
                title: Text(
                  "Add-Ons",
                  style: context.titleMedium?.copyWith(color: onPrimaryColor, fontWeight: FontWeight.bold),
                ),
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: _myItemAddons.length,
                    itemBuilder: (context, index) {
                      String addonType = _myItemAddons[index].addonType;
                      String canChooseUpto = _myItemAddons[index].canChooseUpto.toString();
                      bool isChoice = addonType == "Choices";
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isChoice
                              ?MyChoicesAddons(
                            addonItem: _myItemAddons[index],
                            onChanges: (addonName, addonItem ,value) {


                              if(selectedAddons.containsKey(addonName)){

                                if(value){
                                  if(selectedAddons[addonName]!.length < int.parse(canChooseUpto)){
                                    selectedAddons[addonName]?.add({
                                      "name": addonItem,
                                      "price": "0.0",
                                      "qty": "1",
                                    });}
                                }else{
                                  selectedAddons[addonName]?.removeWhere((element) => element['name'] == addonItem);
                                }
                              }else{
                                selectedAddons[addonName] = [];
                                selectedAddons[addonName]?.add({
                                  "name": addonItem,
                                  "price": "0.0",
                                  "qty": "1",
                                });
                              }

                              if(selectedAddons.containsKey(addonName)){
                                if(selectedAddons[addonName]!.isEmpty){
                                  selectedAddons.remove(addonName);
                                }
                              }

                              getTotalPrice();
                              print(selectedAddons);

                            },
                          )
                          :MyIngredientsAddons(
                            addonItem: _myItemAddons[index],
                            onChanges: (addonName, addonItem, price,isAdd) {

                              if (selectedAddons.containsKey(addonName)) {

                                if (price > 0) {
                                  if (!selectedAddons[addonName]!.any((element) => element['name'] == addonItem)) {

                                    selectedAddons[addonName]?.add({
                                      "name": addonItem,
                                      "price": price.toString(),
                                      "qty": "1",
                                    });
                                  } else {

                                    // Increase the totalAddonPrice by the difference in price
                                    var existingItem = selectedAddons[addonName]!.firstWhere((element) => element['name'] == addonItem);
                                    existingItem['price'] = price.toString();
                                    int qty = isAdd ? int.parse(existingItem['qty']!)+1 : int.parse(existingItem['qty']!)-1;
                                    existingItem['qty'] = qty.toString();
                                  }
                                } else {

                                  // Decrease the totalAddonPrice by the unit price of the item being removed
                                  var removedItem = selectedAddons[addonName]!.firstWhere((element) => element['name'] == addonItem);
                                  selectedAddons[addonName]?.removeWhere((element) => element['name'] == addonItem);
                                  // int qty = int.parse(removedItem['qty']!)-1;
                                  // removedItem['qty'] = qty.toString();
                                }
                              } else {
                                selectedAddons[addonName] = [{
                                  "name": addonItem,
                                  "price": price.toString(),
                                  "qty": "1",
                                }];
                              }


                              if(selectedAddons.containsKey(addonName)){
                                if(selectedAddons[addonName]!.isEmpty){
                                  selectedAddons.remove(addonName);
                                }
                              }

                              getTotalPrice();

                              double addOnsPrice= selectedAddons.values
                                  .expand((addons) => addons)
                                  .map((addon) => addon['price'])
                                  .fold(0, (prev, price) => prev + (double.parse(price!)));


                              print(selectedAddons);


                            },

                          ),
                          10.verticalSpace,

                        ],
                      );
                    },
                    physics: const NeverScrollableScrollPhysics(),
                  ),
                ],
            ),
          ),
          10.verticalSpace,
          Container(
            height: 150.h,
            width: 380.w,
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            decoration: BoxDecoration(
              color: softBlack,
              borderRadius: BorderRadius.circular(22.r),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(getPriceTotoal(priceStr),
                            style: context.headlineLarge),
                        Baseline(
                          baseline: 10.h,
                          baselineType: TextBaseline.alphabetic,
                          child: Text("€", style: context.headlineSmall),
                        ),
                      ],
                    ),
                    Text(AppLocalizations.of(context)!.totalPrice, style: context.titleSmall).px(11.w),
                  ],
                ),
              ),
              3.horizontalSpace,
              Expanded(
                child: PrimaryButton(
                  child: Text(
                    AppLocalizations.of(context)!.addToCart,
                    style: TextStyle(
                      color: const Color(0xFFE4E4E4),
                      fontSize: 14.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                  ),
                  onPressed: () {
                    final myData = Provider.of<CartNotifier>(context, listen: false);
                    myData.addItem(
                      widget.restaurantId,
                      widget.restaurantName,
                      widget.restaurantImage,
                      widget.foodItem["itemId"],
                      widget.foodItem['photo'] ?? "",
                      widget.foodItem['name'],
                      double.parse(widget.foodItem['discountedPrice'].toString()),
                      widget.foodItem['rewards'].toString(),
                      number,
                      selectedSize,
                      selectedAddons,
                    );
                    addToCartPopUp();
                  },
                ).wh(164.w, 60.h),
              )
            ]),
          ).marginOnly(
            bottom: 25.h,
            left: 25.w,
            right: 25.w,
          ),
        ],
      ),
    );
  }
}

class MyChoicesAddons extends StatefulWidget {
  final AddonItemWithId addonItem;
  final Function(String, String, bool) onChanges;
  const MyChoicesAddons({Key? key, required this.addonItem, required this.onChanges}) : super(key: key);

  @override
  State<MyChoicesAddons> createState() => _MyChoicesAddonsState();
}

class _MyChoicesAddonsState extends State<MyChoicesAddons> {
  List<String> selectedAddonItems = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.addonItem.addonName,
          style: context.titleSmall?.copyWith(color: onPrimaryColor, fontWeight: FontWeight.bold),
        ),
        Text("You can Choose up to ${widget.addonItem.canChooseUpto} items"),
        Column(
          children: widget.addonItem.addonItems.map((addonItem) {
            String addonName = addonItem['name'];
            bool isSelected = selectedAddonItems.contains(addonName);

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(addonName),
                Checkbox(
                  value: isSelected,
                  onChanged: (value) {
                    bool isAdded = value!;
                    setState(() {

                      if (value!) {
                        if (selectedAddonItems.length < widget.addonItem.canChooseUpto) {
                          selectedAddonItems.add(addonName);
                        }
                      } else {
                        selectedAddonItems.remove(addonName);
                      }
                      widget.onChanges(widget.addonItem.addonName, addonName, isAdded);
                    });
                  },
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}



class MyIngredientsAddons extends StatefulWidget {
  final AddonItemWithId addonItem;
  final Function(String, String, double,bool) onChanges;
  const MyIngredientsAddons({Key? key, required this.addonItem, required this.onChanges}) : super(key: key);

  @override
  State<MyIngredientsAddons> createState() => _MyIngredientsAddonsState();
}

class _MyIngredientsAddonsState extends State<MyIngredientsAddons> {
  List<int> _itemCountList = [];

  @override
  void initState() {
    super.initState();
    _itemCountList = List.filled(widget.addonItem.addonItems.length, 0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
      Text(
      widget.addonItem.addonName,
      style: context.titleSmall?.copyWith(color: onPrimaryColor, fontWeight: FontWeight.bold),
    ),
    Text("You can Choose up to ${widget.addonItem.canChooseUpto} items"),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.addonItem.addonItems.length,
          itemBuilder: (context, index) {
            final item = widget.addonItem.addonItems[index];
            String addonName = item['name'];
            double price = double.parse(item['price'].toString());
            int itemCount = _itemCountList[index];
            double totalPrice = price * itemCount;
            String priceToShow = itemCount > 1 ? "$totalPrice  (-/$price)" : "$price";
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(addonName),
              subtitle: Text('Price: $priceToShow',style: TextStyle(color: primaryColor ),),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_itemCountList[index] > 0) {
                        setState(() {
                          _itemCountList[index]--;
                          widget.onChanges(widget.addonItem.addonName, item['name'], _calculateTotalPrice(),false);
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 13.r,
                      backgroundColor: primaryColor.withOpacity(0.9),
                      child: Icon(Icons.remove,size: 14.sp,),
                    ),
                  ),
                  5.horizontalSpace,
                  SizedBox(
                    width: 20.w,
                      child: Center(child: Text(_itemCountList[index].toString(),style: TextStyle(fontSize: 15.sp,color: Colors.white ),))),
                  5.horizontalSpace,
                  GestureDetector(
                    onTap: () {
                      if (_calculateTotalCount() < widget.addonItem.canChooseUpto) {
                        setState(() {
                          _itemCountList[index]++;
                          widget.onChanges(widget.addonItem.addonName, item['name'], _calculateTotalPrice(),true);
                        });
                      }
                    },
                    child: CircleAvatar(
                      radius: 13.r,
                      backgroundColor: primaryColor.withOpacity(0.9),
                      child: Icon(Icons.add,size: 14.sp,),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  int _calculateTotalCount() {
    return _itemCountList.fold(0, (prev, count) => prev + count);
  }

  double _calculateTotalPrice() {
    double totalPrice = 0;
    for (int i = 0; i < widget.addonItem.addonItems.length; i++) {
      totalPrice += _itemCountList[i] * double.parse(widget.addonItem.addonItems[i]['price'].toString());
    }
    return totalPrice;
  }
}





class PlaceOrderCategoriesController extends GetxController {
  RxInt activeChip = 0.obs;

  void setActiveChip(int index) {
    activeChip.value = index;
  }
}

class PlaceOrderChip extends StatelessWidget {
  final int index;
  final String name;

  const PlaceOrderChip({Key? key, required this.index, required this.name}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ElevatedButton(
        onPressed: () {
          switch (index) {
            case 0:
              Get.find<PlaceOrderCategoriesController>().setActiveChip(index);
              break;
            case 1:
              Get.find<PlaceOrderCategoriesController>().setActiveChip(index);
              break;
            case 2:
              Get.find<PlaceOrderCategoriesController>().setActiveChip(index);
              break;
            default:
              Get.find<PlaceOrderCategoriesController>().setActiveChip(index);
          }
        },
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          backgroundColor: Get.find<PlaceOrderCategoriesController>().activeChip.value == index ? primaryColor : softBlack,
          foregroundColor: onNeutralColor,
          disabledBackgroundColor: softBlack,
          textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          // side: BorderSide(
          //   color: Get.find<PlaceOrderCategoriesController>().activeChip.value == index
          //       ? primaryColor
          //       : Colors.transparent,
          //   width: 1,
          // ),
          shape: const StadiumBorder(),
          maximumSize: Size(115.w, 55.h),
        ),
        child: AutoSizeText(
          name,
          maxLines: 1,
        ),
      ),
    );
  }
}
