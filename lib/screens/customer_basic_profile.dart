import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/screens/get_started_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:velocity_x/velocity_x.dart';

import 'package:paraiso/repositories/customer_firebase_calls.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/primary_button.dart';

import '../controllers/customer_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/profile_pic_controller.dart';
import '../controllers/sort_by_distance_controller.dart';
import '../repositories/customer_auth_repo.dart';
import '../util/image_source.dart';
import '../util/location/user_location.dart';
import '../util/theme/theme.dart';
import '../widgets/svgtextfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UserProfileController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxBool emailValid = false.obs;

  bool get isEmailValid => emailValid.value;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _schoolController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
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
    // Add additional text validation logic
    return null;
  }

  String? textValidator(String? value) {
    if (value!.isEmpty) {
      return "Can't be Empty!";
    }
    // Add additional text validation logic
    return null;
  }

  String? passwordValidator(String? value) {
    if (value!.isEmpty) {
      return "Please enter your password";
    } else if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    // Add additional password validation logic
    return null;
  }
}

class CustomerBasicProfile extends StatefulWidget {
  const CustomerBasicProfile({
    Key? key,
  }) : super(key: key);

  @override
  State<CustomerBasicProfile> createState() => _CustomerBasicProfileState();
}

class _CustomerBasicProfileState extends State<CustomerBasicProfile> {
  final UserProfileController userProfileController = Get.put(UserProfileController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isAuthenticating = false;

  List<String> schoolNames = [
    "Montpellier Business School",
    "ESG",
    "Ynov campus",
    "Université de Montpellier",
    "Idrac",
    "Sup de Com",
    "Autres",
  ];

  String name = '';
  String email = '';
  String schoolName = 'ESG';
  int coconuts = 0;
  String phone = '';
  String photo = '';
  Map<String, dynamic> user = {};

  bool isLoading = false;

  Future<void> getCurrentUser() async {
    final currentUser = await CustomerAuthRep().getCurrentUserFromFirebase();
    user = await CustomerAuthRep().getCurrentUserFromFirebase();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? userEmail = prefs.getString('currentCustomerEmail');
    setState(() {
      name = currentUser['userName']!;
      email = userEmail!;
      schoolName = currentUser['schoolName']!;
      coconuts = user['rewards'] is double ? user['rewards'].toInt() : (user['rewards'] is String ? int.parse(user['rewards']) : user['rewards']);
      phone = currentUser['phoneNumber'];
      photo = currentUser['photo'];

      userProfileController._emailController.text = email;
      userProfileController._nameController.text = name;
      userProfileController._schoolController.text = schoolName;
      userProfileController._numberController.text = phone;
    });
  }

  @override
  void initState() {
    getCurrentUser();
    super.initState();
  }

  bool addressUpdated = true;

  void deleteAccountPopup() {
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
                            await CustomerAuthRep().deleteUserFromFirebase();
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
    // return HeadlineDisplay();
    // print(ScreenUtil().scaleWidth);
    // screen width:
    // print(ScreenUtil().screenWidth);

    // print("Am I logged in: " +
    //     Get.find<AuthController>().getIsLoggedIn.toString());

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
                          color: primaryColor,
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: profilePicController.imageUrl != null && profilePicController.imageUrl != "" ? NetworkImage(profilePicController.imageUrl!) : (NetworkImage(photo)),
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
                        controller: userProfileController._emailController,
                        validator: userProfileController.emailValidator,
                        textInputType: TextInputType.emailAddress,
                      ),
                      5.verticalSpace,
                      SvgTextField(
                        hintText: AppLocalizations.of(context)!.name,
                        controller: userProfileController._nameController,
                        validator: userProfileController.textValidator,
                        textInputType: TextInputType.text,
                      ),
                      5.verticalSpace,
                      SizedBox(
                        width: MediaQuery.sizeOf(context).width,
                        child: DropdownButtonFormField<String>(
                          isDense: true,
                          decoration: myInputDecoration().copyWith(
                            contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                          ),
                          hint: Text(AppLocalizations.of(context)!.chooseYourSchool, style: TextStyle(fontSize: 18.sp)),
                          value: schoolName,
                          items: schoolNames.map((school) {
                            return DropdownMenuItem<String>(
                              value: school,
                              child: Text(
                                school,
                                style: TextStyle(fontSize: 18.sp),
                              ),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              schoolName = newValue!;
                            });
                          },
                        ),
                      ),
                      15.verticalSpace,
                      SvgTextField(
                        hintText: AppLocalizations.of(context)!.number,
                        controller: userProfileController._numberController,
                        validator: userProfileController.numberValidator,
                        textInputType: TextInputType.number,
                      ),
                      25.verticalSpace,
                      Consumer<CustomerController>(
                        builder: (context, customerController, child) {
                          if (customerController.user.isEmpty) {
                            return SizedBox(
                                height: 80,
                                width: 80,
                                child: Transform.scale(
                                  scale: .5,
                                  child: CircularProgressIndicator(color: primaryColor),
                                ));
                          } else {
                            GeoPoint location = customerController.user['location'];

                            double latitude = location.latitude;
                            double longitude = location.longitude;

                            return FutureBuilder<String>(
                              future: UserLocation().getAddress(latitude, longitude),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 100.w),
                                    child: SizedBox(
                                        height: 60,
                                        width: 10,
                                        child: Transform.scale(
                                          scale: .5,
                                          child: CircularProgressIndicator(color: primaryColor),
                                        )),
                                  );
                                } else if (snapshot.hasError) {
                                  return Text("Couldn't fetch address: ${snapshot.error}");
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
                                        addressUpdated
                                            ? Expanded(
                                                child: Text(
                                                  userAddress,
                                                  softWrap: true,
                                                  maxLines: 3,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              )
                                            : Expanded(
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 80.w),
                                                  child: SizedBox(
                                                      height: 60,
                                                      width: 10,
                                                      child: Transform.scale(
                                                        scale: .5,
                                                        child: CircularProgressIndicator(color: primaryColor),
                                                      )),
                                                ),
                                              ),
                                        5.horizontalSpace,
                                        InkWell(
                                          onTap: () async {
                                            setState(() {
                                              addressUpdated = false;
                                            });
                                            final Position? newPosition = await UserLocation().requestLocationPermission();
                                            await CustomerAuthRep().updateUserAddress(newPosition!);
                                            await customerController.getCurrentUser();
                                            GeoPoint newLocation = customerController.user['location'];

                                            double newLatitude = newLocation.latitude;
                                            double newLongitude = newLocation.longitude;
                                            var dataa= await UserLocation().getAddress(newLatitude, newLongitude);
                                            await MyCustomerCalls().refreshNearbyRestaurants();
                                            final resByDist = Provider.of<SortByDistanceController>(context, listen: false);
                                            await resByDist.getRestaurantsByDistance();
                                            setState(() {
                                              addressUpdated = true;
                                            });
                                          },
                                          child: Text(
                                            addressUpdated ? AppLocalizations.of(context)!.update : AppLocalizations.of(context)!.updating,
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
                      40.verticalSpace,
                      Center(
                        child: PrimaryButton(
                          onPressed: () async {
                            setState(() {
                              isLoading = true;
                            });
                            Map<String, dynamic> data = profilePicController.imageUrl != null && profilePicController.imageUrl != ""
                                ? {
                                    "userName": userProfileController._nameController.text,
                                    "schoolName": userProfileController._schoolController.text,
                                    "phoneNumber": userProfileController._numberController.text,
                                    "photo": profilePicController.imageUrl,
                                  }
                                : {
                                    "userName": userProfileController._nameController.text,
                                    "schoolName": userProfileController._schoolController.text,
                                    "phoneNumber": userProfileController._numberController.text,
                                  };

                            final customerAuth = CustomerAuthRep();
                            // final user =
                            await customerAuth.updateUserProfile(data);
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
