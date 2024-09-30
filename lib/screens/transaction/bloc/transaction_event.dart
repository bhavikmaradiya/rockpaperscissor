import 'package:rockpaperscissor/screens/auth/model/user.dart';

abstract class TransactionEvent {}

class TransactionInitialEvent extends TransactionEvent {
  final User? currentUser;

  TransactionInitialEvent({
    required this.currentUser,
  });
}

class TransactionTopupWallet extends TransactionEvent {
  final double amount;

  TransactionTopupWallet({
    required this.amount,
  });
}
