import 'package:rockpaperscissor/screens/room/model/quick_match.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';

abstract class LobbyEvent {}

class LobbyInitialEvent extends LobbyEvent {
  final Room? room;
  final QuickMatch? quickMatch;

  LobbyInitialEvent({
    this.room,
    this.quickMatch,
  });
}

class OpponentFoundEvent extends LobbyEvent {
  final Room room;

  OpponentFoundEvent(
    this.room,
  );
}

class StartExpireTimerEvent extends LobbyEvent {}

class CancelGameEvent extends LobbyEvent {
  final bool isExpired;

  CancelGameEvent({
    this.isExpired = false,
  });
}

class TimerTickEvent extends LobbyEvent {
  final Room room;
  final int remainingTime;

  TimerTickEvent({
    required this.room,
    required this.remainingTime,
  });
}

class ExpireTimerTickEvent extends LobbyEvent {
  final int remainingTime;

  ExpireTimerTickEvent({
    required this.remainingTime,
  });
}
