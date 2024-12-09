import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/controllers/res_categories_controller.dart';
import 'package:paraiso/screens/free_items_screen.dart';
import 'package:paraiso/screens/place_order.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../controllers/Restaurants/menu_controller.dart';
import '../controllers/Restaurants/nearby_restaurants_controller.dart';
import '../controllers/rewards_controller.dart';
import '../repositories/customer_firebase_calls.dart';
import '../routes/routes_constants.dart';
import '../util/local_storage/shared_preferences_helper.dart';
import 'Restaurant/Main/RHomeView.dart';

class RestaurantDetailsScreen extends StatefulWidget {
  final String restaurantName;
  final String restaurantEmail;
  final String restaurantAddress;
  final String image;
  final String isOnlineImage;
  final String restaurantID;
  final bool isAvailable;

  const RestaurantDetailsScreen(
      {Key? key,
      required this.restaurantName,
      required this.restaurantAddress,
      required this.image,
      required this.isOnlineImage,
      required this.restaurantID,
      required this.restaurantEmail,
      this.isAvailable = true})
      : super(key: key);

  @override
  State<RestaurantDetailsScreen> createState() =>
      _RestaurantDetailsScreenState();
}

class _RestaurantDetailsScreenState extends State<RestaurantDetailsScreen> {
  // String restaurantAddress = "Brooklyn, 8th Ave";
  ResCategoriesController resCategoriesController =
      Get.put(ResCategoriesController());

  List<Map<String, dynamic>> items = [];
  bool loading = false;
  Map<String, dynamic>? res = {};
  List<Map<String, dynamic>> freeItems = [];
  String? freeItemName;
  String? freeItemGiftType;
  int? freeItemGiftAmount;
  String? freeItemGiftImg;
  late RewardsController _rewardsController;
  late MenuItemsController _menuItemsController;

  Future<void> getRestaurant(String email, String restaurantAdminId) async {
    setState(() {
      loading = true;
    });
    final mydata = MyCustomerCalls();
    res = await mydata.getRestaurantByEmail(email);
    res ??= await mydata.getRestaurantById(restaurantAdminId);
    setState(() {
      loading = false;
    });
  }

  Future<void> getItems(String email, String restaurantAdminId) async {
    final mydata = MyCustomerCalls();
    var docs = await mydata.getItemsbyEmail(email);
    docs = docs.isEmpty ? await mydata.getItems(restaurantAdminId) : docs;
    for (final doc in docs) {
      items.add({
        "itemId": doc.id,
        "itemData": doc.data(),
      });
    }
    for (final item in items) {
      final itemData = item["itemData"];
      if (isItemFree(itemData)) {
        freeItems.add(item);
      }
    }
    if (freeItems.isNotEmpty) {
      freeItemName = freeItems[0]['itemData']['name'];
      freeItemGiftType = freeItems[0]['itemData']['free'].keys.first;
      freeItemGiftAmount =
          freeItems[0]['itemData']['free'][freeItemGiftType].toInt();
      freeItemGiftImg = pickImage(freeItemGiftType!);
    }
    setState(() {});
  }

  bool isItemFree(Map<String, dynamic> itemData) {
    return itemData.containsKey("free") && itemData['free'].isNotEmpty;
  }

  @override
  void didChangeDependencies() async {
    getData();
    super.didChangeDependencies();
  }

  getData() async {
    final email = SharedPreferencesHelper.getCustomerEmail();
    _rewardsController = Provider.of<RewardsController>(context, listen: false);
    _menuItemsController =
        Provider.of<MenuItemsController>(context, listen: false);
    await _menuItemsController.fetchMenu(widget.restaurantID);
    await _rewardsController.getRewards(email!);
  }

  @override
  void initState() {
    super.initState();
    getRestaurant(widget.restaurantEmail, widget.restaurantID);
    getItems(widget.restaurantEmail, widget.restaurantID);
  }

