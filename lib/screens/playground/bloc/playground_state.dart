import 'package:rockpaperscissor/enums/moves_type_enums.dart';
import 'package:rockpaperscissor/enums/room_type_enums.dart';
import 'package:rockpaperscissor/enums/winner_type_enums.dart';
import 'package:rockpaperscissor/screens/playground/model/player_move.dart';

abstract class PlaygroundState {}

class PlaygroundInitialState extends PlaygroundState {}

class PlaygroundLoadingState extends PlaygroundState {
  final bool isLoading;

  PlaygroundLoadingState({
    this.isLoading = true,
  });
}

class TimerRunningState extends PlaygroundState {
  final int remainingTime;

  TimerRunningState({
    required this.remainingTime,
  });
}

/*class PlaygroundTurnSwitchedState extends PlaygroundState {
  final String whichPlayerTurn;

  PlaygroundTurnSwitchedState(
    this.whichPlayerTurn,
  );
}*/

class PlaygroundRoundTimedOutState extends PlaygroundState {
  final bool isLoading;

  PlaygroundRoundTimedOutState({
    this.isLoading = true,
  });
}

class PlaygroundMoveInputProcessingState extends PlaygroundState {
  final bool isProcessing;

  PlaygroundMoveInputProcessingState({
    this.isProcessing = true,
  });
}

class RoundSwitchState extends PlaygroundState {
  final int currentRound;

  RoundSwitchState({
    required this.currentRound,
  });
}

class RoundPointsUpdatedState extends PlaygroundState {
  final int player1Points;
  final int player2Points;

  RoundPointsUpdatedState({
    this.player1Points = 0,
    this.player2Points = 0,
  });
}

class PlaygroundPlayerMoveChangeState extends PlaygroundState {
  final RoomTypeEnums roomType;
  final PlayerMove playerMove;
  final String? player1Name;
  final String? player2Name;

  PlaygroundPlayerMoveChangeState({
    required this.playerMove,
    required this.player1Name,
    required this.player2Name,
    required this.roomType,
  });
}

class TimerCompleteState extends PlaygroundState {}

class PlaygroundRoundStartedState extends PlaygroundState {}

class PlaygroundRoundBufferingState extends PlaygroundState {
  final bool isLoading;

  PlaygroundRoundBufferingState({
    this.isLoading = true,
  });
}

class DisableActionsState extends PlaygroundState {
  final bool shouldDisable;

  DisableActionsState(this.shouldDisable);
}

class PlaygroundAllRoundFinishedState extends PlaygroundState {
  PlaygroundAllRoundFinishedState();
}

class PlaygroundStartScoreboardState extends PlaygroundState {
  final String? roomId;

  PlaygroundStartScoreboardState(this.roomId,);
}

class PlaygroundRoundFinishingState extends PlaygroundState {
  final bool isFinished;
  final bool isWon;
  final int? round;
  final WinnerTypeEnum? winnerType;
  final MovesTypeEnums? player1Move;
  final MovesTypeEnums? player2Move;
  final String? player1Name;
  final String? player2Name;
  final RoomTypeEnums? roomType;

  PlaygroundRoundFinishingState({
    this.isFinished = false,
    this.isWon = false,
    this.winnerType,
    this.round,
    this.player1Move,
    this.player2Move,
    this.player1Name,
    this.player2Name,
    this.roomType,
  });
}
