import 'package:flutter/material.dart';
import 'package:illuminate/common.dart';

class Dimensions {
  const Dimensions();

  static const double p4 = 4;
  static const double p8 = 8;
  static const double p12 = 12;
  static const double p16 = 16;
  static const double p20 = 20;
  static const double p24 = 24;

  static const radiusButton = 12.0;
  static const radiusInput = 12.0;
}

class AppColors {
  const AppColors();

  static final primary = MaterialColor(0xff5e72e4, const Color(0xff5e72e4).swatch());

  static const info = Colors.blue;
  static const error = Colors.red;
  static const destructive = Colors.red;
  static const success = Colors.green;
  static const warning = Colors.orange;

  static const backgroundColor = Color(0xfff8fafc);
}

class Strings {
  static const oauthAccessToken = 'oauthAccessToken';
  static const oauthRefreshToken = 'oauthRefreshToken';

  static const cloudLoggingServiceAccount = 'cloud-logging-service-account.json';

  static const storageKeyOnboardingFinished = 'keyOnboardingFinished';
  static const storageKeyLoggingIdentifier = 'keyCloudLoggingIdentifier';
}

class Font {
  const Font();

  static const String primaryFont = 'Inter Tight';
  static const String secondaryFont = 'Inter Tight';
}

class FontSize {
  const FontSize();

  static const double small = 14;
  static const double standard = 16;
  static const double button = 18;
  static const double title = 20;

  static const double lineHeight = 1.1;
}
