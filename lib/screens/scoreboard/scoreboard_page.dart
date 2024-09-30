import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';
import 'package:rockpaperscissor/const/assets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/enums/moves_type_enums.dart';
import 'package:rockpaperscissor/enums/room_type_enums.dart';
import 'package:rockpaperscissor/enums/winner_type_enums.dart';
import 'package:rockpaperscissor/screens/playground/widget/loading_dialog.dart';
import 'package:rockpaperscissor/screens/room/model/round_info.dart';
import 'package:rockpaperscissor/screens/scoreboard/bloc/scoreboard_bloc.dart';
import 'package:rockpaperscissor/screens/scoreboard/bloc/scoreboard_event.dart';
import 'package:rockpaperscissor/screens/scoreboard/bloc/scoreboard_state.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';
import 'package:rockpaperscissor/utils/sound_utils.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';
import 'package:rockpaperscissor/widgets/neumorphic_container.dart';
import 'package:rockpaperscissor/widgets/toolbar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ScoreboardPage extends StatefulWidget {
  const ScoreboardPage({super.key});

  @override
  State<ScoreboardPage> createState() => _ScoreboardPageState();
}

class _ScoreboardPageState extends State<ScoreboardPage> {
  ScoreboardBloc? _scoreboardBloc;
  late AppLocalizations _appLocalizations;

