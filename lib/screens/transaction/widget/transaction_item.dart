import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:neon_widgets/neon_widgets.dart';
import 'package:rockpaperscissor/config/app_config.dart';
import 'package:rockpaperscissor/const/assets.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:rockpaperscissor/const/dimens.dart';
import 'package:rockpaperscissor/enums/color_enums.dart';
import 'package:rockpaperscissor/enums/transaction_type_enums.dart';
import 'package:rockpaperscissor/screens/transaction/model/user_transaction.dart';
import 'package:rockpaperscissor/utils/color_utils.dart';

class TransactionItem extends StatelessWidget {
  final UserTransaction transaction;
  final AppLocalizations appLocalizations;

  const TransactionItem({
    super.key,
    required this.transaction,
    required this.appLocalizations,
  });

  @override
  Widget build(BuildContext context) {
    final transactionType =
        transaction.transactionType == TransactionTypeEnums.gameWon.name
            ? TransactionTypeEnums.gameWon
            : transaction.transactionType == TransactionTypeEnums.gameLost.name
                ? TransactionTypeEnums.gameLost
                : TransactionTypeEnums.topUp;
    final dateTime = DateFormat(AppConfig.transactionDateTimeFormat).format(
      DateTime.fromMillisecondsSinceEpoch(
        transaction.createdAt!,
      ),
    );
    final isWinner = transactionType == TransactionTypeEnums.gameWon;
    final isLoser = transactionType == TransactionTypeEnums.gameLost;
    final isTopUp = transactionType == TransactionTypeEnums.topUp;
    final amount = (transaction.transactionAmount ?? 0).round();
    final walletAmount = (transaction.transactionPostWalletBal ?? 0).round();
    final amountString = (amount.toString().length > 3
        ? '${amount.toString().substring(0, 3)}..'
        : amount.toString());
    final walletAmountString = (walletAmount.toString().length > 3
        ? '${walletAmount.toString().substring(0, 3)}..'
        : walletAmount.toString());
    final isNegative = amount.isNegative;
    return Card(
      color: Colors.purple,
      margin: EdgeInsets.symmetric(
        vertical: Dimens.dimens_9.h,
      ),
      elevation: 15,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Dimens.dimens_10.w,
          vertical: Dimens.dimens_11.h,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FlickerNeonContainer(
              containerColor: ColorUtils.getColor(
                context,
                ColorEnums.purpleColor,
              ),
              flickerTimeInMilliSeconds: 0,
              borderRadius: BorderRadius.circular(
                Dimens.dimens_30.r,
              ),
              lightSpreadRadius: 0,
              lightBlurRadius: 0,
              padding: EdgeInsets.all(
                Dimens.dimens_11.r,
              ),
              borderColor: ColorUtils.getColor(
                context,
                ColorEnums.whiteColor,
              ),
              borderWidth: Dimens.dimens_1.w,
              child: Image.asset(
                isWinner
                    ? Assets.winnerFlagIcon
                    : isLoser
                        ? Assets.gameOverIcon
                        : Assets.coinIcon,
                width: Dimens.dimens_30.w,
                height: Dimens.dimens_30.w,
              ),
            ),
            SizedBox(
              width: Dimens.dimens_7.w,
            ),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: FlickerNeonText(
                      text: isWinner
                          ? appLocalizations.transactionWonTitle(
                              transaction.opponentName!,
                            )
                          : isLoser
                              ? appLocalizations.transactionLostTitle(
                                  transaction.opponentName!,
                                )
                              : appLocalizations.transactionTopupTitle(
                                  amount,
                                ),
                      flickerTimeInMilliSeconds: 0,
                      textColor: ColorUtils.getColor(
                        context,
                        ColorEnums.whiteColor,
                      ),
                      maxLine: 2,
                      textAlign: TextAlign.start,
                      textOverflow: TextOverflow.ellipsis,
                      spreadColor: Colors.white,
                      blurRadius: 0,
                      textSize: Dimens.dimens_18.sp,
                    ),
                  ),
                  SizedBox(
                    height: Dimens.dimens_1.h,
                  ),
                  Flexible(
                    child: FlickerNeonText(
                      text: dateTime,
                      flickerTimeInMilliSeconds: 0,
                      textColor: ColorUtils.getColor(
                        context,
                        ColorEnums.whiteColor,
                      ),
                      maxLine: 1,
                      textOverflow: TextOverflow.ellipsis,
                      spreadColor: Colors.white,
                      blurRadius: 0,
                      textSize: Dimens.dimens_16.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: Dimens.dimens_10.w,
            ),
            if (amount != 0)
              Column(
                children: [
                  FlickerNeonContainer(
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
                    padding: EdgeInsets.all(
                      Dimens.dimens_10.r,
                    ),
                    borderColor: ColorUtils.getColor(
                      context,
                      ColorEnums.whiteColor,
                    ),
                    borderWidth: Dimens.dimens_1.w,
                    child: FlickerNeonText(
                      text: isNegative ? amountString : '+$amountString',
                      flickerTimeInMilliSeconds: 0,
                      textColor: ColorUtils.getColor(
                        context,
                        transaction.transactionAmount!.round().isNegative
                            ? ColorEnums.redColor
                            : ColorEnums.greenColor,
                      ),
                      maxLine: 1,
                      textOverflow: TextOverflow.ellipsis,
                      spreadColor: Colors.white,
                      blurRadius: 0,
                      textSize: Dimens.dimens_21.sp,
                    ),
                  ),
                  SizedBox(
                    height: Dimens.dimens_3.h,
                  ),
                  if (walletAmount != 0)
                    FlickerNeonText(
                      text: walletAmountString,
                      flickerTimeInMilliSeconds: 0,
                      textColor: ColorUtils.getColor(
                        context,
                        ColorEnums.whiteColor,
                      ),
                      maxLine: 1,
                      textOverflow: TextOverflow.ellipsis,
                      spreadColor: Colors.white,
                      blurRadius: 0,
                      textSize: Dimens.dimens_18.sp,
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
