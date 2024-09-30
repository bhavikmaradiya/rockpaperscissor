import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rockpaperscissor/config/app_config.dart';
import 'package:rockpaperscissor/routes.dart';
import 'package:rockpaperscissor/utils/static_functions.dart';

part 'splash_event.dart';
part 'splash_state.dart';

class SplashBloc extends Bloc<SplashEvent, SplashState> {
  final _firebaseAuth = FirebaseAuth.instance;

  SplashBloc() : super(SplashInitialState()) {
    on<SplashInitialEvent>(_onInit);
    add(SplashInitialEvent());
  }

  Future<void> _onInit(
    SplashInitialEvent event,
    Emitter<SplashState> emit,
  ) async {
    await Future.delayed(
      const Duration(
        seconds: AppConfig.splashDuration,
      ),
    );
    if (_firebaseAuth.currentUser != null) {
      StaticFunctions.getCurrentUser();
      emit(
        SplashNavigationState(
          Routes.home,
        ),
      );
    } else {
      emit(
        SplashNavigationState(
          Routes.authentication,
        ),
      );
    }
  }
}
