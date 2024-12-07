import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/food_tile.dart';

import '../repositories/customer_firebase_calls.dart';

class DiscountSortList extends StatefulWidget {
  const DiscountSortList({Key? key}) : super(key: key);

  @override
  State<DiscountSortList> createState() => _DiscountSortListState();
}

class _DiscountSortListState extends State<DiscountSortList> {
  dynamic restaurantLists = [];
  bool isLoading = false;

  Future<void> getData() async {
    setState(() {
      isLoading = true;
    });
    final mydata = MyCustomerCalls();
    final items = SharedPreferencesHelper.getCustomerType() == 'guest'
        ? await mydata.getItemsByDiscountForGuest()
        : await mydata.getItemsByDiscount();
    for (final item in items) {
      restaurantLists.add(item);
      print('restaurantLists');
      print(restaurantLists);
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        31.verticalSpace,
        isLoading
            ? Center(child: CircularProgressIndicator(color: primaryColor))
            : restaurantLists.length == 0
                ? Center(
                    child: Text(
                        AppLocalizations.of(context)!.noDiscountedItemsYet))
                : SizedBox(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * .65,
                    child: ListView.builder(
                      itemCount: restaurantLists.length,
                      itemBuilder: (context, index) {
                        return FoodTile(
                          restaurantId: restaurantLists[index]["itemName"],
                          addOns: restaurantLists[index]['addOns'] ?? [],
                          itemData: restaurantLists[index]["itemData"],
                          foodName: restaurantLists[index]["itemName"],
                          foodImage: restaurantLists[index]["itemPhoto"],
                          restaurantName: restaurantLists[index]
                              ["restaurantName"],
                          restaurantDistance: double.parse(
                                  (restaurantLists[index]['distance'] / 1000.0)
                                      .toString())
                              .toStringAsFixed(2),
                          discountPercentage: restaurantLists[index]
                              ["discount"],
                          // othersOrdered: 12,
                          othersOrdered:
                              restaurantLists[index]["userOrderCount"] ?? 1,
                          restaurantImage: restaurantLists[index]
                              ["restaurantLogo"],
                          imgOthers2:
                              "Restaurant sort by Discount_img-2_378_11538.png",
                          imgOthers1:
                              "Restaurant sort by Discount_img-3_378_11539.png",
                          imgOthers3:
                              "Restaurant sort by Discount_bg_378_11540.png",
                        );
                      },
                    ),
                  ),
      ],
    );
  }
}
