import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:paraiso/util/theme/theme_constants.dart';

var darkTheme = ThemeData(
  // Define the default font family.
  fontFamily: 'Recoleta',
  // Define the default brightness and colors.
  brightness: Brightness.dark,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: neutralColor,

  splashColor: primaryColor.withOpacity(0.1),
  // button splash color

  useMaterial3: true,

  // Define the default `TextTheme`. Use this to specify the default
  // text styling for headlines, titles, bodies of text, and more.
  //
  // textTheme: Typography.material2021().englishLike.apply(
  //     fontFamily: 'Recoleta',
  //     bodyColor: secondaryColor,
  //     displayColor: onSecondaryColor,
  // fontSizeFactor: 1.sp,
  // ),
  textTheme: TextTheme(
    displayLarge: TextStyle(fontSize: 96.sp),
    displayMedium: TextStyle(fontSize: 72.sp),
    displaySmall: TextStyle(fontSize: 60.sp),
    headlineLarge: TextStyle(fontSize: 48.sp),
    headlineMedium: TextStyle(fontSize: 40.sp),
    headlineSmall: TextStyle(fontSize: 34.sp),
    titleLarge: TextStyle(fontSize: 30.sp),
    titleMedium: TextStyle(fontSize: 24.sp),
    titleSmall: TextStyle(fontSize: 20.sp),
    bodyLarge: TextStyle(fontSize: 18.sp),
    bodyMedium: TextStyle(fontSize: 16.sp),
    bodySmall: TextStyle(fontSize: 13.sp),
    labelSmall: TextStyle(fontSize: 10.sp),
  ).apply(
    fontFamily: 'Recoleta',
    bodyColor: onNeutralColor, //gray
    displayColor: white,
    fontSizeFactor: 1.sp,
  ),
  // https://stackoverflow.com/questions/67930143/the-argument-type-color-cant-be-assigned-to-the-parameter-type-materialcolo

  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: primaryColor,
    onPrimary: onPrimaryColor,
    primaryContainer: primaryColor,
    onPrimaryContainer: onPrimaryColor,
    secondary: primaryColor,
    onSecondary: onPrimaryColor,
    secondaryContainer: primaryColor,
    onSecondaryContainer: onPrimaryColor,
    tertiary: primaryColor,
    onTertiary: onPrimaryColor,
    tertiaryContainer: primaryColor,
    onTertiaryContainer: onPrimaryColor,
    error: neutralColor,
    onError: white,
    errorContainer: neutralColor,
    onErrorContainer: white,
    brightness: Brightness.dark,
    background: neutralColor,
    outline: primaryColor,
    // inverseSurface: onPrimaryColor,
    // surfaceTint: Color(0xFF000000),
    // onInverseSurface: primaryColor,
    // inversePrimary: onPrimaryColor,
    // shadow: Color(0xFF000000),
    // outlineVariant: Color(0xFF534341),
    // scrim: Color(0xFF000000),
    surface: neutralColor,
    onSurface: onNeutralColor,
    // surfaceVariant: Color(0xFF534341),
    // onSurfaceVariant: Color(0xFFD8C2BF),
  ),

  // BUTTON

  buttonTheme: ButtonThemeData(
    textTheme: ButtonTextTheme.normal,
    buttonColor: softBlack,
    splashColor: primaryColor.withOpacity(0.1),
    colorScheme: ColorScheme.fromSwatch().copyWith(
      // primary: onPrimaryColor,
      // secondary: softBlack,
      brightness: Brightness.dark,
      background: softBlack,
      //background color for widgets like Card, bottomNavigationBar,btns etc
      surface: softBlack,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(100.0),
    ),
    height: 60.h,
    padding: EdgeInsets.symmetric(
      vertical: 14.h,
      horizontal: 20.w,
    ),
  ),

  cardTheme: CardTheme(
    elevation: 0.6,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  ),
  // alert dialog
  dialogTheme: DialogTheme(
    backgroundColor: softBlack,
    shadowColor: Colors.black.withOpacity(0.8),
    actionsPadding: EdgeInsets.symmetric(horizontal: 60.w, vertical: 28.h),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22.r),
    ),
  ),

  iconTheme: IconThemeData(
    color: primaryColor,
  ),

  appBarTheme: AppBarTheme(
    elevation: 0.0,
    backgroundColor: primaryColor,
    titleTextStyle: TextStyle(
      color: onPrimaryColor,
    ),
    actionsIconTheme: IconThemeData(
      color: onNeutralColor,
    ),
    iconTheme: IconThemeData(
      color: onNeutralColor,
      size: 24,
    ),
  ),

  snackBarTheme: mySnackBarTheme(),
  checkboxTheme: myCheckBoxTheme(),

  // TEXT FIELD THEME
  inputDecorationTheme: myInputDecorationTheme(),
);

