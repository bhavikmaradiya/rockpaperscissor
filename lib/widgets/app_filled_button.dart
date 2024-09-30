
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';

class AppFilledButton extends StatelessWidget {
  final String title;
  final void Function() onButtonPressed;
  final bool enabled;
  final Color? backgroundColor;
  final Color? textColor;

  const AppFilledButton({
    required this.title,
    required this.onButtonPressed,
    this.enabled = true,
    this.backgroundColor,
    this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: Dimens.dimens_50.h,
      child: FilledButton(
        onPressed: enabled ? onButtonPressed : null,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor ??
              ColorUtils.getColor(
                context,
                ColorEnums.gray99Color,
              ).withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(
                Dimens.dimens_5.r,
              ),
            ),
          ),
          disabledBackgroundColor: ColorUtils.getColor(
            context,
            ColorEnums.gray6CColor,
          ).withOpacity(0.4),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: textColor ??
                ColorUtils.getColor(
                  context,
                  enabled ? ColorEnums.whiteColor : ColorEnums.grayA8Color,
                ),
            fontWeight: FontWeight.w700,
            fontSize: Dimens.dimens_20.sp,
          ),
        ),
      ),
    );
  }
}
