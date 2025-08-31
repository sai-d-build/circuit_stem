import 'package:flutter/material.dart';
import 'presentation/features/menus/screens/main_menu.dart';
import 'presentation/features/menus/screens/level_select.dart';
import 'presentation/features/game/screens/game_screen.dart';

class AppRoutes {
  static const String mainMenu = '/';
  static const String levelSelect = '/levels';
  static const String gameScreen = '/game';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainMenu:
        return MaterialPageRoute(builder: (_) => const MainMenuScreen());

      case levelSelect:
        return MaterialPageRoute(
          builder: (_) => const LevelSelectScreen(),
        );

      case gameScreen:
        if (settings.arguments is! int) {
          return MaterialPageRoute(
              builder: (_) => _errorPage(
                  'The game screen requires a levelIndex (int) argument.'));
        }
        final levelIndex = settings.arguments as int;
        return MaterialPageRoute(
            builder: (_) => GameScreen(levelId: levelIndex));

      default:
        return MaterialPageRoute(
            builder: (_) => _errorPage('Unknown route: ${settings.name}'));
    }
  }

  static Widget _errorPage(String message) {
    return Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text(message)),
    );
  }
}
