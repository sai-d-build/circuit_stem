import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/services/goal_checking_service.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';
import 'package:circuit_stem/domain/entities/goal.dart';

void main() {
  group('GoalCheckingService', () {
    late GoalCheckingService goalCheckingService;

    setUp(() {
      goalCheckingService = const GoalCheckingService();
    });

    test('returns false when goal is not met', () {
      // Arrange
      final components = [
        const ComponentModel(id: 'bulb', type: 'bulb', r: 0, c: 0, isPowered: false),
      ];
      final grid = Grid(rows: 1, cols: 1, components: components);
      final level = LevelDefinition(
        id: 'test_level',
        title: 'Test Level',
        description: '',
        levelNumber: 1,
        author: '',
        version: 1,
        rows: 1,
        cols: 1,
        blockedCells: [],
        initialComponents: [],
        paletteComponents: [],
        goals: const [Goal(type: 'power', targetId: 'bulb')],
        hints: [],
      );

      // Act
      final result = goalCheckingService.isLevelComplete(grid, level);

      // Assert
      expect(result, isFalse);
    });

    test('returns true when goal is met', () {
      // Arrange
      final components = [
        const ComponentModel(id: 'bulb', type: 'bulb', r: 0, c: 0, isPowered: true),
      ];
      final grid = Grid(rows: 1, cols: 1, components: components);
      final level = LevelDefinition(
        id: 'test_level',
        title: 'Test Level',
        description: '',
        levelNumber: 1,
        author: '',
        version: 1,
        rows: 1,
        cols: 1,
        blockedCells: [],
        initialComponents: [],
        paletteComponents: [],
        goals: const [Goal(type: 'power', targetId: 'bulb')],
        hints: [],
      );

      // Act
      final result = goalCheckingService.isLevelComplete(grid, level);

      // Assert
      expect(result, isTrue); // Placeholder, this should be true when implemented
    });
  });
}
