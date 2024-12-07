import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/routes/routes_constants.dart';
import 'package:paraiso/util/theme/theme.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/primary_button.dart';
import 'package:simple_progress_indicators/simple_progress_indicators.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../controllers/profile_controller.dart';
import '../widgets/svgtextfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    final formattedText = StringBuffer();

    if (text.isNotEmpty) {
      formattedText.write('+');
      if (text.isNotEmpty) {
        formattedText.write(text.substring(0, 1));
        formattedText.write(' ');
      }

      if (text.length >= 2) {
        formattedText.write(text.substring(1, 2));
        formattedText.write(' ');
      } else if (text.length > 1) {
        formattedText.write(text.substring(1));
      }

      if (text.length >= 4) {
        formattedText.write(text.substring(2, 4));
        formattedText.write(' ');
      } else if (text.length > 2) {
        formattedText.write(text.substring(2));
      }

      if (text.length >= 6) {
        formattedText.write(text.substring(4, 6));
        formattedText.write(' ');
      } else if (text.length > 4) {
        formattedText.write(text.substring(4));
      }

      if (text.length >= 8) {
        formattedText.write(text.substring(6, 8));
        formattedText.write(' ');
      } else if (text.length > 6) {
        formattedText.write(text.substring(6));
      }

      if (text.length >= 10) {
        formattedText.write(text.substring(8, 10));
      } else if (text.length > 8) {
        formattedText.write(text.substring(8));
      }
    }
// print(formattedText.toString());
    return TextEditingValue(
      text: formattedText.toString(),
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}

class CreateProfilePhone extends StatefulWidget {
  const CreateProfilePhone({Key? key}) : super(key: key);

  @override
  State<CreateProfilePhone> createState() => _CreateProfilePhoneState();
}

class _CreateProfilePhoneState extends State<CreateProfilePhone> {
  TextEditingController phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  ProfileController profileController = Get.put(ProfileController());

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Container(
              height: 53.h,
              width: 53.h,
              decoration: BoxDecoration(color: softBlack, borderRadius: BorderRadius.circular(50)),
              padding: EdgeInsets.only(left: 10.w),
              child: const Icon(Icons.arrow_back_ios)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
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
                value: 4 / 5,
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
                    AppLocalizations.of(context)!.gotchaNextWhatsYourPhoneNumber,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineLarge!.copyWith(
                      fontWeight: bold,
                    ),
                    maxLines: 2,
                  ),
                ),
              ),
              31.verticalSpace,
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
                child: SvgTextField(
                  hintText: "+33 55-55-55-55",
                  controller: phoneController,
                  validator: (value) {
                    // if (value!.isEmpty) {
                    //   return "Please enter your email";
                    // }
                    return null;
                  },
                  textInputFormatter: [LengthLimitingTextInputFormatter(17), MaskTextInputFormatter(mask: "+## ## ## ## ##")],
                  prefixIcon: "assets/images/Create Account(phone num)_Call_248_3459.svg",
                  textInputType: TextInputType.phone,
                ),
              ),
              40.verticalSpace,
              Center(
                child: PrimaryButton(
                  onPressed: () {
                    if (phoneController.text.isNotEmpty) {
                      Get.find<ProfileController>().phone = phoneController.text;
                      context.push(AppRouteConstants.createProfileSchoolName);
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
