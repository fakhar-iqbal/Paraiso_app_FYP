// Purpose: to check if user is logged in or not and redirect (or if Premium) to login page if not logged in
// better to use stateless widget instead of statefull widget cuz longer time to initialize app and even
// state, after the check is done, the widget is not used anymore so wastes time and resources

import 'package:flutter/material.dart';

class ProtectedRoute extends StatelessWidget {
  final Widget child;

  const ProtectedRoute({Key? key, required this.child}) : super(key: key);

  factory ProtectedRoute.checkAuth({required Widget child}) {
    //TODO: RE IMPLEMENT THIS USING PROVIDER (CHECK IF USER IS LOGGED IN)
    // if (Get.find<AuthController>().isLoggedIn.value == false) {
    //   return ProtectedRoute(child: LoginScreen());
    // }
    return ProtectedRoute(child: child);
  }

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
