import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/routes/routes_constants.dart';
import 'package:paraiso/util/local_storage/shared_preferences_helper.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:paraiso/widgets/primary_button.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();
  }

  Position? currentPosition;
  String? _currentAddress;
  void _getCurrentLocation() async {
    try {
      currentPosition = await getCurrentLocation();
      _currentAddress = await getAddressFromCoordinates(currentPosition!);
      print('currentPosition.latitude');
      print(currentPosition!.latitude);
      SharedPreferencesHelper.saveUserLocation(
          currentPosition!.latitude, currentPosition!.longitude);
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw 'Location services are disabled.';
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw 'Location permissions are permanently denied, we cannot request permissions.';
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<String> getAddressFromCoordinates(Position position) async {
    try {
      SharedPreferencesHelper.saveUserLocation(
          position.latitude, position.latitude);
      print('user location get');
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark place = placemarks[0];
      return "${place.street}, ${place.locality}, ${place.postalCode}, ${place.country}";
    } catch (e) {
      return "Address not found";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/paraiso_logo.png',
              height: 126.h,
              width: 101.w,
            ),
            // AppLogo(
            //   height: 126.h,
            //   width: 101.w,
            // ),
            93.5.verticalSpace,
            Text(
              "Paraiso",
              style: Theme.of(context).textTheme.displaySmall!.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
            ),
            37.verticalSpace,
            // SizedBox(
            //   width: 270.w,
            //   child: AutoSizeText(
            //     "Étudiant",
            //     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            //           height: 1.2.h,
            //         ),
            //     textAlign: TextAlign.center,
            //     maxLines: 2,
            //   ),
            // ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * .1,
            ),
            PrimaryButton(
              onPressed: () async {
                // context.push(AppRouteConstants.loginRoute);

                SharedPreferencesHelper.saveCustomerType("guest");
                await FirebaseMessaging.instance.getToken().then((val) {
                  SharedPreferencesHelper.saveCustomerEmail(val.toString());
                  context.go(AppRouteConstants.homeRoute);
                  print('SharedPreferencesHelper.getCustomerType()');
                  print(SharedPreferencesHelper.getCustomerType());
                  print(SharedPreferencesHelper.getCustomerType());
                });
              },
              icon: Icons.arrow_forward_ios_outlined,
              enabled: true,
              child: AutoSizeText(
                "Continues Guest",
                style: TextStyle(
                  color: const Color(0xFFE4E4E4),
                  fontSize: 18.sp,
                  fontFamily: 'Recoleta',
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
              ),
            ),
            20.verticalSpace,
            PrimaryButton(
              onPressed: () async {
                context.push(AppRouteConstants.loginRoute);

                SharedPreferencesHelper.saveCustomerType("user");
                // await FirebaseMessaging.instance.getToken().then((val) {
                //   SharedPreferencesHelper.saveCustomerEmail(val.toString());
                //   context.go(AppRouteConstants.homeRoute);
                //   print('SharedPreferencesHelper.getCustomerType()');
                //   print(SharedPreferencesHelper.getCustomerType());
                //   print(SharedPreferencesHelper.getCustomerType());
                // });
              },
              icon: Icons.arrow_forward_ios_outlined,
              enabled: true,
              child: AutoSizeText(
                "User",
                style: TextStyle(
                  color: const Color(0xFFE4E4E4),
                  fontSize: 18.sp,
                  fontFamily: 'Recoleta',
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
              ),
            ),
            SizedBox(
              height: MediaQuery.sizeOf(context).height * .15,
            ),
            GestureDetector(
              onTap: () async {
                context.push(AppRouteConstants.restaurantLogin);
                SharedPreferencesHelper.saveUserSignupChoice("restaurant");
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AutoSizeText(
                    "${AppLocalizations.of(context)!.restaurant} ",
                    style: TextStyle(
                      color: primaryColor,
                      fontSize: 15.sp,
                      fontFamily: 'Recoleta',
                      fontWeight: FontWeight.w700,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                  ),
                  Icon(
                    Icons.arrow_forward_ios_outlined,
                    size: 15.h,
                  ),
                ],
              ),
            ),
            // logout button
            // ElevatedButton(
            //     onPressed: () {
            //       // method 2 see definition in auth_controller.dart
            //       FirebaseAuth.instance.signOut();
            //       context.pushReplacement(AppRouteConstants.homeRoute);
            //     },
            //     child: const Text("Logout"))
          ],
        ),
      )),
    );
  }
}
