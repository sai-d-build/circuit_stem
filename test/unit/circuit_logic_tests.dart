

import 'package:flutter_test/flutter_test.dart';

import '../helpers/game_test_helper.dart';
import '../helpers/test_setup_helper.dart';

void main() {
  group('Circuit Logic Tests for Level 1', () {
    setUpAll(() async {
      await TestSetupHelper.initializeTestEnvironment();
    });

    testWidgets('TC-L1-07: A partial or incomplete circuit does not power components', (tester) async {
      // ARRANGE
      // Level 1 starts in an incomplete state, so no component moves are needed.
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final bulbId = 'bulb1';

      // ACT
      // The circuit is already in a partial state. We just need to check it.
      // For good measure, we can tap the switch to ensure it's closed,
      // though it shouldn't matter if the circuit is broken elsewhere.
      final sw = GameTestHelper.findComponentById(setup.container, 'switch1');
      await GameTestHelper.tapGridCell(tester, sw.r, sw.c);

      // ASSERT
      // Verify that the bulb is not powered.
      final isPowered = GameTestHelper.isBulbPowered(setup.container, bulbId);
      expect(isPowered, isFalse, reason: 'Bulb should not be powered in a partial circuit.');
    });

    testWidgets('TC-L1-08: A complete circuit powers the bulb', (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final container = setup.container;
      final bulbId = 'bulb1';

      // ARRANGE: Move components to form a valid 2x2 circuit.
      // Battery is at (1,1) by default.
      // Move Switch to (1,2)
      await GameTestHelper.dragComponentToGrid(tester, container, 'switch1', 1, 2);
      // Move Bulb to (2,2)
      await GameTestHelper.dragComponentToGrid(tester, container, 'bulb1', 2, 2);
      // Move Wire to (2,1)
      await GameTestHelper.dragComponentToGrid(tester, container, 'wire1', 2, 1);

      // At this point, the bulb should still be off because the switch is open.
      expect(GameTestHelper.isBulbPowered(container, bulbId), isFalse);

      // ACT
      // Tap the switch to close the circuit.
      final sw = GameTestHelper.findComponentById(container, 'switch1');
      await GameTestHelper.tapGridCell(tester, sw.r, sw.c);

      // ASSERT
      // Verify that the bulb is now powered.
      final isPowered = GameTestHelper.isBulbPowered(container, bulbId);
      expect(isPowered, isTrue, reason: 'Bulb should be powered in a complete circuit.');
    });

    testWidgets('TC-L1-09: A complete circuit with a timer powers the bulb and activates the timer',
        (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final container = setup.container;
      final bulbId = 'bulb1';
      final timerId = 'timer1';

      // ARRANGE: Move components to form a valid 2x3 circuit.
      // This assumes level 1 has at least two wires.
      // Battery is at (1,1) by default.
      await GameTestHelper.dragComponentToGrid(tester, container, 'switch1', 1, 2);
      await GameTestHelper.dragComponentToGrid(tester, container, 'timer1', 1, 3);
      await GameTestHelper.dragComponentToGrid(tester, container, 'bulb1', 2, 3);
      await GameTestHelper.dragComponentToGrid(tester, container, 'wire1', 2, 2);
      // This test requires a second wire, assuming 'wire2' exists in the level.
      // If not, this test needs a level with more components.
      await GameTestHelper.dragComponentToGrid(tester, container, 'wire2', 2, 1);

      // Pre-condition check
      expect(GameTestHelper.isBulbPowered(container, bulbId), isFalse);
      expect(GameTestHelper.isTimerActive(container, timerId), isFalse);

      // ACT
      // Tap the switch to close the circuit.
      final sw = GameTestHelper.findComponentById(container, 'switch1');
      await GameTestHelper.tapGridCell(tester, sw.r, sw.c);

      // ASSERT
      // Verify that both the bulb is powered and the timer is active.
      expect(GameTestHelper.isBulbPowered(container, bulbId), isTrue, reason: 'Bulb should be powered.');
      expect(GameTestHelper.isTimerActive(container, timerId), isTrue, reason: 'Timer should be active.');
    });

    testWidgets('TC-L1-10: Meeting all goals triggers the win condition', (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final container = setup.container;

      // ARRANGE: Create the same winning circuit as in TC-L1-09.
      await GameTestHelper.dragComponentToGrid(tester, container, 'switch1', 1, 2);
      await GameTestHelper.dragComponentToGrid(tester, container, 'timer1', 1, 3);
      await GameTestHelper.dragComponentToGrid(tester, container, 'bulb1', 2, 3);
      await GameTestHelper.dragComponentToGrid(tester, container, 'wire1', 2, 2);
      await GameTestHelper.dragComponentToGrid(tester, container, 'wire2', 2, 1);

      // ACT
      // Tap the switch to close the circuit and meet all goals.
      final sw = GameTestHelper.findComponentById(container, 'switch1');
      await GameTestHelper.tapGridCell(tester, sw.r, sw.c);

      // ASSERT
      // Verify that the game engine reports a win state.
      expect(GameTestHelper.isGameInWinState(container), isTrue, reason: 'Win condition should be met when all goals are achieved.');
    });

    testWidgets('TC-L1-12: Breaking a winning circuit revokes the win state', (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final container = setup.container;
      final bulbId = 'bulb1';
      final timerId = 'timer1';

      // ARRANGE: Create the same winning circuit as in TC-L1-09.
      await GameTestHelper.dragComponentToGrid(tester, container, 'switch1', 1, 2);
      await GameTestHelper.dragComponentToGrid(tester, container, 'timer1', 1, 3);
      await GameTestHelper.dragComponentToGrid(tester, container, 'bulb1', 2, 3);
      await GameTestHelper.dragComponentToGrid(tester, container, 'wire1', 2, 2);
      await GameTestHelper.dragComponentToGrid(tester, container, 'wire2', 2, 1);

      // ACT 1: Complete the circuit to achieve the win state.
      final sw = GameTestHelper.findComponentById(container, 'switch1');
      await GameTestHelper.tapGridCell(tester, sw.r, sw.c);

      // ASSERT 1: Verify everything is active and the game is won.
      expect(GameTestHelper.isGameInWinState(container), isTrue, reason: 'Setup failed: Win condition not met.');
      expect(GameTestHelper.isBulbPowered(container, bulbId), isTrue, reason: 'Setup failed: Bulb not powered.');

      // ACT 2: Tap the switch again to open it, breaking the circuit.
      await GameTestHelper.tapGridCell(tester, sw.r, sw.c);

      // ASSERT 2: Verify the win state is revoked and components are off.
      expect(GameTestHelper.isGameInWinState(container), isFalse, reason: 'Win condition should be revoked after breaking circuit.');
      expect(GameTestHelper.isBulbPowered(container, bulbId), isFalse, reason: 'Bulb should turn off after breaking circuit.');
      expect(GameTestHelper.isTimerActive(container, timerId), isFalse, reason: 'Timer should stop after breaking circuit.');
    });

  });
}

