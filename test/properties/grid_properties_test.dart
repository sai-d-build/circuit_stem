import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/game_engine_notifier.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:circuit_stem/infrastructure/audio/audio_service.dart';
import 'package:circuit_stem/application/animation_scheduler.dart';
import 'package:circuit_stem/infrastructure/persistence/level_manager.dart';
import 'package:circuit_stem/common/logger.dart';
import 'package:mockito/mockito.dart';

class MockAudioService extends Mock implements AudioService {}

class MockLogger extends Mock implements Logger {}

class MockLevelManager extends Mock implements LevelManagerNotifier {}

void main() {
  group('Grid Properties Tests', () {
    late GameEngineNotifier notifier;
    late LevelDefinition testLevel;
    final random = Random();

    setUp(() {
      testLevel = const LevelDefinition(
        id: 'test_level',
        title: 'Test Level',
        description: 'A simple test level',
        levelNumber: 1,
        author: 'Test Author',
        version: 1,
        rows: 10,
        cols: 10,
        blockedCells: [],
        initialComponents: [],
        paletteComponents: [
          ComponentModel(
              id: 'wire_palette', type: 'wire', r: 0, c: 0, terminals: []),
          ComponentModel(
              id: 'resistor_palette',
              type: 'resistor',
              r: 0,
              c: 0,
              terminals: []),
        ],
        goals: [],
        hints: [],
      );

      notifier = GameEngineNotifier(
        audioService: MockAudioService(),
        animationScheduler: AnimationScheduler(),
        levelManager: MockLevelManager(),
      );

      notifier.loadLevel(testLevel);
    });

    test('Property: All components must be within the grid boundaries',
        () async {
      // Arrange
      const numberOfActions = 100;

      for (var i = 0; i < numberOfActions; i++) {
        final shouldCreate = random.nextBool();
        if (shouldCreate || notifier.state.grid.components.isEmpty) {
          // Create a new component
          final paletteComponents = notifier.state.paletteComponents;
          final template =
              paletteComponents[random.nextInt(paletteComponents.length)];
          final row = random.nextInt(testLevel.rows);
          final col = random.nextInt(testLevel.cols);
          final action = CreateComponentFromTemplateAction(
            templateId: template.id,
            row: row,
            col: col,
          );
          await notifier.executeAction(action);
        } else {
          // Move an existing component
          final components = notifier.state.grid.components;
          final componentToMove = components[random.nextInt(components.length)];
          final row = random.nextInt(testLevel.rows);
          final col = random.nextInt(testLevel.cols);
          final action = MoveComponentAction(
            componentId: componentToMove.id,
            newRow: row,
            newCol: col,
          );
          await notifier.executeAction(action);
        }

        // Assert
        for (final component in notifier.state.grid.components) {
          expect(component.r, greaterThanOrEqualTo(0));
          expect(component.r, lessThan(testLevel.rows));
          expect(component.c, greaterThanOrEqualTo(0));
          expect(component.c, lessThan(testLevel.cols));
        }
      }
    });
  });
}
