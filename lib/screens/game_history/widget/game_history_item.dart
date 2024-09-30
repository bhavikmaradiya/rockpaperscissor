import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/const/assets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/enums/room_type_enums.dart';
import 'package:rockpaperscissor/enums/winner_type_enums.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';
import 'package:super_banners/super_banners.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class GameHistoryItem extends StatelessWidget {
  const GameHistoryItem({
    super.key,
    required this.appLocalizations,
    required this.currentMatch,
    this.onTap,
  });

  final AppLocalizations appLocalizations;
  final Room currentMatch;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final isBotMatch = currentMatch.roomType == RoomTypeEnums.botPlayer.name;
    final isQuickMatch = currentMatch.isAutoMatch ?? false;
    final isWinner = StaticFunctions.userId == currentMatch.winnerId;
    final isDraw = WinnerTypeEnum.draw.name == currentMatch.winnerId;
    final totalWonRound = currentMatch.roundInfo!
        .where(
          (element) => element.winnerId == StaticFunctions.userId,
        )
        .length;
    return Stack(
      children: [
        Card(
          color: Colors.purple,
          margin: EdgeInsets.symmetric(
            vertical: Dimens.dimens_9.h,
          ),
          elevation: 15,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(
                Dimens.dimens_11.r,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.dimens_10.w,
                  vertical: Dimens.dimens_11.h,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          FlickerNeonContainer(
                            containerColor: ColorUtils.getColor(
                              context,
                              ColorEnums.purpleColor,
                            ),
                            flickerTimeInMilliSeconds: 0,
                            borderRadius: BorderRadius.circular(
                              Dimens.dimens_11.r,
                            ),
                            lightSpreadRadius: 0,
                            lightBlurRadius: 0,
                            padding: EdgeInsets.all(
                              Dimens.dimens_14.r,
                            ),
                            borderColor: ColorUtils.getColor(
                              context,
                              ColorEnums.whiteColor,
                            ),
                            borderWidth: Dimens.dimens_1.w,
                            child: Center(
                              child: Image.asset(
                                isWinner
                                    ? Assets.winnerFlagIcon
                                    : Assets.gameOverIcon,
                                height: Dimens.dimens_75.w,
                                width: Dimens.dimens_75.w,
                                scale: 6,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: ColorUtils.getColor(
                                  context,
                                  ColorEnums.lightYellowColor2,
                                ),
                                borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(
                                    Dimens.dimens_11.r,
                                  ),
                                ),
                              ),
                              padding: EdgeInsets.symmetric(
                                vertical: Dimens.dimens_3.h,
                              ),
                              child: FlickerNeonText(
                                text: isBotMatch
                                    ? appLocalizations.gamePlayedWithBot
                                    : isQuickMatch
                                        ? appLocalizations
                                            .gamePlayedWithQuickMatch
                                        : appLocalizations.gamePlayedWithFriend,
                                flickerTimeInMilliSeconds: 0,
                                textColor: ColorUtils.getColor(
                                  context,
                                  ColorEnums.blackColor,
                                ),
                                maxLine: 1,
                                textOverflow: TextOverflow.ellipsis,
                                spreadColor: Colors.black,
                                blurRadius: 1,
                                textSize: Dimens.dimens_15.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: Dimens.dimens_10.w,
                            vertical: Dimens.dimens_8.h,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              FlickerNeonText(
                                text:
                                    'Room: ${currentMatch.roomId!.toUpperCase().substring(0, 5)}',
                                flickerTimeInMilliSeconds: 0,
                                textColor: ColorUtils.getColor(
                                  context,
                                  ColorEnums.whiteColor,
                                ),
                                maxLine: 1,
                                textOverflow: TextOverflow.ellipsis,
                                spreadColor: Colors.white,
                                blurRadius: 1,
                                textSize: Dimens.dimens_19.sp,
                              ),
                              SizedBox(
                                height: Dimens.dimens_1.h,
                              ),
                              FlickerNeonText(
                                text: appLocalizations.gameTotalRounds(
                                  currentMatch.totalRounds ?? 0,
                                ),
                                flickerTimeInMilliSeconds: 0,
                                textColor: ColorUtils.getColor(
                                  context,
                                  ColorEnums.whiteColor,
                                ),
                                maxLine: 1,
                                textOverflow: TextOverflow.ellipsis,
                                spreadColor: Colors.white,
                                blurRadius: 1,
                                textSize: Dimens.dimens_19.sp,
                              ),
                              SizedBox(
                                height: Dimens.dimens_1.h,
                              ),
                              FlickerNeonText(
                                text: appLocalizations.gamePotAmount(
                                  currentMatch.totalPotAmount?.round() ?? 0,
                                ),
                                flickerTimeInMilliSeconds: 0,
                                textColor: ColorUtils.getColor(
                                  context,
                                  ColorEnums.whiteColor,
                                ),
                                maxLine: 1,
                                textOverflow: TextOverflow.ellipsis,
                                spreadColor: Colors.white,
                                blurRadius: 1,
                                textSize: Dimens.dimens_19.sp,
                              ),
                              if (isWinner)
                                SizedBox(
                                  height: Dimens.dimens_1.h,
                                ),
                              if (isWinner)
                                FlickerNeonText(
                                  text: appLocalizations.wonRounds(
                                    '$totalWonRound/${currentMatch.totalRounds}',
                                  ),
                                  flickerTimeInMilliSeconds: 0,
                                  textColor: ColorUtils.getColor(
                                    context,
                                    ColorEnums.whiteColor,
                                  ),
                                  maxLine: 1,
                                  textOverflow: TextOverflow.ellipsis,
                                  spreadColor: Colors.white,
                                  blurRadius: 1,
                                  textSize: Dimens.dimens_19.sp,
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          child: CornerBanner(
            bannerPosition: CornerBannerPosition.topRight,
            bannerColor: ColorUtils.getColor(
              context,
              isWinner
                  ? ColorEnums.greenColor
                  : isDraw
                      ? ColorEnums.lightYellowColor
                      : ColorEnums.redColor,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: Dimens.dimens_1.h,
              ),
              child: FlickerNeonText(
                text: isWinner
                    ? appLocalizations.gamePlayWon
                    : isDraw
                        ? appLocalizations.gamePlayDraw
                        : appLocalizations.gamePlayLost,
                flickerTimeInMilliSeconds: 0,
                textColor: ColorUtils.getColor(
                  context,
                  ColorEnums.blackColor,
                ),
                maxLine: 1,
                textOverflow: TextOverflow.ellipsis,
                spreadColor: Colors.black,
                blurRadius: 1,
                textSize: Dimens.dimens_17.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
