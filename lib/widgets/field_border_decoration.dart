
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';

class FieldBorderDecoration {
  static InputDecoration fieldBorderDecoration(
    BuildContext context, {
    double contentPadding = 0,
    double? borderRadius,
    ColorEnums fillColor = ColorEnums.whiteColor,
    ColorEnums borderColor = ColorEnums.grayE0Color,
    bool isMultiLine = false,
    Widget? suffixIcon,
    String? hint,
    TextStyle? hintStyle,
        double? borderWidth,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: hintStyle,
      fillColor: ColorUtils.getColor(
        context,
        fillColor,
      ),
      enabledBorder: _fieldBorder(
        context,
        borderColor: borderColor,
        borderRadius: borderRadius,
        borderWidth: borderWidth,
      ),
      disabledBorder: _fieldBorder(
        context,
        borderColor: borderColor,
        borderRadius: borderRadius,
        borderWidth: borderWidth,
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: ColorUtils.getColor(
            context,
            ColorEnums.black33Color,
          ),
          width: Dimens.dimens_1.w,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(
            borderRadius ?? Dimens.dimens_5.r,
          ),
        ),
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: contentPadding.w,
        vertical: isMultiLine ? contentPadding.h : 0,
      ),
      suffixIcon: suffixIcon,
      filled: true,
    );
  }

  static OutlineInputBorder _fieldBorder(
    BuildContext context, {
    ColorEnums borderColor = ColorEnums.grayE0Color,
    double? borderRadius,
    double? borderWidth,
  }) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(
        Radius.circular(
          borderRadius ?? Dimens.dimens_5.r,
        ),
      ),
      borderSide: BorderSide(
        color: ColorUtils.getColor(
          context,
          borderColor,
        ),
        width: borderWidth ?? Dimens.dimens_1.w,
      ),
    );
  }
}
