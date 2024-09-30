import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rockpaperscissor/enums/moves_type_enums.dart';
import 'package:rockpaperscissor/enums/winner_type_enums.dart';
import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/utils/notification_token_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/firestore_config.dart';
import '../config/preference_config.dart';

class StaticFunctions {
  static final _fireStoreInstance = FirebaseFirestore.instance;
  static String? _userId;
  static User? _user;

  static String? get userId => _userId;

  static Future<String?> getCurrentUserId({
    bool fetchUser = true,
  }) async {
    if (_userId != null && _userId!.trim().isNotEmpty) {
      return _userId;
    }
    final preference = await SharedPreferences.getInstance();
    _userId = preference.getString(PreferenceConfig.userIdPref);
    if (fetchUser && _user == null) {
      unawaited(getCurrentUser());
    }
    return _userId;
  }

  static Future<User?> getCurrentUser({
    bool fetchFromDB = false,
  }) async {
    final userId = await getCurrentUserId(fetchUser: false);
    if (!fetchFromDB &&
        _user != null &&
        _user!.userId!.trim().isNotEmpty &&
        userId == _user!.userId!) {
      return _user;
    }
    if (userId != null) {
      final doc = await _fireStoreInstance
          .collection(FireStoreConfig.userCollection)
          .doc(userId)
          .get();
      try {
        _user = User.fromSnapshot(doc);
      } catch (e) {
        debugPrint(e.toString());
      }
    }
    return _user;
  }

  static Future<void> clearOnLogout() async {
    await NotificationTokenHelper.removeTokenOnLogout();
    _userId = null;
    _user = null;
    final preference = await SharedPreferences.getInstance();
    preference.clear();
  }

  static MovesTypeEnums? getMoveEnumFromString(String move) {
    if (move == MovesTypeEnums.paper.name) {
      return MovesTypeEnums.paper;
    } else if (move == MovesTypeEnums.rock.name) {
      return MovesTypeEnums.rock;
    } else if (move.trim().isNotEmpty) {
      return MovesTypeEnums.scissor;
    }
    return null;
  }

  static WinnerTypeEnum determineWinnerFrom({
    required String? player1Move,
    required String? player2Move,
  }) {
    if (player1Move != null && player2Move != null) {
      if (player1Move == player2Move) {
        return WinnerTypeEnum.draw;
      } else if ((player1Move == MovesTypeEnums.rock.name &&
              player2Move == MovesTypeEnums.scissor.name) ||
          (player1Move == MovesTypeEnums.paper.name &&
              player2Move == MovesTypeEnums.rock.name) ||
          (player1Move == MovesTypeEnums.scissor.name &&
              player2Move == MovesTypeEnums.paper.name)) {
        return WinnerTypeEnum.player1;
      } else {
        return WinnerTypeEnum.player2;
      }
    } else {
      return (player1Move == null && player2Move != null)
          ? WinnerTypeEnum.player2
          : (player2Move == null && player1Move != null)
              ? WinnerTypeEnum.player1
              : WinnerTypeEnum.draw;
    }
  }
}
