import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:paraiso/controllers/Restaurants/AddOnController.dart';
import 'package:paraiso/controllers/Restaurants/res_auth_controller.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../controllers/Restaurants/image_provider.dart';
import '../../controllers/Restaurants/menu_controller.dart';
import '../../models/product_item.dart';
import '../../util/app_constants.dart';
import '../../util/image_source.dart';
import '../../util/theme/theme_constants.dart';
import '../../widgets/primary_button.dart';
import '../addon_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'RAddOnView.dart';

class RAddItemView extends StatefulWidget {
  const RAddItemView({Key? key}) : super(key: key);

  @override
  State<RAddItemView> createState() => _RAddItemViewState();
}

class _RAddItemViewState extends State<RAddItemView> {
  final itemTitleTxt = TextEditingController();

  final itemDetailTxt = TextEditingController();

  final workingHourTxt = TextEditingController();
  List<Addon> addons = [Addon(expanded: false)];
  List<Map<String, dynamic>> addOnsData = [];

  final prepareDelayTxt = TextEditingController();

  final sPriceController = TextEditingController();
  final mPriceController = TextEditingController();
  final lPriceController = TextEditingController();

  String itemDetailItemtxt = AppConstants.productType[ProductType.plat]!;
  bool availability = false, lowPrice = false, mediumPrice = false, largePrice = false;
  int counter = 0;
  double sPrice = 5;
  double mPrice = 10;
  double lPrice = 20;

  List<AddonItemWithId> _addons = [];
  List<AddonItemWithId> _MyItemAddons = [];

  String? priceValidator(String? value) {
    if (value != null) {
      final isNumeric = double.tryParse(value);
      if (isNumeric == null || isNumeric.isNaN) {
        return "Please enter a valid number";
      }
    }
    return null;
  }

