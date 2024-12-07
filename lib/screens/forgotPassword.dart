import 'package:auto_size_text/auto_size_text.dart';
import 'package:email_otp/email_otp.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/controllers/customer_controller.dart';
import 'package:paraiso/screens/Restaurant/RSignInView.dart';
import 'package:paraiso/util/theme/theme.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/app_specific/paraiso_logo.dart';
import 'package:paraiso/widgets/primary_button.dart';
import 'package:paraiso/widgets/sized_icons.dart';
import 'package:provider/provider.dart';
import 'package:velocity_x/velocity_x.dart';

import '../controllers/profile_controller.dart';
import '../repositories/customer_auth_repo.dart';
import '../repositories/customer_firebase_calls.dart';
import '../routes/routes_constants.dart';
import '../util/local_storage/shared_preferences_helper.dart';
import '../widgets/svgtextfield.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'login_screen.dart';

class ForgotFormController extends GetxController {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  RxBool emailValid = false.obs;

  bool get isEmailValid => emailValid.value;
  RxBool rememberMe = false.obs;

  void toggleRememberMe() {
    rememberMe.toggle();
  }

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  ProfileController profileController = Get.put(ProfileController());

  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) {
      emailValid.value = false;
      return 'Veuillez saisir une adresse e-mail';
    }

    if (!GetUtils.isEmail(value)) {
      emailValid.value = false;
      return 'Veuillez saisir une adresse e-mail valide';
    }
    // Add additional email validation logic
    emailValid.value = true;
    return null;
  }

  String? passwordValidator(String? value) {
    if (value!.isEmpty) {
      return "Veuillez saisir votre mot de passe.";
    } else if (value.length < 6) {
      return "Le mot de passe doit comporter au moins 6 caractères.";
    }
    // Add additional password validation logic
    return null;
  }

  String? otpValidator(String? value) {
    if (value!.isEmpty) {
      return "Veuillez entrer l'OTP.";
    } else if (value.length != 6) {
      return "L'OTP doit comporter 6 chiffres.";
    }
    // Add additional password validation logic
    return null;
  }

  void submitForm(BuildContext context) {
    //TODO uncomment this
  }
}

