import 'package:rockpaperscissor/enums/room_type_enums.dart';
import 'package:rockpaperscissor/screens/room/model/room.dart';

abstract class RoomPrefEvent {}

class RoomAmountTextChangeEvent extends RoomPrefEvent {
  final String amountText;

  RoomAmountTextChangeEvent(this.amountText);
}

class RoomPrefSubmitHostEvent extends RoomPrefEvent {
  RoomPrefSubmitHostEvent();
}

class RoomRoundValueChangeEvent extends RoomPrefEvent {
  final int roundToPlay;

  RoomRoundValueChangeEvent(this.roundToPlay);
}

class RoomMinBetValueSwitchEvent extends RoomPrefEvent {
  RoomMinBetValueSwitchEvent();
}

class RoomSwitchHostJoinEvent extends RoomPrefEvent {
  RoomSwitchHostJoinEvent();
}

class RoomJoinEvent extends RoomPrefEvent {
  final String inviteCode;

  RoomJoinEvent(this.inviteCode);
}

class RoomPrefInitialEvent extends RoomPrefEvent {
  final RoomTypeEnums roomType;
  final bool shouldAutoMatch;

  RoomPrefInitialEvent({
    required this.roomType,
    required this.shouldAutoMatch,
  });
}
