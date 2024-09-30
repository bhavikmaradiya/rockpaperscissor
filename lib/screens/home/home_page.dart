import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/config/app_config.dart';
import 'package:rockpaperscissor/const/assets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/enums/room_type_enums.dart';
import 'package:rockpaperscissor/routes.dart';
import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/screens/home/bloc/home_bloc.dart';
import 'package:rockpaperscissor/screens/home/widget/popup_dialog.dart';
import 'package:rockpaperscissor/screens/room/bloc/room_pref_bloc.dart';
import 'package:rockpaperscissor/screens/room/room_pref_dialog.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';
import 'package:rockpaperscissor/utils/notification_token_helper.dart';
import 'package:rockpaperscissor/utils/sound_utils.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';
import 'package:rockpaperscissor/widgets/button_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeBloc? _homeBlocProvider;
  late AppLocalizations _appLocalizations;
  bool _isTopUpDialogVisible = false;

  final _searchTextController = TextEditingController();
  final _searchTextFocusNode = FocusNode();

  @override
  void initState() {
    StaticFunctions.getCurrentUser();
    NotificationTokenHelper.uploadFcmToken();
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    if (StaticFunctions.userId == null ||
        StaticFunctions.userId!.trim().isEmpty) {
      await StaticFunctions.getCurrentUserId();
    }
    if (_homeBlocProvider == null) {
      _homeBlocProvider = BlocProvider.of<HomeBloc>(context);
      _homeBlocProvider?.add(
        HomeInitialEvent(),
      );
    }
    super.didChangeDependencies();
  }

  void _listenToHomeState(
    _,
    HomeState state,
  ) {
    if (state is HomeLoggedOutState) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        Routes.authentication,
        (route) => false,
      );
    } else if (state is HomeWalletTopUpState) {
      if (!state.shouldHide) {
        _isTopUpDialogVisible = true;
        _showWalletTopDialog();
      } else if (_isTopUpDialogVisible) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    final titlePadding = MediaQuery.sizeOf(context).height * 0.07;
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (prev, current) =>
          current is HomeLoggedOutState || current is HomeWalletTopUpState,
      listener: _listenToHomeState,
      child: Scaffold(
        body: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: Dimens.dimens_20.w,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Column(
                  children: [
                    SafeArea(
                      bottom: false,
                      child: Hero(
                        tag: Assets.loginBanner,
                        child: Image.asset(
                          Assets.loginBanner,
                          width: double.infinity,
                          height: Dimens.dimens_300.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // Flickering neon line
                    FlickerNeonLine(
                      spreadColor: Colors.yellow.shade200,
                      lightSpreadRadius: 5,
                      lightBlurRadius: 20,
                      lineWidth: double.infinity,
                      margin: EdgeInsets.symmetric(
                        horizontal: Dimens.dimens_35.w,
                      ),
                      lineHeight: 1,
                      lineColor: Colors.white10,
                      randomFlicker: false,
                      flickerTimeInMilliSeconds: 0,
                    ),
                    BlocBuilder<HomeBloc, HomeState>(
                      buildWhen: (_, current) => current is ProfileUpdatedState,
                      builder: (_, state) {
                        final isProfileState = state is ProfileUpdatedState;
                        final currentUser = isProfileState ? state.user : null;
                        final isFirstTimeUser =
                            isProfileState ? state.isFirstTime : true;
                        return _buildUsernameWidget(
                          context,
                          currentUser: currentUser,
                          isFirstTimeUser: isFirstTimeUser,
                          titlePadding: titlePadding,
                        );
                      },
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: Dimens.dimens_40.w,
                        ),
                        child: Column(
                          children: [
                            ButtonWidget(
                              title: _appLocalizations.playWithBotOption,
                              textSize: Dimens.dimens_27.sp,
                              onTap: () {
                                SoundUtils.playButtonClick();
                                _showAmountAndRoundsDialog(
                                  RoomTypeEnums.botPlayer,
                                );
                              },
                            ),
                            SizedBox(
                              height: Dimens.dimens_25.h,
                            ),
                            ButtonWidget(
                              title: _appLocalizations.playMultiplayerOption,
                              textSize: Dimens.dimens_27.sp,
                              onTap: () {
                                SoundUtils.playButtonClick();
                                _showMultiplayerDialog();
                              },
                            ),
                            SizedBox(
                              height: Dimens.dimens_25.h,
                            ),
                            ButtonWidget(
                              title: _appLocalizations.viewWalletOption,
                              textSize: Dimens.dimens_27.sp,
                              onTap: () {
                                SoundUtils.playButtonClick();
                                Navigator.pushNamed(
                                  context,
                                  Routes.transaction,
                                );
                              },
                            ),
                            SizedBox(
                              height: Dimens.dimens_25.h,
                            ),
                            ButtonWidget(
                              title: _appLocalizations.gameHistoryOption,
                              textSize: Dimens.dimens_27.sp,
                              onTap: () {
                                SoundUtils.playButtonClick();
                                Navigator.pushNamed(
                                  context,
                                  Routes.gameHistory,
                                );
                              },
                            ),
                            SafeArea(
                              top: false,
                              child: SizedBox(
                                height: Dimens.dimens_15.h,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: Dimens.dimens_12.h,
                right: Dimens.dimens_7.w,
                child: SafeArea(
                  child: FlickerNeonContainer(
                    containerColor: ColorUtils.getColor(
                      context,
                      ColorEnums.purpleColor,
                    ),
                    flickerTimeInMilliSeconds: 0,
                    borderRadius: BorderRadius.circular(
                      Dimens.dimens_15.r,
                    ),
                    borderColor: ColorUtils.getColor(
                      context,
                      ColorEnums.whiteColor,
                    ),
                    borderWidth: Dimens.dimens_1.w,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(
                          Dimens.dimens_15.r,
                        ),
                        onTap: () {
                          SoundUtils.playButtonClick();
                          _showLogoutDialog();
                        },
                        child: Padding(
                          padding: EdgeInsets.all(
                            Dimens.dimens_10.r,
                          ),
                          child: const Icon(
                            Icons.logout,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: Dimens.dimens_12.h,
                left: Dimens.dimens_7.w,
                child: SafeArea(
                  child: BlocBuilder<HomeBloc, HomeState>(
                    buildWhen: (_, current) => current is ProfileUpdatedState,
                    builder: (_, state) {
                      final balance = (state is ProfileUpdatedState &&
                                  state.user.walletBalance != null
                              ? state.user.walletBalance!.round()
                              : 0)
                          .toString();
                      return FlickerNeonContainer(
                        containerColor: ColorUtils.getColor(
                          context,
                          ColorEnums.purpleColor,
                        ),
                        flickerTimeInMilliSeconds: 0,
                        borderRadius: BorderRadius.circular(
                          Dimens.dimens_15.r,
                        ),
                        borderColor: ColorUtils.getColor(
                          context,
                          ColorEnums.whiteColor,
                        ),
                        borderWidth: Dimens.dimens_1.w,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              Dimens.dimens_15.r,
                            ),
                            onTap: () {
                              SoundUtils.playButtonClick();
                              Navigator.pushNamed(
                                context,
                                Routes.transaction,
                                arguments: state is ProfileUpdatedState
                                    ? state.user
                                    : null,
                              );
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: Dimens.dimens_9.w,
                                vertical: Dimens.dimens_6.h,
                              ),
                              child: Hero(
                                tag: Routes.transaction,
                                child: Material(
                                  color: Colors.transparent,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Image.asset(
                                        Assets.coinIcon,
                                        height: Dimens.dimens_35.w,
                                        width: Dimens.dimens_35.w,
                                      ),
                                      SizedBox(
                                        width: Dimens.dimens_2.w,
                                      ),
                                      Flexible(
                                        child: FlickerNeonText(
                                          text: balance.length > 3
                                              ? '$balance..'
                                              : balance,
                                          flickerTimeInMilliSeconds: 0,
                                          textColor: ColorUtils.getColor(
                                            context,
                                            ColorEnums.whiteColor,
                                          ),
                                          maxLine: 1,
                                          textOverflow: TextOverflow.ellipsis,
                                          spreadColor: Colors.purple,
                                          blurRadius: 20,
                                          textSize: Dimens.dimens_26.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return PopupDialog(
          title: _appLocalizations.logoutTitle,
          subTitle: _appLocalizations.logoutSubtitle,
          content: Row(
            children: [
              Expanded(
                child: ButtonWidget(
                  title: _appLocalizations.logoutNegative,
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
                  title: _appLocalizations.logoutPositive,
                  textSize: Dimens.dimens_24.sp,
                  onTap: () {
                    SoundUtils.playButtonClick();
                    Navigator.pop(context);
                    _homeBlocProvider?.add(
                      HomeLogoutEvent(),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  AnimatedSwitcher _buildUsernameWidget(
    BuildContext context, {
    User? currentUser,
    required bool isFirstTimeUser,
    required double titlePadding,
  }) {
    return AnimatedSwitcher(
      duration: const Duration(
        milliseconds: 500,
      ),
      switchInCurve: Curves.elasticIn,
      switchOutCurve: Curves.elasticIn,
      child: currentUser?.name != null
          ? Column(
              children: [
                SizedBox(
                  height: Dimens.dimens_30.h,
                ),
                FlickerNeonText(
                  text: isFirstTimeUser
                      ? _appLocalizations.homeUserNameFirstTitle(
                          currentUser!.name!,
                        )
                      : _appLocalizations.homeUserNameSecondTitle(
                          currentUser!.name!,
                        ),
                  flickerTimeInMilliSeconds: 0,
                  textColor: ColorUtils.getColor(
                    context,
                    ColorEnums.whiteColor,
                  ),
                  spreadColor: Colors.purple,
                  blurRadius: 20,
                  textSize: Dimens.dimens_30.sp,
                ),
                SizedBox(
                  height: titlePadding,
                ),
              ],
            )
          : SizedBox(
              height: Dimens.dimens_35.h + (titlePadding * 1.5),
            ),
    );
  }

  void _showMultiplayerDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return PopupDialog(
          title: _appLocalizations.playMultiplayerOption,
          subTitle: _appLocalizations.letsMatch,
          content: Column(
            children: [
              ButtonWidget(
                title: _appLocalizations.quickMatchOption,
                textSize: Dimens.dimens_24.sp,
                onTap: () {
                  SoundUtils.playButtonClick();
                  Navigator.pop(context);
                  _showAmountAndRoundsDialog(
                    RoomTypeEnums.realPlayer,
                    autoMatch: true,
                  );
                },
              ),
              SizedBox(
                height: Dimens.dimens_10.h,
              ),
              ButtonWidget(
                title: _appLocalizations.friendMatchOption,
                textSize: Dimens.dimens_24.sp,
                onTap: () {
                  SoundUtils.playButtonClick();
                  Navigator.pop(context);
                  _showAmountAndRoundsDialog(
                    RoomTypeEnums.realPlayer,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAmountAndRoundsDialog(
    RoomTypeEnums roomType, {
    bool autoMatch = false,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return BlocProvider<RoomPrefBloc>(
          create: (_) => RoomPrefBloc(),
          child: RoomPrefDialog(
            roomType: roomType,
            shouldAutoMatch: autoMatch,
          ),
        );
      },
    );
  }

  void _showWalletTopDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return Stack(
          children: [
            Center(
              child: PopupDialog(
                title: _appLocalizations.walletTopupFirstTimeTitle,
                content: Column(
                  children: [
                    Lottie.asset(
                      Assets.walletAnimation,
                      height: Dimens.dimens_170.w,
                      width: Dimens.dimens_170.w,
                    ),
                    SizedBox(
                      height: Dimens.dimens_20.h,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: Dimens.dimens_7.w,
                      ),
                      child: Text(
                        _appLocalizations.walletTopupFirstTimeSubtitle(
                          AppConfig.initialWalletAmount,
                        ),
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
                    SizedBox(
                      height: Dimens.dimens_20.h,
                    ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Lottie.asset(
                Assets.winnerAnimation,
                height: Dimens.dimens_170.w,
                width: Dimens.dimens_170.w,
              ),
            ),
          ],
        );
      },
    ).then((value) {
      _isTopUpDialogVisible = false;
    });
  }

  @override
  void dispose() {
    _searchTextFocusNode.dispose();
    _searchTextController.dispose();
    super.dispose();
  }
}
