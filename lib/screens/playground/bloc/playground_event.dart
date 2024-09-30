import 'package:rockpaperscissor/enums/moves_type_enums.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';

abstract class PlaygroundEvent {}

class PlaygroundInitEvent extends PlaygroundEvent {
  final Room currentRoom;

  PlaygroundInitEvent({
    required this.currentRoom,
  });
}

class StopTimerEvent extends PlaygroundEvent {}

class StartTimerEvent extends PlaygroundEvent {
  final int duration;

  StartTimerEvent(
    this.duration,
  );
}

class GameCompletedEvent extends PlaygroundEvent{}

class DisableActionsEvent extends PlaygroundEvent{
  final bool shouldDisable;

  DisableActionsEvent(this.shouldDisable);
}

class PlaygroundMoveInputEvent extends PlaygroundEvent {
  final MovesTypeEnums moveType;

  PlaygroundMoveInputEvent({
    required this.moveType,
  });
}

class TimerTickEvent extends PlaygroundEvent {
  final int remainingTime;

  TimerTickEvent(
    this.remainingTime,
  );
}
