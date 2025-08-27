import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../helpers/game_test_helper.dart';
import '../helpers/test_setup_helper.dart';

void main() {
  group('Hint System Tests', () {
    setUpAll(() async {
      await TestSetupHelper.initializeTestEnvironment();
    });

    testWidgets('TC-L1-11: Tapping hint button makes hint visible',
        (tester) async {
      // ARRANGE
      await TestSetupHelper.pumpGameScreenForLevel(tester, 0);

      // Assert that the hint is not initially visible.
      // We assume the hint is a widget identified by a specific key.
      expect(find.byKey(const Key('hint_ghost_wire')), findsNothing);

      // ACT: Tap the hint button.
      // We assume the hint button has a key.
      await GameTestHelper.tapButton(tester, const Key('hint_button'));
      await tester.pumpAndSettle();

      // ASSERT: Verify that the hint is now visible.
      expect(find.byKey(const Key('hint_ghost_wire')), findsOneWidget,
          reason: 'Hint UI should be visible after tapping the hint button');
    });

    testWidgets('TC-L1-20: Hint ghost wire fades after a duration',
        (tester) async {
      // ARRANGE
      await TestSetupHelper.pumpGameScreenForLevel(tester, 0);

      // ACT: Tap the hint button to show the hint.
      await GameTestHelper.tapButton(tester, const Key('hint_button'));
      await tester.pumpAndSettle();

      // ASSERT: Verify the hint is initially visible.
      expect(find.byKey(const Key('hint_ghost_wire')), findsOneWidget);

      // ACT 2: Pump the tester forward in time to simulate the fade animation completing.
      // We assume the fade duration is 2 seconds for this test.
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle(); // Let the UI rebuild after the animation.

      // ASSERT 2: Verify that the hint is no longer visible.
      expect(find.byKey(const Key('hint_ghost_wire')), findsNothing,
          reason: 'Hint UI should fade and be removed after its duration');
    });
  });
}
