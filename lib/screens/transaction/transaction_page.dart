import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/config/app_config.dart';
import 'package:rockpaperscissor/const/assets.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/routes.dart';
import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/screens/home/widget/popup_dialog.dart';
import 'package:rockpaperscissor/screens/transaction/bloc/transaction_bloc.dart';
import 'package:rockpaperscissor/screens/transaction/bloc/transaction_event.dart';
import 'package:rockpaperscissor/screens/transaction/bloc/transaction_state.dart';
import 'package:rockpaperscissor/screens/transaction/widget/transaction_item.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';
import 'package:rockpaperscissor/utils/sound_utils.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';
import 'package:rockpaperscissor/widgets/app_text_field.dart';
import 'package:rockpaperscissor/widgets/button_widget.dart';
import 'package:rockpaperscissor/widgets/toast_widget.dart';
import 'package:rockpaperscissor/widgets/toolbar.dart';
import 'package:shimmer/shimmer.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  TransactionBloc? _transactionBloc;
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
    if (_transactionBloc == null) {
      User? currentUser;
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args != null && args is User) {
        currentUser = ModalRoute.of(context)?.settings.arguments as User;
      }
      _transactionBloc = BlocProvider.of<TransactionBloc>(context);
      _transactionBloc?.add(
        TransactionInitialEvent(
          currentUser: currentUser,
        ),
      );
    }
    super.didChangeDependencies();
  }

  void _listenToTransactionState(
    _,
    TransactionState state,
  ) {
    if (state is TransactionsToppedUpState) {
      toastBuilder.showToast(
        gravity: ToastGravity.TOP,
        toastDuration: const Duration(
          seconds: AppConfig.defaultToastDuration,
        ),
        child: ToastWidget(
          message: _appLocalizations.topupSuccess,
          isSuccess: true,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    _appLocalizations = AppLocalizations.of(context)!;
    return BlocListener<TransactionBloc, TransactionState>(
      listenWhen: (_, current) => current is TransactionsToppedUpState,
      listener: _listenToTransactionState,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: Dimens.dimens_20.w,
            ),
            child: Column(
              children: [
                ToolbarWidget(
                  title: _appLocalizations.transactionTitle,
                  onTap: () {
                    SoundUtils.playButtonClick();
                    Navigator.pop(context);
                  },
                ),
                SizedBox(
                  height: Dimens.dimens_10.h,
                ),
                _buildWallet(
                  context,
                ),
                SizedBox(
                  height: Dimens.dimens_30.h,
                ),
                Expanded(
                  child: BlocBuilder<TransactionBloc, TransactionState>(
                    buildWhen: (_, current) =>
                        current is TransactionsLoadingState ||
                        current is TransactionUpdatedState ||
                        current is TransactionsEmptyState,
                    builder: (_, state) {
                      final list = state is TransactionUpdatedState
                          ? state.transactionList
                          : [];
                      if (state is TransactionsLoadingState) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                      if (list.isEmpty) {
                        return Center(
                          child: FlickerNeonText(
                            text: _appLocalizations.noTransaction,
                            flickerTimeInMilliSeconds: 0,
                            textColor: ColorUtils.getColor(
                              context,
                              ColorEnums.whiteColor,
                            ),
                            textOverflow: TextOverflow.ellipsis,
                            spreadColor: Colors.white,
                            blurRadius: 10,
                            textSize: Dimens.dimens_21.sp,
                          ),
                        );
                      }
                      return ListView.builder(
                        itemCount: list.length,
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemBuilder: (_, index) {
                          return SafeArea(
                            top: false,
                            bottom: index == list.length - 1,
                            child: TransactionItem(
                              transaction: list[index],
                              appLocalizations: _appLocalizations,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showTopupDialog() {
    showDialog(
      context: context,
      builder: (_) {
        final amountFieldController = TextEditingController(
          text: AppConfig.defaultBetAmount.round().toString(),
        );
        return PopupDialog(
          title: _appLocalizations.topupTitle,
          content: Column(
            children: [
              AppTextField(
                title: _appLocalizations.topupTextFieldTitle,
                titleTextSize: Dimens.dimens_18.sp,
                titleTextColor: ColorEnums.whiteColor,
                textEditingController: amountFieldController,
                keyboardType: TextInputType.number,
                inputFormatter: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                    AppConfig.amountMaxLength,
                  ),
                ],
                keyboardAction: TextInputAction.done,
                hint: 'e.g. 50',
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
                title: _appLocalizations.topupBtn,
                textSize: Dimens.dimens_25.sp,
                borderWidth: Dimens.dimens_1.w,
                onTap: () {
                  SoundUtils.playButtonClick();
                  final amount =
                      double.tryParse(amountFieldController.text.trim());
                  if (amount != null && amount > 0) {
                    _transactionBloc?.add(
                      TransactionTopupWallet(
                        amount: amount,
                      ),
                    );
                    Navigator.pop(context);
                  } else {
                    toastBuilder.showToast(
                      gravity: ToastGravity.TOP,
                      toastDuration: const Duration(
                        seconds: AppConfig.defaultToastDuration,
                      ),
                      child: ToastWidget(
                        message: _appLocalizations.topupError,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  BlocBuilder<TransactionBloc, TransactionState> _buildWallet(
    BuildContext context,
  ) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      buildWhen: (_, current) => current is TransactionUserUpdatedState,
      builder: (_, state) {
        final user =
            state is TransactionUserUpdatedState ? state.currentUser : null;
        return Card(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              Dimens.dimens_15.r,
            ),
          ),
          color: ColorUtils.getColor(
            context,
            ColorEnums.redColor,
          ),
          child: FlickerNeonContainer(
            width: double.infinity,
            containerColor: ColorUtils.getColor(
              context,
              ColorEnums.purpleColor,
            ),
            flickerTimeInMilliSeconds: 0,
            borderRadius: BorderRadius.circular(
              Dimens.dimens_15.r,
            ),
            lightSpreadRadius: 0,
            lightBlurRadius: 0,
            borderColor: ColorUtils.getColor(
              context,
              ColorEnums.whiteColor,
            ),
            padding: EdgeInsets.symmetric(
              vertical: Dimens.dimens_15.h,
              horizontal: Dimens.dimens_15.w,
            ),
            borderWidth: Dimens.dimens_1.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Hero(
                  tag: Routes.transaction,
                  child: Material(
                    color: Colors.transparent,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          Assets.coinIcon,
                          height: Dimens.dimens_60.w,
                          width: Dimens.dimens_60.w,
                          scale: 10,
                        ),
                        Flexible(
                          child: FlickerNeonText(
                            text: (user?.walletBalance ?? 0).round().toString(),
                            flickerTimeInMilliSeconds: 0,
                            textColor: ColorUtils.getColor(
                              context,
                              ColorEnums.whiteColor,
                            ),
                            maxLine: 1,
                            textOverflow: TextOverflow.ellipsis,
                            spreadColor: Colors.purple,
                            blurRadius: 20,
                            textSize: Dimens.dimens_45.sp,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: Dimens.dimens_3.h,
                ),
                FlickerNeonText(
                  text: _appLocalizations.yourBalance,
                  flickerTimeInMilliSeconds: 0,
                  textColor: ColorUtils.getColor(
                    context,
                    ColorEnums.whiteColor,
                  ),
                  maxLine: 1,
                  textOverflow: TextOverflow.ellipsis,
                  spreadColor: Colors.purple,
                  blurRadius: 20,
                  textSize: Dimens.dimens_27.sp,
                ),
                SizedBox(
                  height: Dimens.dimens_20.h,
                ),
                ButtonWidget(
                  title: _appLocalizations.topUp,
                  textSize: Dimens.dimens_25.sp,
                  blurRadius: 2,
                  shouldSpread: false,
                  onTap: () {
                    SoundUtils.playButtonClick();
                    _showTopupDialog();
                  },
                  borderWidth: Dimens.dimens_1.w,
                  textColor: ColorEnums.purpleColor,
                  backgroundColor: ColorEnums.lightYellowColor2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
