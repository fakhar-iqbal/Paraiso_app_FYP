import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paraiso/controllers/rewards_controller.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../repositories/customer_auth_repo.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SendGifts extends StatefulWidget {
  final Map<String, dynamic> user;
  const SendGifts({Key? key, required this.user}) : super(key: key);

  @override
  State<SendGifts> createState() => _SendGiftsState();
}

class _SendGiftsState extends State<SendGifts> {
  int number = 1;
  String selectedItem = "";
  int selectedItemCount = 0;
  int selectedTileIndex = -1;
  String email = "";

  late RewardsController _rewardsController;
  final customerAuth = CustomerAuthRep();

  @override
  void didChangeDependencies() async {
    _rewardsController = Provider.of<RewardsController>(context, listen: false);
    final currentCustomer = await customerAuth.getCurrentUser();
    email = currentCustomer['email'];
    await _rewardsController.getRewards(email);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: neutralColor,
        leading: IconButton(
          icon: Container(
              height: 53.h,
              width: 53.h,
              decoration: BoxDecoration(color: softBlack, borderRadius: BorderRadius.circular(50)),
              padding: EdgeInsets.only(left: 10.w),
              child: const Icon(Icons.arrow_back_ios)),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.sendGifts,
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
      body: Consumer<RewardsController>(
        builder: (context, value, child) {
          return ListView(
            children: [
              // Text(
              //   'Select Gift',
              //   style: TextStyle(
              //     color: const Color(0xFFE4E4E4),
              //     fontSize: 23.sp,
              //     fontFamily: 'Recoleta',
              //     fontWeight: FontWeight.w700,
              //   ),
              // ).pLTRB(25.w, 0.h, 25.w, 25.h),
              //grid here
              GridView(
                scrollDirection: Axis.vertical,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 1,
                  crossAxisSpacing: 11.w,
                  mainAxisSpacing: 16.5.h,
                  childAspectRatio: 2,
                ),
                children: [
                  // FoodGiftTile(
                  //   image: "Send Gifts_burger 1_346_10807.png",
                  //   owned: value.rewards["Burger"] ?? 0,
                  //   onSelect: (selected) {
                  //     if (selectedTileIndex == 0) {
                  //       setState(() {
                  //         selectedItem = "";
                  //         selectedTileIndex = -1;
                  //       });
                  //     } else {
                  //       setState(() {
                  //         selectedItem =
                  //             AppConstants.giftItems[GiftItems.burger]!;
                  //         selectedItemCount =
                  //             value.rewards["Burger"] ?? 0;
                  //         selectedTileIndex = 0;
                  //         number = selectedItemCount > 0 ? 1 : 0;
                  //       });
                  //     }
                  //   },
                  //   toggled: selectedTileIndex == 0,
                  // ),
                  // FoodGiftTile(
                  //   image: "send_pizza.png",
                  //   owned: value.rewards["Pizza"] ?? 0,
                  //   onSelect: (selected) {
                  //     if (selectedTileIndex == 1) {
                  //       setState(() {
                  //         selectedItem = "";
                  //         selectedTileIndex = -1;
                  //       });
                  //     } else {
                  //       setState(() {
                  //         selectedItem =
                  //             AppConstants.giftItems[GiftItems.pizza]!;
                  //         selectedItemCount =
                  //             value.rewards["Pizza"] ?? 0;
                  //         selectedTileIndex = 1;
                  //         number = selectedItemCount > 0 ? 1 : 0;
                  //       });
                  //     }
                  //   },
                  //   toggled: selectedTileIndex == 1,
                  // ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                    child: FoodGiftTile(
                      image: "Food Filter_OBJECTS_458_13901.svg",
                      owned: value.rewards.toInt(),
                      onSelect: (selected) {
                        // if (selectedTileIndex == 2) {
                        //   setState(() {
                        //     selectedItem = "";
                        //     selectedTileIndex = -1;
                        //   });
                        // } else {
                        //   setState(() {
                        //     selectedItem =
                        //         AppConstants.giftItems[GiftItems.coconut]!;
                        //     selectedItemCount =
                        //         value.rewards["Coconut"] ?? 0;
                        //     selectedTileIndex = 2;
                        //     number = selectedItemCount > 0 ? 1 : 0;
                        //   });
                        // }
                      },
                      toggled: selectedTileIndex == 2,
                    ),
                  ),
                  // FoodGiftTile(
                  //   image: "Send Gifts_float 1_352_11143.png",
                  //   owned: value.rewards["Float"] ?? 0,
                  //   onSelect: (selected) {
                  //     if (selectedTileIndex == 3) {
                  //       setState(() {
                  //         selectedItem = "";
                  //         selectedTileIndex = -1;
                  //       });
                  //     } else {
                  //       setState(() {
                  //         selectedItem =
                  //             AppConstants.giftItems[GiftItems.float]!;
                  //         selectedItemCount =
                  //             value.rewards["Float"] ?? 0;
                  //         selectedTileIndex = 3;
                  //         number = selectedItemCount > 0 ? 1 : 0;
                  //       });
                  //     }
                  //   },
                  //   toggled: selectedTileIndex == 3,
                  // ),
                  // FoodGiftTile(
                  //   image: "Send Gifts_buritto 1_352_11140.png",
                  //   owned: value.rewards["Buritto"] ?? 0,
                  //   onSelect: (selected) {
                  //     if (selectedTileIndex == 4) {
                  //       setState(() {
                  //         selectedItem = "";
                  //         selectedTileIndex = -1;
                  //       });
                  //     } else {
                  //       setState(() {
                  //         selectedItem =
                  //             AppConstants.giftItems[GiftItems.buritto]!;
                  //         selectedItemCount =
                  //             value.rewards["Buritto"] ?? 0;
                  //         selectedTileIndex = 4;
                  //         number = selectedItemCount > 0 ? 1 : 0;
                  //       });
                  //     }
                  //   },
                  //   toggled: selectedTileIndex == 4,
                  // ),
                  // FoodGiftTile(
                  //   image: "Send Gifts_ice cream 1_352_11144.png",
                  //   owned: value.rewards["Icecream"] ?? 0,
                  //   onSelect: (selected) {
                  //     if (selectedTileIndex == 5) {
                  //       setState(() {
                  //         selectedItem = "";
                  //         selectedTileIndex = -1;
                  //       });
                  //     } else {
                  //       setState(() {
                  //         selectedItem =
                  //             AppConstants.giftItems[GiftItems.icecream]!;
                  //         selectedItemCount =
                  //             value.rewards["Icecream"] ?? 0;
                  //         selectedTileIndex = 5;
                  //         number = selectedItemCount > 0 ? 1 : 0;
                  //       });
                  //     }
                  //   },
                  //   toggled: selectedTileIndex == 5,
                  // ),
                ],
              ).pLTRB(25.w, 0.h, 25.w, 16.h).h(200.h),

              // MORE Button
              // InkWell(
              //   onTap: () {},
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     children: [
              //       Text(
              //         "More",
              //         style: TextStyle(
              //           color: const Color(0xFFE4E4E4),
              //           fontSize: 23.sp,
              //           fontFamily: 'Recoleta',
              //           fontWeight: FontWeight.w400,
              //         ),
              //       ),
              //       4.horizontalSpace,
              //       const Icon(
              //         Icons.keyboard_arrow_down,
              //         color: Color(0xFFE4E4E4),
              //         size: 20,
              //       ),
              //     ],
              //   ).pLTRB(25.w, 0.h, 25.w, 0.h),
              // ),

              Divider(
                color: softGray,
                thickness: .5.h,
                // indent: 25,
                // endIndent: 25,
              ),
              28.verticalSpace,
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppLocalizations.of(context)!.quantity,
                    style: context.titleLarge?.copyWith(color: onPrimaryColor, fontWeight: FontWeight.bold),
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
                            if (number < value.rewards) {
                              number++;
                            }
                          });
                        },
                        child: const Icon(Icons.add)),
                  ])
                ],
              ).pLTRB(25.w, 0.h, 10.h, 0.h),
              24.verticalSpace,
              Divider(
                color: softGray,
                thickness: .5.h,
                // indent: 25,
                // endIndent: 25,
              ),
              72.verticalSpace,
              Center(
                child: PrimaryButton(
                  onPressed: () async {
                    String rewardImg = "assets/images/Food Filter_OBJECTS_458_13901.svg";
                    bool rewardSentStatus = false;

                    if (number > 0 && value.rewards > 0) {
                      // print("sending rewards ${widget.user['schoolName']}");
                      rewardSentStatus = await _rewardsController.sendRewards(email, widget.user['email'], selectedItem, number);
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: primaryColor,
                            duration: const Duration(seconds: 2),
                            content: Center(
                              child: Text(
                                AppLocalizations.of(context)!.youDontHaveEnoughCoconuts,
                                style: const TextStyle(color: Colors.white, fontFamily: "Recoleta"),
                              ),
                            ),
                          ),
                        );
                      }
                    }

                    if (mounted) {
                      rewardSentStatus
                          ? showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(22.r),
                                  ),
                                  backgroundColor: softBlack,
                                  content: VStack(crossAlignment: CrossAxisAlignment.center, [
                                    12.verticalSpace,
                                    Stack(
                                      children: [
                                        SvgPicture.asset(
                                          "assets/images/confetti.svg",
                                          width: 287.w,
                                          height: 176.h,
                                        ),
                                        Positioned(
                                          top: 62,
                                          right: 79,
                                          child: SvgPicture.asset(
                                            "assets/images/gift_wrap.svg",
                                            width: 128.w,
                                          ),
                                        )
                                      ],
                                    ).h(233.h),
                                    30.verticalSpace,
                                    Text(
                                      AppLocalizations.of(context)!.sent,
                                      style: TextStyle(
                                        color: white,
                                        fontSize: 30.sp,
                                        fontFamily: 'Recoleta',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text.rich(
                                          TextSpan(
                                            children: [
                                              TextSpan(
                                                text: AppLocalizations.of(context)!.rewardSentSuccess,
                                                style: TextStyle(
                                                  color: white,
                                                  fontSize: 20,
                                                  fontFamily: 'Recoleta',
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '  ',
                                                style: TextStyle(
                                                  fontSize: 20.sp,
                                                  fontFamily: 'Recoleta',
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              TextSpan(
                                                text: '$number ',
                                                style: TextStyle(
                                                  fontSize: 20.sp,
                                                  fontFamily: 'Recoleta',
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        rewardImg.contains(".svg")
                                            ? SvgPicture.asset(
                                                rewardImg,
                                                width: 40.w,
                                              )
                                            : const SizedBox.shrink(),
                                        rewardImg.contains(".png")
                                            ? Image.asset(
                                                rewardImg,
                                                width: 50.w,
                                              )
                                            : const SizedBox.shrink(),
                                      ],
                                    )
                                  ]),
                                  actions: [
                                    Center(
                                      child: Container(
                                        width: 136.w,
                                        height: 45.h,
                                        decoration: ShapeDecoration(
                                          shape: RoundedRectangleBorder(
                                            side: const BorderSide(width: 0.50, color: Color(0xFF2F58CD)),
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            AppLocalizations.of(context)!.close,
                                            style: TextStyle(
                                              color: const Color(0xFF2F58CD),
                                              fontSize: 13.sp,
                                              fontFamily: 'Recoleta',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                      ).onTap(() {
                                        value.getRewards(email);
                                        Navigator.pop(context);
                                        setState(() {
                                          number = 1;
                                        });
                                      }),
                                    )
                                  ],
                                );
                              })
                          : "";
                    }
                  },
                  child: AutoSizeText(
                    AppLocalizations.of(context)!.sendNow,
                    style: TextStyle(
                      color: const Color(0xFFE4E4E4),
                      fontSize: 18.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                  ),
                ),
              )
            ],
          );
        },
      ),
      //friends list
    );
  }
}

