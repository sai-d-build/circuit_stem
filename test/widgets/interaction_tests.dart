import 'package:circuit_stem/common/assets.dart';

import 'package:flutter_test/flutter_test.dart';

import '../helpers/game_test_helper.dart';
import '../helpers/test_setup_helper.dart';

void main() {
  group('Interaction Tests for Level 1', () {
    // This setup runs once before all tests in this file.
    // It pre-loads all level files and registers all game components.
    setUpAll(() async {
      await TestSetupHelper.initializeTestEnvironment();
    });

    testWidgets(
        'TC-L1-04: Attempting to drag an immovable component (Battery) fails',
        (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final batteryId = 'bat1';
      final initialComponent =
          GameTestHelper.findComponentById(setup.container, batteryId);

      // ACT
      await GameTestHelper.dragComponentToGrid(
        tester,
        setup.container,
        batteryId,
        initialComponent.r + 1,
        initialComponent.c + 1,
      );

      // ASSERT
      final finalComponent =
          GameTestHelper.findComponentById(setup.container, batteryId);
      expect(finalComponent.r, equals(initialComponent.r));
      expect(finalComponent.c, equals(initialComponent.c));
    });

    testWidgets(
        'TC-L1-05: Attempting to drag an immovable component (Switch) fails',
        (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final switchId = 'switch1';
      final initialComponent =
          GameTestHelper.findComponentById(setup.container, switchId);

      // ACT
      await GameTestHelper.dragComponentToGrid(
        tester,
        setup.container,
        switchId,
        initialComponent.r + 1,
        initialComponent.c + 1,
      );

      // ASSERT
      final finalComponent =
          GameTestHelper.findComponentById(setup.container, switchId);
      expect(finalComponent.r, equals(initialComponent.r));
      expect(finalComponent.c, equals(initialComponent.c));
    });

    testWidgets(
        'TC-L1-06: Dragging a component onto an occupied tile fails and gives feedback',
        (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final audioService = setup.audioService;

      final movableId = 'bulb1'; // The bulb is movable
      final stationaryId = 'bat1'; // The battery is not

      final movableInitial =
          GameTestHelper.findComponentById(setup.container, movableId);
      final stationary =
          GameTestHelper.findComponentById(setup.container, stationaryId);

      // ACT
      // Attempt to drag the bulb onto the battery's position
      await GameTestHelper.dragComponentToGrid(
        tester,
        setup.container,
        movableId,
        stationary.r,
        stationary.c,
      );

      // ASSERT
      // 1. The component should have returned to its original position.
      final movableFinal =
          GameTestHelper.findComponentById(setup.container, movableId);
      expect(movableFinal.r, equals(movableInitial.r));
      expect(movableFinal.c, equals(movableInitial.c));

      // 2. A warning sound should have been played.
      GameTestHelper.expectSoundPlayed(audioService, AppAssets.audioWarning);
    });

    testWidgets('TC-L1-02: Move bulb component to a valid position',
        (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final container = setup.container;
      final bulbId = 'bulb1';
      final initialComponent =
          GameTestHelper.findComponentById(container, bulbId);
      final targetRow = initialComponent.r + 2;
      final targetCol = initialComponent.c + 2;

      // ACT
      await GameTestHelper.dragComponentToGrid(
        tester,
        container,
        bulbId,
        targetRow,
        targetCol,
      );

      // ASSERT
      final finalComponent =
          GameTestHelper.findComponentById(container, bulbId);
      expect(finalComponent.r, equals(targetRow));
      expect(finalComponent.c, equals(targetCol));
    });
  });
}
