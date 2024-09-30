import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/config/app_config.dart';
import 'package:rockpaperscissor/const/assets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/enums/room_type_enums.dart';
import 'package:rockpaperscissor/routes.dart';
import 'package:rockpaperscissor/screens/home/widget/popup_dialog.dart';
import 'package:rockpaperscissor/screens/room/bloc/room_pref_bloc.dart';
import 'package:rockpaperscissor/screens/room/bloc/room_pref_event.dart';
import 'package:rockpaperscissor/screens/room/bloc/room_pref_state.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';
import 'package:rockpaperscissor/utils/sound_utils.dart';
import 'package:rockpaperscissor/widgets/app_text_field.dart';
import 'package:rockpaperscissor/widgets/button_widget.dart';
import 'package:rockpaperscissor/widgets/field_title.dart';
import 'package:rockpaperscissor/widgets/toast_widget.dart';

class RoomPrefDialog extends StatefulWidget {
  final RoomTypeEnums _roomType;
  final bool shouldAutoMatch;

  const RoomPrefDialog({
    super.key,
    required RoomTypeEnums roomType,
    this.shouldAutoMatch = false,
  }) : _roomType = roomType;

  @override
  State<RoomPrefDialog> createState() => _RoomPrefDialogState();
}

class _RoomPrefDialogState extends State<RoomPrefDialog> {
  RoomPrefBloc? _roomBlocProvider;
  late AppLocalizations appLocalizations;
  final _betAmountTextEditingController = TextEditingController();
  final _inviteCodeTextEditingController = TextEditingController();
  final _betAmountTextFocusNode = FocusNode();
  final _inviteCodeTextFocusNode = FocusNode();
  late FToast toastBuilder;

  @override
  void initState() {
    super.initState();
    toastBuilder = FToast();
    toastBuilder.init(context);
    _betAmountTextEditingController.text =
        AppConfig.defaultBetAmount.round().toString();
  }

  @override
  Future<void> didChangeDependencies() async {
    if (_roomBlocProvider == null) {
      _roomBlocProvider ??= BlocProvider.of<RoomPrefBloc>(context);
      _roomBlocProvider?.add(
        RoomPrefInitialEvent(
          roomType: widget._roomType,
          shouldAutoMatch: widget.shouldAutoMatch,
        ),
      );
    }
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _betAmountTextEditingController.dispose();
    _betAmountTextFocusNode.dispose();

    _inviteCodeTextEditingController.dispose();
    _inviteCodeTextFocusNode.dispose();
  }

