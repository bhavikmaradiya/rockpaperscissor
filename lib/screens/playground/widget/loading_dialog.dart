import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/const/assets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';

class LoadingDialog extends StatelessWidget {
  final String animation;
  final String subtitle;
  final String? title;

  const LoadingDialog({
    super.key,
    this.animation = Assets.handAnimation,
    required this.subtitle,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return FlickerNeonContainer(
      containerColor: ColorUtils.getColor(
        context,
        ColorEnums.darkPurpleColor,
      ),
      margin: EdgeInsets.symmetric(
        horizontal: Dimens.dimens_25.w,
      ),
      flickerTimeInMilliSeconds: 0,
      borderRadius: BorderRadius.circular(
        Dimens.dimens_10.r,
      ),
      lightSpreadRadius: 10,
      lightBlurRadius: 20,
      spreadColor: ColorUtils.getColor(
        context,
        ColorEnums.darkPurpleColor,
      ).withOpacity(0.5),
      borderWidth: Dimens.dimens_1_5.w,
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.dimens_40.w,
        vertical: Dimens.dimens_30.h,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null)
            Text(
              title!,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimens.dimens_27.sp,
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.grayF5Color,
                ).withOpacity(0.9),
                fontWeight: FontWeight.bold,
              ),
            ),
          Lottie.asset(
            animation,
            height: Dimens.dimens_170.w,
            width: Dimens.dimens_170.w,
          ),
          Flexible(
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: Dimens.dimens_23.sp,
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.grayF5Color,
                ).withOpacity(0.9),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
