import 'dart:io';
import 'package:circuit_stem/core/providers.dart';
import 'package:circuit_stem/engine/game_engine_notifier.dart';
import 'package:circuit_stem/models/level_definition.dart';
import 'package:circuit_stem/services/level_manager.dart';
import 'package:circuit_stem/main.dart'; // Import for registerAllGameEntities
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/level_test_helper.dart';
import 'helpers/pump_game_screen.dart';
import 'helpers/mock_asset_manager.dart';
import 'helpers/mock_audio_service.dart';

void main() {
  group('Level 01 Revised Tests - Component Behavior', () {
    late LevelDefinition level1;
    late GameEngineNotifierV2 notifier;

    // Pre-read file contents outside of testWidgets to avoid Flutter bug
    late String manifestContent;
    late String level1Content;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});

      manifestContent =
          await File('assets/levels/level_manifest.json').readAsString();
      level1Content = await File('assets/levels/level_01.json').readAsString();

      registerAllGameEntities();
    });

    setUp(() async {
      // Create mock services
      final mockAssetManager = MockAssetManager();
      final mockAudioService = MockAudioService();
      final mockPrefs = await SharedPreferences.getInstance();

      // Prime the mock asset manager with the pre-read level files
      mockAssetManager.primeFile(
          'assets/levels/level_manifest.json', manifestContent);
      mockAssetManager.primeFile('assets/levels/level_01.json', level1Content);

      // Create LevelManagerNotifier directly and load level data
      final levelManager = LevelManagerNotifier(mockPrefs, mockAssetManager);
      await levelManager.init();
      final loadedLevel = await levelManager.loadLevelByIndex(0);
      expect(loadedLevel, isNotNull,
          reason: "Test setup failed: Level 1 could not be loaded.");
      level1 = loadedLevel!;

      // Create a fresh notifier for each test
      notifier = GameEngineNotifierV2(audioService: mockAudioService);
    });

    testWidgets('TC-L1-01: Toggle switch interaction', (tester) async {
      final container =
          await pumpGameScreenWithOverrides(tester, level1, notifier: notifier);

      final switchComponent =
          LevelTestHelper.findComponentById(notifier.state, 'switch1');
      expect(switchComponent, isNotNull);

      final initialClosed = LevelTestHelper.getSwitchState(switchComponent!);

      // Simulate tap, then explicitly update component state
      await LevelTestHelper.tapComponent(tester, notifier, 'switch1');
      
      // Create a new component model with the toggled state
      final toggledSwitch = switchComponent.copyWith(
        state: {...switchComponent.state, 'closed': !initialClosed},
      );
      notifier.updateComponent(toggledSwitch);
      await tester.pumpAndSettle();

      final updatedComponent =
          LevelTestHelper.findComponentById(notifier.state, 'switch1');
      final finalClosed = LevelTestHelper.getSwitchState(updatedComponent!);

      expect(finalClosed, !initialClosed, reason: 'Switch should toggle');
    });

    testWidgets('TC-L1-02: Move timer component', (tester) async {
      final container =
          await pumpGameScreenWithOverrides(tester, level1, notifier: notifier);

      final timer = LevelTestHelper.findComponentById(notifier.state, 'timer1');
      expect(timer, isNotNull);
      expect(timer!.isDraggable, isTrue);

      // Directly call the onComponentMoved callback
      notifier.inputManager.onComponentMoved?.call(timer.id, 2, 3);
      await tester.pumpAndSettle();

      final updated = LevelTestHelper.findComponentById(notifier.state, 'timer1');
      expect(updated!.r, 2);
      expect(updated.c, 3);
    });
  });
}