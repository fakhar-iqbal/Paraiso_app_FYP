import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AuthController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    //TODO: uncomment it
    // subscribeToFirebase();

    // ever(
    //     isLoggedIn,
    //         (value) {
    // doesn't work cuz currentState is null in the beginning
    // if (value == true) {
    //   // go to login page
    //   _shellNavigatorKey.currentState!.pushReplacementNamed(AppRouteConstants.homeRoute);
    // }
    // else{
    //   // go to home page
    //   _rootNavigatorKey.currentState!.pushReplacementNamed(AppRouteConstants.loginRoute);
    // }
    // }
    // );
  }

  // Rx<User?> isLoggedIn = FirebaseAuth.instance.currentUser.obs;
  RxBool isLoggedIn = true.obs; //TODO: make it false

  bool get getIsLoggedIn => isLoggedIn.value;

  // subscribe to auth changes from firebase
  void subscribeToFirebase() {
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user == null) {
        // AppRouter.shellNavigatorKey.currentState!.pushReplacementNamed(AppRouteConstants.loginRoute);

        isLoggedIn.value = false;
      } else {
        // AppRouter.shellNavigatorKey.currentState!.pushReplacementNamed(AppRouteConstants.homeRoute);
        isLoggedIn.value = true;
      }
    });
  }

  void login() {
    isLoggedIn.value = true;
    // print("log in");
  }

  // must redirect to home page afterwards
  void logOut() {
    isLoggedIn.value = false;
  }
}

// two ways of routing
// 1. using a check if logged in or not in initState of every page or just
// homepage and then redirect to login page if needed using function below
// 2. using ProtectedRoute to tightly guard every page in the router.dart file

// No. 2 requires less work, just and no1 is repetitive and sluggish and still
// doesn't guarantee that user can't access any pages not meant to be accessed
// without logging in

// void isLoginRedirectNeeded() {
//   if (isLoggedIn.value == false) {
//     // redirect to login page
//     return true;
//   }
//     return false;
// }
