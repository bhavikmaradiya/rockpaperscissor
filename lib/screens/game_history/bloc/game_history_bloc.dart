import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';
import 'package:rockpaperscissor/enums/room_status_enums.dart';
import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/screens/game_history/bloc/game_history_event.dart';
import 'package:rockpaperscissor/screens/game_history/bloc/game_history_state.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';

class GameHistoryBloc extends Bloc<GameHistoryEvent, GameHistoryState> {
  static final _fireStoreInstance = FirebaseFirestore.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _roomSubscription;
  late User user;
  final List<Room> _roomList = [];

  GameHistoryBloc() : super(GameHistoryInitialState()) {
    on<GameHistoryInitialEvent>(_init);
  }

  Future<void> _init(
    GameHistoryInitialEvent event,
    Emitter<GameHistoryState> emit,
  ) async {
    emit(GameHistoryLoadingState());
    user = (await StaticFunctions.getCurrentUser())!;
    await _listenToGameHistory(emit);
    await _roomSubscription?.asFuture();
  }

  Future<void> _listenToGameHistory(
    Emitter<GameHistoryState> emit,
  ) async {
    final snapshotStream = await _getMyRoomSnapshot();
    _roomSubscription = snapshotStream.listen(
      (snapshot) async {
        _roomList.clear();
        if (snapshot.docs.isNotEmpty) {
          await Future.forEach(
            snapshot.docs,
            (element) {
              Room? room;
              try {
                room = Room.fromSnapshot(
                  element,
                );
              } on Exception catch (_) {}
              if (room != null &&
                  room.status == RoomStatusEnums.finished.name &&
                  room.playerIds != null &&
                  room.playerIds!.contains(user.userId!)) {
                _roomList.add(
                  room,
                );
              }
            },
          );
          if (_roomList.isNotEmpty) {
            emit(
              GameHistoryUpdatedState(
                _roomList,
              ),
            );
          } else {
            emit(GameHistoryEmptyState());
          }
        } else {
          emit(GameHistoryEmptyState());
        }
      },
    );
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      _getMyRoomSnapshot() async {
    return _fireStoreInstance
        .collection(FireStoreConfig.roomCollection)
        .where(
          FireStoreConfig.roomStatusField,
          isEqualTo: RoomStatusEnums.finished.name,
        )
        .where(
          FireStoreConfig.roomPlayerIdsField,
          arrayContains: user.userId!,
        )
        .orderBy(
          FireStoreConfig.createdAtField,
          descending: true,
        )
        .snapshots();
  }

  @override
  Future<void> close() {
    _roomSubscription?.cancel();
    return super.close();
  }
}
