import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const fontFamily = 'Outfit';

  static const display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 40,
    height: 1.12,
    fontWeight: FontWeight.w700,
    letterSpacing: -1.2,
  );
  static const headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    height: 1.2,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );
  static const headlineSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 1.25,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
  );
  static const title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.3,
    fontWeight: FontWeight.w600,
  );
  static const subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.45,
    fontWeight: FontWeight.w500,
  );
  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );
  static const bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.45,
    fontWeight: FontWeight.w400,
  );
  static const label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.25,
    fontWeight: FontWeight.w600,
  );
  static const caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.35,
    fontWeight: FontWeight.w400,
  );

  static TextTheme textTheme(Color primary, Color secondary) => TextTheme(
    displayLarge: display.copyWith(color: primary),
    displayMedium: display.copyWith(fontSize: 36, color: primary),
    displaySmall: headline.copyWith(fontSize: 32, color: primary),
    headlineLarge: headline.copyWith(color: primary),
    headlineMedium: headlineSmall.copyWith(color: primary),
    headlineSmall: headlineSmall.copyWith(fontSize: 22, color: primary),
    titleLarge: title.copyWith(fontSize: 22, color: primary),
    titleMedium: subtitle.copyWith(color: primary),
    titleSmall: label.copyWith(color: primary),
    bodyLarge: body.copyWith(color: primary),
    bodyMedium: bodySmall.copyWith(fontSize: 14, color: primary),
    bodySmall: caption.copyWith(color: secondary),
    labelLarge: label.copyWith(color: primary),
    labelMedium: caption.copyWith(fontSize: 11, color: secondary),
    labelSmall: caption.copyWith(fontSize: 10, color: secondary),
  );
}
