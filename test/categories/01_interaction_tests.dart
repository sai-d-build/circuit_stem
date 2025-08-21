
import 'package:circuit_stem/common/assets.dart';
import 'package:circuit_stem/models/component.dart';
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

    testWidgets('TC-L1-04: Attempting to drag an immovable component (Battery) fails', (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final batteryId = 'bat1';
      final initialPosition = GameTestHelper.findComponentById(setup.container, batteryId).position;

      // ACT
      await GameTestHelper.dragComponentToGrid(
        tester,
        setup.container,
        batteryId,
        initialPosition.r + 1,
        initialPosition.c + 1,
      );

      // ASSERT
      final finalPosition = GameTestHelper.findComponentById(setup.container, batteryId).position;
      expect(finalPosition, equals(initialPosition),
          reason: "Immovable component should not change position after being dragged.");
    });

    testWidgets('TC-L1-05: Attempting to drag an immovable component (Switch) fails', (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final switchId = 'switch1';
      final initialPosition = GameTestHelper.findComponentById(setup.container, switchId).position;

      // ACT
      await GameTestHelper.dragComponentToGrid(
        tester,
        setup.container,
        switchId,
        initialPosition.r + 1,
        initialPosition.c + 1,
      );

      // ASSERT
      final finalPosition = GameTestHelper.findComponentById(setup.container, switchId).position;
      expect(finalPosition, equals(initialPosition),
          reason: "Immovable component should not change position after being dragged.");
    });

    testWidgets('TC-L1-06: Dragging a component onto an occupied tile fails and gives feedback',
        (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final audioService = setup.audioService;

      final movableId = 'bulb1'; // The bulb is movable
      final stationaryId = 'bat1'; // The battery is not

      final movableInitialPos = GameTestHelper.findComponentById(setup.container, movableId).position;
      final stationaryPos = GameTestHelper.findComponentById(setup.container, stationaryId).position;

      // ACT
      // Attempt to drag the bulb onto the battery's position
      await GameTestHelper.dragComponentToGrid(
        tester,
        setup.container,
        movableId,
        stationaryPos.r,
        stationaryPos.c,
      );

      // ASSERT
      // 1. The component should have returned to its original position.
      final movableFinalPos = GameTestHelper.findComponentById(setup.container, movableId).position;
      expect(movableFinalPos, equals(movableInitialPos),
          reason: "Component should return to original position after invalid drag.");

      // 2. A warning sound should have been played.
      GameTestHelper.expectSoundPlayed(audioService, AppAssets.audioWarning);
    });
  });
}
