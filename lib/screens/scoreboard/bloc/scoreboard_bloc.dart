import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';
import 'package:rockpaperscissor/enums/room_type_enums.dart';
import 'package:rockpaperscissor/enums/winner_type_enums.dart';
import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';
import 'package:rockpaperscissor/screens/scoreboard/bloc/scoreboard_event.dart';
import 'package:rockpaperscissor/screens/scoreboard/bloc/scoreboard_state.dart';
import 'package:rockpaperscissor/screens/transaction/model/user_transaction.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';

class ScoreboardBloc extends Bloc<ScoreboardEvent, ScoreboardState> {
  static final _fireStoreInstance = FirebaseFirestore.instance;
  late User player1;
  User? player2;
  late Room room;
  late String currentUserId;
  UserTransaction? transaction;

  ScoreboardBloc() : super(ScoreboardInitialState()) {
    on<ScoreboardInitialEvent>(_init);
  }

  Future<void> _init(
    ScoreboardInitialEvent event,
    Emitter<ScoreboardState> emit,
  ) async {
    emit(ScoreboardLoadingState());
    currentUserId = (await StaticFunctions.getCurrentUserId())!;
    room = await _fetchRoomInfoFromFirebase(
      roomId: event.roomId,
    );
    final player1Id = room.hostId!;
    final player2Id = room.playerIds!.firstWhere(
      (element) => element != player1Id,
    );

    player1 = await _fetchPlayerInfoFromFirebase(
      playerId: player1Id,
    );
    if (room.roomType == RoomTypeEnums.realPlayer.name) {
      player2 = await _fetchPlayerInfoFromFirebase(
        playerId: player2Id,
      );
    }
    if(room.winnerId != WinnerTypeEnum.draw.name){
      transaction = await _fetchTransactionInfoFromFirebase(
        roomId: event.roomId,
      );
    }
    emit(
      ScoreboardUpdatedState(
        player1: player1,
        player2: player2,
        roomData: room,
        transaction: transaction,
      ),
    );
    final isWinner = currentUserId == room.winnerId;
    if (event.isFromGame && isWinner) {
      emit(ScoreboardWinnerAnimationState());
      await Future.delayed(
        const Duration(
          milliseconds: 5000,
        ),
      );
      emit(
        ScoreboardWinnerAnimationState(
          shouldAnimate: false,
        ),
      );
    }
  }

  Future<User> _fetchPlayerInfoFromFirebase({
    required String playerId,
  }) async {
    final doc = await _fireStoreInstance
        .collection(FireStoreConfig.userCollection)
        .doc(playerId)
        .get();
    return User.fromSnapshot(doc);
  }

  Future<Room> _fetchRoomInfoFromFirebase({
    required String roomId,
  }) async {
    final doc = await _fireStoreInstance
        .collection(FireStoreConfig.roomCollection)
        .doc(roomId)
        .get();
    return Room.fromSnapshot(doc);
  }

  Future<UserTransaction> _fetchTransactionInfoFromFirebase({
    required String roomId,
  }) async {
    final doc = await _fireStoreInstance
        .collection(
          FireStoreConfig.transactionCollection,
        )
        .where(
          FireStoreConfig.transactionUserIdField,
          isEqualTo: currentUserId,
        )
        .where(
          FireStoreConfig.transactionRoomIdField,
          isEqualTo: roomId,
        )
        .get();
    return UserTransaction.fromSnapshot(doc.docs.first);
  }
}
