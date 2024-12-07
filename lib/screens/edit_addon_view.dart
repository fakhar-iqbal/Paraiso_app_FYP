import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:paraiso/util/theme/theme_constants.dart';

import 'addon_view.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EditAddonView extends StatefulWidget {
  final List<Addon> addons;
  final ValueChanged<List<Addon>> onAddonsChanged;
  final ValueChanged<List<Map<String, dynamic>>> onAddonadded;
  final List<dynamic> addOnsData;

  const EditAddonView({
    Key? key,
    required this.addons,
    required this.onAddonsChanged,
    required this.onAddonadded,
    required this.addOnsData,
  }) : super(key: key);

  @override
  _EditAddonViewState createState() => _EditAddonViewState();
}

class _EditAddonViewState extends State<EditAddonView> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController descController = TextEditingController();
  List<bool> requiredFlags = [];

  List<Map<String, dynamic>> addOns = [];

  @override
  void initState() {
    // setState(() {
    //   requiredFlags = widget.addons.map((e) => e.expanded).toList();
    //   for (final addon in widget.addOnsData) {
    //     addOns.add(addon);
    //   }
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < widget.addons.length; i++) ...[
          _buildAddonItem(i),
        ]
      ],
    );
  }

  Widget _buildAddonItem(int index) {
    if (kDebugMode) print("_buildAddonItem called!");
    final addon = widget.addons[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (addon.expanded == false && index == widget.addons.length - 1) {
                addon.expanded = !addon.expanded;
                final newAddon = Addon(expanded: false);
                final updatedAddons = List<Addon>.from(widget.addons)..add(newAddon);
                widget.onAddonsChanged(updatedAddons);
                // adding new addon
                requiredFlags.add(false);
                addOns.add({
                  "name": nameController.text,
                  "price": priceController.text,
                  "description": descController.text,
                  "required": requiredFlags[index],
                });
                widget.onAddonadded(addOns);
              } else {
                if (addon.expanded == true) {
                  if (addOns.length == 1) {
                    if (kDebugMode) print("last one!!!!!!");
                  } else {
                    addOns.removeAt(index);
                    widget.addons.removeAt(index);
                    widget.onAddonsChanged(widget.addons);
                    widget.onAddonadded(addOns);
                  }
                } else {
                  requiredFlags.add(false);
                  addOns.add({
                    "name": nameController.text,
                    "price": priceController.text,
                    "description": descController.text,
                    "required": requiredFlags[index],
                  });
                  widget.onAddonadded(addOns);
                }
                addon.expanded = !addon.expanded;
              }
            });
          },
          child: Container(
            padding: addon.expanded ? const EdgeInsets.symmetric(vertical: 0.0) : const EdgeInsets.symmetric(vertical: 5.0),
            child: TextFormField(
              enabled: false,
              style: TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 16.sp,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                suffixIcon: addon.expanded
                    ? Icon(
                        Icons.remove_circle_outline,
                        color: primaryColor,
                      )
                    : const Icon(Icons.add_box_outlined),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                hintText: addon.expanded ? AppLocalizations.of(context)!.discardAddon : AppLocalizations.of(context)!.clickHereToAddAddon,
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 16.sp,
                  color: addon.expanded ? primaryColor : Colors.white,
                ),
              ),
            ),
          ),
        ),
        if (addon.expanded)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        // controller: nameController,
                        initialValue: addOns[index]['name'],
                        onChanged: (value) {
                          addOns[index]["name"] = value;
                          widget.onAddonadded(addOns);
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                          hintText: AppLocalizations.of(context)!.addonName,
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Expanded(
                      child: TextFormField(
                        // controller: priceController,
                        initialValue: addOns[index]['price'] != null ? addOns[index]['price'].toString() : "",
                        onChanged: (value) {
                          addOns[index]["price"] = value;
                          widget.onAddonadded(addOns);
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                          hintText: AppLocalizations.of(context)!.addonPrice,
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10.h,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        // controller: descController,
                        initialValue: addOns[index]['description'],
                        onChanged: (value) {
                          addOns[index]["description"] = value;
                          widget.onAddonadded(addOns);
                        },
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 16.sp,
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
                          hintText: AppLocalizations.of(context)!.description,
                          hintStyle: TextStyle(
                            fontWeight: FontWeight.w400,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10.w,
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(child: Padding(padding: EdgeInsets.symmetric(horizontal: 10.w), child: Text(AppLocalizations.of(context)!.required))),
                          Expanded(
                            child: Checkbox(
                              activeColor: primaryColor,
                              side: BorderSide(color: softBlack),
                              value: requiredFlags[index],
                              onChanged: (value) {
                                setState(() {
                                  requiredFlags[index] = !requiredFlags[index];
                                });
                                addOns[index]["required"] = value;
                                widget.onAddonadded(addOns);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Widget _buildAddButton() {
  //   print("_buildAddButton called!");
  //   return GestureDetector(
  //     onTap: () {
  //       final newAddon = Addon(expanded: true);
  //       final updatedAddons = List<Addon>.from(widget.addons)..add(newAddon);
  //       widget.onAddonsChanged(updatedAddons);
  //     },
  //     child: SizedBox(
  //       child: TextFormField(
  //         enabled: false,
  //         style: TextStyle(
  //           fontWeight: FontWeight.w400,
  //           fontSize: 16.sp,
  //           color: Colors.white,
  //         ),
  //         decoration: InputDecoration(
  //           suffixIcon: const Icon(Icons.add_box_outlined),
  //           contentPadding: EdgeInsets.symmetric(horizontal: 20.w),
  //           hintText: 'Click here to add addon',
  //           hintStyle: TextStyle(
  //             fontWeight: FontWeight.w400,
  //             fontSize: 16.sp,
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