  @override
  Widget build(BuildContext context) {
    List<String> categories = items
        .map((item) => item["itemData"]["type"] as String)
        .toSet()
        .toList();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
      ),
      body: SafeArea(
        child: loading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : ListView(
                // remove the bounce effect
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                children: [
                  // FIRST ROW
                  HStack(crossAlignment: CrossAxisAlignment.start, [
                    widget.isOnlineImage == "true"
                        ? Container(
                            width: 100.h,
                            height: 100.h,
                            decoration: ShapeDecoration(
                              shape: const CircleBorder(),
                              color: Colors.white,
                              image: DecorationImage(
                                image: NetworkImage(widget.image),
                                fit: BoxFit.contain,
                              ),
                            ),
                            // child: Image.network(
                            //   image,
                            //   width: 73.w,
                            //   height: 73.h,
                            // ),
                          )
                        : Image.asset(
                            "assets/images/${widget.image}",
                            width: 100.h,
                            height: 100.h,
                          ).scale(scaleValue: 1.5).cornerRadius(22.h),
                    // Image.asset(
                    //   // could load a less rounded variant by appending rounded_rect to
                    //   // the img and then name the restaurants acc
                    //   // then remove the scaling,
                    //   "assets/images/${widget.image}",
                    //   width: 100.h,
                    //   height: 100.h,
                    // ).scale(scaleValue: 1.5).cornerRadius(22.h),
                    10.horizontalSpace,
                    VStack([
                      SizedBox(
                        width: 262.w,
                        child: Text(
                          widget.restaurantName,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                                fontWeight: FontWeight.bold,
                                color: onPrimaryColor,
                              ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ),
                      4.verticalSpace,
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width * .6,
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/images/restaurant location.svg",
                                color: primaryColor,
                                width: 18.w,
                              ),
                              5.horizontalSpace,
                              Expanded(
                                child: Text(
                                  widget.restaurantAddress,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                        color: onNeutralColor,
                                      ),
                                ),
                              ),
                            ]),
                      ),
                      Consumer<NearbyRestaurantsController>(
                        builder: (context, value, child) {
                          bool isNoFavorite = value.restaurantFavorites
                                  .containsKey(widget.restaurantID)
                              ? value.restaurantFavorites[widget.restaurantID]!
                              : true;
                          return ElevatedButton(
                            onPressed: () async {
                              if (SharedPreferencesHelper.getCustomerType() !=
                                  'guest') {
                                isNoFavorite = !isNoFavorite;

                                await value.toggleRestaurantFavorite(
                                    widget.restaurantID, isNoFavorite);
                              } else {
                                context.push(AppRouteConstants.loginRoute);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              foregroundColor: onPrimaryColor,
                              disabledBackgroundColor: softBlack,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              shape: const StadiumBorder(),
                              minimumSize: Size(30.w, 30.h),
                            ),
                            child: HStack(
                              alignment: MainAxisAlignment.spaceBetween,
                              [
                                Icon(
                                  isNoFavorite == false
                                      ? Icons.check_circle
                                      : Icons.favorite,
                                  size: 18.h,
                                ),
                                8.horizontalSpace,
                                Text(
                                  isNoFavorite == false
                                      ? AppLocalizations.of(context)!.following
                                      : AppLocalizations.of(context)!.follow,
                                  style: TextStyle(fontSize: 15.sp),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ])
                  ]).pLTRB(25.w, 25.h, 25.w, 0),
                  // SECOND ROW
                  HStack([
                    GestureDetector(
                      onTap: () {
                        if (freeItemName != null) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FreeItemsScreen(
                                        restaurantID: widget.restaurantID,
                                        restaurantName: widget.restaurantName,
                                        image: widget.image,
                                        userRewards: _rewardsController.rewards,
                                      ))).then((value) => getData());
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: softBlack,
                          borderRadius: BorderRadius.circular(22.h),
                        ),
                        child: ClipRRect(
                            borderRadius: BorderRadius.circular(22.h),
                            child: ZStack([
                              // FractionallySizedBox(
                              //   widthFactor: 1,
                              //   heightFactor: 1.7,
                              //   child:
                              Positioned(
                                top: -45.h,
                                child: Image.asset(
                                  "assets/images/wave_3.png",
                                  width: 380.w,
                                  height: 175.h,
                                  fit: BoxFit.fill,
                                ),
                                // child: SvgPicture.asset(
                                //   "assets/images/wave_3.png",
                                //   // ),
                                // ).w(380.w),
                              ),
                              Positioned(
                                top: 10.h,
                                left: 25.w,
                                right: 27.w,
                                child: VStack(
                                    alignment: MainAxisAlignment.spaceBetween,
                                    [
                                      HStack(
                                          alignment:
                                              MainAxisAlignment.spaceBetween,
                                          [
                                            Text(
                                              AppLocalizations.of(context)!
                                                  .rewards,
                                              style: TextStyle(
                                                fontFamily: "Recoleta",
                                                fontSize: 22.sp,
                                                fontWeight: FontWeight.w700,
                                                color: const Color(0xffe5e5e5),
                                                height: 30 / 22,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                            Consumer<RewardsController>(
                                              builder: (context, value, child) {
                                                return Row(
                                                  children: [
                                                    Text.rich(
                                                      TextSpan(
                                                        children: [
                                                          TextSpan(
                                                            text:
                                                                '${AppLocalizations.of(context)!.owned}   ',
                                                            style:
                                                                const TextStyle(
                                                              color: Color(
                                                                  0xFFE4E4E4),
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Recoleta',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            ),
                                                          ),
                                                          TextSpan(
                                                            text: value.rewards
                                                                    is double
                                                                ? "${value.rewards.toInt()} "
                                                                : "${value.rewards} ",
                                                            style:
                                                                const TextStyle(
                                                              color: Color(
                                                                  0xFFE4E4E4),
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Recoleta',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    4.horizontalSpace,
                                                    SvgPicture.asset(
                                                      "assets/images/Food Filter_OBJECTS_458_13901.svg",
                                                      width: 20.w,
                                                    ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ]).w(380.w),
                                      HStack(
                                          alignment:
                                              MainAxisAlignment.spaceBetween,
                                          [
                                            Text(
                                                freeItemName != null
                                                    ? AppLocalizations.of(
                                                            context)!
                                                        .freeItemName(
                                                            freeItemName!)
                                                    : AppLocalizations.of(
                                                            context)!
                                                        .noFreeItems,
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.w400,
                                                )),
                                            freeItemName != null
                                                ? HStack([
                                                    Text(
                                                      freeItemGiftAmount
                                                          .toString(),
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineSmall!
                                                          .copyWith(
                                                              fontSize: 22.sp,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  onPrimaryColor),
                                                    ),
                                                    4.horizontalSpace,
                                                    freeItemGiftImg != null &&
                                                            freeItemGiftImg!
                                                                .contains(
                                                                    ".svg")
                                                        ? SvgPicture.asset(
                                                            freeItemGiftImg!,
                                                            width: 20.w,
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                                    freeItemGiftImg != null &&
                                                            freeItemGiftImg!
                                                                .contains(
                                                                    ".png")
                                                        ? Image.asset(
                                                            freeItemGiftImg!,
                                                            width: 25.w,
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                                  ])
                                                : const SizedBox.shrink(),
                                          ]).w(380
                                          .w), // to stretch bottom row full width
                                    ]).wh(380.w, 125.h),
                              ),
                            ])
                            // .scale(
                            //   scaleValue: 1.2,
                            // ),
                            ),
                      ).wh(380.w, 150.h),
                    ),
                  ]).wFull(context).marginAll(25.w).onInkTap(() {}),
                  // THIRD ROW
                  HStack([
                    //   btn 1
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5.w,
                          vertical: 9.h,
                        ).copyWith(left: 11.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: onPrimaryColor,
                            width: .5,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                          borderRadius: BorderRadius.circular(15.h),
                        ),
                        child: VStack([
                          HStack([
                            //   icon
                            SvgPicture.asset(
                              "assets/images/moon.svg",
                              color: primaryColor,
                              width: 16.w,
                            ),
                            4.horizontalSpace,
                            SizedBox(
                              child: Text(
                                " ${AppLocalizations.of(context)!.closed}",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(
                                      color: onPrimaryColor,
                                    ),
                              ),
                            )
                          ]),
                          4.verticalSpace,
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              res!['openingHrs'] ?? " --- ",
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    color: onPrimaryColor,
                                  ),
                            ),
                          )
                        ]),
                      ).onTap(() {}),
                    ),
                    10.horizontalSpace,
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 147.w,
                        maxWidth: 150.w,
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15.w,
                          vertical: 9.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: onPrimaryColor,
                            width: .5,
                            strokeAlign: BorderSide.strokeAlignInside,
                          ),
                          borderRadius: BorderRadius.circular(15.h),
                        ),
                        child: VStack([
                          HStack([
                            //   icon
                            SvgPicture.asset(
                              "assets/images/clock.svg",
                              color: primaryColor,
                              width: 16.w,
                            ),
                            4.horizontalSpace,
                            Text(
                              res!['prepDelay'] == null
                                  ? "---"
                                  : res!['prepDelay'] != ""
                                      ? " ${res!['prepDelay']}"
                                      : "---",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: onPrimaryColor,
                                  ),
                            )
                          ]),
                          4.verticalSpace,
                          Text(
                            AppLocalizations.of(context)!.estPickupTime,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: onPrimaryColor,
                                    ),
                          )
                        ]),
                      ).onTap(() {}),
                    ),
                    //   btn 2
                  ]).marginSymmetric(horizontal: 25.w),

                  // FOURTH ROW
                  HStack(alignment: MainAxisAlignment.spaceBetween, [
                    Text(
                      AppLocalizations.of(context)!.categories,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: onPrimaryColor,
                          ),
                    ),
                  ]).pLTRB(25, 21, 26, 0),
                  // FIFTH ROW
                  // HStack([
                  //   const ResChip(index: 0, name: "Drinks"),
                  //   14.horizontalSpace,
                  //   const ResChip(index: 1, name: "Fast Food"),
                  //   14.horizontalSpace,
                  //   const ResChip(index: 2, name: "Sweets"),
                  // ]).scrollHorizontal().w(360.w).pLTRB(25, 8, 26, 0),
                  // SIXTH ROW
                  HStack(
                    categories.map((category) {
                      int index = categories.indexOf(category);
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: ResChip(
                          index: index,
                          name: category,
                        ),
                      );
                    }).toList(),
                  ).scrollHorizontal().w(360.w).pLTRB(25, 8, 26, 0),
                  // SEVENTH ROW
                  // const HStack(alignment: MainAxisAlignment.spaceBetween, [
                  //   myText(),
                  //   // Text(
                  //   //   "Drinks",
                  //   //   style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  //   //         fontWeight: FontWeight.bold,
                  //   //         color: onPrimaryColor,
                  //   //       ),
                  //   // ),
                  // ]).pLTRB(25, 9, 25, 5),
                  //EIGHTTH ROW
                  10.verticalSpace,
                  Obx(() {
                    final activeChip =
                        Get.find<ResCategoriesController>().activeChip.value;
                    if (activeChip >= 0 && activeChip < categories.length) {
                      return MyItemsList(
                        items: items
                            .where((element) =>
                                element["itemData"]["type"] ==
                                categories[activeChip])
                            .toList(),
                        restaurantImage: widget.image,
                        restaurantID: widget.restaurantID,
                        restaurantName: widget.restaurantName,
                      );
                    } else {
                      // Handle the case when no category is selected
                      return MyItemsList(
                        items: items,
                        restaurantImage: widget.image,
                        restaurantID: widget.restaurantID,
                        restaurantName: widget.restaurantName,
                      );
                    }
                  }),
                ],
              ),
      ),
    );
  }
}

