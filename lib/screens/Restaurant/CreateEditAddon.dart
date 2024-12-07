import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../controllers/Restaurants/res_auth_controller.dart';
import '../../models/product_item.dart';
import '../../repositories/res_post_repo.dart';
import '../../util/theme/theme_constants.dart';
import '../../widgets/primary_button.dart';
import 'RAddOnView.dart';

class CreateEditAddon extends StatefulWidget {
  final bool isEdit;
  final AddonItemWithId? addonItemWithId;
  const CreateEditAddon({super.key, this.isEdit = false, this.addonItemWithId});

  @override
  State<CreateEditAddon> createState() => _CreateEditAddonState();
}

class _CreateEditAddonState extends State<CreateEditAddon> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _choiceNameController = TextEditingController();
  String addonType = "Addon Taper";
  int counter = 0;

  // create a list of map that save data of choices
  List<Map<String, dynamic>> choicesList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.isEdit) {
      _nameController.text = widget.addonItemWithId!.addonName;
      addonType = widget.addonItemWithId!.addonType;
      counter = widget.addonItemWithId!.canChooseUpto;
      choicesList = widget.addonItemWithId!.addonItems;
    }
  }

  void addToChoicesList(int index) {
    if (index != -1) {
      choicesList[index]["name"] = _choiceNameController.text;
      choicesList[index]["price"] =
          _priceController.text.isEmpty ? 0 : _priceController.text;
      setState(() {});
      return;
    }

    choicesList.add({
      "name": _choiceNameController.text,
      "price": _priceController.text.isEmpty ? 0 : _priceController.text,
    });
    _choiceNameController.clear();
    _priceController.clear();
    setState(() {});
  }

  void locationPopup({int index = -1}) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.r),
              ),
              backgroundColor: const Color.fromRGBO(53, 53, 53, 1),
              content: VStack(
                crossAlignment: CrossAxisAlignment.center,
                [
                  5.verticalSpace,
                  Text(
                    "Add Addon ${addonType == "Ingredients" ? "Ingredients" : "Choices"}",
                    style: context.titleLarge?.copyWith(
                      color: onPrimaryColor,
                    ),
                  ),
                  20.verticalSpace,
                  TextField(
                    controller: _choiceNameController,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        color: Colors.white),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                        hintText: "Name",
                        hintStyle: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16.sp)),
                  ),
                  10.verticalSpace,
                  TextField(
                    enabled: addonType != "Ingredients" ? false : true,
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        color: Colors.white),
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                      hintText: "Price Per Ingredient",
                      hintStyle: TextStyle(
                          fontWeight: FontWeight.w400, fontSize: 16.sp),
                    ),
                  ),
                  5.verticalSpace,
                  if (addonType != "Ingredients")
                    Row(
                      children: [
                        20.horizontalSpace,
                        Icon(
                          Icons.info_outline,
                          color: const Color(0xFF2F58CD),
                          size: 20.sp,
                        ),
                        5.horizontalSpace,
                        Text(
                          "Price is only for Ingredients",
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 16.sp,
                              color: Colors.white),
                        ),
                      ],
                    )
                ],
              ),
              actions: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    PrimaryButton(
                      icon: Icons.arrow_forward_ios,
                      onPressed: () async {
                        // final resByDist = Provider.of<SortByDistanceController>(
                        //     context,
                        //     listen: false);
                        // await resByDist.getRestaurantsByDistance();
                        if (_choiceNameController.text.isNotEmpty) {
                          addToChoicesList(index);
                        }
                        if (mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        AppLocalizations.of(context)!.confirm,
                        style: TextStyle(
                          color: const Color(0xFFE4E4E4),
                          fontSize: 16.sp,
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
  }

  Future<void> pushToFirebase() async {
    dynamic addonItem = widget.isEdit
        ? AddonItemWithId(
            addonName: _nameController.text,
            addonType: addonType,
            canChooseUpto: counter,
            addonItems: choicesList,
            addonId: widget.addonItemWithId!.addonId,
          )
        : AddonItem(
            addonName: _nameController.text,
            addonType: addonType,
            canChooseUpto: counter,
            addonItems: choicesList,
          );

    final authController = Provider.of<AuthController>(context, listen: false);
    final userId = authController.user!.userId;

    final restaurantRepo = RestaurantPostRepo();
    if (widget.isEdit) {
      await restaurantRepo.updateADDON(
          userId, widget.addonItemWithId!.addonId, addonItem);
      return;
    }
    await restaurantRepo.addADDON(userId, addonItem);
  }

  @override
  Widget build(BuildContext context) {
    if (choicesList.isEmpty) {
      counter = 0;
    }

    if (choicesList.isNotEmpty && counter == 0) {
      counter = 1;
    }

    if (choicesList.length == 1) {
      counter = 1;
    }

    if (counter > choicesList.length && addonType != "Ingredients") {
      counter = choicesList.length;
    }

    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              height: MediaQuery.sizeOf(context).height,
              width: MediaQuery.sizeOf(context).width,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Column(
                children: [
                  Row(children: [
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
                      widget.isEdit ? "Modifier Addon" : "Create Addon",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 23.sp),
                    ),
                    const Spacer(),
                    const Spacer(),
                  ]),
                  SizedBox(height: 40.h),
                  Row(
                    children: [
                      Text(
                        "Addon Détails",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 23.sp),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 30.h,
                  ),
                  TextField(
                    controller: _nameController,
                    style: TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 16.sp,
                        color: Colors.white),
                    decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                        hintText: "Nom",
                        hintStyle: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16.sp)),
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  SizedBox(
                    height: 10.h,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                        color: const Color.fromRGBO(53, 53, 53, 1),
                        borderRadius: BorderRadius.circular(30.r)),
                    child: DropdownButton(
                        items: ["Addon Taper", "Choices", "Ingredients"]
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                ))
                            .toList(),
                        value: addonType,
                        style: TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 16.sp),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          size: 20.sp,
                        ),
                        padding: EdgeInsets.zero,
                        underline: Container(),
                        isExpanded: true,
                        onChanged: (val) {
                          setState(() {
                            addonType = val!;
                          });
                        }),
                  ),
                  20.verticalSpace,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Peut choisir jusqu'à",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 23.sp),
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
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromRGBO(53, 53, 53, 1),
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/icons/minus.png'))),
                            ),
                          ),
                          5.horizontalSpace,
                          Text(
                            '$counter',
                            style: TextStyle(
                                fontWeight: FontWeight.w400, fontSize: 25.sp),
                          ),
                          5.horizontalSpace,
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
                              decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color.fromRGBO(53, 53, 53, 1),
                                  image: DecorationImage(
                                      image:
                                          AssetImage('assets/icons/plus.png'))),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                  20.verticalSpace,
                  Container(
                    height: 1.h,
                    width: MediaQuery.of(context).size.width,
                    color: const Color.fromRGBO(53, 53, 53, 1),
                  ),
                  20.verticalSpace,
                  Row(
                    children: [
                      Text(
                        "Addon ${addonType == "Ingredients" ? "Ingredients" : "Choices"}",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                            fontSize: 23.sp),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _choiceNameController.clear();
                            _priceController.clear();
                          });
                          locationPopup();
                        },
                        child: Container(
                          height: 40.h,
                          width: 60.w,
                          margin: EdgeInsets.only(right: 5.w),
                          decoration: BoxDecoration(
                              color: const Color(0xFF2F58CD),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.r))),
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
                    height: 40.h,
                  ),
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: choicesList.length,
                      itemBuilder: (context, index) {
                        return AddOnTile(
                          title: choicesList[index]["name"],
                          subData: "-/\$${choicesList[index]["price"]}",
                          showSubData:
                              addonType == "Ingredients" ? true : false,
                          onTap: () {
                            setState(() {
                              _choiceNameController.text =
                                  choicesList[index]["name"];
                              if (addonType == "Ingredients") {
                                _priceController.text =
                                    choicesList[index]["price"].toString();
                              } else {
                                _priceController.clear();
                              }
                            });
                            locationPopup(index: index);
                          },
                          onDelete: () {
                            choicesList.removeAt(index);
                            setState(() {});
                          },
                        );
                      },
                    ),
                  ),
                  10.verticalSpace,
                  PrimaryButton(
                    onPressed: () async {
                      if (_nameController.text.isEmpty) {
                        VxToast.show(context,
                            textColor: Colors.white,
                            msg: "Please enter addon name",
                            position: VxToastPosition.top,
                            bgColor: Colors.red,
                            showTime: 900);
                        return;
                      }

                      if (addonType == "Addon Taper") {
                        VxToast.show(context,
                            textColor: Colors.white,
                            msg: "Please select addon type",
                            position: VxToastPosition.top,
                            bgColor: Colors.red,
                            showTime: 900);
                        return;
                      }

                      if (choicesList.isEmpty) {
                        VxToast.show(context,
                            textColor: Colors.white,
                            msg:
                                "Please add addon ${addonType == "Ingredients" ? "Ingredients" : "Choices"}",
                            position: VxToastPosition.top,
                            bgColor: Colors.red,
                            showTime: 900);
                        return;
                      }

                      await pushToFirebase();
                      Navigator.pop(context);
                    },
                    child: Text(
                      widget.isEdit ? "Mise à jour" : "Créer",
                      style: TextStyle(
                        color: const Color(0xFFE4E4E4),
                        fontSize: 16.sp,
                        fontFamily: 'Recoleta',
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  10.verticalSpace,
                ],
              ),
            ),
          ),
        ));
  }
}
