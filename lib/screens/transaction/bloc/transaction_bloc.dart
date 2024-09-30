import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rockpaperscissor/config/app_config.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';
import 'package:rockpaperscissor/config/preference_config.dart';
import 'package:rockpaperscissor/enums/transaction_type_enums.dart';
import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/screens/transaction/bloc/transaction_event.dart';
import 'package:rockpaperscissor/screens/transaction/bloc/transaction_state.dart';
import 'package:rockpaperscissor/screens/transaction/model/user_transaction.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final _fireStoreInstance = FirebaseFirestore.instance;
  late User _currentUser;
  final List<UserTransaction> _transactionsList = [];
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _transactionsSubscription;

  TransactionBloc() : super(TransactionInitialState()) {
    on<TransactionInitialEvent>(_init);
    on<TransactionTopupWallet>(_onTopupWallet);
  }

  Future<void> _onTopupWallet(
    TransactionTopupWallet event,
    Emitter<TransactionState> emit,
  ) async {
    final amount = event.amount;
    if (amount > 0) {
      final batch = _fireStoreInstance.batch();
      final user = await _fetchPlayerInfoFromFirebase();
      final walletAmount = user.walletBalance ?? 0;
      final postWalletAmount = walletAmount + amount;

      final userRef = FirebaseFirestore.instance
          .collection(FireStoreConfig.userCollection)
          .doc(_currentUser.userId!);

      batch.update(userRef, {
        FireStoreConfig.userWalletBalanceField: postWalletAmount,
      });

      final transaction = _getTransaction(
        amount: amount,
        postWalletAmount: postWalletAmount,
      );

      final transactionRef = FirebaseFirestore.instance
          .collection(FireStoreConfig.transactionCollection)
          .doc(transaction.transactionId);
      batch.set(transactionRef, transaction.toMap());
      await batch.commit();
      emit(TransactionsToppedUpState());
    }
  }

  UserTransaction _getTransaction({
    required double amount,
    required double postWalletAmount,
  }) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return UserTransaction()
      ..transactionId = _generateTransactionId()
      ..transactionAmount = amount
      ..transactionPostWalletBal = postWalletAmount
      ..transactionUserId = _currentUser.userId!
      ..transactionType = TransactionTypeEnums.topUp.name
      ..createdAt = timestamp;
  }

  String _generateTransactionId() {
    return _fireStoreInstance
        .collection(FireStoreConfig.transactionCollection)
        .doc()
        .id;
  }

  Future<void> _init(
    TransactionInitialEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionsLoadingState());
    final currentUserArg =
        event.currentUser ?? (await StaticFunctions.getCurrentUser());
    if (currentUserArg != null) {
      _currentUser = currentUserArg;
      emit(
        TransactionUserUpdatedState(
          _currentUser,
        ),
      );
    }
    await _listenToCurrentUser(emit);
    await _listenToTransactions(emit);
    await _userSubscription?.asFuture();
    await _transactionsSubscription?.asFuture();
  }

  Future<void> _listenToCurrentUser(
    Emitter<TransactionState> emit,
  ) async {
    final snapshotStream = await _getUserSnapshot();
    _userSubscription = snapshotStream.listen(
      (snapshot) {
        User? user;
        try {
          user = User.fromSnapshot(snapshot);
        } on Exception catch (_) {}
        if (user != null) {
          _currentUser = user;
          emit(
            TransactionUserUpdatedState(
              _currentUser,
            ),
          );
        }
      },
    );
  }

  Future<void> _listenToTransactions(
    Emitter<TransactionState> emit,
  ) async {
    final snapshotStream = await _getTransactionsSnapshot();
    _transactionsSubscription = snapshotStream.listen(
      (snapshot) async {
        _transactionsList.clear();
        if (snapshot.docs.isNotEmpty) {
          await Future.forEach(
            snapshot.docs,
            (element) {
              UserTransaction? transaction;
              try {
                transaction = UserTransaction.fromSnapshot(
                  element,
                );
              } on Exception catch (_) {}
              if (transaction != null) {
                _transactionsList.add(
                  transaction,
                );
              }
            },
          );
          if (_transactionsList.isNotEmpty) {
            emit(
              TransactionUpdatedState(
                _transactionsList,
              ),
            );
          } else {
            emit(TransactionsEmptyState());
          }
        } else {
          emit(TransactionsEmptyState());
        }
      },
    );
  }

  Future<Stream<DocumentSnapshot<Map<String, dynamic>>>>
      _getUserSnapshot() async {
    String? userId = await StaticFunctions.getCurrentUserId();
    if (userId == null) {
      final preference = await SharedPreferences.getInstance();
      userId = preference.getString(
        PreferenceConfig.userIdPref,
      );
    }
    return _fireStoreInstance
        .collection(FireStoreConfig.userCollection)
        .doc(userId)
        .snapshots();
  }

  Future<User> _fetchPlayerInfoFromFirebase() async {
    final doc = await _fireStoreInstance
        .collection(FireStoreConfig.userCollection)
        .doc(_currentUser.userId)
        .get();
    return User.fromSnapshot(doc);
  }

  Future<Stream<QuerySnapshot<Map<String, dynamic>>>>
      _getTransactionsSnapshot() async {
    String? userId = await StaticFunctions.getCurrentUserId();
    if (userId == null) {
      final preference = await SharedPreferences.getInstance();
      userId = preference.getString(
        PreferenceConfig.userIdPref,
      );
    }
    return _fireStoreInstance
        .collection(
          FireStoreConfig.transactionCollection,
        )
        .where(
          FireStoreConfig.transactionUserIdField,
          isEqualTo: userId,
        )
        .orderBy(
          FireStoreConfig.createdAtField,
          descending: true,
        )
        .snapshots();
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _transactionsSubscription?.cancel();
    return super.close();
  }
}
