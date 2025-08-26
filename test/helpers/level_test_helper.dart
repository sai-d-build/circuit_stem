
import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/game_engine_notifier.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/application/game_engine_state.dart';

class LevelTestHelper {
  static const double cellSize = 64.0;

  /// Find a component by ID in the current game engine state
  static ComponentModel? findComponentById(
      GameEngineState state, String id) {
    return state.grid.componentsById[id];
  }

  /// Find the first component by its type
  static ComponentModel? findComponentByType(
      GameEngineState state, String type) {
    try {
      return state.grid.components.firstWhere(
        (c) => c.type == type,
      );
    } catch (e) {
      return null;
    }
  }

  /// Check if a component is at a specific row and column
  static bool isComponentAt(ComponentModel component, int r, int c) {
    return component.r == r && component.c == c;
  }

  /// Get switch state
  static bool getSwitchState(ComponentModel component) {
    assert(component.type == 'Component.Switch',
        'Component must be a switch');
    return component.state['closed'] as bool? ?? false;
  }

  /// Tap a component by its ID
  static Future<void> tapComponent(
      WidgetTester tester, GameEngineNotifier notifier, String id) async {
    final comp = findComponentById(notifier.state, id);
    if (comp == null) return;

    final offset = componentCenter(comp);
    await tester.tapAt(offset);
    await tester.pumpAndSettle();
  }

  /// Drag a component by its ID to a new row and column
  static Future<void> dragComponent(
      WidgetTester tester,
      GameEngineNotifier notifier,
      String id,
      int toRow,
      int toCol) async {
    final comp = findComponentById(notifier.state, id);
    if (comp == null) return;

    final from = componentCenter(comp);
    final to = Offset(toCol * cellSize + cellSize / 2,
        toRow * cellSize + cellSize / 2);

    await tester.dragFrom(from, to - from);
    await tester.pumpAndSettle();
  }

  /// Get a component’s center offset for tap/drag
  static Offset componentCenter(ComponentModel component) {
    return Offset(
      component.c * cellSize + cellSize / 2,
      component.r * cellSize + cellSize / 2,
    );
  }
}
