import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/config/theme_config.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PopupDialog extends StatelessWidget {
  final String title;
  final String? subTitle;
  final Widget? content;

  const PopupDialog({
    super.key,
    required this.title,
    this.subTitle,
    this.content,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    return AnimatedPadding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 40,
      ),
      duration: const Duration(
        milliseconds: 100,
      ),
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: FlickerNeonContainer(
            containerColor: ColorUtils.getColor(
              context,
              ColorEnums.darkPurpleColor,
            ),
            margin: EdgeInsets.symmetric(
              horizontal: Dimens.dimens_25.w,
            ),
            width: double.infinity,
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: Dimens.dimens_13.h,
                    horizontal: Dimens.dimens_5.w,
                  ),
                  width: double.infinity,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        ColorUtils.getColor(
                          context,
                          ColorEnums.lightPurpleColor,
                        ).withOpacity(0.8),
                        ColorUtils.getColor(
                          context,
                          ColorEnums.lightPurple2Color,
                        ),
                      ],
                      end: Alignment.bottomCenter,
                      begin: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(
                        Dimens.dimens_10.r,
                      ),
                    ),
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: Dimens.dimens_27.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimens.dimens_27.w,
                      vertical: Dimens.dimens_20.h,
                    ),
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        if (subTitle != null)
                          Text(
                            subTitle!,
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
                        if (subTitle != null && content != null)
                          SizedBox(
                            height: Dimens.dimens_30.h,
                          ),
                        content ?? const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