class MyItemsList extends StatefulWidget {
  final dynamic items;
  final String restaurantID;
  final String restaurantName;
  final String restaurantImage;
  final bool isAvailable;
  const MyItemsList(
      {Key? key,
      this.items,
      required this.restaurantID,
      required this.restaurantName,
      required this.restaurantImage,
      this.isAvailable = true})
      : super(key: key);

  @override
  State<MyItemsList> createState() => _MyItemsListState();
}

class _MyItemsListState extends State<MyItemsList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.items.length == 0
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                AppLocalizations.of(context)!.noItems,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: onPrimaryColor,
                    ),
              ),
            ),
          )
        : SizedBox(
            height: widget.items.length * 148.h,
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final double price =
                    widget.items[index]["itemData"]["discountedPrice"] is int
                        ? (widget.items[index]["itemData"]["discountedPrice"]
                                as int)
                            .toDouble()
                        : widget.items[index]["itemData"]["discountedPrice"];
                final String priceStr = price.toStringAsFixed(2);
                return ResFoodTile(
                  isAvailable:
                      widget.items[index]["itemData"]["availability"] ?? true,
                  foodItem: widget.items[index]["itemData"],
                  restaurantId: widget.restaurantID,
                  restaurantName: widget.restaurantName,
                  restaurantImage: widget.restaurantImage,
                  foodName: widget.items[index]["itemData"]["name"],
                  isOnlineImage: true,
                  image: widget.items[index]["itemData"]["photo"] ?? "",
                  // image: "Restaurant_Rectangle 8_490_4700.png",
                  category: widget.items[index]["itemData"]["type"],
                  price: priceStr,
                  addOns: widget.items[index]["itemData"]["addOns"],
                );
              },
            ),
          );
  }
}

