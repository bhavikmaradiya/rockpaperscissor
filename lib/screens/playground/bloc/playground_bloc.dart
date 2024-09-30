import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rockpaperscissor/config/app_config.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';
import 'package:rockpaperscissor/enums/moves_type_enums.dart';
import 'package:rockpaperscissor/enums/room_status_enums.dart';
import 'package:rockpaperscissor/enums/room_type_enums.dart';
import 'package:rockpaperscissor/enums/transaction_type_enums.dart';
import 'package:rockpaperscissor/enums/winner_type_enums.dart';
import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/screens/playground/bloc/playground_event.dart';
import 'package:rockpaperscissor/screens/playground/bloc/playground_state.dart';
import 'package:rockpaperscissor/screens/playground/model/player_move.dart';
import 'package:rockpaperscissor/screens/transaction/model/user_transaction.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';
import 'package:rockpaperscissor/screens/room/model/round_info.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';

class PlaygroundBloc extends Bloc<PlaygroundEvent, PlaygroundState> {
  static final _fireStoreInstance = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _roomSubscription;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _playerMovesSubscription;
  late Room _currentRoom;
  late PlayerMove? _playerMoves;
  late User _player1Info;
  User? _player2Info;
  late final String _player1Id;
  late final String _player2Id;
  int? _currentRound;
  late User _currentUser;
  Timer? _timer;
  bool _isRoundFinished = false;
  late RoomTypeEnums _roomType;
  int _player1Points = 0;
  int _player2Points = 0;
  bool isFirstTime = true;

  int? get currentRound => _currentRound;

  Room get currentRoom => _currentRoom;

  User get currentUser => _currentUser;

  int get player1Points => _player1Points;

  int get player2Points => _player2Points;

  PlaygroundBloc() : super(PlaygroundInitialState()) {
    on<PlaygroundInitEvent>(_onInit);
    on<StartTimerEvent>(_startTimer);
    on<TimerTickEvent>(_timerTickEvent);
    on<StopTimerEvent>(_stopTimerEvent);
    on<DisableActionsEvent>(_onDisableAction);
    on<PlaygroundMoveInputEvent>(_onMoveInputChangeEvent);
    on<GameCompletedEvent>(_onGameCompleted);
  }

  Future<void> _onInit(
    PlaygroundInitEvent event,
    Emitter<PlaygroundState> emit,
  ) async {
    emit(PlaygroundLoadingState());
    _currentRoom = event.currentRoom;
    _updateRoomInfo(emit);
    await _listenToRoomChanges(emit);
    await _initPlayerMovesCollection();
    await _initPlayers();
    await _listenToPlayerMoveChanges(emit);
    await _roomSubscription?.asFuture();
    await _playerMovesSubscription?.asFuture();
  }

  void _onDisableAction(
    DisableActionsEvent event,
    Emitter<PlaygroundState> emit,
  ) {
    emit(
      DisableActionsState(
        event.shouldDisable,
      ),
    );
  }

