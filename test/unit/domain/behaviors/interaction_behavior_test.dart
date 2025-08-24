import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/domain/behaviors/interaction_behavior.dart';
import 'package:circuit_stem/domain/entities/component_entity.dart';
import 'package:circuit_stem/domain/value_objects/position.dart';
import 'package:circuit_stem/domain/value_objects/action_context.dart';
import 'package:circuit_stem/domain/value_objects/component_type.dart';

void main() {
  group('ToggleBehavior', () {
    test('execute with "tap" action should toggle the "closed" state from false to true', () {
      // ARRANGE
      final behavior = ToggleBehavior();
      final component = ComponentEntity(
        id: 's1',
        type: ComponentType.switchComponent,
        position: Position(r: 1, c: 1),
        state: {'closed': false},
        behaviors: [behavior],
      );
      final context = ActionContext();

      // ACT
      final result = behavior.execute(component, 'tap', context);

      // ASSERT
      expect(result.state['closed'], isTrue);
    });

    test('execute with "tap" action should toggle the "closed" state from true to false', () {
      // ARRANGE
      final behavior = ToggleBehavior();
      final component = ComponentEntity(
        id: 's1',
        type: ComponentType.switchComponent,
        position: Position(r: 1, c: 1),
        state: {'closed': true},
        behaviors: [behavior],
      );
      final context = ActionContext();

      // ACT
      final result = behavior.execute(component, 'tap', context);

      // ASSERT
      expect(result.state['closed'], isFalse);
    });
  });
}
