import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/services/providers.dart';
import '../helpers/game_test_helper.dart';
import '../helpers/test_setup_helper.dart';

void main() {
  group('Game Flow UI Tests', () {
    setUpAll(() async {
      await TestSetupHelper.initializeTestEnvironment();
    });

    testWidgets('TC-L1-10 & TC-L1-27: Win condition shows win dialog/animation',
        (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final container = setup.container;

      // ACT: Complete the circuit to trigger the win condition.
      final switchComp = GameTestHelper.findComponentById(container, 'switch1');
      final isClosed = switchComp.state['closed'] as bool? ?? false;
      if (!isClosed) {
        final newSwitchState = Map<String, dynamic>.from(switchComp.state)
          ..['closed'] = true;
        final updatedSwitch = switchComp.copyWith(state: newSwitchState);
        container
            .read(gameEngineProvider.notifier)
            .updateComponent(updatedSwitch);
        await tester.pumpAndSettle();
      }

      // ASSERT: Verify that the win dialog or a win animation widget is displayed.
      // We look for a widget with a specific key that should be present in the win UI.
      expect(find.byKey(const Key('win_dialog')), findsOneWidget,
          reason:
              'Win dialog or animation should be displayed when all goals are met');
    });

    testWidgets('TC-L1-26: Goal tracker UI updates as goals are met',
        (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final container = setup.container;

      // We will assume the goal tracker has a key and displays text like "Goals: 0/1"
      final initialGoalTracker = find.byKey(const Key('goal_tracker'));
      expect(initialGoalTracker, findsOneWidget);
      expect(find.textContaining('0/'), findsOneWidget);

      // ACT: Complete the circuit to meet a goal.
      final switchComp = GameTestHelper.findComponentById(container, 'switch1');
      final isClosed = switchComp.state['closed'] as bool? ?? false;
      if (!isClosed) {
        final newSwitchState = Map<String, dynamic>.from(switchComp.state)
          ..['closed'] = true;
        final updatedSwitch = switchComp.copyWith(state: newSwitchState);
        container
            .read(gameEngineProvider.notifier)
            .updateComponent(updatedSwitch);
        await tester.pumpAndSettle();
      }

      // ASSERT: Verify that the goal tracker text has updated.
      final finalGoalTracker = find.byKey(const Key('goal_tracker'));
      expect(finalGoalTracker, findsOneWidget);
      expect(find.textContaining('1/'), findsOneWidget,
          reason: 'Goal tracker UI should update when a goal is met');
    });
  });
}