class ResChip extends StatelessWidget {
  final int index;
  final String name;

  const ResChip({Key? key, required this.index, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ElevatedButton(
        onPressed: () {
          if (Get.find<ResCategoriesController>().activeChip.value != index) {
            switch (index) {
              case 0:
                Get.find<ResCategoriesController>().setActiveChip(index);
                break;
              case 1:
                Get.find<ResCategoriesController>().setActiveChip(index);
                break;
              case 2:
                Get.find<ResCategoriesController>().setActiveChip(index);
                break;
              default:
                Get.find<ResCategoriesController>().setActiveChip(index);
            }
          } else {
            Get.find<ResCategoriesController>().setActiveChip(100);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor:
              Get.find<ResCategoriesController>().activeChip.value == index
                  ? primaryColor
                  : softBlack,
          foregroundColor: onNeutralColor,
          disabledBackgroundColor: softBlack,
          textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          // side: BorderSide(
          //   color: Get.find<ResCategoriesController>().activeChip.value == index
          //       ? primaryColor
          //       : Colors.transparent,
          //   width: 1,
          // ),
          shape: const StadiumBorder(),
          minimumSize: Size(100.w, 60.h),
        ),
        child: Text(name),
      ),
    );
  }
}

class ResFoodTile extends StatelessWidget {
  final String foodName;
  final String image;
  final String category;
  final String price;
  final bool isOnlineImage;
  final String restaurantId;
  final bool isAvailable;
  final String restaurantName;
  final String restaurantImage;
  final Map<String, dynamic> foodItem;
  final List<dynamic>? addOns;

