import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';

class ButtonWidget extends StatelessWidget {
  final String title;
  final Function()? onTap;
  final double? textSize;
  final double? borderWidth;
  final double? borderRadius;
  final double? blurRadius;
  final bool shouldSpread;
  final ColorEnums? backgroundColor;
  final ColorEnums? textColor;
  final ColorEnums? borderColor;

  const ButtonWidget({
    super.key,
    required this.title,
    this.onTap,
    this.textSize,
    this.borderRadius,
    this.blurRadius,
    this.borderWidth,
    this.shouldSpread = true,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return FlickerNeonContainer(
      width: double.infinity,
      containerColor: ColorUtils.getColor(
        context,
        backgroundColor ?? ColorEnums.purpleColor,
      ),
      flickerTimeInMilliSeconds: 0,
      borderRadius: BorderRadius.circular(
        borderRadius ?? Dimens.dimens_10.r,
      ),
      borderColor: ColorUtils.getColor(
        context,
        borderColor ?? ColorEnums.whiteColor,
      ),
      lightSpreadRadius: shouldSpread ? 10 : 0,
      lightBlurRadius: shouldSpread ? 60 : 0,
      borderWidth: borderWidth ?? Dimens.dimens_2.w,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(
            Dimens.dimens_10.r,
          ),
          onTap: onTap ?? () {},
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.dimens_15.w,
              vertical: Dimens.dimens_7.w,
            ),
            child: FlickerNeonText(
              text: title,
              flickerTimeInMilliSeconds: 0,
              textColor: ColorUtils.getColor(
                context,
                textColor ?? ColorEnums.whiteColor,
              ),
              spreadColor: Colors.purple,
              blurRadius: blurRadius ?? 20,
              textSize: textSize ?? Dimens.dimens_30.sp,
            ),
          ),
        ),
      ),
    );
  }
}
