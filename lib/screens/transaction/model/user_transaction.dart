import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';

class UserTransaction {
  String? transactionId;
  String? transactionUserId;
  String? transactionRoomId;
  String? transactionType;
  String? opponentName;
  double? transactionAmount;
  double? transactionPostWalletBal;
  int? createdAt;

  UserTransaction({
    this.transactionId,
    this.transactionUserId,
    this.transactionAmount,
    this.opponentName,
    this.transactionRoomId,
    this.transactionType,
    this.transactionPostWalletBal,
    this.createdAt,
  });

  factory UserTransaction.fromSnapshot(DocumentSnapshot data) {
    return UserTransaction(
      transactionId: data[FireStoreConfig.transactionIdField] as String?,
      transactionUserId:
          data[FireStoreConfig.transactionUserIdField] as String?,
      transactionRoomId:
          data[FireStoreConfig.transactionRoomIdField] as String?,
      transactionType: data[FireStoreConfig.transactionTypeField] as String?,
      opponentName: data[FireStoreConfig.transactionOpponentField] as String?,
      transactionPostWalletBal:
          (data[FireStoreConfig.transactionPostWalletBalField] as num?)
              ?.toDouble(),
      transactionAmount:
          (data[FireStoreConfig.transactionAmountField] as num?)?.toDouble(),
      createdAt: data[FireStoreConfig.createdAtField] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FireStoreConfig.transactionIdField: transactionId,
      FireStoreConfig.transactionUserIdField: transactionUserId,
      FireStoreConfig.transactionOpponentField: opponentName,
      FireStoreConfig.transactionRoomIdField: transactionRoomId,
      FireStoreConfig.transactionTypeField: transactionType,
      FireStoreConfig.transactionPostWalletBalField: transactionPostWalletBal,
      FireStoreConfig.transactionAmountField: transactionAmount,
      FireStoreConfig.createdAtField: createdAt,
    };
  }
}
