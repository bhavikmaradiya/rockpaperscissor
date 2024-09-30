import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';
import 'package:rockpaperscissor/widgets/field_border_decoration.dart';
import 'package:rockpaperscissor/widgets/field_title.dart';

import 'keyboard_action/keyboard_actions.dart';

class AppTextField extends StatelessWidget {
  final String? title;
  final TextEditingController? textEditingController;
  final TextInputType? keyboardType;
  final TextInputAction? keyboardAction;
  final void Function(String value) onTextChange;
  final bool isPassword;
  final bool autoFocus;
  final Widget? suffixIcon;
  final bool isMultiLine;
  final double maxLine;
  final double? borderRadius;
  final bool isReadOnly;
  final bool isEnabled;
  final List<TextInputFormatter>? inputFormatter;
  final String? hint;
  final TextStyle? hintStyle;
  final ColorEnums? titleTextColor;
  final ColorEnums? fieldBgColor;
  final FocusNode? focusNode;
  final double? borderWidth;
  final double? titleTextSize;

  const AppTextField({
    required this.onTextChange,
    this.title,
    super.key,
    this.textEditingController,
    this.keyboardType,
    this.borderRadius,
    this.keyboardAction,
    this.titleTextColor,
    this.autoFocus = false,
    this.isPassword = false,
    this.suffixIcon,
    this.isMultiLine = false,
    this.maxLine = 1,
    this.isReadOnly = false,
    this.inputFormatter,
    this.hint,
    this.hintStyle,
    this.fieldBgColor,
    this.focusNode,
    this.isEnabled = true,
    this.borderWidth,
    this.titleTextSize,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          FieldTitle(
            title: title!,
            textColorEnum: titleTextColor,
            textSize: titleTextSize,
          ),
        if (title != null)
          SizedBox(
            height: Dimens.dimens_10.h,
          ),
        SizedBox(
          height:
              isMultiLine ? (Dimens.dimens_50 * maxLine).h : Dimens.dimens_50.h,
          child: KeyboardActions(
            disableScroll: true,
            enable: keyboardType == TextInputType.number ||
                keyboardType == TextInputType.phone ||
                keyboardType ==
                    const TextInputType.numberWithOptions(
                      decimal: true,
                    ) ||
                inputFormatter != null &&
                    (inputFormatter!.contains(
                          FilteringTextInputFormatter.allow(
                            RegExp(
                              '[0-9]',
                            ),
                          ),
                        ) ||
                        inputFormatter!.contains(
                          FilteringTextInputFormatter.digitsOnly,
                        )),
            config: KeyboardActionsConfig(
              nextFocus: false,
              keyboardBarElevation: 0,
              keyboardActionsPlatform: KeyboardActionsPlatform.IOS,
              actions: [
                KeyboardActionsItem(
                  focusNode: focusNode ?? FocusNode(canRequestFocus: false),
                  displayArrows: false,
                ),
              ],
            ),
            child: TextField(
              autofocus: autoFocus,
              obscureText: isPassword,
              maxLines: isMultiLine ? 3 : 1,
              readOnly: isReadOnly,
              enabled: isEnabled,
              enableInteractiveSelection: !isReadOnly,
              inputFormatters: inputFormatter,
              focusNode: focusNode,
              style: TextStyle(
                color: ColorUtils.getColor(
                  context,
                  ColorEnums.black33Color,
                ),
                fontSize: Dimens.dimens_16.sp,
              ),
              cursorColor: ColorUtils.getColor(
                context,
                ColorEnums.black33Color,
              ),
              cursorWidth: 1,
              controller: textEditingController,
              keyboardType: keyboardType ?? TextInputType.text,
              textInputAction: keyboardAction ?? TextInputAction.done,
              decoration: FieldBorderDecoration.fieldBorderDecoration(
                context,
                contentPadding: Dimens.dimens_15.w,
                isMultiLine: isMultiLine,
                suffixIcon: suffixIcon,
                hint: hint,
                borderWidth: borderWidth,
                borderRadius: borderRadius,
                hintStyle: hintStyle,
                fillColor: isEnabled
                    ? (fieldBgColor ?? ColorEnums.whiteColor)
                    : ColorEnums.grayF5Color,
              ),
              onChanged: onTextChange,
            ),
          ),
        ),
      ],
    );
  }
}