  bool checkIfNameOrPriceIsEmpty(List<Map<String, dynamic>> dataList) {
    return !dataList.any((data) {
      final name = data['name']?.toString() ?? '';
      final price = data['price']?.toString() ?? '';
      return name.isEmpty || price.isEmpty;
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    final authController = Provider.of<AuthController>(context, listen: false);
    final addonItemsController = Provider.of<AddOnController>(context, listen: false);
    addonItemsController.fetchADDON(authController.user!.userId);
    _addons = addonItemsController.addons;
  }

  Future<void> locationPopup() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context,setState){
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.r),
              ),
              backgroundColor: const Color.fromRGBO(53, 53, 53, 1),
              content: VStack(
                crossAlignment: CrossAxisAlignment.center,
                [
                  5.verticalSpace,
                  Text(
                    "Ajouter Add-Ons",
                    style: context.titleLarge?.copyWith(
                      color: onPrimaryColor,
                    ),
                  ),
                  20.verticalSpace,
                  SizedBox(
                    height: 300.h,
                    width: 300.w,
                    child: ListView.builder(
                      itemCount: _addons.length,
                      itemBuilder: (context, index) {
                        return AddOnTile(
                          title: _addons[index].addonName,
                          subData: "${_addons[index].addonItems.length}${_addons[index].addonType == "Choices" ? " choices" : " ingredients"}",
                          showDeleteButton: false,
                          isChecked: _MyItemAddons.contains(_addons[index]),
                          onTap: () {
                            if(_MyItemAddons.contains(_addons[index])){
                              _MyItemAddons.remove(_addons[index]);
                            }else{
                              _MyItemAddons.add(_addons[index]);
                            }
                            setState(() {
                            });
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                PrimaryButton(
                  child: Text(
                    "Done",
                    style: TextStyle(
                      color: onPrimaryColor,
                    ),
                  ),
                  onPressed: () {
                    changeState();
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
        } );
  }
  void changeState(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    final imageController = Provider.of<ImageUploadProvider>(context);
    final menuController = Provider.of<MenuItemsController>(context);
    final authController = Provider.of<AuthController>(context, listen: false);

    void selectAnduploadImage() async {
      final imageSource = await ImageSourcePicker.showImageSource(context);
      if (imageSource != null) {
        final file = await ImageSourcePicker.pickFile(imageSource);
        if (file != null) {
          await imageController.uploadImageToFirebase(file);
        }
      }
    }

    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      height: 50.h,
                      width: 50.w,
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
                    AppLocalizations.of(context)!.addItem,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 23.sp),
                  ),
                  const Spacer(),
                  const Spacer(),
                ],
              ),
              SizedBox(
                height: 40.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 80.0,
                    backgroundColor: Colors.grey.shade700,
                    backgroundImage: imageController.imageUrl != null ? NetworkImage(imageController.imageUrl!) : null,
                    child: InkWell(
                      onTap: selectAnduploadImage,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 30.h,
              ),
              Text(
                AppLocalizations.of(context)!.itemDetails,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 23.sp),
              ),
              SizedBox(
                height: 30.h,
              ),
              TextField(
                controller: itemTitleTxt,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp, color: Colors.white),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.w), hintText: AppLocalizations.of(context)!.itemTitle, hintStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp)),
              ),
              SizedBox(
                height: 10.h,
              ),
              TextField(
                controller: itemDetailTxt,
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp, color: Colors.white),
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.w), hintText: AppLocalizations.of(context)!.itemDetail, hintStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp)),
              ),
              SizedBox(
                height: 10.h,
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                decoration: BoxDecoration(color: const Color.fromRGBO(53, 53, 53, 1), borderRadius: BorderRadius.circular(30.r)),
                child: DropdownButton(
                    items: AppConstants.productType.values
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ))
                        .toList(),
                    value: itemDetailItemtxt,
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp),
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      size: 20.sp,
                    ),
                    padding: EdgeInsets.zero,
                    underline: Container(),
                    isExpanded: true,
                    onChanged: (val) {
                      setState(() {
                        itemDetailItemtxt = val!;
                      });
                    }),
              ),
              SizedBox(
                height: 20.h,
              ),
              Row(
                children: [
                  Text("Ajouter Addon:", style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 23.sp),),
                  const Spacer(),
                  GestureDetector(
                    onTap: () async{
                      await locationPopup();
                      setState(() {

                      });
                    },
                    child: Container(
                      height: 40.h,
                      width: 60.w,
                      margin: EdgeInsets.only(right: 5.w),
                      decoration:  BoxDecoration(
                          color: const Color(0xFF2F58CD),
                          borderRadius: BorderRadius.all(Radius.circular(10.r))),
                      child: Center(
                        child: Icon(
                          Icons.add,
                          size: 30.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 95.h* _MyItemAddons.length,
                width: 380.w,
                child: ListView.builder(
                  itemCount: _MyItemAddons.length,
                  itemBuilder: (context, index) {
                    return AddOnTile(
                      title: _MyItemAddons[index].addonName,
                      subData: "${_MyItemAddons[index].addonItems.length}${_MyItemAddons[index].addonType == "Choices" ? " choices" : " ingredients"}",
                      onDelete: (){
                        _MyItemAddons.remove(_MyItemAddons[index]);
                        setState(() {

                        });
                      },
                    );
                  },
                ),
              ),
              // AddonView(
              //   addons: addons,
              //   onAddonsChanged: (newAddons) {
              //     setState(() {
              //       addons = newAddons;
              //     });
              //   },
              //   onAddonadded: (newAddons) {
              //     setState(() {
              //       addOnsData = newAddons;
              //     });
              //   },
              // ),
              SizedBox(
                height: 30.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.availability,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 23.sp),
                  ),
                  SizedBox(
                    height: 30.h,
                    width: 50.w,
                    child: FlutterSwitch(
                        value: availability,
                        inactiveToggleColor: const Color.fromRGBO(53, 53, 53, 1),
                        inactiveColor: Colors.grey.shade700,
                        activeToggleColor: const Color(0xFF2F58CD),
                        activeColor: const Color.fromRGBO(255, 97, 84, 0.5),
                        onToggle: (val) {
                          setState(() {
                            availability = val;
                          });
                        }),
                  )
                ],
              ),
              SizedBox(
                height: 40.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.rewards,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 23.sp),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (counter > 0) {
                            setState(() {
                              counter--;
                            });
                          }
                        },
                        child: Container(
                          height: 40.h,
                          width: 40.w,
                          margin: EdgeInsets.only(right: 5.w),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(53, 53, 53, 1), image: DecorationImage(image: AssetImage('assets/icons/minus.png'))),
                        ),
                      ),
                      Text(
                        '$counter',
                        style: TextStyle(fontWeight: FontWeight.w400, fontSize: 25.sp),
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      Image.asset(
                        'assets/icons/objects.png',
                        height: 20.h,
                        width: 20.w,
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            counter++;
                          });
                        },
                        child: Container(
                          height: 40.h,
                          width: 40.w,
                          margin: EdgeInsets.only(left: 5.w),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(53, 53, 53, 1), image: DecorationImage(image: AssetImage('assets/icons/plus.png'))),
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 40.h,
              ),
              Text(
                AppLocalizations.of(context)!.selectPrice,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 23.sp),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 220.w,
                    margin: EdgeInsets.only(top: 30.h),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                    decoration: BoxDecoration(color: const Color.fromRGBO(53, 53, 53, 1), borderRadius: BorderRadius.circular(18.r)),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              height: 25.h,
                              width: 25.w,
                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(5.r), border: Border.all(color: Colors.grey.shade700)),
                            ),
                            Text(AppLocalizations.of(context)!.size, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)),
                            Text(AppLocalizations.of(context)!.price, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: const Divider(
                            color: Colors.white,
                            thickness: 1.0,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  lowPrice = !lowPrice;
                                });
                              },
                              child: Container(
                                height: 25.h,
                                width: 25.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.r),
                                    border: Border.all(color: lowPrice == true ? Colors.transparent : Colors.grey.shade700),
                                    color: lowPrice == true ? const Color(0xFF2F58CD) : Colors.transparent),
                                child: lowPrice == true
                                    ? Center(
                                        child: Icon(
                                          Icons.done,
                                          size: 22.sp,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Container(),
                              ),
                            ),
                            Text(AppLocalizations.of(context)!.small, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14.sp)),
                            SizedBox(
                              width: 60.w,
                              child: TextFormField(
                                cursorColor: primaryColor,
                                controller: sPriceController,
                                validator: priceValidator,
                                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp, color: Colors.white),
                                decoration:
                                    InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 10.w), hintText: '$sPrice€', hintStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp)),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: const Divider(
                            color: Colors.white,
                            thickness: 1.0,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  mediumPrice = !mediumPrice;
                                });
                              },
                              child: Container(
                                height: 25.h,
                                width: 25.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.r),
                                    border: Border.all(color: mediumPrice == true ? Colors.transparent : Colors.grey.shade700),
                                    color: mediumPrice == true ? const Color(0xFF2F58CD) : Colors.transparent),
                                child: mediumPrice == true
                                    ? Center(
                                        child: Icon(
                                          Icons.done,
                                          size: 22.sp,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Container(),
                              ),
                            ),
                            Text(AppLocalizations.of(context)!.medium, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14.sp)),
                            SizedBox(
                              width: 60.w,
                              child: TextFormField(
                                cursorColor: primaryColor,
                                controller: mPriceController,
                                validator: priceValidator,
                                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp, color: Colors.white),
                                decoration:
                                    InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8.w), hintText: '$mPrice€', hintStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp)),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: const Divider(
                            color: Colors.white,
                            thickness: 1.0,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  largePrice = !largePrice;
                                });
                              },
                              child: Container(
                                height: 25.h,
                                width: 25.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5.r),
                                    border: Border.all(color: largePrice == true ? Colors.transparent : Colors.grey.shade700),
                                    color: largePrice == true ? const Color(0xFF2F58CD) : Colors.transparent),
                                child: largePrice == true
                                    ? Center(
                                        child: Icon(
                                          Icons.done,
                                          size: 22.sp,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Container(),
                              ),
                            ),
                            Text(AppLocalizations.of(context)!.large, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w400, fontSize: 14.sp)),
                            SizedBox(
                              width: 60.w,
                              child: TextFormField(
                                cursorColor: primaryColor,
                                controller: lPriceController,
                                validator: priceValidator,
                                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp, color: Colors.white),
                                decoration:
                                    InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 8.w), hintText: '$lPrice€', hintStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 16.sp)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 30.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MaterialButton(
                    onPressed: () async {
                      List<String> sizes = [];
                      Map<String, num> prices = {};
                      if (lowPrice) {
                        sizes.add("Small");
                        prices.putIfAbsent("Small", () => sPriceController.text == "" ? sPrice : double.parse(sPriceController.text));
                      }
                      if (mediumPrice) {
                        sizes.add("Medium");
                        prices.putIfAbsent("Medium", () => mPriceController.text == "" ? mPrice : double.parse(mPriceController.text));
                      }
                      if (largePrice) {
                        sizes.add("Large");
                        prices.putIfAbsent("Large", () => lPriceController.text == "" ? lPrice : double.parse(lPriceController.text));
                      }


                      if (_MyItemAddons.isEmpty) {
                        final ProductItem item = ProductItem(
                          name: itemTitleTxt.text,
                          description: itemDetailTxt.text,
                          sizes: sizes,
                          prices: prices,
                          photo: imageController.imageUrl ?? "",
                          availability: availability,
                          discount: "0%",
                          discountedPrice: prices[sizes[0]]!.toDouble(),
                          type: itemDetailItemtxt,
                          itemId: "",
                          workingHrs: workingHourTxt.text,
                          prepDelay: prepareDelayTxt.text,
                          rewards: counter,
                          free: {"Coconut": 0},
                          addOns: [],
                        );
                        await menuController.addItem(authController.user!, item);
                        await menuController.fetchMenu(authController.user!.userId);
                      } else {
                        final ProductItem item = ProductItem(
                          name: itemTitleTxt.text,
                          description: itemDetailTxt.text,
                          sizes: sizes,
                          prices: prices,
                          photo: imageController.imageUrl ?? "",
                          availability: availability,
                          discount: "0%",
                          discountedPrice: prices[sizes[0]]!.toDouble(),
                          type: itemDetailItemtxt,
                          itemId: "",
                          workingHrs: workingHourTxt.text,
                          prepDelay: prepareDelayTxt.text,
                          rewards: counter,
                          free: {"Coconut": 0},
                          addOns: _MyItemAddons.map((e) => e.addonId).toList()
                        );
                        await menuController.addItem(authController.user!, item);
                        await menuController.fetchMenu(authController.user!.userId);
                      }

                      if (mounted) Navigator.pop(context);
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
                        children: menuController.addItemLoader
                            ? [const CircularProgressIndicator(color: Colors.white)]
                            : [
                                Text(AppLocalizations.of(context)!.continueText, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.sp, color: Colors.white)),
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
      ),
    );
  }
}
