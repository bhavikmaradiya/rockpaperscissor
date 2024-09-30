import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rockpaperscissor/screens/auth/authentication_page.dart';
import 'package:rockpaperscissor/screens/auth/bloc/auth_bloc.dart';
import 'package:rockpaperscissor/screens/game_history/bloc/game_history_bloc.dart';
import 'package:rockpaperscissor/screens/game_history/game_history_page.dart';
import 'package:rockpaperscissor/screens/home/bloc/home_bloc.dart';
import 'package:rockpaperscissor/screens/home/home_page.dart';
import 'package:rockpaperscissor/screens/lobby/bloc/lobby_bloc.dart';
import 'package:rockpaperscissor/screens/lobby/lobby_page.dart';
import 'package:rockpaperscissor/screens/playground/bloc/playground_bloc.dart';
import 'package:rockpaperscissor/screens/playground/playground_page.dart';
import 'package:rockpaperscissor/screens/scoreboard/bloc/scoreboard_bloc.dart';
import 'package:rockpaperscissor/screens/scoreboard/scoreboard_page.dart';
import 'package:rockpaperscissor/screens/splash/bloc/splash_bloc.dart';
import 'package:rockpaperscissor/screens/splash/splash.dart';
import 'package:rockpaperscissor/screens/transaction/bloc/transaction_bloc.dart';
import 'package:rockpaperscissor/screens/transaction/transaction_page.dart';

class Routes {
  static const String splash = '/splash';
  static const String home = '/home';
  static const String authentication = '/authentication';
  static const String lobby = '/lobby';
  static const String playground = '/playground';
  static const String scoreboard = '/scoreboard';
  static const String transaction = '/transaction';
  static const String gameHistory = '/gamehistory';

  static Map<String, WidgetBuilder> get routeList => {
        splash: (_) => BlocProvider(
              create: (_) => SplashBloc(),
              child: const Splash(),
            ),
        authentication: (_) => BlocProvider(
              create: (_) => AuthBloc(),
              child: AuthenticationPage(),
            ),
        home: (_) => BlocProvider(
              create: (_) => HomeBloc(),
              child: const HomePage(),
            ),
        lobby: (_) => BlocProvider(
              create: (_) => LobbyBloc(),
              child: const LobbyPage(),
            ),
        playground: (_) => BlocProvider(
              create: (_) => PlaygroundBloc(),
              child: const PlaygroundPage(),
            ),
        transaction: (_) => BlocProvider(
              create: (_) => TransactionBloc(),
              child: const TransactionPage(),
            ),
        gameHistory: (_) => BlocProvider(
              create: (_) => GameHistoryBloc(),
              child: const GameHistoryPage(),
            ),
        scoreboard: (_) => BlocProvider(
              create: (_) => ScoreboardBloc(),
              child: const ScoreboardPage(),
            ),
      };
}
