abstract class ScoreboardEvent {}

class ScoreboardInitialEvent extends ScoreboardEvent {
  final String roomId;
  final bool isFromGame;

  ScoreboardInitialEvent(
    this.roomId,
    this.isFromGame,
  );
}
