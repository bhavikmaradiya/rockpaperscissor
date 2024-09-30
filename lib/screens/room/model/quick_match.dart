import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';

class QuickMatch {
  String? matchId;
  double? totalAmount;
  int? totalRounds;
  String? roomId;
  String? playerId;
  int? createdAt;
  int? expiresAt;

  QuickMatch({
    this.matchId,
    this.totalAmount,
    this.roomId,
    this.playerId,
    this.totalRounds,
    this.createdAt,
    this.expiresAt,
  });

  factory QuickMatch.fromSnapshot(DocumentSnapshot document) {
    final data = document.data();
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception();
    }
    return QuickMatch(
      matchId: data[FireStoreConfig.quickMatchIdField] as String?,
      roomId: data[FireStoreConfig.quickMatchRoomIdField] as String?,
      playerId: data[FireStoreConfig.quickMatchPlayerIdField] as String?,
      totalAmount:
          (data[FireStoreConfig.quickMatchAmountField] as num?)?.toDouble(),
      totalRounds: data[FireStoreConfig.quickMatchRoundsField] as int?,
      createdAt: data[FireStoreConfig.createdAtField] as int?,
      expiresAt: data[FireStoreConfig.expiresAtField] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FireStoreConfig.quickMatchIdField: matchId,
      FireStoreConfig.quickMatchRoomIdField: roomId,
      FireStoreConfig.quickMatchPlayerIdField: playerId,
      FireStoreConfig.quickMatchAmountField: totalAmount,
      FireStoreConfig.quickMatchRoundsField: totalRounds,
      FireStoreConfig.createdAtField: createdAt,
      FireStoreConfig.expiresAtField: expiresAt,
    };
  }
}
