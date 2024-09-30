import 'package:flutter/material.dart';
import 'package:rockpaperscissor/const/dark_colors.dart';
import 'package:rockpaperscissor/const/light_colors.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';

class ColorUtils {
  static bool isAppDarkMode(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  static Color getColor(BuildContext context, ColorEnums colorEnum) {
    final isDarkMode = isAppDarkMode(context);
    Color color;
    switch (colorEnum) {
      case ColorEnums.themeColor:
        {
          color = isDarkMode ? DarkColors.themeColor : LightColors.themeColor;
          break;
        }
      case ColorEnums.whiteColor:
        {
          color = isDarkMode ? DarkColors.whiteColor : LightColors.whiteColor;
          break;
        }
      case ColorEnums.blackColor:
        {
          color = isDarkMode ? DarkColors.blackColor : LightColors.blackColor;
          break;
        }
      case ColorEnums.black33Color:
        {
          color =
              isDarkMode ? DarkColors.black33Color : LightColors.black33Color;
          break;
        }
      case ColorEnums.gray6CColor:
        {
          color = isDarkMode ? DarkColors.gray6CColor : LightColors.gray6CColor;
          break;
        }
      case ColorEnums.gray99Color:
        {
          color = isDarkMode ? DarkColors.gray99Color : LightColors.gray99Color;
          break;
        }
      case ColorEnums.statusBarColor:
        {
          color = isDarkMode
              ? DarkColors.statusBarColor
              : LightColors.statusBarColor;
          break;
        }
      case ColorEnums.grayF5Color:
        {
          color = isDarkMode ? DarkColors.grayF5Color : LightColors.grayF5Color;
          break;
        }
      case ColorEnums.grayE0Color:
        {
          color = isDarkMode ? DarkColors.grayE0Color : LightColors.grayE0Color;
          break;
        }
      case ColorEnums.black1AColor:
        {
          color =
              isDarkMode ? DarkColors.black1AColor : LightColors.black1AColor;
          break;
        }
      case ColorEnums.redColor:
        {
          color = isDarkMode ? DarkColors.redColor : LightColors.redColor;
          break;
        }
      case ColorEnums.blueColor:
        {
          color = isDarkMode ? DarkColors.blueColor : LightColors.blueColor;
          break;
        }
      case ColorEnums.blueE6F1F9Color:
        {
          color = isDarkMode
              ? DarkColors.blueE6F1F9Color
              : LightColors.blueE6F1F9Color;
          break;
        }
      case ColorEnums.redFFE3E3Color:
        {
          color = isDarkMode
              ? DarkColors.redFFE3E3Color
              : LightColors.redFFE3E3Color;
          break;
        }
      case ColorEnums.amberF59032Color:
        {
          color = isDarkMode
              ? DarkColors.amberF59032Color
              : LightColors.amberF59032Color;
          break;
        }
      case ColorEnums.greenF2FCF3Color:
        {
          color = isDarkMode
              ? DarkColors.greenF2FCF3Color
              : LightColors.greenF2FCF3Color;
          break;
        }
        case ColorEnums.greenColor:
        {
          color = isDarkMode
              ? DarkColors.greenColor
              : LightColors.greenColor;
          break;
        }
      case ColorEnums.redFDF3F3Color:
        {
          color = isDarkMode
              ? DarkColors.redFDF3F3Color
              : LightColors.redFDF3F3Color;
          break;
        }
      case ColorEnums.grayEAColor:
        {
          color = isDarkMode ? DarkColors.grayEAColor : LightColors.grayEAColor;
          break;
        }
      case ColorEnums.grayD9Color:
        {
          color = isDarkMode ? DarkColors.grayD9Color : LightColors.grayD9Color;
          break;
        }
      case ColorEnums.grayA8Color:
        {
          color = isDarkMode ? DarkColors.grayA8Color : LightColors.grayA8Color;
          break;
        }

      case ColorEnums.blackColor5Opacity:
        {
          color = isDarkMode
              ? DarkColors.blackColor5Opacity
              : LightColors.blackColor5Opacity;
          break;
        }
      case ColorEnums.transparentColor:
        {
          color = isDarkMode
              ? DarkColors.transparentColor
              : LightColors.transparentColor;
          break;
        }
      case ColorEnums.purpleColor:
        {
          color = isDarkMode ? DarkColors.bgColor : DarkColors.bgColor;
          break;
        }
      case ColorEnums.darkPurpleColor:
        {
          color = isDarkMode
              ? DarkColors.darkPurpleColor
              : DarkColors.darkPurpleColor;
          break;
        }
      case ColorEnums.lightPurple2Color:
        {
          color = isDarkMode
              ? DarkColors.lightPurple2Color
              : DarkColors.lightPurple2Color;
          break;
        }
      case ColorEnums.lightPurpleColor:
        {
          color = isDarkMode
              ? DarkColors.lightPurpleColor
              : DarkColors.lightPurpleColor;
          break;
        }
      case ColorEnums.neonBlueColor:
        {
          color =
              isDarkMode ? DarkColors.neonBlueColor : DarkColors.neonBlueColor;
          break;
        }
        case ColorEnums.lightYellowColor:
        {
          color =
              isDarkMode ? DarkColors.lightYellowColor : DarkColors.lightYellowColor;
          break;
        }
        case ColorEnums.lightYellowColor2:
        {
          color =
              isDarkMode ? DarkColors.lightYellowColor2 : DarkColors.lightYellowColor2;
          break;
        }
      default:
        {
          color = isDarkMode ? DarkColors.themeColor : LightColors.themeColor;
          break;
        }
    }
    return color;
  }
}
