import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';

abstract class LobbyState {}

class LobbyInitialState extends LobbyState {}

class LobbyOpponentFoundState extends LobbyState {
  final Room currentRoom;

  LobbyOpponentFoundState(this.currentRoom);
}

class LobbyRoomChangesState extends LobbyState {
  final Room updatedRoom;

  LobbyRoomChangesState(
    this.updatedRoom,
  );
}

class LobbyExpiredState extends LobbyState {
  LobbyExpiredState();
}

class LobbyLoadOpponentViewState extends LobbyState {
  final User opponentPlayer;

  LobbyLoadOpponentViewState({
    required this.opponentPlayer,
  });
}

class LobbyCanceledSuccessfulState extends LobbyState {
  final bool isExpired;

  LobbyCanceledSuccessfulState({
    this.isExpired = false,
  });
}

class LobbyLoadingState extends LobbyState {
  final bool isLoading;

  LobbyLoadingState({
    this.isLoading = true,
  });
}

class TimerRunningState extends LobbyState {
  final int remainingTime;
  final bool isExpired;

  TimerRunningState({
    required this.remainingTime,
    this.isExpired = false,
  });
}
