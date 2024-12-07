import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paraiso/util/theme/theme_constants.dart';

TextStyle textStyleWhite25700 = TextStyle(
  color: const Color(0xFFE4E4E4),
  fontSize: 25.sp,
  fontFamily: 'Recoleta',
  fontWeight: FontWeight.w700,
);

TextStyle textStyleWhite20700 = TextStyle(
  color: const Color(0xFFE4E4E4),
  fontSize: 20.sp,
  fontFamily: 'Recoleta',
  fontWeight: FontWeight.w700,
);

TextStyle textStyleWhite30700 = TextStyle(
  color: const Color(0xFFE4E4E4),
  fontSize: 30.sp,
  fontFamily: 'Recoleta',
  fontWeight: FontWeight.w700,
);

TextStyle textStyleWhite16400 = TextStyle(
  color: const Color(0xFFE4E4E4),
  fontSize: 16.sp,
  fontFamily: 'Recoleta',
  fontWeight: FontWeight.w400,
);

TextStyle textStyleWhite16700 = TextStyle(
  color: const Color(0xFFE4E4E4),
  fontSize: 16.sp,
  fontFamily: 'Recoleta',
  fontWeight: FontWeight.w700,
);

TextStyle textStyleWhite18700 = TextStyle(
  color: const Color(0xFFE4E4E4),
  fontSize: 18.sp,
  fontFamily: 'Recoleta',
  fontWeight: FontWeight.w700,
);

TextStyle textStyleWhite18900 = TextStyle(
  color: const Color(0xFFE4E4E4),
  fontSize: 18.sp,
  fontFamily: 'Recoleta',
  fontWeight: FontWeight.w900,
);

class MyDropDownList1 extends StatefulWidget {
  final String hint;
  final String selectedValue;
  final List<String> items;
  final void Function(String?)? onChanged;
  const MyDropDownList1({Key? key, required this.hint, required this.selectedValue, required this.items, this.onChanged}) : super(key: key);

  @override
  State<MyDropDownList1> createState() => _MyDropDownList1State();
}

class _MyDropDownList1State extends State<MyDropDownList1> {
  bool isOpen = false;
  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        onMenuStateChange: (state) {
          setState(() {
            isOpen = state;
          });
        },
        isExpanded: true,
        hint: Text(
          widget.selectedValue == '' ? widget.hint : widget.selectedValue,
          style: textStyleWhite16400,
          overflow: TextOverflow.ellipsis,
        ),
        items: widget.items
            .map((String item) => DropdownMenuItem<String>(
                  value: item,
                  child: Container(
                    width: 352.w,
                    height: 43.h,
                    decoration: BoxDecoration(
                      color: widget.selectedValue != item ? softBlack.withOpacity(0.10) : softGray,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Row(
                        children: [
                          SizedBox(
                            width: 10.w,
                          ),
                          Text(
                            item,
                            style: widget.selectedValue == item ? textStyleWhite16400 : textStyleWhite16400,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ))
            .toList(),
        onChanged: widget.onChanged,
        buttonStyleData: ButtonStyleData(
          width: 380.w,
          height: 60.h,
          padding: EdgeInsets.only(left: 20.w, right: 22.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22.r),
            border: null,
            color: softBlack,
          ),
          elevation: 0,
        ),
        iconStyleData: IconStyleData(
          icon: isOpen ? const Icon(Icons.arrow_downward_sharp) : const Icon(Icons.arrow_upward_sharp),
          iconSize: 10,
          iconEnabledColor: Colors.white,
          iconDisabledColor: Colors.white,
        ),
        dropdownStyleData: DropdownStyleData(
          elevation: 0,
          maxHeight: 240.h,
          width: 370.w,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: softBlack,
            boxShadow: const [
              BoxShadow(
                color: Color(0x1E000000),
                blurRadius: 4,
                offset: Offset(0, 4),
                spreadRadius: 0,
              )
            ],
          ),
          offset: const Offset(3, -5),
          scrollbarTheme: ScrollbarThemeData(
            radius: Radius.circular(40.r),
            thickness: MaterialStateProperty.all(0),
            thumbVisibility: MaterialStateProperty.all(false),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.only(left: 14, right: 14),
        ),
      ),
    );
  }
}

class MyCartTile extends StatefulWidget {
  final String itemReward;
  final String itemName;
  final String itemPrice;
  final String itemQuantity;
  final String itemSize;
  final String itemImage;
  final void Function() onIncrement;
  final void Function() onDecrement;
  const MyCartTile(
      {Key? key,
      required this.itemName,
      required this.itemPrice,
      required this.itemQuantity,
      required this.itemSize,
      required this.onIncrement,
      required this.onDecrement,
      required this.itemImage,
      required this.itemReward})
      : super(key: key);

  @override
  State<MyCartTile> createState() => _MyCartTileState();
}

class _MyCartTileState extends State<MyCartTile> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              height: 99.h,
              width: 99.w,
              decoration: BoxDecoration(
                color: softBlack,
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Image.network(
                widget.itemImage,
                fit: BoxFit.fill,
              ),
            ),
            SizedBox(width: 20.w),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 200.w,
                  child: Text(
                    "${widget.itemName} (${widget.itemSize})",
                    style: textStyleWhite18700,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '${widget.itemPrice}€',
                  style: textStyleWhite18700,
                ),
                SizedBox(height: 13.h),
                SizedBox(
                  width: 87.w,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                          height: 22.h,
                          width: 22.w,
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 97, 84, 0.1),
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: widget.onDecrement,
                            icon: Icon(
                              size: 14.sp,
                              Icons.remove,
                              color: const Color(0xFF2F58CD),
                            ),
                          )),
                      Text(
                        widget.itemQuantity,
                        style: textStyleWhite20700,
                      ),
                      Container(
                          height: 22.h,
                          width: 22.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2F58CD),
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            onPressed: widget.onIncrement,
                            icon: Icon(
                              size: 14.sp,
                              Icons.add,
                              color: Colors.white,
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            Text(
              "+${widget.itemReward}",
              style: textStyleWhite18700,
            ),
            SizedBox(
              width: 5.w,
            ),
            SvgPicture.asset(
              "assets/images/Food Filter_OBJECTS_458_13901.svg",
              width: 20.w,
            ),
          ],
        ),
        // Checkbox(
        //     value: isChecked,
        //     side: const BorderSide(color: Color.fromRGBO(189, 189, 189, 1)),
        //     activeColor: Color.fromRGBO(76, 228, 128, 1),
        //     checkColor: Colors.black,
        //     onChanged: (val){
        //       setState(() {
        //         isChecked = val!;
        //       });
        //
        //     })
      ],
    );
  }
}
