import 'package:rockpaperscissor/screens/room/model/quick_match.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';

abstract class RoomPrefState {}

class RoomPrefInitialState extends RoomPrefState {}

class RoomPrefUpdatedState extends RoomPrefState {
  RoomPrefUpdatedState();
}

class RoomPrefInvalidState extends RoomPrefState {
  RoomPrefInvalidState();
}

class RoomHostedSuccessState extends RoomPrefState {
  final Room roomData;

  RoomHostedSuccessState(this.roomData);
}

class RoomHostedQuickMatchState extends RoomPrefState {
  final QuickMatch quickMatch;

  RoomHostedQuickMatchState(
    this.quickMatch,
  );
}

class RoomJoinedSuccessState extends RoomPrefState {
  final Room roomData;

  RoomJoinedSuccessState(this.roomData);
}

class RoomNotFoundState extends RoomPrefState {
  RoomNotFoundState();
}

class RoomExpiredState extends RoomPrefState {
  RoomExpiredState();
}

class RoomPrefInsufficientWalletBalanceState extends RoomPrefState {
  RoomPrefInsufficientWalletBalanceState();
}

class RoomPrefLoadingState extends RoomPrefState {
  final bool isLoading;

  RoomPrefLoadingState({
    this.isLoading = true,
  });
}
