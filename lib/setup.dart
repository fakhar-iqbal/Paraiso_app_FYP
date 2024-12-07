import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_storage/get_storage.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';

/*
Run this command if you don't already have firebase_options.dart
flutterfire configure
Docs: https://firebase.flutter.dev/docs/cli/
*/

Future initializePreConfig() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "pk_live_51MVrzeFEInIeQ0sUKdZie82qk5TAarvFDB4Jubh3lmnY3hc7iGHzDUVUrGtShz9UFuJeYb7rYfdgEgKeTCCZ3VIs00Qo2gSl1I";
  // Stripe.publishableKey = "pk_test_51OAzOaBv5r2e0H1dyPNETX31O9rsaIpZLpoRuWnjLWzVbleyjIfG2tdFDOrie18giCmF4jaadcy0n18zsaIbdozU002Tqqb68X";
  await dotenv.load(fileName: "assets/.env");
  setupGetStorage();
  await sharedPrefInit();
  await firebaseSetup();
  await screenUtilSetup();
  spinnerSetup();
}

void setupGetStorage() {
  GetStorage.init();
}

Future sharedPrefInit() async {
  await SharedPreferencesHelper.init();
}

void spinnerSetup() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.circle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    // ..progressColor = Colors.yellow
    // ..backgroundColor = Colors.green
    // ..indicatorColor = Colors.yellow
    // ..textColor = Colors.yellow
    // ..maskColor = Colors.blue.withOpacity(0.5)
    // ..userInteractions = true
    ..dismissOnTap = false;
}

Future screenUtilSetup() async {
  // to support font adaptation in the textTheme of app theme
  await ScreenUtil.ensureScreenSize();
}

firebaseSetup() async {
  if (Platform.isWindows) return;

  await Firebase.initializeApp();
  // await FirebaseAuth.instance.wait();
}

// extension FirebaseAuthExtension on FirebaseAuth {
//   wait() async {
//     bool ready = false;
//     FirebaseAuth.instance.authStateChanges().listen((event) {
//       ready = true;
//     });

//     while (ready == false) {
//       await Future.delayed(const Duration(milliseconds: 250));
//     }
//   }
// }
