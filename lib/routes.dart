import 'package:flutter/material.dart';

import 'presentation/features/game/screens/game_screen.dart';
import 'presentation/features/menus/screens/level_select.dart';
import 'presentation/features/menus/screens/main_menu.dart';
import 'presentation/features/menus/screens/settings_screen.dart';

class AppRoutes {
  static const String mainMenu = '/';
  static const String levelSelect = '/levels';
  static const String settings = '/settings';
  static const String gameScreen = '/game';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainMenu:
        return MaterialPageRoute(builder: (_) => const MainMenuScreen());

      case levelSelect:
        return MaterialPageRoute(
          builder: (_) => const LevelSelectScreen(),
        );

      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());

      case gameScreen:
        if (settings.arguments is! String) {
          return MaterialPageRoute(
              builder: (_) => _errorPage(
                  'The game screen requires a levelId (String) argument.'));
        }
        final levelId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => GameScreen(levelId: levelId));

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