  const ResFoodTile({
    Key? key,
    required this.foodName,
    required this.image,
    required this.category,
    this.isOnlineImage = false,
    this.restaurantId = '',
    this.restaurantName = '',
    required this.price,
    required this.foodItem,
    required this.restaurantImage,
    required this.addOns,
    this.isAvailable = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(15.w, 13.h, 36.w, 13.h),
      margin: EdgeInsets.fromLTRB(25.w, 0.h, 25.w, 15.h),
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(
          color: Color(0xFFF3EEDD),
          width: 1.w,
        ),
      ),
      child: HStack(
          alignment: MainAxisAlignment.start,
          axisSize: MainAxisSize.max,
          [
            isOnlineImage
                ? Container(
                    width: 90.h,
                    height: 95.h,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(image),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(22.h),
                    ),
                  )
                : Container(
                    width: 97.h,
                    height: 97.h,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/images/$image"),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(22.h),
                    ),
                  ),
            18.horizontalSpace,
            VStack([
              // FIRST ROW
              // foodName.text
              if (!isAvailable)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(5.h),
                  ),
                  child: Center(
                    child: Text(
                      "Unavailable",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                    ),
                  ),
                ),
              SizedBox(
                width: MediaQuery.sizeOf(context).width * .5,
                child: Text(
                  foodItem["name"].toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
              2.verticalSpace,
              SizedBox(
                width: MediaQuery.sizeOf(context).width * .5,
                child: Text(
                  foodItem["type"].toString(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Color(0xFF2F58CD),
                      ),
                ),
              ),
              //SECOND ROW
              HStack(
                  alignment: MainAxisAlignment.start,
                  axisSize: MainAxisSize.max,
                  [
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: onPrimaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Baseline(
                      baseline: 10.h,
                      baselineType: TextBaseline.alphabetic,
                      child: Text("€",
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color: onPrimaryColor,
                                    fontWeight: FontWeight.bold,
                                  )),
                    ),
                    13.horizontalSpace,
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        foregroundColor: onPrimaryColor,
                        side: BorderSide(
                          color: onPrimaryColor,
                          width: .5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.r)),
                        ),
                        // minimumSize: Size(100.w, 60.h),
                      ),
                      onPressed: () {},
                      child: HStack([
                        Text("+${foodItem["rewards"]} "),
                        4.horizontalSpace,
                        SvgPicture.asset(
                          "assets/images/Food Filter_OBJECTS_458_13901.svg",
                          width: 16.w,
                        ),
                      ]),
                    )
                  ]).wh(210.w, 30.h),
              10.verticalSpace,
              // 2nd column LAST ROW
              const HStack([]),
            ]).scrollVertical(),
          ]).w(350.w),
    ).w(1.sw).hPCT(context: context, heightPCT: 16).onTap(() {
      // context.push((context) => PlaceOrder(
      //       restaurantId: restaurantId,
      //       restaurantName: restaurantName,
      //       restaurantImage: restaurantImage,
      //       foodItem: foodItem,
      //       addOns: addOns ?? [],
      //     ));
      if (isAvailable) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => PlaceOrder(
                    restaurantId: restaurantId,
                    restaurantName: restaurantName,
                    foodItem: foodItem,
                    restaurantImage: restaurantImage,
                    addOns: addOns ?? [])));
      }
    });
  }
}

