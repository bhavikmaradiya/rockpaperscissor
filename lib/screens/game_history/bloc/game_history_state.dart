import 'package:rockpaperscissor/screens/room/model/room.dart';

abstract class GameHistoryState {}

class GameHistoryInitialState extends GameHistoryState {}

class GameHistoryEmptyState extends GameHistoryState {}

class GameHistoryUpdatedState extends GameHistoryState {
  final List<Room> roomList;

  GameHistoryUpdatedState(
    this.roomList,
  );
}

class GameHistoryLoadingState extends GameHistoryState {}
