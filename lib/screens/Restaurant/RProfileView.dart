import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/controllers/Restaurants/res_auth_controller.dart';
import 'package:paraiso/models/restaurant_admin_model.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../../controllers/profile_controller.dart';
import '../../controllers/profile_pic_controller.dart';
import '../../util/image_source.dart';
import '../../widgets/svgtextfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ResProfileController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxBool emailValid = false.obs;

  bool get isEmailValid => emailValid.value;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _openingTimeController = TextEditingController();
  final TextEditingController _prepDelayController = TextEditingController();
  ProfileController profileController = Get.put(ProfileController());

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      emailValid.value = false;
      return 'Please enter an email';
    }
    if (!GetUtils.isEmail(value)) {
      emailValid.value = false;
      return 'Please enter a valid email';
    }
    // Add additional email validation logic
    emailValid.value = true;
    return null;
  }

  String? numberValidator(String? value) {
    if (value!.isEmpty) {
      return "Can't be Empty!";
    } else if (!value.isPhoneNumber) {
      return "Enter a valid number";
    }
    return null;
  }

  String? textValidator(String? value) {
    if (value!.isEmpty) {
      return "Can't be Empty!";
    }
    // Add additional text validation logic
    return null;
  }
}

class RProfileView extends StatefulWidget {
  const RProfileView({Key? key}) : super(key: key);

  @override
  State<RProfileView> createState() => _RProfileViewState();
}

class _RProfileViewState extends State<RProfileView> {
  final ResProfileController resProfileController = Get.put(ResProfileController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';
  String photo = '';
  String address = '';
  String openingTime = '';
  String openingTime1 = '';
  String closingTime = '';
  String prepDelay = '';

  bool isLoading = false;

  Future<void> getCurrentUser(RestaurantAdmin admin) async {
    setState(() {
      name = admin.username;
      email = admin.email;
      address = admin.address;
      openingTime1 = admin.openingHrs.split("-")[0];
      closingTime = admin.openingHrs.split("-")[1];
      prepDelay = admin.prepDelay;
      photo = admin.logo;

      resProfileController._emailController.text = email;
      resProfileController._nameController.text = name;
      resProfileController._addressController.text = address;
      resProfileController._prepDelayController.text = prepDelay;
      resProfileController._openingTimeController.text = openingTime;
    });
  }

  @override
  void initState() {
    final authController = Provider.of<AuthController>(context, listen: false);
    getCurrentUser(authController.user!);
    super.initState();
  }

  void deleteAccountPopup() {
    final authController = Provider.of<AuthController>(context, listen: false);
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22.r),
              ),
              backgroundColor: softBlack,
              content: VStack(crossAlignment: CrossAxisAlignment.center, [
                10.verticalSpace,
                Text("Êtes-vous sûr de vouloir supprimer votre compte ?",
                    textAlign: TextAlign.center,
                    style: context.titleSmall?.copyWith(
                      color: onPrimaryColor,
                    )),
              ]),
              actions: [
                Row(
                  children: [
                    12.horizontalSpace,
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        PrimaryButton(
                          icon: Icons.arrow_forward_ios,
                          onPressed: () async {
                            await authController.deleteAccount();
                            if (mounted) {
                              context.go('/get_started');
                            }
                          },
                          child: Text(
                            "Bien sûr",
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
                            "Non",
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
                ),
              ],
            ));
    setState(() {});
  }



