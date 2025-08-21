
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/game_test_helper.dart';
import '../helpers/test_setup_helper.dart';

void main() {
  group('Game Flow Tests for Level 1', () {
    setUpAll(() async {
      await TestSetupHelper.initializeTestEnvironment();
    });

    testWidgets('TC-L1-28: Restart button resets component positions', (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final container = setup.container;
      final movableId = 'bulb1';

      // Get the component's starting position.
      final initialPosition = GameTestHelper.findComponentById(container, movableId).position;

      // ACT 1: Move the component to a new, valid position.
      await GameTestHelper.dragComponentToGrid(tester, container, movableId, 4, 4);

      // ASSERT 1: Verify the component has moved.
      final movedPosition = GameTestHelper.findComponentById(container, movableId).position;
      expect(movedPosition, isNot(equals(initialPosition)), reason: "Component should have moved before restart.");

      // ACT 2: Tap the restart button.
      await GameTestHelper.tapButton(tester, const Key('restart_button'));

      // ASSERT 2: Verify the component is back in its original position.
      final finalPosition = GameTestHelper.findComponentById(container, movableId).position;
      expect(finalPosition, equals(initialPosition), reason: "Component should reset to initial position after restart.");
    });

    testWidgets('TC-L1-29: Undo button reverts the last move', (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final container = setup.container;
      final movableId = 'bulb1';

      // Get the component's starting position.
      final initialPosition = GameTestHelper.findComponentById(container, movableId).position;

      // ACT 1: Move the component to a new, valid position.
      await GameTestHelper.dragComponentToGrid(tester, container, movableId, 4, 4);

      // ASSERT 1: Verify the component has moved.
      final movedPosition = GameTestHelper.findComponentById(container, movableId).position;
      expect(movedPosition, isNot(equals(initialPosition)), reason: "Component should have moved before undo.");

      // ACT 2: Tap the undo button.
      await GameTestHelper.tapButton(tester, const Key('undo_button'));

      // ASSERT 2: Verify the component is back in its original position.
      final finalPosition = GameTestHelper.findComponentById(container, movableId).position;
      expect(finalPosition, equals(initialPosition), reason: "Component should revert to previous position after undo.");
    });

    testWidgets('TC-L1-30: Rapidly tapping a switch does not queue multiple animations', (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final scheduler = setup.scheduler;

      final sw = GameTestHelper.findComponentById(setup.container, 'switch1');

      // ACT: Tap the switch 10 times in quick succession.
      for (int i = 0; i < 10; i++) {
        // No need to pump and settle here, we want to simulate rapid taps.
        await tester.tapAt(GameTestHelper.gridToPixel(sw.r, sw.c));
      }
      // A final pump to let the engine process the taps.
      await tester.pump();

      // ASSERT
      // Verify that the schedule method was called only once.
      // The game engine should prevent new animations while one is running.
      verify(() => scheduler.schedule(any(), any())).called(1);
    });
  });
}
