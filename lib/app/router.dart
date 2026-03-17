import 'package:flutter/material.dart';
import 'package:chess/features/home/presentation/screens/home_screen.dart';
import 'package:chess/features/game/presentation/screens/game_screen.dart';
import 'package:chess/features/online/presentation/screens/online_lobby_screen.dart';
import 'package:chess/features/online/presentation/screens/online_game_screen.dart';
import 'package:chess/features/settings/presentation/screens/settings_screen.dart';

class AppRouter {
  static const home = '/';
  static const game = '/game';
  static const online = '/online';
  static const onlineGame = '/online/game';
  static const settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return _buildRoute(const HomeScreen(), routeSettings);
      case game:
        return _buildRoute(const GameScreen(), routeSettings);
      case online:
        return _buildRoute(const OnlineLobbyScreen(), routeSettings);
      case onlineGame:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return _buildRoute(
          OnlineGameScreen(
            roomCode: args['roomCode'] as String,
            playerId: args['playerId'] as String,
            isHost: args['isHost'] as bool,
          ),
          routeSettings,
        );
      case settings:
        return _buildRoute(const SettingsScreen(), routeSettings);
      default:
        return _buildRoute(const HomeScreen(), routeSettings);
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