class ForgotPasswordScreen extends StatefulWidget {
  final String userType;
  const ForgotPasswordScreen({Key? key,this.userType="user"}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final ForgotFormController loginFormController =
      Get.put(ForgotFormController());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isAuthenticating = false;

  String forgotUserId = "";
  String forgotUserEmail = "";
  String forgotUserType = "";

  void signInAnonymously(Function callback) {
    FirebaseAuth.instance.signInAnonymously().then((value) {
      if (kDebugMode) print("User ID: ${value.user!.uid}");
      callback();
    });
  }

  String screenType = "email";

  EmailOTP myAuth = EmailOTP();

  Future<void> sendOtp() async {
    if (loginFormController
        ._emailController.text.isEmpty) {
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
      return;
    }else{
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Envoi de l'OTP en cours...",
              style: context.titleMedium?.copyWith(
                color: white,
              ),
            ),
          ),
          backgroundColor: successColor,
        ),
      );

      myAuth.setConfig(
          appEmail: "me@pariso.com",
          appName: "Paraiso",
          userEmail: loginFormController._emailController.text,
          otpLength: 6,
          otpType: OTPType.digitsOnly);

      await myAuth.sendOTP();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "OTP envoyé!",
              style: context.titleMedium?.copyWith(
                color: white,
              ),
            ),
          ),
          backgroundColor: successColor,
        ),
      );
      setState(() {
        screenType = "otp";
      });
    }


  }

  Future<void> verifyOtp() async{
    if (loginFormController
        ._otpController.text.isEmpty) {
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
      return;
    }
    else{
      bool isVerified=await myAuth.verifyOTP(
        otp: loginFormController._otpController.text,
      );
      if(isVerified){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                "L'OTP a été vérifié !",
                style: context.titleMedium?.copyWith(
                  color: white,
                ),
              ),
            ),
            backgroundColor: successColor,
          ),
        );
        setState(() {
          screenType = "password";
        });
      }
      else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(
              child: Text(
                "Otp incorrect, veuillez réessayer ! ",
                style: context.titleMedium?.copyWith(
                  color: white,
                ),
              ),
            ),
            backgroundColor: dangerColor,
          ),
        );
      }

      loginFormController._otpController.clear();

    }

  }

  Future<void> changePassword() async{

    print("forgotUserId: $forgotUserId");
    print("forgotUserEmail: $forgotUserEmail");
    print("forgotUserType: $forgotUserType");


    if (loginFormController
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
      return;
    }
    else{



      final mycust=MyCustomerCalls();

      await mycust.changePassword(
        password : loginFormController._passwordController.text,
        userId : forgotUserId,
        userType : forgotUserType,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(
            child: Text(
              "Mot de passe changé ! ",
              style: context.titleMedium?.copyWith(
                color: white,
              ),
            ),
          ),
          backgroundColor: successColor,
        ),
      );


      loginFormController._passwordController.clear();

      if(widget.userType=="user"){
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
      }
      else{
        Navigator.push(context, MaterialPageRoute(builder: (context) => const RSignInView()));
      }


      setState(() {
        screenType = "email";
      });

    }
  }

  @override
  Widget build(BuildContext context) {
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
                          Image.asset('assets/images/paraiso_logo.png',height: 66.5.h,
                            width: 53.35.w,),
                          // AppLogo(
                          //   height: 66.5.h,
                          //   width: 53.35.w,
                          // ),
                          9.horizontalSpace,
                          Text(
                            "Paraiso",
                            style: context.headlineLarge!.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      88.verticalSpace,
                      SizedBox(
                        width: 208,
                        height: 39,
                        child: Text(
                          "Réinitialiser le mot de passe",
                          textAlign: TextAlign.center,
                          style: context.titleLarge!.copyWith(
                            fontWeight: bold,
                            color: white,
                          ),
                        ),
                      ),
                      4.verticalSpace,
                      if (screenType == "email")
                        SizedBox(
                          width: 273.w,
                          height: 55.h,
                          child: AutoSizeText(
                            "Veuillez saisir votre adresse e-mail ci-dessous et nous vous enverrons un code OTP pour réinitialiser votre mot de passe.",
                            textAlign: TextAlign.center,
                            style: context.titleSmall,
                            maxLines: 2,
                          ),
                        ),
                      if (screenType == "otp")
                        SizedBox(
                          width: 273.w,
                          child: AutoSizeText(
                            "Veuillez saisir l'OTP envoyé à votre adresse e-mail : ",
                            textAlign: TextAlign.center,
                            style: context.titleSmall,
                            maxLines: 2,
                          ),
                        ),
                      if (screenType == "otp")
                        SizedBox(
                          width: 273.w,
                          child: AutoSizeText(
                            loginFormController._emailController.text,
                            textAlign: TextAlign.center,
                            style: context.titleSmall,
                            maxLines: 2,
                          ),
                        ),
                      if (screenType == "password")
                        SizedBox(
                          width: 273.w,
                          child: AutoSizeText(
                            "Veuillez saisir votre nouveau mot de passe.",
                            textAlign: TextAlign.center,
                            style: context.titleSmall,
                            maxLines: 2,
                          ),
                        ),
                      38.verticalSpace,
                      if (screenType == "email")Obx(() {
                        return SvgTextField(
                          hintText:
                              AppLocalizations.of(context)!.enterYourEmail,
                          controller: loginFormController._emailController,
                          validator: loginFormController.emailValidator,
                          prefixIcon: "assets/images/email_icon.svg",
                          suffixIcon: loginFormController.isEmailValid
                              ? const SizedIcons(
                                  svgPath: "assets/images/icon_checkmark.svg",
                                  scale: .4,
                                )
                              : null,
                          textInputType: TextInputType.emailAddress,
                        );
                      }),
                      18.verticalSpace,
                      if (screenType == "otp")
                        SvgTextField(
                          hintText: "Entrez l'OTP",
                          controller: loginFormController._otpController,
                          validator: loginFormController.otpValidator,
                          prefixIcon:
                          "assets/images/Customer Login_Lock_I126_1815;71_2129.svg",
                          textInputType: TextInputType.number,
                        ),
                      if (screenType == "password")
                        SvgTextField(
                          hintText: " Entrez le nouveau mot de ",
                          controller: loginFormController._passwordController,
                          validator: loginFormController.passwordValidator,
                          prefixIcon:
                              "assets/images/Customer Login_Lock_I126_1815;71_2129.svg",
                          isPasswordField: true,
                          textInputType: TextInputType.emailAddress,
                        ),
                      53.verticalSpace,
                      Center(
                        child: PrimaryButton(
                          onPressed: () async {

                            if(screenType=="email"){
                              final mycust=MyCustomerCalls();

                              final listsss= await mycust.getEmails();

                              bool isRegistered=false;

                              for(int i=0;i<listsss.length;i++){
                                if(listsss[i]["email"]==loginFormController._emailController.text){
                                  await sendOtp();
                                  isRegistered=true;
                                  setState(() {
                                    forgotUserId = listsss[i]["id"];
                                    forgotUserEmail = listsss[i]["email"];
                                    forgotUserType = listsss[i]["userType"];
                                  });
                                  break;
                                }
                              }
                              if(!isRegistered){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Center(
                                      child: Text(
                                        "passe. E-mail non enregistré !",
                                        style: context.titleMedium,
                                      ),
                                    ),
                                    backgroundColor: dangerColor,
                                  ),
                                );
                              }

                            }

                            if(screenType=="otp"){
                              await verifyOtp();
                            }

                            if(screenType=="password"){
                              await changePassword();
                              // setState(() {
                              //   screenType = "email";
                              // });
                            }
                          },
                          child: isAuthenticating
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : AutoSizeText(
                                  screenType == "email"
                                      ? "Envoyer OTP"
                                      : screenType == "otp"
                                          ? "Vérifier OTP"
                                          : "Réinitialiser le mot de passe",
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
                              text: "Retour",
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
                          if(screenType=="email"){
                            if(widget.userType=="user"){
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                            }
                            else{
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RSignInView()));
                            }
                          }
                          else if(screenType=="otp"){
                            setState(() {
                              screenType = "email";
                            });
                          }
                          else if(screenType=="password"){
                            setState(() {
                              screenType = "otp";
                            });
                          }
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
