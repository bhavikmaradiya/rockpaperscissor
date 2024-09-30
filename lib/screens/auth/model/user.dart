import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';

class User {
  String? userId;
  String? name;
  String? email;
  String? fcmTokens;
  double? walletBalance;
  int? createdAt;
  int? updatedAt;

  User({
    this.userId,
    this.name,
    this.email,
    this.fcmTokens,
    this.walletBalance,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromSnapshot(DocumentSnapshot document) {
    final data = document.data();
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception();
    }

    return User(
      userId: data[FireStoreConfig.userIdField] as String?,
      name: data[FireStoreConfig.userNameField] as String?,
      email: data[FireStoreConfig.userEmailField] as String?,
      walletBalance: (data[FireStoreConfig.userWalletBalanceField] as num?)?.toDouble(),
      fcmTokens: data[FireStoreConfig.userFcmTokenField] as String?,
      createdAt: data[FireStoreConfig.createdAtField] as int?,
      updatedAt: data[FireStoreConfig.updatedAtField] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FireStoreConfig.userIdField: userId,
      FireStoreConfig.userNameField: name,
      FireStoreConfig.userEmailField: email,
      FireStoreConfig.userWalletBalanceField: walletBalance,
      FireStoreConfig.userFcmTokenField: fcmTokens,
      FireStoreConfig.createdAtField: createdAt,
      FireStoreConfig.updatedAtField: updatedAt,
    };
  }
}
