import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rockpaperscissor/config/app_config.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';
import 'package:rockpaperscissor/enums/room_status_enums.dart';
import 'package:rockpaperscissor/enums/room_type_enums.dart';
import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/screens/lobby/bloc/lobby_event.dart';
import 'package:rockpaperscissor/screens/lobby/bloc/lobby_state.dart';
import 'package:rockpaperscissor/screens/room/model/quick_match.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';

class LobbyBloc extends Bloc<LobbyEvent, LobbyState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _roomSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _quickMatchRoomSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _quickMatchSubscription;
  Room? _currentRoom;
  User? _currentPlayer;
  QuickMatch? _myQuickMatch;
  Timer? _timer;
  Timer? _expireTimer;
  bool _isRoomFoundWithMatchings = false;
  bool _isExpired = false;
  bool _isExpireTimerStarted = false;

  Room? get currentRoom => _currentRoom;

  QuickMatch? get currentQuickMatch => _myQuickMatch;

  LobbyBloc() : super(LobbyInitialState()) {
    on<LobbyInitialEvent>(_init);
    on<OpponentFoundEvent>(_startTimer);
    on<StartExpireTimerEvent>(_startExpireTimer);
    on<ExpireTimerTickEvent>(_onExpireTimerTick);
    on<TimerTickEvent>(_timerTickEvent);
    on<CancelGameEvent>(_onCancelGameEvent);
  }

  Future<void> _init(
    LobbyInitialEvent event,
    Emitter<LobbyState> emit,
  ) async {
    _currentRoom = event.room;
    _myQuickMatch = event.quickMatch;
    _currentPlayer = await StaticFunctions.getCurrentUser(
      fetchFromDB: true,
    );
    if (_currentPlayer != null) {
      if (_currentRoom?.roomId != null) {
        await _listenRoomChanges(emit);
      } else if (_myQuickMatch != null) {
        await _listenForQuickMatchRoom(emit);
        await _listenForMatchingPlayers(emit);
        if (!_isExpireTimerStarted) {
          add(StartExpireTimerEvent());
        }
        await _quickMatchRoomSubscription?.asFuture();
        await _quickMatchSubscription?.asFuture();
      }
    }
  }

  Future<void> _onCancelGameEvent(
    CancelGameEvent event,
    Emitter<LobbyState> emit,
  ) async {
    emit(LobbyLoadingState());
    if (_currentRoom != null) {
      _roomSubscription?.cancel();
      await _fireStoreInstance
          .collection(FireStoreConfig.roomCollection)
          .doc(_currentRoom!.roomId!)
          .delete();
    } else if (_myQuickMatch != null) {
      _quickMatchSubscription?.cancel();
      _quickMatchRoomSubscription?.cancel();
      await _fireStoreInstance
          .collection(FireStoreConfig.quickMatchCollection)
          .doc(_myQuickMatch!.matchId!)
          .delete();
    }
    emit(
      LobbyLoadingState(
        isLoading: false,
      ),
    );
    emit(
      LobbyCanceledSuccessfulState(
        isExpired: event.isExpired,
      ),
    );
  }

  Future<void> _listenForMatchingPlayers(
    Emitter<LobbyState> emit,
  ) async {
    final snapshotStream = await _getQuickMatchSnapshot();
    _quickMatchSubscription = snapshotStream.listen(
      (snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          QuickMatch? opponentQuickMatch;
          try {
            opponentQuickMatch = QuickMatch.fromSnapshot(
              snapshot.docs.first,
            );
          } on Exception catch (_) {}
          if (opponentQuickMatch != null &&
              opponentQuickMatch.totalAmount != null &&
              opponentQuickMatch.totalRounds != null &&
              opponentQuickMatch.roomId == null &&
              opponentQuickMatch.matchId != _myQuickMatch!.matchId &&
              opponentQuickMatch.totalRounds == _myQuickMatch!.totalRounds &&
              opponentQuickMatch.totalAmount! >= _myQuickMatch!.totalAmount!) {
            final expireTime = DateTime.fromMillisecondsSinceEpoch(
              opponentQuickMatch.expiresAt!,
            );
            final currentTime = DateTime.now();
            final isQuickMatchAlive = currentTime.isBefore(
              expireTime,
            );
            if (!_isExpired && isQuickMatchAlive) {
              final hostPlayer = _myQuickMatch;
              final timeStamp = DateTime.now();
              final room = Room()
                ..isAutoMatch = true
                ..status = RoomStatusEnums.started.name
                ..roomType = RoomTypeEnums.realPlayer.name
                ..playerIds = [
                  hostPlayer!.playerId!,
                  opponentQuickMatch.playerId!,
                ]
                ..hostId = hostPlayer.playerId!
                ..totalPotAmount = (hostPlayer.totalAmount! * 2)
                ..totalRounds = hostPlayer.totalRounds
                ..currentRound = 1
                ..roomPlayerIdsMap = {
                  hostPlayer.playerId!: hostPlayer.playerId!,
                  opponentQuickMatch.playerId!: opponentQuickMatch.playerId!,
                }
                ..minAmountToJoin = hostPlayer.totalAmount
                ..createdAt = timeStamp.millisecondsSinceEpoch
                ..updatedAt = timeStamp.millisecondsSinceEpoch
                ..expiresAt = timeStamp
                    .add(
                      Duration(
                        milliseconds:
                            (AppConfig.defaultRoomExpirationHourTime * 3600000)
                                .round(),
                      ),
                    )
                    .millisecondsSinceEpoch;
              if (!_isRoomFoundWithMatchings) {
                final doesRoomExists = await _checkIfRoomExistsWith(
                  hostPlayer.playerId!,
                  opponentQuickMatch.playerId!,
                );
                final isMyQuickMatchAvailable =
                    await _checkIfQuickMatchIsStillFree(
                  _myQuickMatch!.matchId!,
                );
                final isOpponentMatchAvailable =
                    await _checkIfQuickMatchIsStillFree(
                  opponentQuickMatch.matchId!,
                );
                if (isMyQuickMatchAvailable &&
                    isOpponentMatchAvailable &&
                    !doesRoomExists &&
                    !_isRoomFoundWithMatchings) {
                  final batch = _fireStoreInstance.batch();
                  room.roomId = _generateRoomId();
                  final roomRef = FirebaseFirestore.instance
                      .collection(FireStoreConfig.roomCollection)
                      .doc(room.roomId);
                  batch.set(roomRef, room.toMap());

                  final quickMatchRef = _fireStoreInstance
                      .collection(FireStoreConfig.quickMatchCollection)
                      .doc(_myQuickMatch!.matchId!);
                  batch.update(quickMatchRef, {
                    FireStoreConfig.quickMatchRoomIdField: room.roomId,
                  });

                  final opponentQuickMatchRef = _fireStoreInstance
                      .collection(FireStoreConfig.quickMatchCollection)
                      .doc(opponentQuickMatch.matchId!);
                  batch.update(opponentQuickMatchRef, {
                    FireStoreConfig.quickMatchRoomIdField: room.roomId,
                  });
                  batch.commit();
                }
              }
            }
          }
        }
      },
    );
  }

  Future<void> _listenForQuickMatchRoom(
    Emitter<LobbyState> emit,
  ) async {
    final snapshotStream = await _getRoomWithPlayersSnapshot();
    _quickMatchRoomSubscription = snapshotStream.listen(
      (snapshot) async {
        if (snapshot.docs.isNotEmpty) {
          Room? foundRoom;
          try {
            foundRoom = Room.fromSnapshot(
              snapshot.docs.first,
            );
          } on Exception catch (_) {}
          if (foundRoom != null &&
              foundRoom.roomId != null &&
              foundRoom.roomPlayerIdsMap != null &&
              foundRoom.roomPlayerIdsMap!.isNotEmpty &&
              foundRoom.isAutoMatch == true &&
              foundRoom.playerIds != null &&
              foundRoom.playerIds!.length > 1 &&
              foundRoom.playerIds!.contains(_myQuickMatch!.playerId!)) {
            _isRoomFoundWithMatchings = true;
            _quickMatchSubscription?.cancel();
            _quickMatchRoomSubscription?.cancel();
            _deleteQuickMatches(
              foundRoom.roomId!,
            );
            await _loadOpponentView(
              emit,
              foundRoom,
            );
            add(
              OpponentFoundEvent(
                foundRoom,
              ),
            );
          }
        }
      },
    );
  }

  Future<void> _deleteQuickMatches(
    String roomId,
  ) async {
    final batch = _fireStoreInstance.batch();
    final foundMatchings = await _fireStoreInstance
        .collection(FireStoreConfig.quickMatchCollection)
        .where(
          FireStoreConfig.quickMatchRoomIdField,
          isEqualTo: roomId,
        )
        .get();

    if (foundMatchings.docs.isNotEmpty) {
      await Future.forEach(foundMatchings.docs, (element) {
        QuickMatch? quickMatch;
        try {
          quickMatch = QuickMatch.fromSnapshot(element);
        } on Exception catch (_) {}
        if (quickMatch != null) {
          batch.delete(
            _fireStoreInstance
                .collection(FireStoreConfig.quickMatchCollection)
                .doc(quickMatch.matchId),
          );
        }
      });
    }
    await batch.commit();
  }

  Future<bool> _checkIfRoomExistsWith(
    String player1,
    String player2,
  ) async {
    final data = await _fireStoreInstance
        .collection(FireStoreConfig.roomCollection)
        .where(
          FireStoreConfig.roomIsAutoMatchField,
          isEqualTo: true,
        )
        .where(
          FireStoreConfig.roomStatusField,
          isEqualTo: RoomStatusEnums.started.name,
        )
        .get();
    Room? room;
    if (data.docs.isNotEmpty) {
      try {
        room = Room.fromSnapshot(data.docs.first);
      } on Exception catch (_) {}
      return room != null &&
          room.playerIds != null &&
          room.playerIds!.length > 1 &&
          room.playerIds!.contains(player1) &&
          room.playerIds!.contains(player2);
    }
    return false;
  }

  Future<bool> _checkIfQuickMatchIsStillFree(
    String matchId,
  ) async {
    final data = await _fireStoreInstance
        .collection(FireStoreConfig.quickMatchCollection)
        .doc(matchId)
        .get();
    QuickMatch? quickMatch;
    try {
      quickMatch = QuickMatch.fromSnapshot(data);
    } on Exception catch (_) {}
    return quickMatch != null && quickMatch.roomId == null;
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      _getRoomWithPlayersSnapshot() async {
    return _fireStoreInstance
        .collection(
          FireStoreConfig.roomCollection,
        )
        .where(
          FireStoreConfig.roomIsAutoMatchField,
          isEqualTo: true,
        )
        .where(
          FireStoreConfig.roomStatusField,
          isEqualTo: RoomStatusEnums.started.name,
        )
        .where(
          FireStoreConfig.roomPlayerIdsMapField,
          isNotEqualTo: null,
        )
        .where(
          FireStoreConfig.roomPlayerIdsField,
          arrayContains: _myQuickMatch!.playerId!,
        )
        .snapshots();
  }

  Future<void> _listenRoomChanges(
    Emitter<LobbyState> emit,
  ) async {
    final snapshotStream = await _getMyRoomSnapshot();
    _roomSubscription = snapshotStream.listen(
      (snapshot) async {
        if (snapshot.exists) {
          try {
            _currentRoom = Room.fromSnapshot(snapshot);
            if (_currentRoom != null) {
              emit(
                LobbyRoomChangesState(
                  _currentRoom!,
                ),
              );
              if (!_isExpireTimerStarted) {
                add(StartExpireTimerEvent());
              }
              if (!_isExpired &&
                  _currentRoom?.status == RoomStatusEnums.started.name &&
                  (_currentRoom?.playerIds?.length ?? 0) > 1) {
                _roomSubscription?.cancel();
                await _loadOpponentView(
                  emit,
                  _currentRoom!,
                );
                add(
                  OpponentFoundEvent(
                    _currentRoom!,
                  ),
                );
              }
            }
          } on Exception catch (_) {}
        }
      },
    );
    await _roomSubscription?.asFuture();
  }

  Future<void> _loadOpponentView(
    Emitter<LobbyState> emit,
    Room room,
  ) async {
    final player1Id = StaticFunctions.userId!;
    final player2Id = room.playerIds!.firstWhere(
      (element) => element != player1Id,
    );
    final opponentPlayer = await _getOpponentPlayer(
      player2Id,
    );
    emit(
      LobbyLoadOpponentViewState(
        opponentPlayer: opponentPlayer,
      ),
    );
  }

  void _startTimer(
    OpponentFoundEvent event,
    Emitter<LobbyState> emit,
  ) {
    if (_isExpireTimerStarted || (_expireTimer?.isActive ?? false)) {
      _expireTimer?.cancel();
    }
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final int remainingTime = AppConfig.defaultLobbyBufferTime - timer.tick;
        if (remainingTime > 0) {
          add(
            TimerTickEvent(
              room: event.room,
              remainingTime: remainingTime,
            ),
          );
        } else {
          add(
            TimerTickEvent(
              room: event.room,
              remainingTime: 0,
            ),
          );
          _timer?.cancel();
        }
      },
    );
  }

  void _startExpireTimer(
    StartExpireTimerEvent event,
    Emitter<LobbyState> emit,
  ) {
    _isExpireTimerStarted = true;
    _expireTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final _e = Duration(
          milliseconds:
              (AppConfig.defaultRoomExpirationHourTime * 3600000).round(),
        ).inSeconds;
        final int remainingTime = _e - timer.tick;
        if (remainingTime > 0) {
          add(
            ExpireTimerTickEvent(
              remainingTime: remainingTime,
            ),
          );
        } else {
          add(
            ExpireTimerTickEvent(
              remainingTime: 0,
            ),
          );
          _expireTimer?.cancel();
        }
      },
    );
  }

  Future<void> _onExpireTimerTick(
    ExpireTimerTickEvent event,
    Emitter<LobbyState> emit,
  ) async {
    emit(
      TimerRunningState(
        remainingTime: event.remainingTime,
        isExpired: true,
      ),
    );
    if (event.remainingTime == 0) {
      _isExpired = true;
      emit(LobbyExpiredState());
      add(
        CancelGameEvent(
          isExpired: true,
        ),
      );
    }
  }

  Future<void> _timerTickEvent(
    TimerTickEvent event,
    Emitter<LobbyState> emit,
  ) async {
    emit(
      TimerRunningState(
        remainingTime: event.remainingTime,
      ),
    );
    if (event.remainingTime == 0) {
      final room = event.room;
      if (room.currentRound == null || room.currentRound == 0) {
        await FirebaseFirestore.instance
            .collection(FireStoreConfig.roomCollection)
            .doc(room.roomId)
            .update({
          FireStoreConfig.roomCurrentRoundField: 1,
        });
        room.currentRound = 1;
      }
      emit(
        LobbyOpponentFoundState(
          room,
        ),
      );
    }
  }

  String _generateRoomId() {
    return _fireStoreInstance
        .collection(FireStoreConfig.roomCollection)
        .doc()
        .id;
  }

  Future<Stream<DocumentSnapshot<Map<String, dynamic>>>>
      _getMyRoomSnapshot() async {
    return _fireStoreInstance
        .collection(FireStoreConfig.roomCollection)
        .doc(_currentRoom!.roomId!)
        .snapshots();
  }

  Future<User> _getOpponentPlayer(
    String playerId,
  ) async {
    final data = await _fireStoreInstance
        .collection(FireStoreConfig.userCollection)
        .doc(playerId)
        .get();
    return User.fromSnapshot(data);
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      _getQuickMatchSnapshot() async {
    return _fireStoreInstance
        .collection(FireStoreConfig.quickMatchCollection)
        /*.where(
          FireStoreConfig.quickMatchIdField,
          isNotEqualTo: _myQuickMatch!.matchId,
        )
        .where(
          FireStoreConfig.quickMatchRoundsField,
          isEqualTo: _myQuickMatch!.totalRounds,
        )*/
        .where(
          Filter.and(
            Filter(
              FireStoreConfig.quickMatchIdField,
              isNotEqualTo: _myQuickMatch!.matchId,
            ),
            Filter(
              FireStoreConfig.quickMatchRoundsField,
              isEqualTo: _myQuickMatch!.totalRounds,
            ),
          ),
        )
        .where(
          FireStoreConfig.quickMatchAmountField,
          isGreaterThanOrEqualTo: _myQuickMatch!.totalAmount,
        )

        /*.where(
          FireStoreConfig.quickMatchAmountField,
          isGreaterThanOrEqualTo: _myQuickMatch!.totalAmount,
        )
        .where(
          FireStoreConfig.expiresAtField,
          isLessThan: DateTime.now().millisecondsSinceEpoch,
        )*/
        .snapshots();
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _expireTimer?.cancel();
    _roomSubscription?.cancel();
    _quickMatchSubscription?.cancel();
    _quickMatchRoomSubscription?.cancel();
    return super.close();
  }
}
