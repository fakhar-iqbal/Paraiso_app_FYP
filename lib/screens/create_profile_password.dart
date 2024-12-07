import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/util/theme/theme.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/normal_appbar.dart';
import 'package:paraiso/widgets/primary_button.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';

import '../controllers/profile_controller.dart';
import '../routes/routes_constants.dart';
import '../widgets/svgtextfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateProfilePassword extends StatefulWidget {
  const CreateProfilePassword({Key? key}) : super(key: key);

  @override
  State<CreateProfilePassword> createState() => _CreateProfilePasswordState();
}

class _CreateProfilePasswordState extends State<CreateProfilePassword> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NormalAppbar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          onChanged: () {
            _formKey.currentState!.validate();
          },
          child: ListView(physics: const ClampingScrollPhysics(), children: [
            34.verticalSpace,
            ProgressBar(
              width: 1.sw,
              value: 3 / 5,
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
                  AppLocalizations.of(context)!.pleaseChooseAStrongPassword,
                  textAlign: TextAlign.center,
                  style: context.textTheme.headlineLarge!.copyWith(
                    fontWeight: bold,
                  ),
                ),
              ),
            ),
            31.verticalSpace,
            Center(
              child: SizedBox(
                width: 293.w,
                height: 55.h,
                child: AutoSizeText(
                  AppLocalizations.of(context)!.makeSureItsUniqueAtLeast8Characters,
                  textAlign: TextAlign.center,
                  style: context.textTheme.titleMedium,
                  maxLines: 2,
                ),
              ),
            ),
            38.verticalSpace,
            Center(
              child: SvgTextField(
                hintText: "examplePass123",
                controller: _passwordController,
                validator: (value) {
                  // if (value!.isEmpty) {
                  //   return "Please enter your password";
                  // }
                  return null;
                },
                // lock
                prefixIcon: "assets/images/Customer Login_Lock_I126_1815;71_2129.svg",
                isPasswordField: true,
              ),
            ),
            18.verticalSpace,
            Center(
              child: SvgTextField(
                //TODO: TRANSFORM
                hintText: "Confirm password",
                controller: _confirmPasswordController,
                validator: (value) {
                  // if (value!.isEmpty) {
                  //   return "Please confirm your password";
                  // }
                  return null;
                },
                prefixIcon: "assets/images/Customer Login_Lock_I126_1815;71_2129.svg",
                isPasswordField: true,
              ),
            ),
            41.verticalSpace,
            Center(
              child: PrimaryButton(
                onPressed: () {
                  // check if empty, show snackbar

                  if (_passwordController.text == _confirmPasswordController.text && _passwordController.text.isNotEmpty && _confirmPasswordController.text.isNotEmpty) {
                    Get.find<ProfileController>().password = _passwordController.text;
                    context.push(AppRouteConstants.createProfilePhone);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Center(
                          child: Text(
                            AppLocalizations.of(context)!.passwordsDoNotMatch,
                            style: context.textTheme.titleMedium,
                          ),
                        ),
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
            //check if height of viewport 1.vh is smaller than 500
            ScreenUtil().scaleHeight < 1 ? 83.h.verticalSpace : 163.h.verticalSpace,
          ]),
        ),
      ),
    );
  }
}
