import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';
import 'package:rockpaperscissor/screens/transaction/model/user_transaction.dart';

abstract class ScoreboardState {}

class ScoreboardInitialState extends ScoreboardState {}

class ScoreboardLoadingState extends ScoreboardState {}

class ScoreboardWinnerAnimationState extends ScoreboardState {
  final bool shouldAnimate;

  ScoreboardWinnerAnimationState({
    this.shouldAnimate = true,
  });
}

class ScoreboardUpdatedState extends ScoreboardState {
  final User player1;
  final User? player2;
  final Room roomData;
  final UserTransaction? transaction;

  ScoreboardUpdatedState({
    required this.player1,
    required this.player2,
    required this.roomData,
    required this.transaction,
  });
}
