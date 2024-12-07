import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/routes/routes_constants.dart';
import 'package:paraiso/util/theme/theme.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/normal_appbar.dart';
import 'package:paraiso/widgets/primary_button.dart';
import 'package:paraiso/widgets/sized_icons.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';

import '../controllers/profile_controller.dart';
import '../widgets/svgtextfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileEmailController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxBool emailValid = false.obs;

  bool get isEmailValid => emailValid.value;

  final TextEditingController _emailController = TextEditingController();

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

  void submitForm() {
    //TODO uncomment this
    // if (formKey.currentState!.validate()) {
    //   // Validation successful, proceed with form submission
    //   _emailController.clear();
    //   _passwordController.clear();
    // } else {
    //   // Validation failed, handle invalid form data
    // }
  }
}

class CreateProfileEmail extends StatefulWidget {
  const CreateProfileEmail({Key? key}) : super(key: key);

  @override
  State<CreateProfileEmail> createState() => _CreateProfileEmailState();
}

class _CreateProfileEmailState extends State<CreateProfileEmail> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final ProfileEmailController profileEmailController = Get.put(ProfileEmailController());

  @override
  void dispose() {
    // TODO: implement dispose
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
                value: 2 / 5,
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
                    AppLocalizations.of(context)!.niceToMeetYouWhatsYourEmail,
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
                    AppLocalizations.of(context)!.thisIsSoYouCanVerifyYourAccount,
                    textAlign: TextAlign.center,
                    style: context.textTheme.titleMedium,
                    maxLines: 2,
                  ),
                ),
              ),
              31.verticalSpace,
              Center(
                child: Obx(() => SvgTextField(
                      hintText: "example@gmailcom",
                      controller: profileEmailController._emailController,
                      validator: profileEmailController.emailValidator,
                      prefixIcon: "assets/images/email_icon.svg",
                      suffixIcon: profileEmailController.isEmailValid
                          ? const SizedIcons(
                              svgPath: "assets/images/icon_checkmark.svg",
                              scale: .4,
                            )
                          : null,
                      textInputType: TextInputType.emailAddress,
                    )),
              ),
              40.verticalSpace,
              Center(
                child: PrimaryButton(
                  onPressed: () {
                    if (profileEmailController._emailController.text.isNotEmpty) {
                      Get.find<ProfileController>().email = profileEmailController._emailController.text;
                      context.push(AppRouteConstants.createProfilePassword);
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
