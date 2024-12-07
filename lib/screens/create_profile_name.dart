import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/controllers/profile_controller.dart';
import 'package:paraiso/routes/routes_constants.dart';
import 'package:paraiso/util/theme/theme.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/normal_appbar.dart';
import 'package:paraiso/widgets/primary_button.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';

import '../widgets/svgtextfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class NameValidator {
  static String? validateName(String? value) {
    // if (value != null) {
    // if (value.length < 3) {
    //   return 'Name must be more than 2 charater';
    // } else
    return '';
    // }
  }

  static void submitForm(GlobalKey<FormState> formKey) {
    if (formKey.currentState!.validate()) {
      // Validation successful, proceed with form submission
    } else {
      // Validation failed, handle invalid form data
    }
  }
}

class CreateProfileName extends StatefulWidget {
  const CreateProfileName({Key? key}) : super(key: key);

  @override
  State<CreateProfileName> createState() => _CreateProfileNameState();
}

class _CreateProfileNameState extends State<CreateProfileName> {
  TextEditingController nameController = TextEditingController();
  ProfileController profileController = Get.put(ProfileController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // TODO: implement dispose
    nameController.dispose();
    profileController.dispose();
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
            children: [
              34.verticalSpace,
              ProgressBar(
                width: 1.sw,
                value: 1 / 5,
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
                    AppLocalizations.of(context)!.readyToCreateYourProfileFirstWhatsYourName,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineLarge!.copyWith(
                      fontWeight: bold,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
              12.verticalSpace,
              Center(
                child: SizedBox(
                  width: 293.w,
                  height: 55.h,
                  child: AutoSizeText(
                    AppLocalizations.of(context)!.thisIsHowYoullAppearOnParaisoNew,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium,
                    maxLines: 2,
                  ),
                ),
              ),
              31.verticalSpace,
              Center(
                child: SvgTextField(
                  hintText: AppLocalizations.of(context)!.enterYourFullName,
                  controller: nameController,
                  validator: NameValidator.validateName,
                  prefixIcon: 'assets/images/Create Account(name-2)_User_248_3071.svg',
                  textInputType: TextInputType.emailAddress,
                ),
              ),
              40.verticalSpace,
              Center(
                child: PrimaryButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty) {
                      Get.find<ProfileController>().name = nameController.text;
                      context.push(AppRouteConstants.createProfileEmail);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Center(child: Text(AppLocalizations.of(context)!.pleaseEnterYourName)),
                        ),
                      );
                    }
                  },
                  icon: Icons.arrow_forward_ios_outlined,
                  child: AutoSizeText(
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