class FoodGiftTile extends StatefulWidget {
  final String image;
  final int owned;
  final bool toggled;
  final Function(bool) onSelect;

  const FoodGiftTile({super.key, required this.image, required this.owned, required this.toggled, required this.onSelect});

  @override
  State<FoodGiftTile> createState() => _FoodGiftTileState();
}

class _FoodGiftTileState extends State<FoodGiftTile> {
  bool toggled = false;

  @override
  Widget build(BuildContext context) {
    // on tap at end
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 150.h,
        minHeight: 124.h,
      ),
      child: Container(
        width: 119.w,
        decoration: ShapeDecoration(
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(22),
            ),
            side: BorderSide(width: widget.toggled ? 1.5 : .5, strokeAlign: BorderSide.strokeAlignCenter, color: widget.toggled ? primaryColor : softGray),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            widget.image.contains(".svg")
                ? Container(
                    padding: EdgeInsets.all(15.h),
                    child: SvgPicture.asset(
                      'assets/images/${widget.image}',
                      width: 50.w,
                    ),
                  )
                : Image.asset(
                    "assets/images/${widget.image}",
                    width: 78.w,
                    height: 78.h,
                  ),
            7.5.verticalSpace,
            Divider(
              color: softGray,
              thickness: .5.h,
            ),
            4.verticalSpace,
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${AppLocalizations.of(context)!.owned}  ',
                    style: TextStyle(
                      color: const Color(0xFFBDBDBD),
                      fontSize: 14.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: widget.owned.toString(),
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 16.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            )
          ],
        ),
      ).onTap(() {
        widget.onSelect(widget.toggled);
        setState(() {});
      }),
    );
  }
}

class CustomDropdown extends StatefulWidget {
  const CustomDropdown({super.key});

  @override
  _CustomDropdownState createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? _selectedValue;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: _selectedValue,
      onChanged: (String? newValue) {
        setState(() {
          _selectedValue = newValue;
        });
      },
      dropdownColor: Colors.black,
      elevation: 0,
      focusColor: Colors.pink,
      iconDisabledColor: Colors.white,
      iconEnabledColor: Colors.white,
      isDense: true,
      itemHeight: 60,
      selectedItemBuilder: (BuildContext context) {
        return [
          Text(
            AppLocalizations.of(context)!.more,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Recoleta',
              fontWeight: FontWeight.w400,
            ),
          ),
        ];
      },
      items: const [
        DropdownMenuItem<String>(
          value: 'Food1',
          child: Text(
            'Food1',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Recoleta',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Food3',
          child: Text(
            'Food1',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Recoleta',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        DropdownMenuItem<String>(
          value: 'Food2',
          child: Text(
            'Food1',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontFamily: 'Recoleta',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        // Add more DropdownMenuItems as needed
      ],
    );
  }
}
