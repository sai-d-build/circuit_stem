
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/core/providers.dart';
import 'package:circuit_stem/ui/game_screen.dart';
import 'package:circuit_stem/engine/game_engine_notifier.dart';
import 'package:circuit_stem/models/level_definition.dart';

Future<ProviderContainer> pumpGameScreenWithOverrides(
    WidgetTester tester,
    LevelDefinition level,
    {required GameEngineNotifierV2 notifier}) async {

  // Create the provider container with overrides
  final container = ProviderContainer(
    overrides: [
      gameEngineProvider.overrideWith((_) => notifier),
    ],
  );

  // Load the level into the notifier
  notifier.loadLevel(level); // Removed await

  // Build the widget tree
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        home: GameScreen(levelIndex: 0), // Changed level.index to 0
      ),
    ),
  );

  await tester.pumpAndSettle();

  return container;
}
