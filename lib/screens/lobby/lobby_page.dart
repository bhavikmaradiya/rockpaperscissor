import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/config/app_config.dart';
import 'package:rockpaperscissor/const/assets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/enums/room_status_enums.dart';
import 'package:rockpaperscissor/routes.dart';
import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/screens/home/widget/popup_dialog.dart';
import 'package:rockpaperscissor/screens/lobby/bloc/lobby_bloc.dart';
import 'package:rockpaperscissor/screens/lobby/bloc/lobby_event.dart';
import 'package:rockpaperscissor/screens/lobby/bloc/lobby_state.dart';
import 'package:rockpaperscissor/screens/playground/bloc/playground_bloc.dart';
import 'package:rockpaperscissor/screens/room/model/quick_match.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';
import 'package:rockpaperscissor/utils/sound_utils.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';
import 'package:rockpaperscissor/widgets/button_widget.dart';
import 'package:rockpaperscissor/widgets/toast_widget.dart';

class LobbyPage extends StatefulWidget {
  const LobbyPage({super.key});

  @override
  State<LobbyPage> createState() => _LobbyPageState();
}

class _LobbyPageState extends State<LobbyPage> {
  LobbyBloc? _lobbyBloc;
  late AppLocalizations _appLocalizations;
  late FToast toastBuilder;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    toastBuilder = FToast();
    toastBuilder.init(context);
  }

  @override
  Future<void> didChangeDependencies() async {
    currentUser = await StaticFunctions.getCurrentUser();
    if (_lobbyBloc == null) {
      final args = ModalRoute.of(context)?.settings.arguments;
      Room? room;
      QuickMatch? quickMatch;
      if (args is Room) {
        room = args;
      }
      if (args is QuickMatch) {
        quickMatch = args;
      }
      _lobbyBloc ??= BlocProvider.of<LobbyBloc>(context);
      _lobbyBloc?.add(
        LobbyInitialEvent(
          room: room,
          quickMatch: quickMatch,
        ),
      );
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: PopScope(
        canPop: false,
        child: SafeArea(
          child: Stack(
            children: [
              BlocConsumer<LobbyBloc, LobbyState>(
                listener: (_, state) {
                  if (state is LobbyOpponentFoundState) {
                    Navigator.pushReplacementNamed(
                      context,
                      Routes.playground,
                      arguments: state.currentRoom,
                    );
                  } else if (state is LobbyCanceledSuccessfulState) {
                    toastBuilder.showToast(
                      gravity: ToastGravity.TOP,
                      toastDuration: const Duration(
                        seconds: AppConfig.defaultToastDuration,
                      ),
                      child: ToastWidget(
                        message: state.isExpired
                            ? _appLocalizations.roomExpiredToast
                            : _appLocalizations.cancelledLobbyMsg,
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                listenWhen: (_, current) =>
                    current is LobbyOpponentFoundState ||
                    current is LobbyCanceledSuccessfulState,
                buildWhen: (prev, current) =>
                    current is LobbyRoomChangesState ||
                    current is LobbyExpiredState ||
                    current is TimerRunningState,
                builder: (_, state) {
                  final room = _lobbyBloc?.currentRoom;
                  final quickMatch = _lobbyBloc?.currentQuickMatch;
                  final inviteCode = room?.inviteCode;
                  return SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: Dimens.dimens_25.h,
                        ),
                        if (room?.hostId == StaticFunctions.userId &&
                            inviteCode != null &&
                            inviteCode.trim().isNotEmpty)
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
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _copyToClipboard(
                                  inviteCode,
                                ),
                                borderRadius: BorderRadius.circular(
                                  Dimens.dimens_10.r,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: Dimens.dimens_12.w,
                                    vertical: Dimens.dimens_4.h,
                                  ),
                                  child: Column(
                                    children: [
                                      FlickerNeonText(
                                        text: _appLocalizations.inviteCodeReady,
                                        flickerTimeInMilliSeconds: 0,
                                        textColor: ColorUtils.getColor(
                                          context,
                                          ColorEnums.whiteColor,
                                        ),
                                        spreadColor: Colors.purple,
                                        blurRadius: 20,
                                        textSize: Dimens.dimens_22.sp,
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.copy,
                                            size: Dimens.dimens_20.w,
                                          ),
                                          SizedBox(
                                            width: Dimens.dimens_10.w,
                                          ),
                                          FlickerNeonText(
                                            text: inviteCode,
                                            flickerTimeInMilliSeconds: 0,
                                            textColor: ColorUtils.getColor(
                                              context,
                                              ColorEnums.whiteColor,
                                            ),
                                            spreadColor: Colors.white,
                                            blurRadius: 10,
                                            textOverflow: TextOverflow.ellipsis,
                                            fontWeight: FontWeight.bold,
                                            textSize: Dimens.dimens_30.sp,
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        SizedBox(
                          height: Dimens.dimens_3.h,
                        ),
                        _buildPlayer(
                          playerName:
                              '${currentUser?.name ?? _appLocalizations.defaultPlayerName(1)} (${_appLocalizations.you})',
                        ),
                        const Spacer(),
                        BlocBuilder<LobbyBloc, LobbyState>(
                          buildWhen: (_, state) =>
                              state is LobbyLoadOpponentViewState,
                          builder: (_, state) {
                            final opponent = state is LobbyLoadOpponentViewState
                                ? state.opponentPlayer
                                : null;
                            return FlickerNeonText(
                              text: opponent == null
                                  ? _appLocalizations.waiting
                                  : _appLocalizations.vs,
                              flickerTimeInMilliSeconds: 0,
                              textColor: ColorUtils.getColor(
                                context,
                                ColorEnums.whiteColor,
                              ),
                              spreadColor: Colors.white,
                              blurRadius: 0,
                              textOverflow: TextOverflow.ellipsis,
                              textSize: Dimens.dimens_28.sp,
                            );
                          },
                        ),
                        const Spacer(),
                        BlocBuilder<LobbyBloc, LobbyState>(
                          buildWhen: (_, state) =>
                              state is LobbyLoadOpponentViewState,
                          builder: (_, state) {
                            final opponent = state is LobbyLoadOpponentViewState
                                ? state.opponentPlayer
                                : null;
                            return AnimatedSwitcher(
                              duration: const Duration(
                                milliseconds: 500,
                              ),
                              switchInCurve: Curves.elasticIn,
                              switchOutCurve: Curves.elasticIn,
                              child: opponent != null
                                  ? _buildPlayer(
                                      playerName: opponent.name ??
                                          _appLocalizations.defaultPlayerName(
                                            2,
                                          ),
                                    )
                                  : const SizedBox(),
                            );
                          },
                        ),
                        const Spacer(),
                        BlocBuilder<LobbyBloc, LobbyState>(
                          buildWhen: (_, current) =>
                              state is TimerRunningState ||
                              state is LobbyExpiredState,
                          builder: (_, state) {
                            int? remainingTime;
                            Duration? duration;
                            String? expireTime;
                            if (state is TimerRunningState &&
                                state.remainingTime > 0) {
                              remainingTime = state.remainingTime;
                              duration = Duration(
                                seconds: remainingTime,
                              );
                              String twoDigits(int n) =>
                                  n.toString().padLeft(2, "0");
                              final seconds = twoDigits(
                                  duration.inSeconds.remainder(60).abs());
                              final minute = twoDigits(
                                  duration.inMinutes.remainder(60).abs());
                              expireTime = '$minute:$seconds';
                            }
                            return Column(
                              children: [
                                if (state is TimerRunningState &&
                                    state.remainingTime > 0)
                                  Column(
                                    children: [
                                      FlickerNeonText(
                                        text: !state.isExpired
                                            ? _appLocalizations.matchStartsIn
                                            : _appLocalizations.matchExpiresIn,
                                        flickerTimeInMilliSeconds: 0,
                                        textColor: ColorUtils.getColor(
                                          context,
                                          ColorEnums.whiteColor,
                                        ),
                                        spreadColor: Colors.white,
                                        blurRadius: 20,
                                        fontWeight: FontWeight.bold,
                                        textOverflow: TextOverflow.ellipsis,
                                        textSize: Dimens.dimens_26.sp,
                                      ),
                                      FlickerNeonText(
                                        text: state.isExpired
                                            ? expireTime!
                                            : '${state.remainingTime}s',
                                        flickerTimeInMilliSeconds: 2000,
                                        textColor: ColorUtils.getColor(
                                          context,
                                          state.isExpired ||
                                                  state.remainingTime < 5
                                              ? ColorEnums.redColor
                                              : ColorEnums.greenColor,
                                        ),
                                        spreadColor: Colors.white,
                                        blurRadius: 20,
                                        fontWeight: FontWeight.bold,
                                        textOverflow: TextOverflow.ellipsis,
                                        textSize: Dimens.dimens_26.sp,
                                      ),
                                    ],
                                  ),
                                if (state is! LobbyExpiredState &&
                                    (state is TimerRunningState &&
                                        state.isExpired) &&
                                    (quickMatch != null ||
                                        room?.hostId == StaticFunctions.userId))
                                  Column(
                                    children: [
                                      SizedBox(
                                        height: Dimens.dimens_5.h,
                                      ),
                                      Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: Dimens.dimens_35.w,
                                          vertical: Dimens.dimens_5.h,
                                        ),
                                        child: ButtonWidget(
                                          title: _appLocalizations.cancel,
                                          textSize: Dimens.dimens_28.sp,
                                          onTap: () {
                                            SoundUtils.playButtonClick();
                                            _showCancelRoomDialog();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            );
                          },
                        ),
                        SizedBox(
                          height: Dimens.dimens_20.h,
                        ),
                      ],
                    ),
                  );
                },
              ),
              BlocBuilder<LobbyBloc, LobbyState>(
                buildWhen: (_, current) => current is LobbyLoadingState,
                builder: (_, state) {
                  final isLoading =
                      state is LobbyLoadingState && state.isLoading;
                  return Positioned.fill(
                    child: AbsorbPointer(
                      absorbing: isLoading,
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const SizedBox(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer({
    required String playerName,
  }) {
    return Column(
      children: [
        Container(
          height: Dimens.dimens_205.w,
          width: Dimens.dimens_205.w,
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              Positioned.fill(
                child: Lottie.asset(
                  Assets.rippleAnimation,
                  height: Dimens.dimens_200.w,
                  width: Dimens.dimens_200.w,
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Image.asset(
                  Assets.userPlaceholder,
                  height: Dimens.dimens_200.w / 2.1,
                  width: Dimens.dimens_200.w / 2.1,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: FlickerNeonText(
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
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showCancelRoomDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return PopupDialog(
          title: _appLocalizations.cancelRoomTitle,
          subTitle: _appLocalizations.cancelRoomSubtitle,
          content: Row(
            children: [
              Expanded(
                child: ButtonWidget(
                  title: _appLocalizations.no,
                  textSize: Dimens.dimens_24.sp,
                  onTap: () {
                    SoundUtils.playButtonClick();
                    Navigator.pop(context);
                  },
                ),
              ),
              SizedBox(
                width: Dimens.dimens_10.w,
              ),
              Expanded(
                child: ButtonWidget(
                  title: _appLocalizations.yesCancel,
                  textSize: Dimens.dimens_24.sp,
                  onTap: () {
                    SoundUtils.playButtonClick();
                    Navigator.pop(context);
                    _lobbyBloc?.add(
                      CancelGameEvent(),
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  void _copyToClipboard(
    String inviteCode,
  ) {
    Clipboard.setData(
      ClipboardData(
        text: inviteCode,
      ),
    ).then(
      (value) {
        toastBuilder.showToast(
          gravity: ToastGravity.BOTTOM,
          toastDuration: const Duration(
            seconds: AppConfig.defaultToastDuration,
          ),
          child: ToastWidget(
            message: _appLocalizations.inviteCodeCopied,
            isSuccess: true,
          ),
        );
      },
    );
  }
}