  Future<void> _onGameCompleted(
    GameCompletedEvent event,
    Emitter<PlaygroundState> emit,
  ) async {
    final batch = _fireStoreInstance.batch();

    final roomData = <String, dynamic>{};
    final player1Data = <String, dynamic>{};
    final player2Data = <String, dynamic>{};

    roomData[FireStoreConfig.roomStatusField] = RoomStatusEnums.finished.name;

    final latestRoomInfo = await _getRoomUpdatedData();
    final roundInfo = latestRoomInfo.roundInfo!;
    final lastRound = roundInfo.last;

    final player1Id = latestRoomInfo.hostId!;
    final player2Id = latestRoomInfo.playerIds!.firstWhere(
      (element) => element != player1Id,
    );

    final lastPlayerId = (latestRoomInfo.roomType ==
                RoomTypeEnums.botPlayer.name ||
            (lastRound.player1Move == null && lastRound.player2Move == null))
        ? player1Id
        : lastRound.player1Move == null
            ? player2Id
            : player1Id;

    //save data only from last played user or from host user
    if (lastPlayerId == _currentUser.userId!) {
      final totalPotAmount = latestRoomInfo.totalPotAmount!;
      double player1WonAmount = 0;
      double player2WonAmount = 0;
      double player1WalletAmount = 0;
      double player2WalletAmount = 0;
      double eachBetAmount = totalPotAmount / 2;
      String? player1Name;
      String? player2Name;

      final player1Points =
          roundInfo.where((element) => element.winnerId == player1Id).length;
      final player2Points =
          roundInfo.where((element) => element.winnerId == player2Id).length;

      final areAllDraw = roundInfo.every(
            (element) => element.winnerId == WinnerTypeEnum.draw.name,
          ) ||
          player1Points == player2Points;
      if (!areAllDraw) {
        final player1 = await _fetchPlayerInfoFromFirebase(
          playerId: player1Id,
        );
        User? player2;
        if (latestRoomInfo.roomType == RoomTypeEnums.realPlayer.name) {
          player2 = await _fetchPlayerInfoFromFirebase(
            playerId: player2Id,
          );
        }
        player1Name = player1.name ?? 'Unknown';
        player2Name = player2?.name ?? 'Computer';

        final player1Wallet = player1.walletBalance ?? 0;
        final player2Wallet = player2?.walletBalance ?? 0;
        if (player1Points > player2Points) {
          player1WonAmount = eachBetAmount;
          player2WonAmount = -eachBetAmount;
          player1WalletAmount = player1Wallet + eachBetAmount;
          player2WalletAmount = player2Wallet - eachBetAmount;
          roomData[FireStoreConfig.roomWinnerIdField] = player1Id;
        } else {
          player2WonAmount = eachBetAmount;
          player1WonAmount = -eachBetAmount;
          player1WalletAmount = player1Wallet - eachBetAmount;
          player2WalletAmount = player2Wallet + eachBetAmount;
          roomData[FireStoreConfig.roomWinnerIdField] = player2Id;
        }
        player1Data[FireStoreConfig.userWalletBalanceField] =
            player1WalletAmount;
        if (player2 != null) {
          player2Data[FireStoreConfig.userWalletBalanceField] =
              player2WalletAmount;
        }
      } else {
        roomData[FireStoreConfig.roomWinnerIdField] = WinnerTypeEnum.draw.name;
      }
      if (player1Data.isNotEmpty) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final transaction = UserTransaction()
          ..transactionId = _generateTransactionId()
          ..transactionAmount = player1WonAmount
          ..transactionPostWalletBal = player1WalletAmount
          ..transactionRoomId = latestRoomInfo.roomId!
          ..transactionUserId = player1Id
          ..opponentName = player2Name
          ..transactionType = player1WonAmount.isNegative
              ? TransactionTypeEnums.gameLost.name
              : TransactionTypeEnums.gameWon.name
          ..createdAt = timestamp;

        final transactionRef = _fireStoreInstance
            .collection(FireStoreConfig.transactionCollection)
            .doc(transaction.transactionId);
        batch.set(transactionRef, transaction.toMap());

        final player1Ref = _fireStoreInstance
            .collection(FireStoreConfig.userCollection)
            .doc(player1Id);
        batch.update(player1Ref, player1Data);
      }
      if (player2Data.isNotEmpty) {
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final transaction = UserTransaction()
          ..transactionId = _generateTransactionId()
          ..transactionAmount = player2WonAmount
          ..transactionPostWalletBal = player2WalletAmount
          ..transactionRoomId = latestRoomInfo.roomId!
          ..transactionUserId = player2Id
          ..opponentName = player1Name
          ..transactionType = player2WonAmount.isNegative
              ? TransactionTypeEnums.gameLost.name
              : TransactionTypeEnums.gameWon.name
          ..createdAt = timestamp;

        final transactionRef = _fireStoreInstance
            .collection(FireStoreConfig.transactionCollection)
            .doc(transaction.transactionId);
        batch.set(transactionRef, transaction.toMap());

        final player2Ref = _fireStoreInstance
            .collection(FireStoreConfig.userCollection)
            .doc(player2Id);
        batch.update(player2Ref, player2Data);
      }
    }

