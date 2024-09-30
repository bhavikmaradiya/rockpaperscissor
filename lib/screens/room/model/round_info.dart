import 'package:rockpaperscissor/config/firestore_config.dart';

class RoundInfo {
  int? roundNo;
  String? player1Id;
  String? player2Id;
  String? player1Move;
  String? player2Move;
  String? winnerId;

  RoundInfo({
    this.roundNo = 1,
    this.player1Id,
    this.player2Id,
    this.player1Move,
    this.player2Move,
    this.winnerId,
  });

  factory RoundInfo.fromMap(Map<String, dynamic> data) {
    return RoundInfo(
      roundNo: data[FireStoreConfig.roundNoField] as int?,
      player1Id: data[FireStoreConfig.player1IdField] as String?,
      player2Id: data[FireStoreConfig.player2IdField] as String?,
      player1Move: data[FireStoreConfig.player1MoveField] as String?,
      player2Move: data[FireStoreConfig.player2MoveField] as String?,
      winnerId: data[FireStoreConfig.roundWinnerIdField] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FireStoreConfig.roundNoField: roundNo,
      FireStoreConfig.player1IdField: player1Id,
      FireStoreConfig.player2IdField: player2Id,
      FireStoreConfig.player1MoveField: player1Move,
      FireStoreConfig.player2MoveField: player2Move,
      FireStoreConfig.roundWinnerIdField: winnerId,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RoundInfo &&
          runtimeType == other.runtimeType &&
          roundNo == other.roundNo;

  @override
  int get hashCode => roundNo.hashCode;
}
