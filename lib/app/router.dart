import 'package:flutter/material.dart';
import 'package:chess/features/home/presentation/screens/home_screen.dart';
import 'package:chess/features/game/presentation/screens/game_screen.dart';
import 'package:chess/features/online/presentation/screens/online_placeholder_screen.dart';
import 'package:chess/features/settings/presentation/screens/settings_screen.dart';

class AppRouter {
  static const home = '/';
  static const game = '/game';
  static const online = '/online';
  static const settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case home:
        return _buildRoute(const HomeScreen());
      case game:
        return _buildRoute(const GameScreen());
      case online:
        return _buildRoute(const OnlinePlaceholderScreen());
      case settings:
        return _buildRoute(const SettingsScreen());
      default:
        return _buildRoute(const HomeScreen());
    }
  }

  static PageRouteBuilder _buildRoute(Widget page) {
    return PageRouteBuilder(
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
