import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:paraiso/controllers/Restaurants/AddOnController.dart';
import 'package:provider/provider.dart';

import '../../controllers/Restaurants/res_auth_controller.dart';
import '../../repositories/res_post_repo.dart';
import 'CreateEditAddon.dart';

class RAddOnView extends StatefulWidget {
  const RAddOnView({super.key});

  @override
  State<RAddOnView> createState() => _RAddOnViewState();
}

class _RAddOnViewState extends State<RAddOnView> {

  @override
  void didChangeDependencies() async {
    final addonItemsController = Provider.of<AddOnController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);
    await addonItemsController.fetchADDON(authController.user!.userId);
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<AddOnController>(
      builder: (context, value, child) {
        final myaADDONS = value.addons;
        return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CreateEditAddon()),
                ).then((value) => setState((){
                  final addonItemsController = Provider.of<AddOnController>(context, listen: false);
                  final authController = Provider.of<AuthController>(context, listen: false);
                  addonItemsController.fetchADDON(authController.user!.userId);
                }));
              },
              backgroundColor: const Color(0xFF2F58CD),
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            body: SingleChildScrollView(
              child: SafeArea(
                child: Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  child: Column(
                    children: [
                      Row(children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            height: 50.h,
                            width: 50.w,
                            margin: EdgeInsets.only(right: 5.w),
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color.fromRGBO(53, 53, 53, 1)),
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.only(left: 8.w),
                                child: Icon(
                                  Icons.arrow_back_ios,
                                  size: 20.sp,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          AppLocalizations.of(context)!.manageaddons,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 23.sp),
                        ),
                        const Spacer(),
                        const Spacer(),
                      ]),
                      const SizedBox(height: 40),
                      Expanded(
                        child: RefreshIndicator(
                          onRefresh: () async {
                            final addonItemsController = Provider.of<AddOnController>(context, listen: false);
                            final authController = Provider.of<AuthController>(context, listen: false);
                            await addonItemsController.fetchADDON(authController.user!.userId);
                          },
                          child: ListView.builder(
                            itemCount: myaADDONS.length,
                            itemBuilder: (context, index) {
                              return AddOnTile(
                                title: myaADDONS[index].addonName,
                                subData: "${myaADDONS[index].addonItems.length}${myaADDONS[index].addonType== "Choices" ? " choices" : " ingredients"}",
                                onDelete: () async {
                                  final addonItemsController = Provider.of<AddOnController>(context, listen: false);
                                  final authController = Provider.of<AuthController>(context, listen: false);
                                  await addonItemsController.removeADDON(authController.user!.userId, myaADDONS[index].addonId);
                                  await addonItemsController.fetchADDON(authController.user!.userId);
                                },
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => CreateEditAddon(isEdit:true ,addonItemWithId: myaADDONS[index])),
                                  ).then((value) => setState((){
                                    final addonItemsController = Provider.of<AddOnController>(context, listen: false);
                                    final authController = Provider.of<AuthController>(context, listen: false);
                                    addonItemsController.fetchADDON(authController.user!.userId);
                                  }));
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ));
      },
    );
  }
}



class AddOnTile extends StatefulWidget {
  final String? title;
  final String? subData;
  final void Function()? onDelete;
  final void Function()? onTap;
  final bool showSubData;
  final bool showDeleteButton;
  final bool isChecked;
  const AddOnTile({super.key, this.title, this.subData, this.onDelete,  this.showSubData=true, this.onTap,  this.showDeleteButton=true,this.isChecked=false});

  @override
  State<AddOnTile> createState() => _AddOnTileState();
}

class _AddOnTileState extends State<AddOnTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: widget.onTap,
      child: Container(
        width: 380.w,
        height: 68.h,
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          color: Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(22.r),
          border: Border.all(
            color: Color(0xFFF3EEDD),
            width: 1.w,
          ),
        ),
        child: Padding(
          padding:  EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title??"CUISSONS",
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: "Recoleta",
                          fontWeight: FontWeight.w700,
                          fontSize: 20.sp
                      )),
                  if(widget.showSubData)Text(widget.subData ?? " 2 choices",
                      style: TextStyle(
                          color: const Color(0xFF2F58CD),
                          fontFamily: "Recoleta",
                          fontWeight: FontWeight.w400,
                          fontSize: 13.sp
                      )),
                ],
              ),
              const Spacer(),
              widget.showDeleteButton? GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: widget.onDelete,
                child: SvgPicture.asset(
                  'assets/icons/Delete.svg',
                ),
              ):0.horizontalSpace,
              if(widget.isChecked)const Icon(Icons.check, color: const Color(0xFF2F58CD),)
            ],
          ),
        ),
      ),
    );
  }
}
