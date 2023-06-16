import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:ttt/constants/constants.dart';

class HeaderTextStyle extends TextStyle {
  const HeaderTextStyle({
    Color color = Colors.black87,
    FontWeight fontWeight = FontWeight.bold,
    double? fontSize,
    double? letterSpacing,
  }) : super(
          color: color,
          fontFamily: Font.primaryFont,
          fontWeight: fontWeight,
          fontSize: fontSize ?? FontSize.standard,
          letterSpacing: letterSpacing,
        );
}

class BaseTextStyle extends TextStyle {
  const BaseTextStyle({
    Color color = Colors.black87,
    FontWeight fontWeight = FontWeight.normal,
    double? fontSize,
    double? lineHeight,
    double? letterSpacing,
    List<FontFeature>? fontFeatures,
  }) : super(
          color: color,
          fontFamily: Font.primaryFont,
          fontWeight: fontWeight,
          fontSize: fontSize ?? FontSize.standard,
          letterSpacing: letterSpacing,
          fontFeatures: fontFeatures,
        );
}
