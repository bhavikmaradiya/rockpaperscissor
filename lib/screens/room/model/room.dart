import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rockpaperscissor/config/app_config.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';
import 'package:rockpaperscissor/screens/room/model/round_info.dart';

class Room {
  String? roomId;
  String? inviteCode;
  String? status;
  bool? isAutoMatch;
  String? roomType;
  String? winnerId;
  int? totalRounds;
  int? currentRound;
  String? hostId;
  List<String>? playerIds;
  List<RoundInfo>? roundInfo;
  double? totalPotAmount;
  double? minAmountToJoin;
  Map<String, dynamic>? roomPlayerIdsMap;
  int? createdAt;
  int? updatedAt;
  int? expiresAt;

  Room({
    this.roomId,
    this.inviteCode,
    this.isAutoMatch,
    this.status,
    this.roomType,
    this.winnerId,
    this.currentRound,
    this.totalRounds,
    this.hostId,
    this.playerIds,
    this.roundInfo,
    this.totalPotAmount,
    this.minAmountToJoin,
    this.roomPlayerIdsMap,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
  });

  factory Room.fromSnapshot(DocumentSnapshot document) {
    final data = document.data();
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception();
    }

    final roomRounds = <RoundInfo>[];
    final roundsList = data[FireStoreConfig.roomRoundInfoField];
    if (roundsList != null &&
        roundsList is List<dynamic> &&
        roundsList.isNotEmpty) {
      for (var i = 0; i < roundsList.length; i++) {
        final roundData = roundsList[i];
        if (roundData != null &&
            roundData is Map<String, dynamic> &&
            roundData.isNotEmpty) {
          final roundInfo = RoundInfo.fromMap(roundData);
          if (roundInfo.roundNo != null && !roomRounds.contains(roundInfo)) {
            roomRounds.add(roundInfo);
          }
        }
      }
    }

    final playerIds = <String>[];
    final playerIdList = data[FireStoreConfig.roomPlayerIdsField];
    if (playerIdList != null && playerIdList is List<dynamic>) {
      for (var i = 0; i < playerIdList.length; i++) {
        final playerId = playerIdList[i];
        if (playerId != null &&
            playerId is String &&
            !playerIds.contains(playerId)) {
          playerIds.add(playerId);
        }
      }
    }
    Map<String, dynamic>? playerIdsMap;
    if (data[FireStoreConfig.roomPlayerIdsMapField] != null &&
        data[FireStoreConfig.roomPlayerIdsMapField] is Map<String, dynamic>) {
      playerIdsMap =
          data[FireStoreConfig.roomPlayerIdsMapField] as Map<String, dynamic>;
    }

    return Room(
      roomId: data[FireStoreConfig.roomIdField] as String?,
      isAutoMatch: data[FireStoreConfig.roomIsAutoMatchField] as bool?,
      inviteCode: data[FireStoreConfig.roomInviteCodeField] as String?,
      status: data[FireStoreConfig.roomStatusField] as String?,
      roomType: data[FireStoreConfig.roomTypeField] as String?,
      winnerId: data[FireStoreConfig.roomWinnerIdField] as String?,
      currentRound: data[FireStoreConfig.roomCurrentRoundField] as int?,
      totalRounds: data[FireStoreConfig.roomTotalRoundsField] as int?,
      hostId: data[FireStoreConfig.roomHostIdField] as String?,
      roomPlayerIdsMap: playerIdsMap,
      playerIds: playerIds,
      roundInfo: roomRounds,
      totalPotAmount:
          (data[FireStoreConfig.roomTotalPotAmountField] as num?)?.toDouble(),
      minAmountToJoin:
          (data[FireStoreConfig.roomMinAmountToJoinField] as num?)?.toDouble(),
      createdAt: data[FireStoreConfig.createdAtField] as int?,
      updatedAt: data[FireStoreConfig.updatedAtField] as int?,
      expiresAt: data[FireStoreConfig.expiresAtField] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FireStoreConfig.roomIdField: roomId,
      FireStoreConfig.roomIsAutoMatchField: isAutoMatch,
      FireStoreConfig.roomInviteCodeField: inviteCode,
      FireStoreConfig.roomStatusField: status,
      FireStoreConfig.roomTypeField: roomType,
      FireStoreConfig.roomWinnerIdField: winnerId,
      FireStoreConfig.roomCurrentRoundField: currentRound,
      FireStoreConfig.roomTotalRoundsField: totalRounds,
      FireStoreConfig.roomHostIdField: hostId,
      FireStoreConfig.roomTotalPotAmountField: totalPotAmount,
      FireStoreConfig.roomMinAmountToJoinField: minAmountToJoin,
      FireStoreConfig.roomPlayerIdsField: playerIds,
      FireStoreConfig.roomPlayerIdsMapField: roomPlayerIdsMap,
      FireStoreConfig.roomRoundInfoField:
          roundInfo?.map((e) => e.toMap()).toList(),
      FireStoreConfig.createdAtField: createdAt,
      FireStoreConfig.updatedAtField: updatedAt,
      FireStoreConfig.expiresAtField: expiresAt,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room &&
          runtimeType == other.runtimeType &&
          roomId == other.roomId;

  @override
  int get hashCode => roomId.hashCode;
}
