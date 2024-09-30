import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';
import 'package:rockpaperscissor/const/assets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/enums/moves_type_enums.dart';
import 'package:rockpaperscissor/enums/room_type_enums.dart';
import 'package:rockpaperscissor/enums/winner_type_enums.dart';
import 'package:rockpaperscissor/routes.dart';
import 'package:rockpaperscissor/screens/playground/bloc/playground_bloc.dart';
import 'package:rockpaperscissor/screens/playground/bloc/playground_event.dart';
import 'package:rockpaperscissor/screens/playground/bloc/playground_state.dart';
import 'package:rockpaperscissor/screens/playground/widget/loading_dialog.dart';
import 'package:rockpaperscissor/screens/playground/widget/round_completion_dialog.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';
import 'package:rockpaperscissor/utils/sound_utils.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';
import 'package:rockpaperscissor/widgets/button_widget.dart';
import 'package:rockpaperscissor/widgets/neumorphic_container.dart';

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  PlaygroundBloc? _playgroundBloc;
  late AppLocalizations _appLocalizations;
  late FToast toastBuilder;

  @override
  void initState() {
    super.initState();
    toastBuilder = FToast();
    toastBuilder.init(context);
  }

  @override
  Future<void> didChangeDependencies() async {
    if (_playgroundBloc == null) {
      final roomArgs = ModalRoute.of(context)?.settings.arguments as Room;
      _playgroundBloc ??= BlocProvider.of<PlaygroundBloc>(context);
      _playgroundBloc?.add(
        PlaygroundInitEvent(
          currentRoom: roomArgs,
        ),
      );
    }
    super.didChangeDependencies();
  }

  void _listenToStateChange(
    _,
    PlaygroundState state,
  ) {
    if (state is PlaygroundStartScoreboardState) {
      final Map<String, dynamic> data = {};
      data[FireStoreConfig.roomIdField] = state.roomId;
      data['isFromGame'] = true;
      Navigator.pushReplacementNamed(
        context,
        Routes.scoreboard,
        arguments: data,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = StaticFunctions.userId;
    _appLocalizations = AppLocalizations.of(context)!;
    return BlocListener<PlaygroundBloc, PlaygroundState>(
      listenWhen: (_, current) => current is PlaygroundStartScoreboardState,
      listener: _listenToStateChange,
      child: Scaffold(
        body: PopScope(
          canPop: false,
          child: Stack(
            children: [
              Positioned.fill(
                top: Dimens.dimens_20.h,
                bottom: Dimens.dimens_20.h,
                left: Dimens.dimens_20.w,
                right: Dimens.dimens_20.w,
                child: SafeArea(
                  child: Column(
                    children: [
                      BlocBuilder<PlaygroundBloc, PlaygroundState>(
                        buildWhen: (_, current) =>
                            current is TimerRunningState ||
                            current is TimerCompleteState ||
                            current is RoundSwitchState,
                        builder: (_, state) {
                          final currentRound = _playgroundBloc?.currentRound;
                          final currentRoom = state is! PlaygroundInitialState
                              ? _playgroundBloc?.currentRoom
                              : null;
                          if (currentRound != null) {
                            return Column(
                              children: [
                                if (currentRoom != null)
                                  FlickerNeonText(
                                    text: _appLocalizations.potAmount(
                                        currentRoom.totalPotAmount?.round() ??
                                            0),
                                    flickerTimeInMilliSeconds: 0,
                                    textColor: ColorUtils.getColor(
                                      context,
                                      ColorEnums.whiteColor,
                                    ),
                                    spreadColor: Colors.white,
                                    blurRadius: 10,
                                    textSize: Dimens.dimens_30.sp,
                                  ),
                                SizedBox(
                                  height: Dimens.dimens_10.h,
                                ),
                                FlickerNeonContainer(
                                  containerColor: ColorUtils.getColor(
                                    context,
                                    ColorEnums.purpleColor,
                                  ),
                                  flickerTimeInMilliSeconds: 0,
                                  borderRadius: BorderRadius.circular(
                                    Dimens.dimens_10.r,
                                  ),
                                  borderColor: ColorUtils.getColor(
                                    context,
                                    ColorEnums.whiteColor,
                                  ),
                                  borderWidth: Dimens.dimens_1.w,
                                  child: Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: Dimens.dimens_12.w,
                                      vertical: Dimens.dimens_4.h,
                                    ),
                                    child: Column(
                                      children: [
                                        FlickerNeonText(
                                          text: _appLocalizations
                                              .roundNoTitle(currentRound),
                                          flickerTimeInMilliSeconds: 0,
                                          textColor: ColorUtils.getColor(
                                            context,
                                            ColorEnums.whiteColor,
                                          ),
                                          spreadColor: Colors.white,
                                          blurRadius: 10,
                                          fontWeight: FontWeight.bold,
                                          textSize: Dimens.dimens_30.sp,
                                        ),
                                        if (state is TimerRunningState)
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              FlickerNeonText(
                                                text: _appLocalizations
                                                    .remainingSec,
                                                flickerTimeInMilliSeconds: 0,
                                                textColor: ColorUtils.getColor(
                                                  context,
                                                  ColorEnums.whiteColor,
                                                ),
                                                spreadColor: Colors.white,
                                                blurRadius: 20,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                textSize: Dimens.dimens_22.sp,
                                              ),
                                              FlickerNeonText(
                                                text: '${state.remainingTime}s',
                                                flickerTimeInMilliSeconds: 1000,
                                                textColor: ColorUtils.getColor(
                                                  context,
                                                  state.remainingTime < 7
                                                      ? ColorEnums.redColor
                                                      : ColorEnums.greenColor,
                                                ),
                                                spreadColor: Colors.white,
                                                blurRadius: 20,
                                                fontWeight: FontWeight.bold,
                                                textOverflow:
                                                    TextOverflow.ellipsis,
                                                textSize: Dimens.dimens_26.sp,
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return const SizedBox();
                        },
                      ),
                      BlocBuilder<PlaygroundBloc, PlaygroundState>(
                        buildWhen: (_, current) =>
                            current is PlaygroundPlayerMoveChangeState,
                        builder: (_, state) {
                          bool isPlayer1Playing = false;
                          bool isPlayer2Playing = false;
                          String player1Name = '';
                          String player2Name = '';
                          if (state is PlaygroundPlayerMoveChangeState) {
                            final playerMove = state.playerMove;
                            if (playerMove.player1Move == null ||
                                playerMove.player2Move == null) {
                              if (playerMove.player1Move == null &&
                                  playerMove.player2Move == null) {
                                isPlayer1Playing =
                                    playerMove.player1Id == currentUserId;
                                isPlayer2Playing =
                                    playerMove.player2Id == currentUserId;
                              } else {
                                isPlayer1Playing =
                                    playerMove.player1Move == null;
                                isPlayer2Playing =
                                    playerMove.player2Move == null;
                              }
                            }

                            if (state.roomType == RoomTypeEnums.botPlayer) {
                              player2Name = _appLocalizations.botPlayerName;
                            } else {
                              player2Name = state.player2Name ??
                                  _appLocalizations.defaultPlayerName(2);
                            }
                            player1Name = state.player1Name ??
                                _appLocalizations.defaultPlayerName(1);
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: Dimens.dimens_30.h,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: _buildPlayerProfile(
                                      context,
                                      isPlaying: isPlayer1Playing,
                                      playerName: player1Name,
                                      isPlayer1: true,
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildPlayerProfile(
                                      context,
                                      isPlaying: isPlayer2Playing,
                                      playerName: player2Name,
                                      isPlayer1: false,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                      const Spacer(),
                      Center(
                        child: FlickerNeonText(
                          text: _appLocalizations.waitingForMove,
                          flickerTimeInMilliSeconds: 0,
                          textColor: ColorUtils.getColor(
                            context,
                            ColorEnums.whiteColor,
                          ),
                          maxLine: 3,
                          spreadColor: Colors.white,
                          blurRadius: 20,
                          textOverflow: TextOverflow.ellipsis,
                          textSize: Dimens.dimens_22.sp,
                        ),
                      ),
                      const Spacer(),
                      BlocBuilder<PlaygroundBloc, PlaygroundState>(
                        buildWhen: (_, current) =>
                            current is PlaygroundPlayerMoveChangeState,
                        builder: (_, state) {
                          bool shouldHide = false;
                          if (state is PlaygroundPlayerMoveChangeState) {
                            final playerMove = state.playerMove;
                            shouldHide = (playerMove.player1Move != null &&
                                    playerMove.player2Move != null) ||
                                (playerMove.player1Move != null &&
                                    playerMove.player1Id == currentUserId) ||
                                (playerMove.player2Move != null &&
                                    playerMove.player2Id == currentUserId);
                          }

                          return IgnorePointer(
                            ignoring: shouldHide,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildActionBtn(
                                  context,
                                  move: MovesTypeEnums.rock,
                                ),
                                _buildActionBtn(
                                  context,
                                  move: MovesTypeEnums.paper,
                                ),
                                _buildActionBtn(
                                  context,
                                  move: MovesTypeEnums.scissor,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        height: Dimens.dimens_25.h,
                      ),
                    ],
                  ),
                ),
              ),
              _buildInitialLoader(),
              _buildRoundFinishingDialog(),
              _buildRoundTimeoutDialog(),
              _buildAllRoundFinishedDialog(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn(
    BuildContext context, {
    required MovesTypeEnums move,
  }) {
    return BlocBuilder<PlaygroundBloc, PlaygroundState>(
      buildWhen: (_, current) => current is DisableActionsState,
      builder: (_, state) {
        final isProcessing =
            state is DisableActionsState && state.shouldDisable;
        return NeumorphicContainer(
          color: ColorUtils.getColor(
            context,
            ColorEnums.purpleColor,
          ),
          padding: EdgeInsets.all(
            Dimens.dimens_15.r,
          ),
          onTap: isProcessing
              ? null
              : () {
                  SoundUtils.playButtonClick();
                  _playgroundBloc?.add(
                    PlaygroundMoveInputEvent(
                      moveType: move,
                    ),
                  );
                },
          child: Image.asset(
            move == MovesTypeEnums.rock
                ? Assets.rockIcon
                : move == MovesTypeEnums.paper
                    ? Assets.paperIcon
                    : Assets.scissorIcon,
            scale: Dimens.dimens_12.r,
            color: ColorUtils.getColor(
              context,
              ColorEnums.whiteColor,
            ),
          ),
        );
      },
    );
  }

  Column _buildPlayerProfile(
    BuildContext context, {
    required bool isPlayer1,
    bool isPlaying = false,
    required String playerName,
  }) {
    return Column(
      children: [
        Container(
          height: Dimens.dimens_175.w,
          width: Dimens.dimens_175.w,
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 500,
                  ),
                  switchInCurve: Curves.elasticIn,
                  switchOutCurve: Curves.elasticIn,
                  child: isPlaying
                      ? Lottie.asset(
                          Assets.playingRippleAnimation,
                          height: Dimens.dimens_175.w,
                          width: Dimens.dimens_175.w,
                          fit: BoxFit.cover,
                        )
                      : const SizedBox(),
                ),
              ),
              Center(
                child: Image.asset(
                  Assets.userPlaceholder,
                  height: Dimens.dimens_175.w / 1.6,
                  width: Dimens.dimens_175.w / 1.6,
                ),
              ),
            ],
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
        BlocBuilder<PlaygroundBloc, PlaygroundState>(
          buildWhen: (_, current) => current is RoundPointsUpdatedState,
          builder: (_, state) {
            int points = isPlayer1
                ? (_playgroundBloc?.player1Points ?? 0)
                : (_playgroundBloc?.player2Points ?? 0);
            if (state is RoundPointsUpdatedState) {
              points = isPlayer1 ? state.player1Points : state.player2Points;
            }
            return FlickerNeonText(
              text: _appLocalizations.points(points),
              flickerTimeInMilliSeconds: 0,
              textColor: ColorUtils.getColor(
                context,
                ColorEnums.whiteColor,
              ),
              spreadColor: Colors.white,
              blurRadius: 20,
              textOverflow: TextOverflow.ellipsis,
              textSize: Dimens.dimens_22.sp,
            );
          },
        ),
      ],
    );
  }

  Widget _buildInitialLoader() {
    return Positioned.fill(
      child: BlocBuilder<PlaygroundBloc, PlaygroundState>(
        buildWhen: (_, current) =>
            current is PlaygroundLoadingState ||
            current is PlaygroundRoundBufferingState,
        builder: (_, state) {
          final isLoading =
              (state is PlaygroundLoadingState && state.isLoading) ||
                  (state is PlaygroundRoundBufferingState && state.isLoading);
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
                      subtitle: _appLocalizations.bufferingLoadingTitle,
                    )
                  : const SizedBox(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAllRoundFinishedDialog() {
    return Positioned.fill(
      child: BlocBuilder<PlaygroundBloc, PlaygroundState>(
        buildWhen: (_, current) => current is PlaygroundAllRoundFinishedState,
        builder: (_, state) {
          final shouldShow = state is PlaygroundAllRoundFinishedState;
          return AbsorbPointer(
            absorbing: shouldShow,
            child: AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 500,
              ),
              switchInCurve: Curves.elasticIn,
              switchOutCurve: Curves.elasticIn,
              child: shouldShow
                  ? LoadingDialog(
                      subtitle: _appLocalizations.completedAllRoundSubtitle,
                      animation: Assets.gameOverAnimation,
                    )
                  : const SizedBox(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoundFinishingDialog() {
    return Positioned.fill(
      child: BlocBuilder<PlaygroundBloc, PlaygroundState>(
        buildWhen: (_, current) => current is PlaygroundRoundFinishingState,
        builder: (_, state) {
          String player1Name = '';
          String player2Name = '';

          final isOnlyRoundFinished = state is PlaygroundRoundFinishingState &&
              !state.isFinished &&
              _playgroundBloc?.currentRound != null;
          if (isOnlyRoundFinished) {
            if (state.roomType == RoomTypeEnums.botPlayer) {
              player2Name = _appLocalizations.botPlayerName;
            } else {
              player2Name =
                  state.player2Name ?? _appLocalizations.defaultPlayerName(2);
            }
            player1Name =
                state.player1Name ?? _appLocalizations.defaultPlayerName(1);
          }

          return AbsorbPointer(
            absorbing: isOnlyRoundFinished,
            child: AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 500,
              ),
              switchInCurve: Curves.elasticIn,
              switchOutCurve: Curves.elasticIn,
              child: isOnlyRoundFinished
                  ? RoundCompletionDialog(
                      winnerType: state.winnerType!,
                      player1Move: state.player1Move!,
                      player2Move: state.player2Move!,
                      player1Name: player1Name,
                      player2Name: player2Name,
                      roundNo: state.round!,
                      isWon: state.isWon,
                    )
                  : const SizedBox(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoundTimeoutDialog() {
    return Positioned.fill(
      child: BlocBuilder<PlaygroundBloc, PlaygroundState>(
        buildWhen: (_, current) => current is PlaygroundRoundTimedOutState,
        builder: (_, state) {
          final shouldShow =
              state is PlaygroundRoundTimedOutState && state.isLoading;
          return AbsorbPointer(
            absorbing: shouldShow,
            child: AnimatedSwitcher(
              duration: const Duration(
                milliseconds: 500,
              ),
              switchInCurve: Curves.elasticIn,
              switchOutCurve: Curves.elasticIn,
              child: shouldShow
                  ? LoadingDialog(
                      title: _appLocalizations
                          .roundNoTitle(_playgroundBloc?.currentRound ?? 0),
                      subtitle: _appLocalizations.timeoutSubtitle,
                      animation: Assets.timeoutAnimation,
                    )
                  : const SizedBox(),
            ),
          );
        },
      ),
    );
  }
}
