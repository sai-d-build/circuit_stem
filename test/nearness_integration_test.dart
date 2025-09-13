import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/application/services/implementations/grid_validation_service_impl.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/application/states/history_state.dart';
import 'package:sparkcircuit/application/states/interaction_state.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';
import 'package:sparkcircuit/domain/entities/core/grid.dart';

void main() {
  group('Nearness Rule Integration Tests', () {
    late DefaultGridValidationService validator;
    late GameState gameState;

    setUp(() {
      validator = DefaultGridValidationService();

      // Create initial game state with some components
      final initialComponents = {
        'comp1': ComponentModel(
          id: 'comp1',
          type: ComponentType.resistor,
          row: 2,
          col: 2,
          properties: {},
        ),
        'comp2': ComponentModel(
          id: 'comp2',
          type: ComponentType.capacitor,
          row: 5,
          col: 5,
          properties: {},
        ),
      };

      final grid = Grid(
        rows: 10,
        cols: 10,
        components: initialComponents,
      );

      gameState = GameState(
        grid: grid,
        isPaused: false,
        isWin: false,
        currentLevel: null,
        interactionState: InteractionState.initial(),
        history: HistoryState.initial(),
        lastUpdated: DateTime.now(),
      );
    });

    group('Basic Nearness Validation', () {
      test('should allow placement at sufficient distance', () {
        // Position (0,0) should be valid (distance to comp1: ~2.8, to comp2: ~7.1)
        final result = validator.validatePosition(0, 0, gameState);
        expect(result.isValid, isTrue);
      });

      test('should reject placement adjacent to existing component', () {
        // Position (2,3) is adjacent to comp1 at (2,2)
        final result = validator.validatePosition(2, 3, gameState);
        expect(result.isValid, isFalse);
        expect(result.reason, contains('too close'));
      });

      test('should reject placement diagonally adjacent', () {
        // Position (3,3) is diagonally adjacent to comp1 at (2,2)
        final result = validator.validatePosition(3, 3, gameState);
        expect(result.isValid, isFalse);
        expect(result.reason, contains('too close'));
      });

      test('should reject placement on same position', () {
        // Position (2,2) is occupied by comp1
        final result = validator.validatePosition(2, 2, gameState);
        expect(result.isValid, isFalse);
        expect(result.reason, contains('occupied'));
      });
    });

    group('Edge Cases', () {
      test('should handle empty grid', () {
        final emptyGrid = Grid(
          rows: 10,
          cols: 10,
          components: {},
        );
        final emptyGameState = GameState(
          grid: emptyGrid,
          isPaused: false,
          isWin: false,
          currentLevel: null,
          interactionState: InteractionState.initial(),
          history: HistoryState.initial(),
          lastUpdated: DateTime.now(),
        );

        // Any position should be valid in empty grid
        final result = validator.validatePosition(5, 5, emptyGameState);
        expect(result.isValid, isTrue);
      });

      test('should handle grid boundaries', () {
        // Position outside bounds
        final result = validator.validatePosition(-1, 5, gameState);
        expect(result.isValid, isFalse);
        expect(result.reason, contains('out of bounds'));
      });

      test('should handle corner positions', () {
        // Corner position far from components
        final result = validator.validatePosition(9, 9, gameState);
        expect(result.isValid, isTrue);
      });
    });

    group('Multiple Components Scenarios', () {
      test('should handle dense component placement', () {
        // Add more components to create a dense area
        final denseComponents =
            Map<String, ComponentModel>.from(gameState.grid.components);
        denseComponents['comp3'] = ComponentModel(
          id: 'comp3',
          type: ComponentType.wire,
          row: 1,
          col: 1,
          properties: {},
        );
        denseComponents['comp4'] = ComponentModel(
          id: 'comp4',
          type: ComponentType.wire,
          row: 1,
          col: 3,
          properties: {},
        );

        final denseGrid = Grid(
          rows: 10,
          cols: 10,
          components: denseComponents,
        );
        final denseGameState = GameState(
          grid: denseGrid,
          isPaused: false,
          isWin: false,
          currentLevel: null,
          interactionState: InteractionState.initial(),
          history: HistoryState.initial(),
          lastUpdated: DateTime.now(),
        );

        // Position (1,2) should be invalid (between comp3 and comp4)
        final result = validator.validatePosition(1, 2, denseGameState);
        expect(result.isValid, isFalse);
        expect(result.reason, contains('too close'));
      });

      test('should find valid positions in complex layouts', () {
        // Create a more complex layout
        final complexComponents = {
          'comp1': ComponentModel(
              id: 'comp1',
              type: ComponentType.resistor,
              row: 0,
              col: 0,
              properties: {}),
          'comp2': ComponentModel(
              id: 'comp2',
              type: ComponentType.capacitor,
              row: 0,
              col: 2,
              properties: {}),
          'comp3': ComponentModel(
              id: 'comp3',
              type: ComponentType.wire,
              row: 2,
              col: 1,
              properties: {}),
        };

        final complexGrid = Grid(
          rows: 5,
          cols: 5,
          components: complexComponents,
        );
        final complexGameState = GameState(
          grid: complexGrid,
          isPaused: false,
          isWin: false,
          currentLevel: null,
          interactionState: InteractionState.initial(),
          history: HistoryState.initial(),
          lastUpdated: DateTime.now(),
        );

        // Test various positions
        final testPositions = [
          (0, 1), // Should be invalid (between comp1 and comp2)
          (1, 0), // Should be invalid (adjacent to comp1)
          (1, 1), // Should be invalid (adjacent to multiple components)
          (2, 0), // Should be invalid (adjacent to comp3)
          (3, 3), // Should be valid (far from all components)
          (4, 4), // Should be valid (corner far away)
        ];

        for (final pos in testPositions) {
          final result =
              validator.validatePosition(pos.$1, pos.$2, complexGameState);
          final expectedValid = pos == (3, 3) || pos == (4, 4);
          expect(result.isValid, equals(expectedValid),
              reason:
                  'Position (${pos.$1}, ${pos.$2}) validation should be $expectedValid');
        }
      });
    });

    group('Performance Tests', () {
      test('should handle large grids efficiently', () {
        // Create a larger grid with many components
        final largeComponents = <String, ComponentModel>{};
        for (var i = 0; i < 20; i++) {
          largeComponents['comp$i'] = ComponentModel(
            id: 'comp$i',
            type: ComponentType.wire,
            row: i * 2,
            col: i * 2,
            properties: {},
          );
        }

        final largeGrid = Grid(
          rows: 50,
          cols: 50,
          components: largeComponents,
        );
        final largeGameState = GameState(
          grid: largeGrid,
          isPaused: false,
          isWin: false,
          currentLevel: null,
          interactionState: InteractionState.initial(),
          history: HistoryState.initial(),
          lastUpdated: DateTime.now(),
        );

        final stopwatch = Stopwatch()..start();

        // Test validation performance
        for (var i = 0; i < 100; i++) {
          final row = (i * 7) % 50;
          final col = (i * 13) % 50;
          validator.validatePosition(row, col, largeGameState);
        }

        stopwatch.stop();
        final elapsedMs = stopwatch.elapsedMilliseconds;

        // Should complete within reasonable time (under 500ms for 100 validations)
        expect(elapsedMs, lessThan(500),
            reason:
                'Large grid validation took ${elapsedMs}ms for 100 operations');
      });
    });

    group('Integration with Component Types', () {
      test('should validate different component types', () {
        final componentTypes = [
          ComponentType.resistor,
          ComponentType.capacitor,
          ComponentType.wire,
          ComponentType.battery,
          ComponentType.bulb,
        ];

        for (final type in componentTypes) {
          // Position far from existing components should be valid for any type
          final result = validator.validatePosition(8, 8, gameState);
          expect(result.isValid, isTrue,
              reason: '$type placement at (8,8) should be valid');
        }
      });

      test('should handle component-specific properties', () {
        // Test with components that have different properties
        final specialComponents =
            Map<String, ComponentModel>.from(gameState.grid.components);
        specialComponents['special'] = ComponentModel(
          id: 'special',
          type: ComponentType.battery,
          row: 7,
          col: 7,
          properties: {'voltage': 12.0},
        );

        final specialGrid = Grid(
          rows: 10,
          cols: 10,
          components: specialComponents,
        );
        final specialGameState = GameState(
          grid: specialGrid,
          isPaused: false,
          isWin: false,
          currentLevel: null,
          interactionState: InteractionState.initial(),
          history: HistoryState.initial(),
          lastUpdated: DateTime.now(),
        );

        // Position adjacent to special component should be invalid
        final result = validator.validatePosition(7, 8, specialGameState);
        expect(result.isValid, isFalse);
        expect(result.reason, contains('too close'));
      });
    });
  });
}
