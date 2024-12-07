import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/controllers/categories_controller.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/custom_chip.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../controllers/sort_by_distance_controller.dart';

class DistanceSortList extends StatefulWidget {
  const DistanceSortList({Key? key}) : super(key: key);

  @override
  State<DistanceSortList> createState() => _DistanceSortListState();
}

class _DistanceSortListState extends State<DistanceSortList> {
  @override
  Widget build(BuildContext context) {
    final categoryProvider = Provider.of<CategoriesProvider>(context);
    final restaurantsList =
        Provider.of<SortByDistanceController>(context, listen: false);

    // Get unique categories from the restaurant data
    List<String> uniqueCategories = restaurantsList.restaurants
        .map((restaurant) => restaurant['category'] as String)
        .toSet()
        .toList();

    return VxBlock(
      children: [
        HStack(alignment: MainAxisAlignment.spaceBetween, [
          uniqueCategories.isEmpty
              ? const SizedBox.shrink()
              : Text(
                  AppLocalizations.of(context)!.categories,
                  style: TextStyle(
                    color: const Color(0xFFE4E4E4),
                    fontSize: 20.sp,
                    fontFamily: 'Recoleta',
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ]).pLTRB(36, 21, 26, 0),
        HStack(
          uniqueCategories.map((category) {
            int index = uniqueCategories.indexOf(category);
            return Padding(
              padding: EdgeInsets.only(right: 8.w),
              child: SortByDistanceChip(
                index: index,
                name: category,
              ),
            );
          }).toList(),
        ).scrollHorizontal().pLTRB(30, 10, 26, 7),

        //   divider
        //   divider
        uniqueCategories.isEmpty
            ? const SizedBox.shrink()
            : Divider(
                color: softBlack,
                thickness: 1,
              ),
        7.verticalSpace,
        Consumer<SortByDistanceController>(
          builder: (context, value, child) {
            final restaurantsList = value.restaurants;
            final selectedCategory = categoryProvider.selectedCategory;

            final filteredRestaurants = restaurantsList.where((restaurant) {
              final restaurantCategory = restaurant['category'];
              return selectedCategory.isEmpty ||
                  restaurantCategory == selectedCategory;
            }).toList();

            final uniqueFilteredRestaurants =
                filteredRestaurants.toSet().toList();

            return uniqueFilteredRestaurants.isEmpty
                ? Center(
                    child: Text(
                        AppLocalizations.of(context)!.noNearbyRestaurantsFound))
                : SizedBox(
                    width: double.infinity,
                    height: MediaQuery.sizeOf(context).height * .52,
                    child: ListView.builder(
                      itemCount: uniqueFilteredRestaurants.length,
                      itemBuilder: (context, index) {
                        return RestaurantTile(
                          isAvailable: uniqueFilteredRestaurants[index]
                                  ['availability'] ??
                              true,
                          restaurantID:
                              uniqueFilteredRestaurants[index]['id'] ?? '',
                          email: uniqueFilteredRestaurants[index]['email'],
                          restaurantName: uniqueFilteredRestaurants[index]
                                  ['name'] ??
                              'avcc',
                          restaurantAddress: uniqueFilteredRestaurants[index]
                                  ['address'] ??
                              "Unknown",
                          restaurantDescription:
                              '${uniqueFilteredRestaurants[index]["description"]}',
                          distance: double.parse(
                                  (uniqueFilteredRestaurants[index]
                                              ['distance'] /
                                          1000.0)
                                      .toString())
                              .toStringAsFixed(2),
                          image: uniqueFilteredRestaurants[index]['logo'] ?? "",
                          isOnlineImage: true,
                        );
                      },
                    ),
                  );
          },
        ),
      ],
    );
  }
}

class RestaurantTile extends StatelessWidget {
  final String restaurantID;
  final String restaurantName;
  final String restaurantDescription;
  final String restaurantAddress;
  final String distance;
  final String image;
  final bool isAvailable;
  final bool isOnlineImage;
  final String? email;

  const RestaurantTile(
      {Key? key,
      required this.restaurantName,
      required this.restaurantDescription,
      required this.restaurantAddress,
      required this.distance,
      required this.image,
      this.isAvailable = true,
      this.isOnlineImage = false,
      this.restaurantID = "",
      this.email})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        GoRouter.of(context)
            .push(Uri(path: '/restaurantDetails', queryParameters: {
          "email": email ?? "",
          "restaurantID": restaurantID,
          "restaurantName": restaurantName,
          "restaurantDescription": restaurantDescription,
          "restaurantAddress": restaurantAddress,
          "distance": distance,
          "image": image,
          "isAvailable": isAvailable.toString(),
          "isOnlineImage": isOnlineImage.toString(),
        }).toString());
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(25.w, 0.h, 20.w, 15.h),
        padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: const Color(0xFFF3EEDD),
            width: 1.w,
          ),
        ),
        width: context.screenWidth,
        child: HStack(alignment: MainAxisAlignment.start, [
          isOnlineImage && image != ""
              ? Container(
                  width: 73.w,
                  height: 73.h,
                  decoration: ShapeDecoration(
                    shape: ContinuousRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    color: Colors.white,
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.contain,
                    ),
                  ),
                )
              : (image == ""
                  ? Container(
                      width: 73.w,
                      height: 73.h,
                      decoration: BoxDecoration(
                        color: softGray,
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: Center(
                          child: VxTextBuilder(restaurantName[0])
                              .textStyle(
                                Theme.of(context).textTheme.headlineLarge!,
                              )
                              .bold
                              .capitalize
                              .make()),
                    )
                  : Image.asset(
                      "assets/images/$image",
                      width: 73.w,
                      height: 73.h,
                    )),
          14.horizontalSpace,
          VStack(alignment: MainAxisAlignment.center, [
            SizedBox(
              width: 190.w,
              child: VxTextBuilder(
                restaurantName,
              )
                  .textStyle(
                    Theme.of(context).textTheme.titleSmall!,
                  )
                  .bold
                  .ellipsis
                  .make(),
            ),
            4.verticalSpace,
            // restaurantName.text. .make(),

            SizedBox(
              width: 190.w,
              child: AutoSizeText(
                restaurantDescription,
                maxLines: 2,
              ),
            )
          ]),
          const Spacer(),
          '$distance km'.text.color(onNeutralColor).make(),
        ]),
      ),
    );
  }
}

List<Map<String, dynamic>> filterMenuItemsByCategory(
    List<Map<String, dynamic>> allItems, String category) {
  if (category == "Tous les articles") {
    return allItems;
  } else {
    return allItems.where((item) => item['category'] == category).toList();
  }
}
