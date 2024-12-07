import 'package:auto_size_text/auto_size_text.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/controllers/customer_controller.dart';
import 'package:paraiso/util/theme/theme.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/primary_button.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../controllers/profile_controller.dart';
import '../repositories/customer_auth_repo.dart';
import '../routes/routes_constants.dart';
import '../util/local_storage/shared_preferences_helper.dart';
import '../widgets/svgtextfield.dart';
import 'forgotPassword.dart';

class LoginFormController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxBool emailValid = false.obs;

  bool get isEmailValid => emailValid.value;
  RxBool rememberMe = false.obs;

  void toggleRememberMe() {
    rememberMe.toggle();
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
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

  String? passwordValidator(String? value) {
    if (value!.isEmpty) {
      return "Please enter your password";
    } else if (value.length < 6) {
      return "Password must be at least 6 characters";
    }
    // Add additional password validation logic
    return null;
  }

  void submitForm(BuildContext context) {
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

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final LoginFormController loginFormController =
      Get.put(LoginFormController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isAuthenticating = false;

  void signInAnonymously(Function callback) {
    FirebaseAuth.instance.signInAnonymously().then((value) {
      if (kDebugMode) print("User ID: ${value.user!.uid}");
      callback();
    });
  }

  EmailOTP myAuth = EmailOTP();

  @override
  Widget build(BuildContext context) {
    // return HeadlineDisplay();
    // print(ScreenUtil().scaleWidth);
    // screen width:
    // print(ScreenUtil().screenWidth);

    // print("Am I logged in: " +
    //     Get.find<AuthController>().getIsLoggedIn.toString());

    final customerController =
        Provider.of<CustomerController>(context, listen: false);

    return Scaffold(
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
                      128.verticalSpace,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/paraiso_logo.png',
                            height: 40.h,
                            width: 40.w,
                          ),
                          // AppLogo(
                          //   height: 66.5.h,
                          //   width: 53.35.w,
                          // ),
                          9.horizontalSpace,
                          Text(
                            "Paraiso",
                            style: context.headlineLarge!.copyWith(
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Recoleta',
                            ),
                          ),
                        ],
                      ),
                      88.verticalSpace,
                      SizedBox(
                        width: 208,
                        height: 39,
                        child: Text(
                          AppLocalizations.of(context)!.welcomeBack,
                          textAlign: TextAlign.center,
                          style: context.titleLarge!.copyWith(
                            fontWeight: bold,
                            color: white,
                          ),
                        ),
                      ),
                      4.verticalSpace,
                      SizedBox(
                        width: 273.w,
                        height: 55.h,
                        child: AutoSizeText(
                          AppLocalizations.of(context)!
                              .useYourCredentialsBelowAndLoginToYourAccount,
                          textAlign: TextAlign.center,
                          style: context.titleSmall,
                          maxLines: 2,
                        ),
                      ),
                      38.verticalSpace,
                      Obx(() {
                        return SvgTextField(
                          hintText:
                              AppLocalizations.of(context)!.enterYourEmail,
                          controller: loginFormController._emailController,
                          validator: loginFormController.emailValidator,
                          prefixIcon: "assets/images/email_icon.svg",
                          suffixIcon: loginFormController.isEmailValid
                              ? Transform.scale(
                                  scale: .4,
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.check,
                                      color: Colors.black,
                                      size: 30.sp,
                                    ),
                                  ),
                                )
                              : null,
                          textInputType: TextInputType.emailAddress,
                        );
                      }),
                      18.verticalSpace,
                      SvgTextField(
                        hintText:
                            AppLocalizations.of(context)!.enterYourPassword,
                        controller: loginFormController._passwordController,
                        validator: loginFormController.passwordValidator,
                        prefixIcon:
                            "assets/images/Customer Login_Lock_I126_1815;71_2129.svg",
                        isPasswordField: true,
                        textInputType: TextInputType.emailAddress,
                      ),
                      15.verticalSpace,
                      SizedBox(
                        width: context.width * .8767,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              //   forgot password
                              GestureDetector(
                                  onTap: () async {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const ForgotPasswordScreen()));
                                  },
                                  child: Text(
                                    AppLocalizations.of(context)!
                                        .forgotPassword,
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      color: const Color(0xFFE4E4E4),
                                      fontSize: 15.sp,
                                      fontFamily: 'Recoleta',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )),
                            ]),
                      ),
                      53.verticalSpace,
                      Center(
                        child: PrimaryButton(
                          onPressed: () async {
                            // context.push(AppRouteConstants.createProfileName);
                            // check if empty, show snackbar
                            if (loginFormController
                                    ._emailController.text.isEmpty ||
                                loginFormController
                                    ._passwordController.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Center(
                                    child: Text(
                                      AppLocalizations.of(context)!
                                          .pleaseFillInAllFields,
                                      style: context.titleMedium,
                                    ),
                                  ),
                                  backgroundColor: dangerColor,
                                ),
                              );
                            } else {
                              // loginFormController.submitForm(context);
                              setState(() {
                                isAuthenticating = true;
                              });
                              final customerAuth = CustomerAuthRep();
                              final result = await customerAuth.signIn(
                                loginFormController._emailController.text,
                                loginFormController._passwordController.text,
                              );
                              if (result == "Login successful") {
                                await SharedPreferencesHelper.saveCustomerEmail(
                                    loginFormController._emailController.text);
                                await customerController.getCurrentUser();
                                if (kDebugMode) print("loginuserrrrrrrrrr");
                                if (kDebugMode) print(customerController.user);
                                SharedPreferencesHelper.saveCustomerType(
                                    'user');
                                setState(() {
                                  isAuthenticating = false;
                                });
                                loginFormController._emailController.clear();
                                loginFormController._passwordController.clear();
                                if (mounted) {
                                  context.go(AppRouteConstants.homeRoute);
                                }
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
                            }
                          },
                          child: isAuthenticating
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : AutoSizeText(
                                  AppLocalizations.of(context)!
                                      .logIntoYourAccount,
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
                      ScreenUtil().scaleHeight < 1
                          ? 83.h.verticalSpace
                          : 163.h.verticalSpace,

                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text:
                                  '${AppLocalizations.of(context)!.dontHaveAnAccount} ',
                              style: const TextStyle(
                                color: Color(0xFFE4E4E4),
                                fontSize: 15,
                                fontFamily: 'Recoleta',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: AppLocalizations.of(context)!.signUpHere,
                              style: const TextStyle(
                                color: Color(0xFF2F58CD),
                                fontSize: 15,
                                fontFamily: 'Recoleta',
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ).onTap(
                        () {
                          context.push(AppRouteConstants.createProfileName);
                        },
                      ).paddingOnly(bottom: 5.h),
                    ]),
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
