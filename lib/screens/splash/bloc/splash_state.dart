part of 'splash_bloc.dart';

abstract class SplashState {}

class SplashInitialState extends SplashState {}

class SplashNavigationState extends SplashState {
  final String route;

  SplashNavigationState(this.route);
}
