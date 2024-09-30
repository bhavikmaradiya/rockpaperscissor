import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rockpaperscissor/const/dark_colors.dart';
import 'package:rockpaperscissor/const/light_colors.dart';

class ThemeConfig {
  static const dmSansFonts = 'DMSans';
  static const playFonts = 'Play';

  static ThemeData lightTheme = ThemeData(
    primaryColor: LightColors.themeColor,
    fontFamily: playFonts,
    scaffoldBackgroundColor: LightColors.whiteColor,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: LightColors.whiteColor,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark,
      ),
    ),
    brightness: Brightness.light,
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
        TargetPlatform.iOS: OpenUpwardsPageTransitionsBuilder(),
      },
    ),
  );

  static ThemeData darkTheme = ThemeData(
    primaryColor: DarkColors.themeColor,
    fontFamily: playFonts,
    scaffoldBackgroundColor: DarkColors.bgColor,
    brightness: Brightness.dark,
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: LightColors.transparentColor,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.light,
      ),
    ),
    useMaterial3: true,
    pageTransitionsTheme: const PageTransitionsTheme(builders: {
      TargetPlatform.android: OpenUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: OpenUpwardsPageTransitionsBuilder(),
    }),
  );
}