  @override
  Future<void> didChangeDependencies() async {
    if (_scoreboardBloc == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      late String roomId;
      bool isFromGame = false;
      if (args is String) {
        roomId = ModalRoute.of(context)?.settings.arguments as String;
      } else if (args is Map<String, dynamic>) {
        roomId = args[FireStoreConfig.roomIdField];
        isFromGame = args['isFromGame'];
      }
      _scoreboardBloc = BlocProvider.of<ScoreboardBloc>(context);
      _scoreboardBloc?.add(
        ScoreboardInitialEvent(
          roomId,
          isFromGame,
        ),
      );
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: Dimens.dimens_20.w,
                ),
                child: Column(
                  children: [
                    ToolbarWidget(
                      title: _appLocalizations.scoreboard,
                      onTap: () {
                        SoundUtils.playButtonClick();
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(
                      height: Dimens.dimens_20.h,
                    ),
                    Expanded(
                      child: BlocBuilder<ScoreboardBloc, ScoreboardState>(
                        buildWhen: (_, current) =>
                            current is ScoreboardUpdatedState,
                        builder: (_, state) {
                          if (state is ScoreboardInitialState) {
                            return const SizedBox();
                          }
                          final updatedState = state as ScoreboardUpdatedState;
                          final player1 = updatedState.player1;
                          final player2 = updatedState.player2;
                          final currentMatch = updatedState.roomData;
                          final transaction = updatedState.transaction;
                          final isBotMatch = currentMatch.roomType ==
                              RoomTypeEnums.botPlayer.name;
                          final isQuickMatch =
                              currentMatch.isAutoMatch ?? false;
                          final isWinner =
                              StaticFunctions.userId == currentMatch.winnerId;
                          final isDraw =
                              WinnerTypeEnum.draw.name == currentMatch.winnerId;

                          final player1Name = player1.name ??
                              _appLocalizations.defaultPlayerName(1);
                          final player2Name = player2?.name ??
                              (isBotMatch
                                  ? _appLocalizations.botPlayerName
                                  : _appLocalizations.defaultPlayerName(1));

                          final player1Id = currentMatch.hostId!;
                          final player2Id = currentMatch.playerIds!.firstWhere(
                            (element) => element != player1Id,
                          );

                          final roundInfo = currentMatch.roundInfo!;
                          final player1Point = roundInfo
                              .where((element) => element.winnerId == player1Id)
                              .length;
                          final player2Point = roundInfo
                              .where((element) => element.winnerId == player2Id)
                              .length;
                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              children: [
                                FlickerNeonText(
                                  text: isWinner
                                      ? _appLocalizations.scoreboardWinnerTitle
                                      : isDraw
                                          ? _appLocalizations
                                              .scoreboardDrawTitle
                                          : _appLocalizations
                                              .scoreboardLoserTitle,
                                  flickerTimeInMilliSeconds: 0,
                                  textColor: ColorUtils.getColor(
                                    context,
                                    isWinner
                                        ? ColorEnums.greenColor
                                        : isDraw
                                            ? ColorEnums.lightYellowColor
                                            : ColorEnums.redColor,
                                  ),
                                  spreadColor: ColorUtils.getColor(
                                    context,
                                    ColorEnums.whiteColor,
                                  ),
                                  blurRadius: 1,
                                  textSize: Dimens.dimens_30.sp,
                                ),
                                SizedBox(
                                  height: Dimens.dimens_7.h,
                                ),
                                if (isWinner)
                                  FlickerNeonText(
                                    text: _appLocalizations
                                        .wonRounds(player1Point),
                                    flickerTimeInMilliSeconds: 0,
                                    textColor: ColorUtils.getColor(
                                      context,
                                      ColorEnums.whiteColor,
                                    ),
                                    spreadColor: ColorUtils.getColor(
                                      context,
                                      ColorEnums.whiteColor,
                                    ),
                                    textSize: Dimens.dimens_23.sp,
                                  ),
                                FlickerNeonText(
                                  text: _appLocalizations.scoreboardTotalPrize(
                                      currentMatch.totalPotAmount!.round()),
                                  flickerTimeInMilliSeconds: 0,
                                  textColor: ColorUtils.getColor(
                                    context,
                                    ColorEnums.whiteColor,
                                  ),
                                  spreadColor: ColorUtils.getColor(
                                    context,
                                    ColorEnums.whiteColor,
                                  ),
                                  textSize: Dimens.dimens_23.sp,
                                ),
                                SizedBox(
                                  height: Dimens.dimens_25.h,
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildPlayerProfile(
                                        context,
                                        playerName: player1Name,
                                        points: player1Point,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildPlayerProfile(
                                        context,
                                        playerName: player2Name,
                                        points: player2Point,
                                      ),
                                    )
                                  ],
                                ),
                                SizedBox(
                                  height: Dimens.dimens_50.h,
                                ),
                                FlickerNeonText(
                                  text: _appLocalizations.scoreboardRounds(
                                    currentMatch.totalRounds!,
                                  ),
                                  flickerTimeInMilliSeconds: 0,
                                  textColor: ColorUtils.getColor(
                                    context,
                                    ColorEnums.whiteColor,
                                  ),
                                  spreadColor: ColorUtils.getColor(
                                    context,
                                    ColorEnums.whiteColor,
                                  ),
                                  textSize: Dimens.dimens_32.sp,
                                ),
                                SizedBox(
                                  height: Dimens.dimens_45.h,
                                ),
                                Column(
                                  children: roundInfo.map(
                                    (round) {
                                      return _buildRoundInfo(
                                        context,
                                        round: round,
                                        player1Name: player1Name,
                                        player1Id: player1Id,
                                        player2Name: player2Name,
                                        player2Id: player2Id,
                                      );
                                    },
                                  ).toList(),
                                ),
                                if (!isDraw)
                                  SizedBox(
                                    height: Dimens.dimens_15.h,
                                  ),
                                if (!isDraw)
                                  FlickerNeonText(
                                    text: isWinner
                                        ? _appLocalizations.scoreRoundWonAmount(
                                            (currentMatch.totalPotAmount! / 2)
                                                .round(),
                                          )
                                        : _appLocalizations
                                            .scoreRoundLostAmount(
                                            (currentMatch.totalPotAmount! / 2)
                                                .round(),
                                          ),
                                    flickerTimeInMilliSeconds: 0,
                                    textColor: ColorUtils.getColor(
                                      context,
                                      isWinner
                                          ? ColorEnums.greenColor
                                          : ColorEnums.redColor,
                                    ),
                                    spreadColor: ColorUtils.getColor(
                                      context,
                                      isWinner
                                          ? ColorEnums.greenColor
                                          : ColorEnums.redColor,
                                    ),
                                    textSize: Dimens.dimens_23.sp,
                                  ),
                                SafeArea(
                                  top: false,
                                  child: SizedBox(
                                    height: Dimens.dimens_50.h,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: BlocBuilder<ScoreboardBloc, ScoreboardState>(
              buildWhen: (_, current) =>
                  current is ScoreboardLoadingState ||
                  current is ScoreboardUpdatedState,
              builder: (_, state) {
                final isLoading = state is ScoreboardLoadingState ||
                    state is ScoreboardInitialState;
                return AbsorbPointer(
                  absorbing: isLoading,
                  child: AnimatedSwitcher(
                    duration: const Duration(
                      milliseconds: 500,
                    ),
                    switchInCurve: Curves.elasticIn,
                    switchOutCurve: Curves.elasticIn,
                    child: isLoading
                        ? LoadingDialog(
                            subtitle: _appLocalizations.scoreboardLoading,
                          )
                        : const SizedBox(),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: BlocBuilder<ScoreboardBloc, ScoreboardState>(
              buildWhen: (_, state) => state is ScoreboardWinnerAnimationState,
              builder: (_, state) {
                final isLoading = state is ScoreboardWinnerAnimationState &&
                    state.shouldAnimate;
                return isLoading
                    ? Lottie.asset(
                        Assets.winnerAnimation,
                        fit: BoxFit.cover,
                      )
                    : const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Padding _buildRoundInfo(
    BuildContext context, {
    required RoundInfo round,
    required String player1Name,
    required String player1Id,
    required String player2Name,
    required String player2Id,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: Dimens.dimens_30.h / 2,
        horizontal: Dimens.dimens_10.w,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _buildPlayerMove(
              context,
              roundNo: round.roundNo!,
              playerName: player1Name,
              move: round.player1Move != null
                  ? StaticFunctions.getMoveEnumFromString(
                      round.player1Move!,
                    )!
                  : null,
              isWinner: round.winnerId == player1Id,
              isDraw: round.winnerId == WinnerTypeEnum.draw.name,
            ),
          ),
          SizedBox(
            width: Dimens.dimens_2.w,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              FlickerNeonText(
                text: _appLocalizations.roundNoTitle(round.roundNo!),
                flickerTimeInMilliSeconds: 0,
                textColor: ColorUtils.getColor(
                  context,
                  ColorEnums.whiteColor,
                ),
                textAlign: TextAlign.center,
                blurRadius: 0,
                spreadColor: ColorUtils.getColor(
                  context,
                  ColorEnums.whiteColor,
                ),
                textSize: Dimens.dimens_19.sp,
              ),
              if (round.winnerId == WinnerTypeEnum.draw.name)
                FlickerNeonText(
                  text: '(${_appLocalizations.scoreRoundDraw.toUpperCase()})',
                  flickerTimeInMilliSeconds: 0,
                  textColor: ColorUtils.getColor(
                    context,
                    ColorEnums.lightYellowColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLine: 2,
                  spreadColor: Colors.white,
                  blurRadius: 0,
                  textOverflow: TextOverflow.ellipsis,
                  textSize: Dimens.dimens_15.sp,
                ),
            ],
          ),
          SizedBox(
            width: Dimens.dimens_2.w,
          ),
          Expanded(
            child: _buildPlayerMove(
              context,
              roundNo: round.roundNo!,
              playerName: player2Name,
              move: round.player2Move != null
                  ? StaticFunctions.getMoveEnumFromString(
                      round.player2Move!,
                    )!
                  : null,
              isWinner: round.winnerId == player2Id,
              isDraw: round.winnerId == WinnerTypeEnum.draw.name,
            ),
          ),
        ],
      ),
    );
  }

  Column _buildPlayerMove(
    BuildContext context, {
    required String playerName,
    required int roundNo,
    required MovesTypeEnums? move,
    required bool isWinner,
    required bool isDraw,
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
                      : move != null
                          ? Assets.scissorIcon
                          : Assets.questionIcon,
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
          textSize: Dimens.dimens_17.sp,
        ),
        if (isWinner)
          FlickerNeonText(
            text: '(${_appLocalizations.scoreRoundWinner.toUpperCase()})',
            flickerTimeInMilliSeconds: 0,
            textColor: ColorUtils.getColor(
              context,
              isWinner ? ColorEnums.greenColor : ColorEnums.lightYellowColor,
            ),
            textAlign: TextAlign.center,
            maxLine: 2,
            spreadColor: Colors.white,
            blurRadius: 0,
            textOverflow: TextOverflow.ellipsis,
            textSize: Dimens.dimens_15.sp,
          ),
      ],
    );
  }

  Column _buildPlayerProfile(
    BuildContext context, {
    required String playerName,
    required int points,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Center(
          child: Image.asset(
            Assets.userPlaceholder,
            height: Dimens.dimens_125.w,
            width: Dimens.dimens_125.w,
          ),
        ),
        FlickerNeonText(
          text: playerName,
          flickerTimeInMilliSeconds: 0,
          textColor: ColorUtils.getColor(
            context,
            ColorEnums.whiteColor,
          ),
          spreadColor: Colors.white,
          blurRadius: 20,
          maxLine: 2,
          textOverflow: TextOverflow.ellipsis,
          textSize: Dimens.dimens_22.sp,
        ),
        FlickerNeonText(
          text: _appLocalizations.points(points),
          flickerTimeInMilliSeconds: 0,
          textColor: ColorUtils.getColor(
            context,
            ColorEnums.whiteColor,
          ),
          spreadColor: Colors.white,
          blurRadius: 0,
          textOverflow: TextOverflow.ellipsis,
          textSize: Dimens.dimens_20.sp,
        ),
      ],
    );
  }
}
