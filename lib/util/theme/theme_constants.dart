import 'package:flutter/material.dart';

// var primaryColor = const Color(0xFFFF6154);
var primaryColor = const Color(0xFF2F58CD);
var onPrimaryColor = const Color(0xFFE5E5E5);
// var secondaryColor = const Color(0xFFFF6154);
var secondaryColor = const Color(0xFF2F58CD);
var onSecondaryColor = const Color(0xFFE5E5E5);
var white = const Color(0xFFE5E5E5);
// var accentColor = const Color(0xFFFF6154);

//background
// var neutralColor = const Color(0xFF2A2A2A); // black

var neutralColor = const Color(0xFF1C1C1C); // black
var softBlack = const Color(0xFF353535);
var onNeutralColor = const Color(0xFFBDBDBD); //gray
var softGray = const Color(0xFFBDBDBD).withOpacity(.5);

var halfPadding = 8.0;
var quarterPadding = 4.0;
var defaultPadding = 16.0;
var doublePadding = 32.0;
var triplePadding = 48.0;
var quadruplePadding = 64.0;
var sextuplePadding = 96.0;
var octuplePadding = 128.0;

var dangerColor = Colors.red[300];
var successColor = Colors.green[300];
var infoColor = Colors.blue[300];
var warningColor = Colors.orange[300];
var disabledColor = Colors.grey[300];

var disabledTextColor = Colors.grey[800];


List<BoxShadow> shadowList = [
  BoxShadow(
    color: Colors.grey[400]!,
    blurRadius: 30,
    offset: const Offset(0, 10),
  )
];

const double xs = 28;
const double sm = 38;
const double md = 50;
const double lg = 60;
const double xl = 70;

// ScreenUtil().setWidth(540)  (dart sdk>=2.6 : 540.w) //Adapted to screen width
// ScreenUtil().setHeight(200) (dart sdk>=2.6 : 200.h) //Adapted to screen height , under normal circumstances, the height still uses x.w
// ScreenUtil().radius(200)    (dart sdk>=2.6 : 200.r)    //Adapt according to the smaller of width or height
// ScreenUtil().setSp(24)      (dart sdk>=2.6 : 24.sp) //Adapter font
// 12.sm   //return min(12,12.sp)
//
// ScreenUtil().pixelRatio       //Device pixel density
// ScreenUtil().screenWidth   (dart sdk>=2.6 : 1.sw)    //Device width
// ScreenUtil().screenHeight  (dart sdk>=2.6 : 1.sh)    //Device height
// ScreenUtil().bottomBarHeight  //Bottom safe zone distance, suitable for buttons with full screen
// ScreenUtil().statusBarHeight  //Status bar height , Notch will be higher
// ScreenUtil().textScaleFactor  //System font scaling factor
//
// ScreenUtil().scaleWidth //The ratio of actual width to UI design
// ScreenUtil().scaleHeight //The ratio of actual height to UI design
//
// ScreenUtil().orientation  //Screen orientation
// 0.2.sw  //0.2 times the screen width
// 0.5.sh  //50% of screen height
// 20.setVerticalSpacing  // SizedBox(height: 20 * scaleHeight)
// 20.horizontalSpace  // SizedBox(height: 20 * scaleWidth)
// const RPadding.all(8)   // Padding.all(8.r) - take advantage of const key word
// EdgeInsets.all(10).w    //EdgeInsets.all(10.w)
// REdgeInsets.all(8)       // EdgeInsets.all(8.r)
// EdgeInsets.only(left:8,right:8).r // EdgeInsets.only(left:8.r,right:8.r).
// BoxConstraints(maxWidth: 100, minHeight: 100).w    //BoxConstraints(maxWidth: 100.w, minHeight: 100.w)
// Radius.circular(16).w          //Radius.circular(16.w)
// BorderRadius.all(Radius.circular(16)).w
