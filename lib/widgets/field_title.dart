import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';

class FieldTitle extends StatelessWidget {
  final String title;
  final ColorEnums? textColorEnum;
  final double? textSize;

  const FieldTitle({
    required this.title,
    super.key,
    this.textSize,
    this.textColorEnum,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        color: ColorUtils.getColor(
          context,
          textColorEnum ?? ColorEnums.gray6CColor,
        ),
        fontSize: textSize ?? Dimens.dimens_15.sp,
      ),
    );
  }
}
