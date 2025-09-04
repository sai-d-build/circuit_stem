import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/application/enhanced_game_state.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

void main() {
  group('GameState', () {
    test('initial creates valid game state', () {
      final level = LevelDefinition(
        levelId: 'test_level',
        version: '1.0.0',
        metadata: const LevelMetadata(
          id: 'test_level',
          title: 'Test Level',
          description: 'A test level',
          difficulty: 'easy',
        ),
        grid: const GridConfig(
          width: 10,
          height: 10,
        ),
        components: const ComponentConfig(
          available: [],
          preplaced: [],
        ),
        goals: const [],
        validation: const ValidationRules(
          circuitRules: [],
          successConditions: [],
        ),
      );

      final state = GameState.initial(level);

      expect(state.currentLevel?.levelId, 'test_level');
      expect(state.grid.cols, 10);
      expect(state.grid.rows, 10);
      expect(state.isPaused, false);
      expect(state.isWin, false);
    });

    test('copyWith creates modified copy', () {
      final level = LevelDefinition(
        levelId: 'test_level',
        version: '1.0.0',
        metadata: const LevelMetadata(
          id: 'test_level',
          title: 'Test Level',
          description: 'A test level',
          difficulty: 'easy',
        ),
        grid: const GridConfig(
          width: 10,
          height: 10,
        ),
        components: const ComponentConfig(
          available: [],
          preplaced: [],
        ),
        goals: const [],
        validation: const ValidationRules(
          circuitRules: [],
          successConditions: [],
        ),
      );

      final state = GameState.initial(level);
      final modifiedState = state.copyWith(isPaused: true);

      expect(modifiedState.isPaused, true);
      expect(modifiedState.currentLevel?.levelId, 'test_level'); // Other properties unchanged
    });
  });
}