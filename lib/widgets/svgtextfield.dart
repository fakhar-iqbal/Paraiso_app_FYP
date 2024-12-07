import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:paraiso/util/theme/theme.dart';
import 'package:paraiso/util/theme/theme_constants.dart';
import 'package:velocity_x/velocity_x.dart';

// uses widget as the prefix icon
class SvgTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final bool hasError;
  final String errorText;
  final TextInputType? textInputType;
  final bool enabled;
  final bool obscureText;
  final bool isPasswordField;
  final String? Function(String?)? validator;
  final String? label;
  final Color? color;
  final int? maxLength;
  final int? maxLines;
  final Widget? suffixIcon;
  final String? prefixIcon;
  final List<TextInputFormatter>? textInputFormatter;

  const SvgTextField({
    Key? key,
    this.controller,
    this.hintText,
    this.hasError = false,
    this.errorText = '',
    this.textInputType,
    this.enabled = true,
    this.obscureText = false,
    this.isPasswordField = false,
    this.validator,
    this.label,
    this.color,
    this.maxLength,
    this.suffixIcon,
    this.prefixIcon,
    this.maxLines = 1,
    this.textInputFormatter,
  }) : super(key: key);

  @override
  State<SvgTextField> createState() => _SvgTextFieldState();
}

class _SvgTextFieldState extends State<SvgTextField> {
  bool obscureText = true;

  final FocusNode _focusNode = FocusNode();
  bool textFieldHasFocus = false;

  InputBorder inputBorder = OutlineInputBorder(borderRadius: BorderRadius.circular(50), borderSide: BorderSide(color: softGray, width: 1));

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        textFieldHasFocus = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: 90.h,
        minHeight: 60.h,
        minWidth: 200.w,
        maxWidth: 379.w,
      ),
      child: TextFormField(
        focusNode: _focusNode,
        onChanged: (value) {
          setState(() {
            // widget.controller!.text = value;
          });
        },
        autofocus: false,
        decoration: myInputDecoration().copyWith(

          contentPadding: widget.prefixIcon != null ? EdgeInsets.symmetric(horizontal: 10.w) : EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          // fillColor: widget.color ?? context.theme.inputDecorationTheme.fillColor,
          // contentPadding: EdgeInsets.symmetric(vertical: 10.h),
          hintText: widget.hintText,
          labelText: widget.label,
          errorText: widget.hasError ? widget.errorText : null,
          // prefixStyle: false
          // ? TextStyle(color: primaryColor)
          // : TextStyle(color: onNeutralColor),
          prefixIconColor: MaterialStateColor.resolveWith(
            (states) => states.contains(MaterialState.focused) ? primaryColor : onNeutralColor,
          ),
          suffixIcon: widget.isPasswordField
              ? IconButton(
                  icon: obscureText
                      ? Icon(
                          Icons.visibility_outlined,
                          color: primaryColor,
                        )
                      : Icon(Icons.visibility_off_outlined, color: primaryColor),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  })
              : widget.suffixIcon,
          prefixIcon: widget.prefixIcon != null
              ? SvgPicture.asset(
                  widget.prefixIcon!,
                  color: textFieldHasFocus ? primaryColor : onNeutralColor,
                ).pLTRB(20.w, 0, 12.w, 0)
              : const SizedBox.shrink(),
          prefixIconConstraints: BoxConstraints(
            minWidth: 18.w,
            minHeight: 18.h,
          ),
        ),
        style: context.textTheme.bodyLarge!.copyWith(
          fontSize: 18.sp,
          // height: 2.h,
        ),
        enabled: widget.enabled,
        controller: widget.controller,
        keyboardType: widget.textInputType,
        obscureText: widget.isPasswordField ? obscureText : widget.obscureText,
        inputFormatters: widget.textInputFormatter,
        validator: widget.validator,
        // autovalidateMode: AutovalidateMode.onUserInteraction,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
      ),
    );
  }
}
