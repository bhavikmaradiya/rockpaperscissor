import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';

class PlayerMove {
  String? player1Id;
  String? player2Id;
  String? player1Move;
  String? player2Move;

  PlayerMove({
    this.player1Id,
    this.player2Id,
    this.player1Move,
    this.player2Move,
  });

  factory PlayerMove.fromSnapshot(DocumentSnapshot document) {
    final data = document.data();
    if (data == null || data is! Map<String, dynamic>) {
      throw Exception();
    }
    return PlayerMove(
      player1Id: data[FireStoreConfig.movesPlayer1IdField] as String?,
      player2Id: data[FireStoreConfig.movesPlayer2IdField] as String?,
      player1Move: data[FireStoreConfig.movesPlayer1MoveField] as String?,
      player2Move: data[FireStoreConfig.movesPlayer2MoveField] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      FireStoreConfig.movesPlayer1IdField: player1Id,
      FireStoreConfig.movesPlayer2IdField: player2Id,
      FireStoreConfig.movesPlayer1MoveField: player1Move,
      FireStoreConfig.movesPlayer2MoveField: player2Move,
    };
  }
}
