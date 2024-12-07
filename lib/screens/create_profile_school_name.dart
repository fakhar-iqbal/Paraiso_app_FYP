import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/routes/routes_constants.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/normal_appbar.dart';
import 'package:paraiso/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:velocity_x/velocity_x.dart';
import 'package:get/get.dart';
import '../controllers/customer_controller.dart';
import '../controllers/profile_controller.dart';
import '../controllers/restaurants_with_discount_controller.dart';
import '../controllers/sort_by_distance_controller.dart';
import '../repositories/customer_auth_repo.dart';
import '../repositories/customer_firebase_calls.dart';
import '../util/location/user_location.dart';
import '../util/theme/theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateProfileSchoolName extends StatefulWidget {
  const CreateProfileSchoolName({Key? key}) : super(key: key);

  @override
  State<CreateProfileSchoolName> createState() => _CreateProfileSchoolNameState();
}

class _CreateProfileSchoolNameState extends State<CreateProfileSchoolName> {
  TextEditingController schoolNameController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ProfileController profileController = Get.put(ProfileController());

  bool isAuthenticating = false;
  bool restaurantsLookUp = false;
  String? selectedSchool;
  List<String> schoolNames = [
    "Montpellier Business School",
    "ESG",
    "Ynov campus",
    "Université de Montpellier",
    "Idrac",
    "Sup de Com",
    "Autres",
  ];

  @override
  void dispose() {
    schoolNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NormalAppbar(),
      body: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState!.validate();
        },
        child: SafeArea(
          child: ListView(
            physics: const ClampingScrollPhysics(),
            children: [
              34.verticalSpace,
              ProgressBar(
                width: 1.sw,
                value: 1,
                height: 5.h,
                backgroundColor: onNeutralColor,
                color: primaryColor,
              ),
              93.verticalSpace,
              Center(
                child: SizedBox(
                  width: 326,
                  height: 68,
                  child: AutoSizeText(
                    AppLocalizations.of(context)!.justOneLastStepLetUsKnowAboutYourSchool,
                    textAlign: TextAlign.center,
                    style: context.headlineLarge!.copyWith(
                      fontWeight: bold,
                      color: onPrimaryColor,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
              31.verticalSpace,
              Center(
                child: SizedBox(
                  width: 293,
                  height: 55,
                  child: Text(
                    AppLocalizations.of(context)!.pleaseEnterYourSchoolName,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18),
                    maxLines: 2,
                  ),
                ),
              ),
              34.verticalSpace,
              Center(
                child: SizedBox(
                  width: MediaQuery.sizeOf(context).width * .85,
                  child: DropdownButtonFormField<String>(
                    isDense: true,
                    decoration: myInputDecoration().copyWith(
                      contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    hint: Text(AppLocalizations.of(context)!.chooseYourSchool, style: TextStyle(fontSize: 18.sp)),
                    value: selectedSchool,
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
                        selectedSchool = newValue;
                        schoolNameController.text = newValue!;
                      });
                    },
                  ),
                ),
              ),
              40.verticalSpace,
              Center(
                child: PrimaryButton(
                  onPressed: () async {
                    if (schoolNameController.text.isNotEmpty) {
                      Get.find<ProfileController>().schoolName = schoolNameController.text;
                      //    TODO: use push to allow to go back else -> go
                      setState(() {
                        isAuthenticating = true;
                      });
                      final myData = Get.find<ProfileController>();
                      final myLocation = await UserLocation().requestLocationPermission();
                      final customerAuth = CustomerAuthRep();
                      final result = await customerAuth.signUp(
                          email: myData.email, password: myData.password, name: myData.name, schoolName: myData.schoolName, phoneNumber: myData.phone, position: myLocation, rewards: 0);
                      if (result == "User added") {
                        setState(() {
                          isAuthenticating = false;
                          restaurantsLookUp = true;
                        });
                        if (mounted) {
                          final resByDist = Provider.of<SortByDistanceController>(context, listen: false);
                          final currentUserController = Provider.of<CustomerController>(context, listen: false);

                          final restController = Provider.of<RestaurantsWithDiscountController>(context, listen: false);

                          await MyCustomerCalls().fetchAndSaveNearbyRestaurants();

                          await currentUserController.getCurrentUser();
                          await MyCustomerCalls().refreshNearbyRestaurants();
                          await resByDist.getRestaurantsByDistance();
                          await restController.getRestaurantsWithDiscounts();
                        }
                        setState(() {
                          restaurantsLookUp = false;
                        });
                        if (mounted) context.go(AppRouteConstants.homeRoute);
                      } else {
                        setState(() {
                          isAuthenticating = false;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Center(
                              child: Text(
                                result,
                                style: context.titleMedium,
                              ),
                            ),
                            backgroundColor: dangerColor,
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(child: Text(AppLocalizations.of(context)!.pleaseEnterYourSchoolName)),
                        ),
                      );
                    }
                  },
                  icon: isAuthenticating || restaurantsLookUp ? null : Icons.arrow_forward_ios_outlined,
                  child: isAuthenticating
                      ? CircularProgressIndicator(
                          color: onPrimaryColor,
                        )
                      : restaurantsLookUp
                          ? AutoSizeText(
                              AppLocalizations.of(context)!.findingRestaurantsNearYou,
                              style: TextStyle(
                                color: const Color(0xFFE4E4E4),
                                fontSize: 15.sp,
                                fontFamily: 'Recoleta',
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.italic,
                              ),
                              maxLines: 1,
                            )
                          : AutoSizeText(
                              AppLocalizations.of(context)!.continueText,
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
            ],
          ),
        ),
      ),
    );
  }
}