//font weights
var thin = FontWeight.w100;
var extraLight = FontWeight.w200;
var light = FontWeight.w300;
var regular = FontWeight.w400;
var medium = FontWeight.w500;
var semiBold = FontWeight.w600;
var bold = FontWeight.w700;
var extraBold = FontWeight.w800;
var black = FontWeight.w900;

// required, [optional, optional2], {default = true, }
InputDecoration myInputDecoration() {
  return InputDecoration(
    // 28.w
    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
    fillColor: softBlack,
    filled: true,
    hintStyle: TextStyle(color: softGray),
    errorStyle: TextStyle(color: dangerColor!),
    labelStyle: TextStyle(color: onNeutralColor),
    prefixStyle: TextStyle(color: onNeutralColor),
    // suffixStyle: TextStyle(color: primaryColor),
    border: myinputborder(),
    enabledBorder: myinputborder(),
    focusedBorder: myfocusborder(),
    errorBorder: myerrorborder(),
    focusedErrorBorder: myfocusederrorborder(),
    disabledBorder: mydisabledborder(),
  );
}

InputDecorationTheme myInputDecorationTheme([bool? isFocused]) {
  return InputDecorationTheme(
    // 28.w
    contentPadding: EdgeInsets.symmetric(vertical: 10.h),
    fillColor: softBlack,
    filled: true,
    hintStyle: TextStyle(color: softGray),
    errorStyle: TextStyle(color: dangerColor!),
    labelStyle: TextStyle(color: onNeutralColor),
    prefixStyle:
        // isFocused == true
        // ? TextStyle(color: primaryColor)
        // :
        TextStyle(color: onNeutralColor),
    suffixStyle: TextStyle(color: onNeutralColor),
    border: mydisabledborder(),
    enabledBorder: myinputborder(),
    focusedBorder: myfocusborder(),
    errorBorder: myerrorborder(),
    focusedErrorBorder: myfocusederrorborder(),
    disabledBorder: mydisabledborder(),
  );
}

//snackbar theme
SnackBarThemeData mySnackBarTheme() {
  return SnackBarThemeData(
    backgroundColor: neutralColor,
    contentTextStyle: TextStyle(color: onNeutralColor),
    actionTextColor: primaryColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0),
    ),
  );
}

CheckboxThemeData myCheckBoxTheme() {
  return CheckboxThemeData(
    fillColor: MaterialStateProperty.all(neutralColor),
    checkColor: MaterialStateProperty.all(onPrimaryColor),
    overlayColor: MaterialStateProperty.all(primaryColor.withOpacity(0.1)),
    splashRadius: 16,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
  );
}

// normal and enabled
OutlineInputBorder myinputborder() {
  //return type is OutlineInputBorder
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(50.0),
    borderSide: BorderSide(color: softBlack, width: 1),
  );
}

OutlineInputBorder mydisabledborder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(50.0),
    borderSide: BorderSide(color: onNeutralColor, width: 1),
  );
}

OutlineInputBorder myfocusborder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(50.0),
    borderSide: BorderSide(color: primaryColor, width: 1),
  );
}

OutlineInputBorder myerrorborder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(50.0),
    borderSide: BorderSide(color: onNeutralColor, width: 1),
  );
}

OutlineInputBorder myfocusederrorborder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(50.0),
    borderSide: BorderSide(color: onNeutralColor, width: 1),
  );
}