  void _listenToState(
    BuildContext _,
    RoomPrefState state,
  ) {
    if (state is RoomPrefInsufficientWalletBalanceState) {
      toastBuilder.showToast(
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(
          seconds: AppConfig.defaultToastDuration,
        ),
        child: ToastWidget(
          message: appLocalizations.insufficientWalletAmount,
        ),
      );
    } else if (state is RoomPrefInvalidState) {
      toastBuilder.showToast(
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(
          seconds: AppConfig.defaultToastDuration,
        ),
        child: ToastWidget(
          message: appLocalizations.invalidPrefData,
        ),
      );
    } else if (state is RoomNotFoundState) {
      toastBuilder.showToast(
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(
          seconds: AppConfig.defaultToastDuration,
        ),
        child: ToastWidget(
          message: appLocalizations.noRoomFound,
        ),
      );
    } else if (state is RoomExpiredState) {
      toastBuilder.showToast(
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(
          seconds: AppConfig.defaultToastDuration,
        ),
        child: ToastWidget(
          message: appLocalizations.roomExpired,
        ),
      );
    } else if (state is RoomHostedSuccessState) {
      toastBuilder.showToast(
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(
          seconds: AppConfig.defaultToastDuration,
        ),
        child: ToastWidget(
          message: appLocalizations.roomPrefSuccess,
          isSuccess: true,
        ),
      );
      Navigator.pop(context);
      if (widget._roomType == RoomTypeEnums.realPlayer) {
        Navigator.pushNamed(
          context,
          Routes.lobby,
          arguments: state.roomData,
        );
      } else {
        Navigator.pushNamed(
          context,
          Routes.playground,
          arguments: state.roomData,
        );
      }
    } else if (state is RoomHostedQuickMatchState) {
      toastBuilder.showToast(
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(
          seconds: AppConfig.defaultToastDuration,
        ),
        child: ToastWidget(
          message: appLocalizations.roomPrefSuccess,
          isSuccess: true,
        ),
      );
      Navigator.pop(context);
      Navigator.pushNamed(
        context,
        Routes.lobby,
        arguments: state.quickMatch,
      );
    } else if (state is RoomJoinedSuccessState) {
      toastBuilder.showToast(
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(
          seconds: AppConfig.defaultToastDuration,
        ),
        child: ToastWidget(
          message: appLocalizations.roomPrefSuccess,
          isSuccess: true,
        ),
      );
      Navigator.pop(context);
      Navigator.pushNamed(
        context,
        Routes.lobby,
        arguments: state.roomData,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    appLocalizations = AppLocalizations.of(context)!;
    return BlocConsumer<RoomPrefBloc, RoomPrefState>(
      listenWhen: (prev, current) =>
          current is RoomPrefInvalidState ||
          current is RoomHostedSuccessState ||
          current is RoomJoinedSuccessState ||
          current is RoomHostedQuickMatchState ||
          current is RoomNotFoundState ||
          current is RoomExpiredState ||
          current is RoomPrefInsufficientWalletBalanceState,
      listener: _listenToState,
      buildWhen: (prev, current) =>
          current is RoomPrefLoadingState || current is RoomPrefUpdatedState,
      builder: (_, state) {
        final isLoading = state is RoomPrefLoadingState && state.isLoading;
        final isHostSelected = _roomBlocProvider?.isHostTabSelected ?? true;
        final shouldShowTabs = widget._roomType != RoomTypeEnums.botPlayer &&
            !widget.shouldAutoMatch;
        return PopScope(
          canPop: !isLoading,
          child: PopupDialog(
            title: appLocalizations.matchPreferenceTitle,
            content: Column(
              children: [
                if (shouldShowTabs)
                  _buildModeSwitcher(
                    isLoading,
                  ),
                if (shouldShowTabs)
                  SizedBox(
                    height: Dimens.dimens_10.h,
                  ),
                AnimatedSwitcher(
                  duration: const Duration(
                    milliseconds: 400,
                  ),
                  child: isHostSelected
                      ? Column(
                          children: [
                            SizedBox(
                              height: Dimens.dimens_10.h,
                            ),
                            _buildTitleText(
                              context,
                              title: isLoading
                                  ? appLocalizations.roomLoadingText
                                  : appLocalizations.matchPreferenceSubtitle,
                            ),
                            SizedBox(
                              height: Dimens.dimens_25.h,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(
                                milliseconds: 400,
                              ),
                              switchInCurve: Curves.ease,
                              switchOutCurve: Curves.ease,
                              child: isLoading
                                  ? Lottie.asset(
                                      Assets.handAnimation,
                                      height: Dimens.dimens_170.w,
                                      width: Dimens.dimens_170.w,
                                    )
                                  : _buildHostBody(),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              height: Dimens.dimens_10.h,
                            ),
                            _buildTitleText(
                              context,
                              title: isLoading
                                  ? appLocalizations.roomLoadingText
                                  : appLocalizations.roomJoinTitle,
                            ),
                            SizedBox(
                              height: Dimens.dimens_25.h,
                            ),
                            AnimatedSwitcher(
                              duration: const Duration(
                                milliseconds: 400,
                              ),
                              switchInCurve: Curves.ease,
                              switchOutCurve: Curves.ease,
                              child: isLoading
                                  ? Lottie.asset(
                                      Assets.handAnimation,
                                      height: Dimens.dimens_170.w,
                                      width: Dimens.dimens_170.w,
                                    )
                                  : _buildJoinBody(
                                      context,
                                    ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Text _buildTitleText(
    BuildContext context, {
    required String title,
  }) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: Dimens.dimens_23.sp,
        color: ColorUtils.getColor(
          context,
          ColorEnums.grayF5Color,
        ).withOpacity(0.9),
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Row _buildModeSwitcher(
    bool isLoading,
  ) {
    final isHostSelected = _roomBlocProvider?.isHostTabSelected ?? true;
    return Row(
      children: [
        Expanded(
          child: ButtonWidget(
            title: appLocalizations.host,
            textSize: Dimens.dimens_24.sp,
            backgroundColor: isHostSelected
                ? ColorEnums.lightYellowColor
                : ColorEnums.purpleColor,
            borderColor: isHostSelected
                ? ColorEnums.whiteColor
                : ColorEnums.transparentColor,
            textColor:
                isHostSelected ? ColorEnums.blackColor : ColorEnums.gray99Color,
            onTap: isLoading
                ? null
                : () {
                    if (!isHostSelected) {
                      SoundUtils.playButtonClick();
                      _roomBlocProvider?.add(
                        RoomSwitchHostJoinEvent(),
                      );
                    }
                  },
          ),
        ),
        SizedBox(
          width: Dimens.dimens_7.w,
        ),
        Expanded(
          child: ButtonWidget(
            title: appLocalizations.join,
            textSize: Dimens.dimens_24.sp,
            backgroundColor: !isHostSelected
                ? ColorEnums.lightYellowColor
                : ColorEnums.purpleColor,
            borderColor: !isHostSelected
                ? ColorEnums.whiteColor
                : ColorEnums.transparentColor,
            textColor: !isHostSelected
                ? ColorEnums.blackColor
                : ColorEnums.gray99Color,
            onTap: isLoading
                ? null
                : () {
                    if (isHostSelected) {
                      SoundUtils.playButtonClick();
                      _roomBlocProvider?.add(
                        RoomSwitchHostJoinEvent(),
                      );
                    }
                  },
          ),
        ),
      ],
    );
  }

  Column _buildHostBody() {
    const roundOptionsToDisplay = AppConfig.roundOptions;
    final room = _roomBlocProvider?.room;
    final selectedRound = _roomBlocProvider?.selectedRound;
    final shouldShowMinBetCheckbox = false;
    /* widget._roomType == RoomTypeEnums.realPlayer &&
                (_roomBlocProvider?.betAmount ?? 0) > 0;*/
    final hintAmount = (_roomBlocProvider?.betAmount ?? 0).round().toString();
    final isMinAmountShouldBeEqualToBetAmount =
        _roomBlocProvider?.isMinAmountShouldBeEqualToBetAmount ?? false;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldTitle(
          title: appLocalizations.selectRound,
          textSize: Dimens.dimens_18.sp,
          textColorEnum: ColorEnums.whiteColor,
        ),
        SizedBox(
          height: Dimens.dimens_10.h,
        ),
        GridView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: roundOptionsToDisplay.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: Dimens.dimens_10.h,
            mainAxisSpacing: Dimens.dimens_10.h,
            childAspectRatio: 2 / 1.5,
          ),
          itemBuilder: (_, index) {
            final currentRound = roundOptionsToDisplay[index];
            final isSelected = selectedRound == currentRound;
            return FlickerNeonContainer(
              width: double.infinity,
              containerColor: ColorUtils.getColor(
                context,
                isSelected
                    ? ColorEnums.lightYellowColor
                    : ColorEnums.purpleColor,
              ),
              flickerTimeInMilliSeconds: 0,
              borderRadius: BorderRadius.circular(
                Dimens.dimens_10.r,
              ),
              borderColor: ColorUtils.getColor(
                context,
                isSelected
                    ? ColorEnums.whiteColor
                    : ColorEnums.transparentColor,
              ),
              borderWidth: Dimens.dimens_2.w,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(
                    Dimens.dimens_10.r,
                  ),
                  onTap: () {
                    SoundUtils.playSelectionClick();
                    _roomBlocProvider?.add(
                      RoomRoundValueChangeEvent(
                        currentRound,
                      ),
                    );
                  },
                  child: Center(
                    child: FlickerNeonText(
                      text: currentRound.toString(),
                      flickerTimeInMilliSeconds: 0,
                      textColor: ColorUtils.getColor(
                        context,
                        isSelected
                            ? ColorEnums.blackColor
                            : ColorEnums.gray99Color,
                      ),
                      spreadColor: Colors.purple,
                      blurRadius: 20,
                      textSize: Dimens.dimens_30.sp,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        SizedBox(
          height: Dimens.dimens_25.h,
        ),
        AppTextField(
          title: appLocalizations.matchAmountTitle,
          titleTextSize: Dimens.dimens_18.sp,
          titleTextColor: ColorEnums.whiteColor,
          focusNode: _betAmountTextFocusNode,
          textEditingController: _betAmountTextEditingController,
          keyboardType: TextInputType.number,
          inputFormatter: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(
              AppConfig.amountMaxLength,
            ),
          ],
          keyboardAction: TextInputAction.done,
          hint: 'e.g. ₹ 50',
          hintStyle: TextStyle(
            color: ColorUtils.getColor(
              context,
              ColorEnums.grayA8Color,
            ),
          ),
          onTextChange: (amountText) => _roomBlocProvider?.add(
            RoomAmountTextChangeEvent(
              amountText,
            ),
          ),
        ),
        if (shouldShowMinBetCheckbox)
          SizedBox(
            height: Dimens.dimens_7.h,
          ),
        if (shouldShowMinBetCheckbox)
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _roomBlocProvider?.add(
                RoomMinBetValueSwitchEvent(),
              ),
              borderRadius: BorderRadius.circular(
                Dimens.dimens_5.r,
              ),
              child: Container(
                padding: EdgeInsets.all(
                  Dimens.dimens_1.r,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlickerNeonContainer(
                      containerColor: ColorUtils.getColor(
                        context,
                        isMinAmountShouldBeEqualToBetAmount
                            ? ColorEnums.lightYellowColor
                            : ColorEnums.purpleColor,
                      ),
                      flickerTimeInMilliSeconds: 0,
                      borderRadius: BorderRadius.circular(
                        Dimens.dimens_5.r,
                      ),
                      borderColor: ColorUtils.getColor(
                        context,
                        !isMinAmountShouldBeEqualToBetAmount
                            ? ColorEnums.whiteColor
                            : ColorEnums.transparentColor,
                      ),
                      borderWidth: Dimens.dimens_2.w,
                      child: isMinAmountShouldBeEqualToBetAmount
                          ? Icon(
                              Icons.check,
                              size: Dimens.dimens_25.r,
                              color: ColorUtils.getColor(
                                context,
                                ColorEnums.blackColor,
                              ),
                            )
                          : SizedBox(
                              width: Dimens.dimens_25.r,
                              height: Dimens.dimens_25.r,
                            ),
                    ),
                    SizedBox(
                      width: Dimens.dimens_10.w,
                    ),
                    Expanded(
                      child: FieldTitle(
                        title: appLocalizations.minEntranceAmountHint(
                          hintAmount.length > 4
                              ? '${hintAmount.substring(0, 3)}...'
                              : hintAmount,
                        ),
                        textSize: Dimens.dimens_16.sp,
                        textColorEnum: ColorEnums.whiteColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        SizedBox(
          height: Dimens.dimens_25.h,
        ),
        ButtonWidget(
          title: widget._roomType == RoomTypeEnums.botPlayer
              ? appLocalizations.play
              : appLocalizations.startMatch,
          onTap: () {
            SoundUtils.playButtonClick();
            _roomBlocProvider?.add(
              RoomPrefSubmitHostEvent(),
            );
          },
        ),
      ],
    );
  }

  Column _buildJoinBody(
    BuildContext context,
  ) {
    return Column(
      children: [
        AppTextField(
          title: appLocalizations.inviteCodeTitle,
          titleTextSize: Dimens.dimens_18.sp,
          titleTextColor: ColorEnums.whiteColor,
          focusNode: _inviteCodeTextFocusNode,
          textEditingController: _inviteCodeTextEditingController,
          keyboardType: TextInputType.text,
          inputFormatter: [
            LengthLimitingTextInputFormatter(
              AppConfig.invitationCodeLength,
            ),
          ],
          keyboardAction: TextInputAction.done,
          hint: 'e.g. AD12',
          hintStyle: TextStyle(
            color: ColorUtils.getColor(
              context,
              ColorEnums.grayA8Color,
            ),
          ),
          onTextChange: (amountText) {},
        ),
        SizedBox(
          height: Dimens.dimens_25.h,
        ),
        ButtonWidget(
          title: appLocalizations.join,
          onTap: () {
            SoundUtils.playButtonClick();
            _roomBlocProvider?.add(
              RoomJoinEvent(
                _inviteCodeTextEditingController.text,
              ),
            );
          },
        ),
      ],
    );
  }
}
