import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paraiso/screens/Restaurant/RActionsView.dart';
import 'package:paraiso/screens/custom_drawer.dart';
import 'package:provider/provider.dart';

// import '../../../controllers/Restaurants/clients_controller.dart';
import '../../../controllers/Restaurants/clients_count_provider.dart';
import '../../../controllers/Restaurants/res_auth_controller.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RLiveView extends StatefulWidget {
  const RLiveView({Key? key}) : super(key: key);

  @override
  State<RLiveView> createState() => _RLiveViewState();
}

class _RLiveViewState extends State<RLiveView> {
  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final authController = Provider.of<AuthController>(context, listen: false);
    // final clientsProvider =
    //     Provider.of<ClientsController>(context, listen: false);
    final clientsCountProvider = Provider.of<ClientCountProvider>(context, listen: false);
    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomDrawer(scaffoldKey: _scaffoldKey),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(top: 40.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      _scaffoldKey.currentState?.openDrawer();
                    },
                    child: Container(
                      height: 80.h,
                      width: 80.w,
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: const Color.fromRGBO(53, 53, 53, 1), width: 2.w)),
                      child: ClipOval(
                          child: Image.network(
                        authController.user!.logo,
                        fit: BoxFit.cover,
                      )),
                    ),
                  ),
                  Expanded(
                    child: Image.asset(
                      'assets/images/paraiso_logo.png',
                      height: 35.h,
                      width: 35.w,)
                  ),
                  Container(
                    height: 60.h,
                    width: 60.w,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: Color.fromRGBO(53, 53, 53, 1), image: DecorationImage(image: AssetImage('assets/icons/notification.png'))),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 30.h,
            ),
            Text(
              AppLocalizations.of(context)!.live,
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 23.sp),
            ),
            SizedBox(
              height: 20.h,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: Color(0xFFF3EEDD),
                        width: 1.w,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.currentlyConnected,
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.sp, color: Colors.white70),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.h, bottom: 30.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(clientsCountProvider.usersCount.toString(), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.sp, color: Colors.white)),
                                  Text(AppLocalizations.of(context)!.users, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.sp, color: Colors.white54)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RActionsView()));
                            },
                            height: 20.h,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r), side: const BorderSide(color: const Color(0xFF2F58CD))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppLocalizations.of(context)!.actions, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.sp, color: const Color(0xFF2F58CD))),
                                SizedBox(
                                  width: 5.w,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15.sp,
                                  color: const Color(0xFF2F58CD),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.w,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: Color(0xFFF3EEDD),
                        width: 1.w,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.connected1km,
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.sp, color: Colors.white70),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.h, bottom: 30.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(clientsCountProvider.usersIn1KM.toString(), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.sp, color: Colors.white)),
                                  Text(AppLocalizations.of(context)!.users, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.sp, color: Colors.white54)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RActionsView()));
                            },
                            height: 20.h,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r), side: const BorderSide(color: const Color(0xFF2F58CD))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppLocalizations.of(context)!.actions, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.sp, color: const Color(0xFF2F58CD))),
                                SizedBox(
                                  width: 5.w,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15.sp,
                                  color: const Color(0xFF2F58CD),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 30.h,
            ),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: Color(0xFFF3EEDD),
                        width: 1.w,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.clientsConnected,
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.sp, color: Colors.white70),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.h, bottom: 30.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(clientsCountProvider.clientCount.toString(), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.sp, color: Colors.white)),
                                  Text(AppLocalizations.of(context)!.users, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.sp, color: Colors.white54)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RActionsView()));
                            },
                            height: 20.h,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r), side: const BorderSide(color: const Color(0xFF2F58CD))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(AppLocalizations.of(context)!.actions, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.sp, color: const Color(0xFF2F58CD))),
                                SizedBox(
                                  width: 5.w,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15.sp,
                                  color: const Color(0xFF2F58CD),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.w,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(22.r),
                      border: Border.all(
                        color: Color(0xFFF3EEDD),
                        width: 1.w,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.nonClientsConnected,
                          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.sp, color: Colors.white70),
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.h, bottom: 30.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text((clientsCountProvider.usersCount - clientsCountProvider.clientCount).toString(),
                                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20.sp, color: Colors.white)),
                                  Text(AppLocalizations.of(context)!.users, style: TextStyle(fontWeight: FontWeight.w400, fontSize: 13.sp, color: Colors.white54)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: MaterialButton(
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => const RActionsView()));
                            },
                            height: 20.h,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r), side: const BorderSide(color: const Color(0xFF2F58CD))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('Action', style: TextStyle(fontWeight: FontWeight.w400, fontSize: 15.sp, color: const Color(0xFF2F58CD))),
                                SizedBox(
                                  width: 5.w,
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 15.sp,
                                  color: const Color(0xFF2F58CD),
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
