import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rockpaperscissor/config/app_config.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';
import 'package:rockpaperscissor/enums/room_status_enums.dart';
import 'package:rockpaperscissor/enums/room_type_enums.dart';
import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/screens/room/bloc/room_pref_event.dart';
import 'package:rockpaperscissor/screens/room/bloc/room_pref_state.dart';
import 'package:rockpaperscissor/screens/room/model/quick_match.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';

class RoomPrefBloc extends Bloc<RoomPrefEvent, RoomPrefState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  final Room _currentHostRoom = Room();
  User? _currentPlayer;
  double? _betAmount;
  int? _selectedRound;
  bool _isMinAmountShouldBeEqualToBetAmount = false;
  bool _isHostTabSelected = true;

  bool get isMinAmountShouldBeEqualToBetAmount =>
      _isMinAmountShouldBeEqualToBetAmount;

  bool get isHostTabSelected => _isHostTabSelected;

  Room get room => _currentHostRoom;

  double? get betAmount => _betAmount;

  int? get selectedRound => _selectedRound;

  RoomPrefBloc() : super(RoomPrefInitialState()) {
    on<RoomPrefInitialEvent>(_init);
    on<RoomAmountTextChangeEvent>(_onUpdateAmount);
    on<RoomRoundValueChangeEvent>(_onUpdateRound);
    on<RoomMinBetValueSwitchEvent>(_onUpdateMinAmountCheckbox);
    on<RoomSwitchHostJoinEvent>(_onSwitchHostJoin);
    on<RoomPrefSubmitHostEvent>(_onSubmit);
    on<RoomJoinEvent>(_onJoin);
  }

  void _onSwitchHostJoin(
    RoomSwitchHostJoinEvent event,
    Emitter<RoomPrefState> emit,
  ) {
    _isHostTabSelected = !_isHostTabSelected;
    emit(RoomPrefUpdatedState());
  }

  Future<void> _onJoin(
    RoomJoinEvent event,
    Emitter<RoomPrefState> emit,
  ) async {
    if (event.inviteCode.trim().isEmpty) {
      emit(RoomPrefInvalidState());
    } else {
      emit(RoomPrefLoadingState());
      final currentPlayer = await StaticFunctions.getCurrentUser(
        fetchFromDB: true,
      );
      if (currentPlayer != null && currentPlayer.userId != null) {
        if ((currentPlayer.walletBalance ?? 0) > 0) {
          final roomInfo = await _fetchRoomInfoFromFirebase(
            event.inviteCode.toUpperCase(),
          );
          if (roomInfo != null &&
              roomInfo.isAutoMatch == false &&
              roomInfo.minAmountToJoin != null &&
              roomInfo.minAmountToJoin! > 0 &&
              roomInfo.roomType == RoomTypeEnums.realPlayer.name &&
              roomInfo.playerIds?.length == 1 &&
              roomInfo.hostId != null &&
              roomInfo.hostId != currentPlayer.userId! &&
              !roomInfo.playerIds!.contains(currentPlayer.userId!)) {
            final roomExpireTime = DateTime.fromMillisecondsSinceEpoch(
              roomInfo.expiresAt!,
            );
            final currentTime = DateTime.now();
            final isRoomAlive = currentTime.isBefore(
              roomExpireTime,
            );
            if (isRoomAlive) {
              if (roomInfo.minAmountToJoin! <=
                  (currentPlayer.walletBalance ?? 0)) {
                roomInfo.playerIds?.add(
                  currentPlayer.userId!,
                );
                roomInfo.status = RoomStatusEnums.started.name;
                roomInfo.totalPotAmount =
                    roomInfo.totalPotAmount! + roomInfo.minAmountToJoin!;
                await FirebaseFirestore.instance
                    .collection(FireStoreConfig.roomCollection)
                    .doc(roomInfo.roomId)
                    .update(roomInfo.toMap());
                emit(RoomJoinedSuccessState(roomInfo));
              } else {
                emit(
                  RoomPrefLoadingState(
                    isLoading: false,
                  ),
                );
                emit(RoomPrefInsufficientWalletBalanceState());
              }
            } else {
              emit(
                RoomPrefLoadingState(
                  isLoading: false,
                ),
              );
              emit(RoomExpiredState());
            }
          } else {
            emit(
              RoomPrefLoadingState(
                isLoading: false,
              ),
            );
            emit(RoomNotFoundState());
          }
        } else {
          emit(
            RoomPrefLoadingState(
              isLoading: false,
            ),
          );
          emit(RoomPrefInsufficientWalletBalanceState());
        }
      } else {
        emit(
          RoomPrefLoadingState(
            isLoading: false,
          ),
        );
        emit(RoomPrefInvalidState());
      }
    }
  }

  Future<Room?> _fetchRoomInfoFromFirebase(
    String inviteCode,
  ) async {
    final roomData = await _fireStoreInstance
        .collection(FireStoreConfig.roomCollection)
        .where(
          FireStoreConfig.roomInviteCodeField,
          isEqualTo: inviteCode,
        )
        .where(
          FireStoreConfig.roomStatusField,
          isEqualTo: RoomStatusEnums.waiting.name,
        )
        .get();
    Room? room;
    if (roomData.docs.isNotEmpty) {
      try {
        room = Room.fromSnapshot(roomData.docs.first);
      } on Exception catch (_) {}
    }
    return room;
  }

  Future<void> _onSubmit(
    RoomPrefSubmitHostEvent event,
    Emitter<RoomPrefState> emit,
  ) async {
    if (_betAmount != null &&
        _betAmount! > 0 &&
        _selectedRound != null &&
        _selectedRound! > 0) {
      emit(RoomPrefLoadingState());
      _currentPlayer ??= await StaticFunctions.getCurrentUser(
        fetchFromDB: true,
      );
      if (_currentPlayer != null) {
        if (_currentPlayer!.walletBalance != null &&
            _betAmount! <= _currentPlayer!.walletBalance!) {
          if (_currentHostRoom.isAutoMatch == true) {
            await _createQuickMatchData(
              emit,
            );
          } else {
            await _createRoomData(
              emit,
            );
          }
        } else {
          emit(
            RoomPrefLoadingState(
              isLoading: false,
            ),
          );
          emit(RoomPrefInsufficientWalletBalanceState());
        }
      } else {
        emit(
          RoomPrefLoadingState(
            isLoading: false,
          ),
        );
        emit(RoomPrefInvalidState());
      }
    } else {
      emit(RoomPrefInvalidState());
    }
  }

  Future<void> _createQuickMatchData(
    Emitter<RoomPrefState> emit,
  ) async {
    final timeStamp = DateTime.now();
    final quickMatch = QuickMatch()
      ..matchId = _generateQuickMatchId()
      ..playerId = _currentPlayer!.userId!
      ..totalRounds = _selectedRound
      ..totalAmount = _betAmount
      ..createdAt = timeStamp.millisecondsSinceEpoch
      ..expiresAt = timeStamp
          .add(
            Duration(
              milliseconds:
                  (AppConfig.defaultRoomExpirationHourTime * 3600000).round(),
            ),
          )
          .millisecondsSinceEpoch;

    await FirebaseFirestore.instance
        .collection(FireStoreConfig.quickMatchCollection)
        .doc(quickMatch.matchId)
        .set(quickMatch.toMap());
    emit(
      RoomHostedQuickMatchState(
        quickMatch,
      ),
    );
  }

  Future<void> _createRoomData(
    Emitter<RoomPrefState> emit,
  ) async {
    final timeStamp = DateTime.now();
    final roomId = _generateRoomId();
    final inviteCode = _currentHostRoom.roomType != RoomTypeEnums.botPlayer.name
        ? await _generateUniqueInvitationCode(roomId)
        : null;
    _currentHostRoom
      ..roomId = roomId
      ..isAutoMatch = false
      ..status = _currentHostRoom.roomType == RoomTypeEnums.botPlayer.name
          ? RoomStatusEnums.started.name
          : RoomStatusEnums.waiting.name
      ..inviteCode = inviteCode
      ..playerIds = [
        _currentPlayer!.userId!,
      ]
      ..hostId = _currentPlayer!.userId!
      ..totalPotAmount =
          _currentHostRoom.roomType == RoomTypeEnums.botPlayer.name
              ? _betAmount! * 2
              : _betAmount
      ..totalRounds = _selectedRound
      ..currentRound =
          _currentHostRoom.roomType == RoomTypeEnums.botPlayer.name ? 1 : null
      ..minAmountToJoin = _betAmount
      ..createdAt = timeStamp.millisecondsSinceEpoch
      ..expiresAt = timeStamp
          .add(
            Duration(
              milliseconds:
                  (AppConfig.defaultRoomExpirationHourTime * 3600000).round(),
            ),
          )
          .millisecondsSinceEpoch
      ..updatedAt = timeStamp.millisecondsSinceEpoch;
    if (_currentHostRoom.roomType == RoomTypeEnums.botPlayer.name) {
      _currentHostRoom.playerIds?.add(
        AppConfig.defaultBotId,
      );
    }
    await FirebaseFirestore.instance
        .collection(FireStoreConfig.roomCollection)
        .doc(roomId)
        .set(_currentHostRoom.toMap());
    emit(
      RoomHostedSuccessState(
        _currentHostRoom,
      ),
    );
  }

  void _onUpdateAmount(
    RoomAmountTextChangeEvent event,
    Emitter<RoomPrefState> emit,
  ) {
    final amount = event.amountText;
    final parsedAmount = double.tryParse(amount);

    if (amount.trim().isNotEmpty && parsedAmount != null && parsedAmount > 0) {
      _betAmount = parsedAmount;
    } else {
      _betAmount = null;
    }
    emit(RoomPrefUpdatedState());
  }

  void _onUpdateRound(
    RoomRoundValueChangeEvent event,
    Emitter<RoomPrefState> emit,
  ) {
    final roundToPlay = event.roundToPlay;

    if (roundToPlay > 0) {
      _selectedRound = roundToPlay;
    } else {
      _selectedRound = null;
    }
    emit(RoomPrefUpdatedState());
  }

  void _onUpdateMinAmountCheckbox(
    RoomMinBetValueSwitchEvent event,
    Emitter<RoomPrefState> emit,
  ) {
    _isMinAmountShouldBeEqualToBetAmount =
        !_isMinAmountShouldBeEqualToBetAmount;
    emit(RoomPrefUpdatedState());
  }

  Future<void> _init(
    RoomPrefInitialEvent event,
    Emitter<RoomPrefState> emit,
  ) async {
    _currentHostRoom.roomType = event.roomType.name;
    _currentHostRoom.isAutoMatch = event.shouldAutoMatch;
    if (AppConfig.roundOptions.isNotEmpty) {
      _selectedRound = AppConfig.roundOptions.first;
    }
    _betAmount = AppConfig.defaultBetAmount;
    emit(RoomPrefUpdatedState());
  }

  String _generateRoomId() {
    return _fireStoreInstance
        .collection(FireStoreConfig.roomCollection)
        .doc()
        .id;
  }

  String _generateQuickMatchId() {
    return _fireStoreInstance
        .collection(FireStoreConfig.quickMatchCollection)
        .doc()
        .id;
  }

  Future<String> _generateUniqueInvitationCode(String roomId) async {
    String inviteCode;
    bool codeExists = true;

    do {
      inviteCode = _generateInvitationCode(roomId); // Generate a code
      QuerySnapshot query = await FirebaseFirestore.instance
          .collection(FireStoreConfig.roomCollection)
          .where(
            FireStoreConfig.roomInviteCodeField,
            isEqualTo: inviteCode,
          )
          .where(
            FireStoreConfig.roomStatusField,
            isNotEqualTo: RoomStatusEnums.finished.name,
          )
          .get();

      codeExists = query.docs.isNotEmpty; // Check if code exists
    } while (codeExists); // Repeat if code already exists
    return inviteCode;
  }

  String _generateInvitationCode(String roomId) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    Random random = Random();
    final twoChars = String.fromCharCodes(Iterable.generate(
        AppConfig.invitationCodeLength ~/ 2,
        (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    return '$twoChars${roomId.substring(roomId.length - AppConfig.invitationCodeLength ~/ 2, roomId.length)}'
        .toUpperCase();
  }
}
