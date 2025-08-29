import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/providers.dart';
import 'package:circuit_stem/presentation/features/game/screens/game_screen.dart'; // Corrected import
import 'package:circuit_stem/application/game_engine_notifier.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/providers.dart';
import 'package:circuit_stem/presentation/features/game/screens/game_screen.dart'; // Corrected import
import 'package:circuit_stem/application/game_engine_notifier.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> pumpGameScreenWithOverrides(
    WidgetTester tester, LevelDefinition level,
    {required GameEngineNotifier notifier, required SharedPreferences prefs}) async {
  // Create the provider container with overrides
  final container = ProviderContainer(
    overrides: [
      gameEngineNotifierProvider.overrideWith((_) => notifier),
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Load the level into the notifier
  await notifier.loadLevel(level);

  // Build the widget tree
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: GameScreen(levelIndex: 0), // Changed level.index to 0
      ),
    ),
  );

  await tester.pumpAndSettle();

  return container;
}
