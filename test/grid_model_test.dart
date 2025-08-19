import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/models/component.dart';
import 'package:circuit_stem/models/level_definition.dart';
import 'package:circuit_stem/engine/game_engine_notifier.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('GameEngineNotifier Grid Logic Tests', () {
    late GameEngineNotifier notifier;
    const initialLevel = LevelDefinition(
      id: 'test_level',
      title: 'Test Level',
      description: '',
      levelNumber: 1,
      rows: 3,
      cols: 3,
      initialComponents: [
        ComponentModel(id: 'c1', type: "Component.Battery", r: 1, c: 1),
      ],
      paletteComponents: [], // Add an empty list for palette components
      goals: [],
      author: 'test',
      version: 1,
      hints: [],
      blockedCells: [],
    );

    setUp(() {
      notifier = GameEngineNotifier(initialLevel: initialLevel);
    });

    test('loadLevel places initial components on the grid', () {
      final grid = notifier.state.grid;
      expect(grid.componentsById.length, 1);
      expect(grid.componentsAt(1, 1).first.id, 'c1');
    });

    test('endDrag moves a component to a new valid position', () {
      notifier.startDrag('c1', const Offset(1 * 64.0 + 32.0, 1 * 64.0 + 32.0));
      notifier.updateDrag('c1', const Offset(2 * 64.0 + 32.0, 2 * 64.0 + 32.0));
      notifier.endDrag('c1');

      final grid = notifier.state.grid;
      expect(grid.componentsAt(1, 1), isEmpty, reason: 'Original position should be empty');
      expect(grid.componentsAt(2, 2), isNotEmpty, reason: 'New position should be occupied');
      expect(grid.componentsAt(2, 2).first.id, 'c1');
    });
  });
}