import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';

class ToastWidget extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const ToastWidget({
    super.key,
    required this.message,
    this.isSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    return FlickerNeonContainer(
      containerColor: ColorUtils.getColor(
        context,
        isSuccess ? ColorEnums.greenColor : ColorEnums.redColor,
      ),
      spreadColor: ColorUtils.getColor(
        context,
        isSuccess ? ColorEnums.greenColor : ColorEnums.redColor,
      ),
      flickerTimeInMilliSeconds: 0,
      borderRadius: BorderRadius.circular(
        Dimens.dimens_10.r,
      ),
      lightBlurRadius: 100,
      borderColor: ColorUtils.getColor(
        context,
        ColorEnums.whiteColor,
      ),
      borderWidth: Dimens.dimens_2.w,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.dimens_15.w,
          vertical: Dimens.dimens_7.w,
        ),
        child: FlickerNeonText(
          text: message,
          flickerTimeInMilliSeconds: 0,
          textColor: ColorUtils.getColor(
            context,
            isSuccess ? ColorEnums.whiteColor :ColorEnums.whiteColor,
          ),
          spreadColor: Colors.transparent,
          blurRadius: 010,
          textSize: Dimens.dimens_20.sp,
        ),
      ),
    );
  }
}