// class StackedWavesPainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..shader = LinearGradient(colors: [
//         primaryColor,
//         primaryColor,
//       ]).createShader(Offset.zero & size);
//
//     final double waveWidth = size.width / 2;
//     final double waveHeight = size.height / 1.85;
//
//     final path = Path()
//       ..moveTo(0, waveHeight * 2)
//       ..quadraticBezierTo(waveWidth / 3.2, waveHeight - waveHeight / 3.5,
//           waveWidth, waveHeight * 1.5)
//       ..quadraticBezierTo(waveWidth * 1.5, waveHeight + waveHeight,
//           waveWidth * 2, waveHeight * 1.2)
//       ..lineTo(-size.width, -size.height * 10)
//       // ..lineTo(0, size.height)
//       ..close();
//
//     canvas.save();
//     canvas.drawPath(path, paint);
//     canvas.restore();
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
//
// class StackedWavesPainter2 extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..shader = LinearGradient(colors: [
//         primaryColor,
//         primaryColor,
//       ]).createShader(Offset.zero & size);
//
//     final double waveWidth = size.width / 2;
//     final double waveHeight = size.height / 1.55;
//
//     final path = Path()
//       ..moveTo(0, waveHeight * 2)
//       ..quadraticBezierTo(waveWidth / 3.2, waveHeight - waveHeight / 3.5,
//           waveWidth, waveHeight * 1.5)
//       ..quadraticBezierTo(waveWidth * 1.5, waveHeight + waveHeight,
//           waveWidth * 2, waveHeight * 1.2)
//       ..lineTo(-size.width, -size.height * 10)
//       // ..lineTo(0, size.height)
//       ..close();
//
//     canvas.save();
//     canvas.drawPath(path, paint);
//     canvas.restore();
//   }
//
//   @override
//   bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
//
// // @override
// // void paint(Canvas canvas, Size size) {
// //   final paint = Paint()
// //     ..shader = LinearGradient(colors: [
// //       Colors.green,
// //       Colors.lightGreenAccent,
// //     ]).createShader(Offset.zero & size);
// //   final double side = 80;
// //   final double radius = 80;
// //
// //   final path = Path()
// //     ..moveTo(0, size.height / 2 + side)
// //     ..arcToPoint(Offset(side, size.height / 2),
// //         radius: Radius.circular(radius))
// //     ..lineTo(size.width - side, size.height / 2)
// //     ..arcToPoint(Offset(size.width, size.height / 2 - side),
// //         radius: Radius.circular(radius), clockwise: false)
// //     ..lineTo(size.width, size.height)
// //     ..lineTo(0, size.height)
// //     ..close();
// //
// //   canvas.save();
// //   canvas.drawPath(path, paint);
// //   canvas.restore();
// //
// //   canvas.save();
// //   canvas.translate(0, 100);
// //   canvas.drawPath(path, Paint()..color = Colors.white);
// //   canvas.restore();
// // }
// //
// // @override
// // bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
// }
