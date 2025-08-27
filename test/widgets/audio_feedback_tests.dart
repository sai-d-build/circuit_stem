import 'package:circuit_stem/common/assets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/game_test_helper.dart';
import '../helpers/test_setup_helper.dart';

void main() {
  group('Audio Feedback Tests for Level 1', () {
    setUpAll(() async {
      await TestSetupHelper.initializeTestEnvironment();
    });

    testWidgets(
        'TC-L1-22: Placing a component in a valid position plays placement sound',
        (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final audioService = setup.audioService;
      final movableId = 'bulb1';

      // ACT
      // Drag the bulb to a valid, empty grid cell.
      await GameTestHelper.dragComponentToGrid(
          tester, setup.container, movableId, 4, 4);

      // ASSERT
      // Verify that the placement sound was played.
      GameTestHelper.expectSoundPlayed(audioService, AppAssets.audioPlacement);
    });

    testWidgets(
        'TC-L1-23: Placing a component in an invalid position plays warning sound',
        (tester) async {
      // ARRANGE
      final setup = await TestSetupHelper.pumpGameScreenForLevel(tester, 0);
      final audioService = setup.audioService;
      final movableId = 'bulb1';
      final stationaryComponent =
          GameTestHelper.findComponentById(setup.container, 'bat1');

      // ACT
      // Attempt to drag the bulb onto the battery's occupied position.
      await GameTestHelper.dragComponentToGrid(
        tester,
        setup.container,
        movableId,
        stationaryComponent.r,
        stationaryComponent.c,
      );

      // ASSERT
      // Verify that the warning sound was played.
      GameTestHelper.expectSoundPlayed(audioService, AppAssets.audioWarning);
    });
  });
}
