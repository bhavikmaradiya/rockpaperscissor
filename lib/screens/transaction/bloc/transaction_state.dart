import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/screens/transaction/model/user_transaction.dart';

abstract class TransactionState {}

class TransactionInitialState extends TransactionState {}

class TransactionUserUpdatedState extends TransactionState {
  final User currentUser;

  TransactionUserUpdatedState(
    this.currentUser,
  );
}

class TransactionUpdatedState extends TransactionState {
  final List<UserTransaction> transactionList;

  TransactionUpdatedState(
    this.transactionList,
  );
}

class TransactionsEmptyState extends TransactionState {}

class TransactionsLoadingState extends TransactionState {}
class TransactionsToppedUpState extends TransactionState {}
