import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:paraiso/controllers/Restaurants/res_auth_controller.dart';
import 'package:provider/provider.dart';

import '../routes/routes_constants.dart';
import '../util/theme/theme_constants.dart';
import 'Restaurant/RActionsView.dart';
import 'Restaurant/RAddOnView.dart';
import 'Restaurant/RMenuView.dart';
import 'Restaurant/RProfileView.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CustomDrawer extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  const CustomDrawer({super.key, required this.scaffoldKey});

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        return Drawer(
          shadowColor: neutralColor,
          elevation: 0.0,
          backgroundColor: neutralColor,
          shape: const BeveledRectangleBorder(),
          width: 200.w,
          child: ListView(
            children: [
              Wrap(
                direction: Axis.vertical,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20.w, top: 15.h),
                    height: 80.h,
                    width: 80.w,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color.fromRGBO(53, 53, 53, 1), width: 2.w)),
                    child: ClipOval(
                        child: Image.network(
                      authController.user!.logo,
                      fit: BoxFit.cover,
                    )),
                  ),
                  DrawerHeader(
                    child: Text(
                      authController.user!.username,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),
                ],
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.profile),
                onTap: () {
                  widget.scaffoldKey.currentState?.closeDrawer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RProfileView()),
                  );
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.menu),
                onTap: () {
                  widget.scaffoldKey.currentState?.closeDrawer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RMenuView()),
                  );
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.actions),
                onTap: () {
                  widget.scaffoldKey.currentState?.closeDrawer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RActionsView()),
                  );
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.manageaddons),
                onTap: () {
                  widget.scaffoldKey.currentState?.closeDrawer();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RAddOnView()),
                  );
                },
              ),
              ListTile(
                title: Text(AppLocalizations.of(context)!.signOut),
                onTap: () async {
                  if (authController.user != null && authController.anonymousUser != null) {
                    await authController.logout();
                    if (mounted) {
                      context.pushReplacement(AppRouteConstants.getStartedRoute);
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
