import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/const/assets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/enums/moves_type_enums.dart';
import 'package:rockpaperscissor/enums/winner_type_enums.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rockpaperscissor/widgets/neumorphic_container.dart';

class RoundCompletionDialog extends StatelessWidget {
  final int roundNo;
  final WinnerTypeEnum winnerType;
  final MovesTypeEnums player1Move;
  final MovesTypeEnums player2Move;
  final String player1Name;
  final String player2Name;
  final bool isWon;

  const RoundCompletionDialog({
    super.key,
    required this.winnerType,
    required this.player1Move,
    required this.player2Move,
    required this.player1Name,
    required this.player2Name,
    required this.roundNo,
    required this.isWon,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context)!;
    final subtitle = winnerType != WinnerTypeEnum.draw
        ? (isWon ? appLocalizations.won : appLocalizations.lost)
        : appLocalizations.draw;
    return Stack(
      children: [
        Center(
          child: FlickerNeonContainer(
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
              horizontal: Dimens.dimens_30.w,
              vertical: Dimens.dimens_30.h,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  appLocalizations.roundNoTitle(roundNo),
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
                SizedBox(
                  height: Dimens.dimens_32.h,
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: _buildPlayer(
                        context,
                        move: player1Move,
                        playerName: player1Name,
                      ),
                    ),
                    SizedBox(
                      width: Dimens.dimens_30.w,
                    ),
                    Flexible(
                      child: _buildPlayer(
                        context,
                        move: player2Move,
                        playerName: player2Name,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: Dimens.dimens_25.h,
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
          ),
        ),
        if (isWon)
          Positioned(
            bottom: 0,
            child: Lottie.asset(
              Assets.winnerAnimation,
              repeat: false,
            ),
          ),
      ],
    );
  }

  Column _buildPlayer(
    BuildContext context, {
    required String playerName,
    required MovesTypeEnums move,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IgnorePointer(
          child: NeumorphicContainer(
            color: ColorUtils.getColor(
              context,
              ColorEnums.purpleColor,
            ),
            padding: EdgeInsets.all(
              Dimens.dimens_12.r,
            ),
            onTap: null,
            child: Image.asset(
              move == MovesTypeEnums.rock
                  ? Assets.rockIcon
                  : move == MovesTypeEnums.paper
                      ? Assets.paperIcon
                      : Assets.scissorIcon,
              scale: Dimens.dimens_11.r,
              color: ColorUtils.getColor(
                context,
                ColorEnums.whiteColor,
              ),
            ),
          ),
        ),
        SizedBox(
          height: Dimens.dimens_20.h,
        ),
        FlickerNeonText(
          text: playerName,
          flickerTimeInMilliSeconds: 0,
          textColor: ColorUtils.getColor(
            context,
            ColorEnums.whiteColor,
          ),
          textAlign: TextAlign.center,
          maxLine: 2,
          spreadColor: Colors.white,
          blurRadius: 20,
          textOverflow: TextOverflow.ellipsis,
          textSize: Dimens.dimens_16.sp,
        ),
      ],
    );
  }
}
