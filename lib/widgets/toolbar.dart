import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';
import 'package:rockpaperscissor/utils/sound_utils.dart';

class ToolbarWidget extends StatelessWidget {
  final String title;
  final Function() onTap;

  const ToolbarWidget({
    super.key,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: Dimens.dimens_10.w,
        vertical: Dimens.dimens_12.h,
      ),
      child: Row(
        children: [
          FlickerNeonContainer(
            containerColor: ColorUtils.getColor(
              context,
              ColorEnums.purpleColor,
            ),
            flickerTimeInMilliSeconds: 0,
            borderRadius: BorderRadius.circular(
              Dimens.dimens_20.r,
            ),
            borderColor: ColorUtils.getColor(
              context,
              ColorEnums.whiteColor,
            ),
            lightSpreadRadius: 0,
            lightBlurRadius: 0,
            borderWidth: Dimens.dimens_1.w,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  Dimens.dimens_20.r,
                ),
                onTap: onTap,
                child: Padding(
                  padding: EdgeInsets.all(
                    Dimens.dimens_10.r,
                  ),
                  child: const Icon(
                    Icons.arrow_back_sharp,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: Dimens.dimens_20.w,
          ),
          FlickerNeonText(
            text: title,
            flickerTimeInMilliSeconds: 0,
            textColor: ColorUtils.getColor(
              context,
              ColorEnums.whiteColor,
            ),
            textOverflow: TextOverflow.ellipsis,
            spreadColor: Colors.white,
            blurRadius: 10,
            textSize: Dimens.dimens_35.sp,
          ),
        ],
      ),
    );
  }
}