  @override
  Widget build(BuildContext context) {

    openingTime = openingTime1 +"-"+ closingTime;

    final profilePicController = Provider.of<ProfilePicController>(context);

    void selectAnduploadImage() async {
      final imageSource = await ImageSourcePicker.showImageSource(context);
      if (imageSource != null) {
        final file = await ImageSourcePicker.pickFile(imageSource);
        if (file != null) {
          await profilePicController.uploadImageToFirebase(file);
        }
      }
    }

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
          onPressed: () async{
            print("Back");
            await profilePicController.setImageUrlNull();
            Navigator.pop(context);

          },
        ),
        title: Center(
          child: Text(
            AppLocalizations.of(context)!.profile,
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
      body: SafeArea(
        child: Form(
          key: _formKey,
          onChanged: () {
            _formKey.currentState!.validate();
          },
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SizedBox(
                    height: context.height,
                    width: context.width * .8767,
                    child: ListView(children: [
                      65.verticalSpace,
                      Container(
                        width: 150.r,
                        height: 150.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.contain,
                            image: profilePicController.imageUrl != null ? NetworkImage(profilePicController.imageUrl!) : NetworkImage(photo),
                          ),
                        ),
                        child: ClipOval(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: selectAnduploadImage,
                            ),
                          ),
                        ),
                      ),
                      35.verticalSpace,
                      SvgTextField(
                        hintText: AppLocalizations.of(context)!.email,
                        enabled: false,
                        controller: resProfileController._emailController,
                        validator: resProfileController.emailValidator,
                        textInputType: TextInputType.emailAddress,
                      ),
                      15.verticalSpace,
                      SvgTextField(
                        hintText: AppLocalizations.of(context)!.name,
                        controller: resProfileController._nameController,
                        validator: resProfileController.textValidator,
                        textInputType: TextInputType.text,
                      ),
                      15.verticalSpace,
                      SvgTextField(
                        hintText: AppLocalizations.of(context)!.address,
                        controller: resProfileController._addressController,
                        validator: resProfileController.textValidator,
                        textInputType: TextInputType.text,
                      ),
                      // 15.verticalSpace,
                      // SvgTextField(
                      //   hintText: AppLocalizations.of(context)!.openingTime,
                      //   controller: resProfileController._openingTimeController,
                      //   validator: resProfileController.textValidator,
                      //   textInputType: TextInputType.text,
                      // ),
                      15.verticalSpace,
                      SvgTextField(
                        hintText: AppLocalizations.of(context)!.prepDelay,
                        controller: resProfileController._prepDelayController,
                        validator: resProfileController.textValidator,
                        textInputType: TextInputType.text,
                      ),
                      15.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((value) {
                                setState(() {
                                  openingTime1 = value!.format(context);
                                });
                              });
                            },
                            child: Container(
                              height: 50.h,
                              width: 185.w,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(53, 53, 53,1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Open at: ${openingTime1=="" ? "select" : openingTime1}"),
                                  Icon(Icons.timer,color:onNeutralColor),
                                ],
                              ),
                            ),
                          ),
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.now(),
                              ).then((value) {
                                setState(() {
                                  closingTime = value!.format(context);
                                });
                              });
                            },
                            child: Container(
                              height: 50.h,
                              width: 185.w,
                              padding: EdgeInsets.symmetric(horizontal: 20.w),
                              decoration: BoxDecoration(
                                color: Color.fromRGBO(53, 53, 53,1),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Close at: ${closingTime=="" ? "select" : closingTime}"),
                                  Icon(Icons.timer,color:onNeutralColor),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      40.verticalSpace,
                      Center(
                        child: PrimaryButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            Map<String, dynamic> data = {
                              "username": resProfileController._nameController.text,
                              "address": resProfileController._addressController.text,
                              "openingHrs": openingTime,
                              "prepDelay": resProfileController._prepDelayController.text,
                              "logo": profilePicController.imageUrl ?? photo,
                            };

                            final authController = Provider.of<AuthController>(context, listen: false);
                            await authController.updateRes(authController.user!.userId, data);

                            setState(() {
                              isLoading = false;
                            });
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!.profileUpdated,
                                      style: context.bodyLarge,
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                  backgroundColor: primaryColor,
                                ),
                              );
                            }
                          },
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : AutoSizeText(
                                  AppLocalizations.of(context)!.update,
                                  style: TextStyle(
                                    color: const Color(0xFFE4E4E4),
                                    fontSize: 18.sp,
                                    fontFamily: 'Recoleta',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  maxLines: 1,
                                ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ),
              Column(
                children: [
                  Center(
                    child: InkWell(
                      onTap: () async {
                        deleteAccountPopup();
                      },
                      child: Text(
                        "Supprimer le compte",
                        style: TextStyle(
                          color: primaryColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                  45.verticalSpace,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
