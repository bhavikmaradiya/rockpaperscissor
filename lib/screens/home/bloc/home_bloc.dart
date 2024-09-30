import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rockpaperscissor/config/app_config.dart';
import 'package:rockpaperscissor/config/firestore_config.dart';
import 'package:rockpaperscissor/config/preference_config.dart';
import 'package:rockpaperscissor/screens/auth/model/user.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSubscription;
  late SharedPreferences prefs;
  User? currentUser;
  final _fireStoreInstance = FirebaseFirestore.instance;
  final _fireAuthInstance = auth.FirebaseAuth.instance;
  bool isFirstTimeUser = false;

  HomeBloc() : super(HomeInitialState()) {
    on<HomeLogoutEvent>(_logoutUser);
    on<HomeInitialEvent>(_init);
  }

  Future<void> _init(
    HomeInitialEvent event,
    Emitter<HomeState> emit,
  ) async {
    prefs = await SharedPreferences.getInstance();
    currentUser = await StaticFunctions.getCurrentUser();
    isFirstTimeUser = prefs.getBool(PreferenceConfig.isFirstTimePref) ?? false;
    if (currentUser != null) {
      emit(
        ProfileUpdatedState(
          user: currentUser!,
          isFirstTime: isFirstTimeUser,
        ),
      );
    }
    await _listenToCurrentUser(emit);
    await _checkForInitialTopup(emit);
    await _userSubscription?.asFuture();
  }

  Future<void> _listenToCurrentUser(
    Emitter<HomeState> emit,
  ) async {
    final snapshotStream = await _getUserSnapshot();
    _userSubscription = snapshotStream.listen(
      (snapshot) {
        User? user;
        try {
          user = User.fromSnapshot(snapshot);
        } on Exception catch (_) {}
        if (user != null) {
          currentUser = user;
          emit(
            ProfileUpdatedState(
              user: currentUser!,
              isFirstTime: isFirstTimeUser,
            ),
          );
        }
      },
    );
  }

  Future<Stream<DocumentSnapshot<Map<String, dynamic>>>>
      _getUserSnapshot() async {
    String? userId = StaticFunctions.userId;
    userId ??= prefs.getString(
      PreferenceConfig.userIdPref,
    );
    return _fireStoreInstance
        .collection(FireStoreConfig.userCollection)
        .doc(userId)
        .snapshots();
  }

  Future<void> _checkForInitialTopup(
    Emitter<HomeState> emit,
  ) async {
    if (isFirstTimeUser &&
        currentUser?.walletBalance?.round() == AppConfig.initialWalletAmount) {
      emit(HomeWalletTopUpState());
      await prefs.setBool(
        PreferenceConfig.isFirstTimePref,
        false,
      );
      await Future.delayed(
        const Duration(
          seconds: 7,
        ),
      );
      emit(
        HomeWalletTopUpState(
          shouldHide: true,
        ),
      );
    }
  }

  Future<void> _logoutUser(
    HomeLogoutEvent event,
    Emitter<HomeState> emit,
  ) async {
    await StaticFunctions.clearOnLogout();
    await _fireAuthInstance.signOut();
    emit(HomeLoggedOutState());
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
