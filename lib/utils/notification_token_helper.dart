import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';
import 'package:rockpaperscissor/screens/auth/model/user.dart';

import '../utils/static_functions.dart';

class NotificationTokenHelper {
  static String? _fcmToken = '';

  static Future<void> uploadFcmToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      unawaited(
        _updateFcmTokenToFirebase(
          newToken: fcmToken,
        ),
      );
    }
  }

  static void observeNotificationChange() {
    FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) async {
        unawaited(
          _updateFcmTokenToFirebase(
            newToken: token,
          ),
        );
      },
    );
  }

  static Future<void> _updateFcmTokenToFirebase({
    required String newToken,
  }) async {
    final firebaseUserId = await StaticFunctions.getCurrentUserId();
    if (firebaseUserId != null) {
      final profileInfo = await _fetchProfileInfoFromFirebase(firebaseUserId);
      if (profileInfo != null) {
        unawaited(
          _updateFcmToken(
            profileInfo,
            newToken: newToken,
          ),
        );
      }
    }
  }

  static Future<User?> _fetchProfileInfoFromFirebase(
    String firebaseUserId,
  ) async {
    final user = await FirebaseFirestore.instance
        .collection(FireStoreConfig.userCollection)
        .doc(firebaseUserId)
        .get();
    User? profileInfo;
    try {
      profileInfo = User.fromSnapshot(user);
    } on Exception catch (_) {}
    return profileInfo;
  }

  static Future<void> removeTokenOnLogout() async {
    final firebaseUserId = await StaticFunctions.getCurrentUserId();
    if (firebaseUserId != null && _fcmToken?.trim().isNotEmpty == true) {
      try {
        await FirebaseFirestore.instance
            .collection(FireStoreConfig.userCollection)
            .doc(firebaseUserId)
            .update({
          FireStoreConfig.userFcmTokenField: null,
        });
      } on Exception catch (_) {}
    }
  }

  static Future<void> _updateFcmToken(
    User profileInfo, {
    required String newToken,
  }) async {
    final data = <String, dynamic>{};
    data[FireStoreConfig.userFcmTokenField] = newToken;
    data[FireStoreConfig.updatedAtField] =
        DateTime.now().millisecondsSinceEpoch;
    await FirebaseFirestore.instance
        .collection(FireStoreConfig.userCollection)
        .doc(profileInfo.userId)
        .update(data);
    _fcmToken = newToken;
  }
}
