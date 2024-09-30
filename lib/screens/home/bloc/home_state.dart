part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitialState extends HomeState {}

class HomeLoggedOutState extends HomeState {}

class HomeWalletTopUpState extends HomeState {
  final bool shouldHide;

  HomeWalletTopUpState({
    this.shouldHide = false,
  });
}

class ProfileUpdatedState extends HomeState {
  final User user;
  final bool isFirstTime;

  ProfileUpdatedState({
    required this.user,
    this.isFirstTime = false,
  });
}