    if (roomData.isNotEmpty) {
      final roomRef = FirebaseFirestore.instance
          .collection(FireStoreConfig.roomCollection)
          .doc(latestRoomInfo.roomId);
      batch.update(roomRef, roomData);
    }

    await batch.commit();
    //need to update wallet
    await Future.delayed(
      const Duration(
        milliseconds: AppConfig.defaultRoundStartBuffer,
      ),
    );
    emit(
      PlaygroundStartScoreboardState(
        _currentRoom.roomId,
      ),
    );
  }

  Future<void> _onMoveInputChangeEvent(
    PlaygroundMoveInputEvent event,
    Emitter<PlaygroundState> emit,
  ) async {
    final move = event.moveType;
    _disableActions();
    if (_roomType == RoomTypeEnums.realPlayer) {
      final isPlayer1 = currentUser.userId == _playerMoves!.player1Id;
      await FirebaseFirestore.instance
          .collection(FireStoreConfig.playerMovesCollection)
          .doc(_currentRoom.roomId)
          .update(
            isPlayer1
                ? {FireStoreConfig.movesPlayer1MoveField: move.name}
                : {FireStoreConfig.movesPlayer2MoveField: move.name},
          );
    } else {
      final isPlayer1 = currentUser.userId == _playerMoves!.player1Id;

      final playerData = <String, dynamic>{};

      if (isPlayer1) {
        playerData[FireStoreConfig.movesPlayer1MoveField] = move.name;
      } else {
        playerData[FireStoreConfig.movesPlayer2MoveField] = move.name;
      }

      await FirebaseFirestore.instance
          .collection(FireStoreConfig.playerMovesCollection)
          .doc(_currentRoom.roomId)
          .update(playerData);

      await Future.delayed(
        const Duration(
          seconds: AppConfig.defaultBotSelectionBufferTime,
        ),
      );
      final botData = <String, dynamic>{};
      final botMove = _generateBotMove();
      if (isPlayer1) {
        botData[FireStoreConfig.movesPlayer2MoveField] = botMove.name;
      } else {
        botData[FireStoreConfig.movesPlayer1MoveField] = botMove.name;
      }
      await FirebaseFirestore.instance
          .collection(FireStoreConfig.playerMovesCollection)
          .doc(_currentRoom.roomId)
          .update(botData);
    }
    _enableActions();
  }

  MovesTypeEnums _generateBotMove() {
    return MovesTypeEnums
        .values[Random().nextInt(MovesTypeEnums.values.length)];
  }

  Future<void> _timerTickEvent(
    TimerTickEvent event,
    Emitter<PlaygroundState> emit,
  ) async {
    emit(
      TimerRunningState(
        remainingTime: event.remainingTime,
      ),
    );
    if (event.remainingTime == 0) {
      emit(TimerCompleteState());
      if (!_isRoundFinished &&
          (_playerMoves?.player1Move == null ||
              _playerMoves?.player2Move == null)) {
        // time out
        await _onTimeOut(
          emit,
        );
      }
    }
  }

  Future<void> _onTimeOut(
    Emitter<PlaygroundState> emit,
  ) async {
    emit(PlaygroundRoundTimedOutState());
    await Future.delayed(
      const Duration(
        seconds: AppConfig.defaultTimeoutDialogBufferTime,
      ),
    );
    _isRoundFinished = true;
    final lastPlayerId = (_roomType == RoomTypeEnums.botPlayer ||
            (_playerMoves!.player1Move == null &&
                _playerMoves!.player2Move == null))
        ? _player1Id
        : _playerMoves!.player1Move == null
            ? _player2Id
            : _player1Id;

    //save data only from last played user or from host user
    if (lastPlayerId == _currentUser.userId) {
      _updateRoundAndMovesData();
    }
  }

  _disableActions() {
    add(DisableActionsEvent(true));
  }

  _enableActions() {
    add(DisableActionsEvent(false));
  }

  void _stopTimerEvent(
    StopTimerEvent event,
    Emitter<PlaygroundState> emit,
  ) {
    _timer?.cancel();
    emit(TimerCompleteState());
  }

  void _startTimer(
    StartTimerEvent event,
    Emitter<PlaygroundState> emit,
  ) {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        final int remainingTime = event.duration - timer.tick;
        if (remainingTime > 0) {
          add(TimerTickEvent(remainingTime));
        } else {
          _timer?.cancel();
          add(TimerTickEvent(0));
        }
      },
    );
  }

  Future<void> _initPlayers() async {
    _currentUser = (await StaticFunctions.getCurrentUser(
      fetchFromDB: true,
    ))!;
    _player1Info = await _fetchPlayerInfoFromFirebase(
      playerId: _player1Id,
    );

    if (_currentRoom.roomType != RoomTypeEnums.botPlayer.name) {
      _player2Info = await _fetchPlayerInfoFromFirebase(
        playerId: _player2Id,
      );
    }
  }

  Future<void> _initPlayerMovesCollection() async {
    _player1Id = _currentRoom.hostId!;
    _player2Id = _currentRoom.playerIds!.firstWhere(
      (element) => element != _player1Id,
    );

    _playerMoves = PlayerMove()
      ..player1Id = _player1Id
      ..player2Id = _player2Id;

    await FirebaseFirestore.instance
        .collection(FireStoreConfig.playerMovesCollection)
        .doc(_currentRoom.roomId)
        .set(_playerMoves!.toMap());
  }

  void _updateRoomInfo(
    Emitter<PlaygroundState> emit,
  ) {
    _currentRound = _currentRoom.currentRound;
    if (_currentRoom.roomType == RoomTypeEnums.realPlayer.name) {
      _roomType = RoomTypeEnums.realPlayer;
    } else if (_currentRoom.roomType == RoomTypeEnums.botPlayer.name) {
      _roomType = RoomTypeEnums.botPlayer;
    }
    if (_currentRound != null) {
      emit(
        RoundSwitchState(
          currentRound: _currentRound!,
        ),
      );
    }
  }

  Future<void> _listenToRoomChanges(
    Emitter<PlaygroundState> emit,
  ) async {
    final snapshotStream = await _getMyRoomSnapshot();
    _roomSubscription = snapshotStream.listen((snapshot) {
      if (snapshot.exists) {
        _currentRoom = Room.fromSnapshot(snapshot);
        if (_currentRoom.roundInfo != null) {
          final player1Points = _currentRoom.roundInfo!
              .where((element) => element.winnerId == _player1Id)
              .length;
          final player2Points = _currentRoom.roundInfo!
              .where((element) => element.winnerId == _player2Id)
              .length;

          if (player1Points != _player1Points ||
              player2Points != _player2Points) {
            _player1Points = player1Points;
            _player2Points = player2Points;
            emit(
              RoundPointsUpdatedState(
                player1Points: player1Points,
                player2Points: player2Points,
              ),
            );
          }
        }

        if (_currentRoom.currentRound != null &&
            _currentRoom.currentRound != _currentRound) {
          _currentRound = _currentRoom.currentRound;
          emit(
            RoundSwitchState(
              currentRound: _currentRound!,
            ),
          );
          //round updated
        }
      } else {
        //in case if room deleted
      }
    });
  }

  Future<void> _listenToPlayerMoveChanges(
    Emitter<PlaygroundState> emit,
  ) async {
    final snapshotStream = await _getPlayerMovesSnapshot();
    _playerMovesSubscription = snapshotStream.listen(
      (snapshot) async {
        emit(
          PlaygroundLoadingState(
            isLoading: false,
          ),
        );
        if (snapshot.exists) {
          String lastPlayerId = '';
          final playerMoves = PlayerMove.fromSnapshot(snapshot);
          if (playerMoves.player1Move != null &&
              playerMoves.player2Move != null) {
            if (_roomType == RoomTypeEnums.realPlayer) {
              if (_playerMoves?.player1Move == null &&
                  playerMoves.player1Move != null) {
                lastPlayerId = _playerMoves!.player1Id!;
              } else if (_playerMoves?.player2Move == null &&
                  playerMoves.player2Move != null) {
                lastPlayerId = _playerMoves!.player2Id!;
              }
            } else {
              lastPlayerId = _currentUser.userId! == playerMoves.player1Id
                  ? playerMoves.player1Id!
                  : playerMoves.player2Id!;
            }
          }
          if ((playerMoves.player1Move == null &&
                  _playerMoves?.player1Move == null &&
                  playerMoves.player2Move == null &&
                  _playerMoves?.player2Move == null) ||
              (playerMoves.player1Move != _playerMoves?.player1Move ||
                  playerMoves.player2Move != _playerMoves?.player2Move)) {
            emit(
              PlaygroundPlayerMoveChangeState(
                playerMove: playerMoves,
                player1Name: _player1Info.name,
                player2Name: _player2Info?.name,
                roomType: _roomType,
              ),
            );
          }
          _playerMoves = playerMoves;
          final player1Move = _playerMoves!.player1Move;
          final player2Move = _playerMoves!.player2Move;

          if (player1Move == null && player2Move == null) {
            //start new round with player1 turn
            _isRoundFinished = false;
            if (isFirstTime) {
              isFirstTime = false;
              emit(PlaygroundRoundBufferingState());
              await Future.delayed(
                const Duration(
                  milliseconds: AppConfig.defaultRoundStartBuffer,
                ),
              );
              emit(
                PlaygroundRoundBufferingState(
                  isLoading: false,
                ),
              );
            } else {
              await Future.delayed(
                const Duration(
                  milliseconds: AppConfig.defaultRoundStartBuffer,
                ),
              );
              emit(
                PlaygroundRoundFinishingState(
                  isFinished: true,
                ),
              );
            }
            emit(
              PlaygroundRoundTimedOutState(
                isLoading: false,
              ),
            );
            add(
              StartTimerEvent(
                AppConfig.defaultRoundMaxBufferTime,
              ),
            );
          } else if (player1Move != null && player2Move != null) {
            _onRoundFinish(
              emit,
              lastPlayerId,
            );
          }
        } else {
          _roomSubscription?.cancel();
          _playerMovesSubscription?.cancel();
          //in case if moves are cleared completely if match is completed
          await Future.delayed(
            const Duration(
              milliseconds: AppConfig.defaultRoundStartBuffer,
            ),
          );
          emit(
            PlaygroundRoundTimedOutState(
              isLoading: false,
            ),
          );
          emit(
            PlaygroundRoundFinishingState(
              isFinished: true,
            ),
          );
          emit(PlaygroundAllRoundFinishedState());
          add(GameCompletedEvent());
        }
      },
    );
  }

  void _onRoundFinish(
    Emitter<PlaygroundState> emit,
    String lastPlayerId,
  ) {
    final player1Move = _playerMoves!.player1Move!;
    final player2Move = _playerMoves!.player2Move!;
    _isRoundFinished = true;
    add(StopTimerEvent()); //finish timer
    final determinedWinner = StaticFunctions.determineWinnerFrom(
      player1Move: player1Move,
      player2Move: player2Move,
    );
    final wonId = determinedWinner == WinnerTypeEnum.player1
        ? _playerMoves!.player1Id
        : determinedWinner != WinnerTypeEnum.draw
            ? _playerMoves!.player2Id
            : null;

    emit(
      PlaygroundRoundFinishingState(
        winnerType: determinedWinner,
        isWon: wonId != null ? wonId == _currentUser.userId : false,
        player1Move: StaticFunctions.getMoveEnumFromString(player1Move)!,
        player2Move: StaticFunctions.getMoveEnumFromString(player2Move)!,
        player1Name: _player1Info.name,
        player2Name: _player2Info?.name,
        roomType: _roomType,
        round: _currentRound,
      ),
    );
    if (lastPlayerId == _currentUser.userId) {
      _updateRoundAndMovesData();
    } else {
      //it's not our turn
    }
  }

  Future<void> _updateRoundAndMovesData() async {
    final batch = _fireStoreInstance.batch();
    final player1Id = _playerMoves!.player1Id!;
    final player2Id = _playerMoves!.player2Id!;

    final player1Move = _playerMoves!.player1Move;
    final player2Move = _roomType == RoomTypeEnums.botPlayer &&
            _playerMoves?.player2Move == null
        ? _generateBotMove().name
        : _playerMoves?.player2Move;

    final determinedWinner = StaticFunctions.determineWinnerFrom(
      player1Move: player1Move,
      player2Move: player2Move,
    );

    final roomRef = FirebaseFirestore.instance
        .collection(FireStoreConfig.roomCollection)
        .doc(_currentRoom.roomId);

    final playerMoveRef = FirebaseFirestore.instance
        .collection(FireStoreConfig.playerMovesCollection)
        .doc(_currentRoom.roomId);

    final roomData = <String, dynamic>{};
    final playerMoveData = <String, dynamic>{};
    bool shouldDeletePlayerMoves = false;

    final isRoundExistsInHistory = _currentRoom.roundInfo != null &&
        _currentRoom.roundInfo!.firstWhereOrNull(
              (element) => element.roundNo == _currentRound,
            ) !=
            null;
    if (!isRoundExistsInHistory) {
      final roundList = <RoundInfo>[];
      if (_currentRoom.roundInfo != null) {
        roundList.addAll(_currentRoom.roundInfo!);
      }
      roundList.add(
        RoundInfo(
          roundNo: _currentRound,
          player1Id: player1Id,
          player2Id: player2Id,
          player1Move: player1Move,
          player2Move: player2Move,
          winnerId: determinedWinner == WinnerTypeEnum.player1
              ? player1Id
              : determinedWinner == WinnerTypeEnum.player2
                  ? player2Id
                  : determinedWinner.name,
        ),
      );
      roomData[FireStoreConfig.roomRoundInfoField] =
          roundList.map((e) => e.toMap()).toList();
    }

    if (_currentRound! < _currentRoom.totalRounds!) {
      //if there are other round remaining, so need to update room round count and clear old moves
      roomData[FireStoreConfig.roomCurrentRoundField] = _currentRound! + 1;
      playerMoveData[FireStoreConfig.movesPlayer1MoveField] = null;
      playerMoveData[FireStoreConfig.movesPlayer2MoveField] = null;
    } else {
      //if all rounds are completed, need to clear player moves
      shouldDeletePlayerMoves = true;
    }

    if (roomData.isNotEmpty) {
      batch.update(
        roomRef,
        roomData,
      );
    }
    if (shouldDeletePlayerMoves) {
      batch.delete(playerMoveRef);
    } else if (playerMoveData.isNotEmpty) {
      batch.update(
        playerMoveRef,
        playerMoveData,
      );
    }
    await batch.commit();
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

  Future<Stream<DocumentSnapshot<Map<String, dynamic>>>>
      _getMyRoomSnapshot() async {
    return _fireStoreInstance
        .collection(FireStoreConfig.roomCollection)
        .doc(_currentRoom.roomId!)
        .snapshots();
  }

  Future<Room> _getRoomUpdatedData() async {
    final snapshot = await _fireStoreInstance
        .collection(FireStoreConfig.roomCollection)
        .doc(_currentRoom.roomId!)
        .get();

    return Room.fromSnapshot(snapshot);
  }

  Future<Stream<DocumentSnapshot<Map<String, dynamic>>>>
      _getPlayerMovesSnapshot() async {
    return _fireStoreInstance
        .collection(FireStoreConfig.playerMovesCollection)
        .doc(_currentRoom.roomId!)
        .snapshots();
  }

  String _generateTransactionId() {
    return _fireStoreInstance
        .collection(FireStoreConfig.transactionCollection)
        .doc()
        .id;
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    _roomSubscription?.cancel();
    _playerMovesSubscription?.cancel();
    return super.close();
  }
}
