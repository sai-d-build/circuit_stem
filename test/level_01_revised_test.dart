import 'dart:io';
import 'package:circuit_stem/core/providers.dart';
import 'package:circuit_stem/engine/game_engine_notifier.dart';
import 'package:circuit_stem/models/level_definition.dart';
import 'package:circuit_stem/services/level_manager.dart';
import 'package:circuit_stem/ui/game_screen.dart';
import 'package:circuit_stem/main.dart'; // Import for registerAllGameEntities
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circuit_stem/common/constants.dart';

import 'helpers/level_01_test_helper.dart';
import 'helpers/mock_asset_manager.dart';
import 'helpers/mock_animation_scheduler.dart';
import 'helpers/mock_audio_service.dart';

import 'helpers/test_setup.dart'; // NEW: Import the TestSetup utility

// This typedef will be replaced by the TestSetup class
// typedef TestSetup = ({
//   ProviderContainer container, 
//   MockAnimationScheduler scheduler,
//   GameEngineNotifier gameEngineNotifier,
//   LevelDefinition level
// });

void main() {
  group('Level 01 Revised Tests - Foundation', () {
    late MockAssetManager mockAssetManager;
    late MockAnimationScheduler mockAnimationScheduler;
    late MockAudioService mockAudioService;
    late SharedPreferences mockPrefs;
    late LevelDefinition level1;
    
    // Pre-read file contents outside of testWidgets to avoid Flutter bug
    late String manifestContent;
    late String level1Content;

    // Set up SharedPreferences mock AND read files ONCE for the entire test group
    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      
      // This MUST be called before any getInstance() calls
      SharedPreferences.setMockInitialValues({});
      
      // Read files here in setUpAll to avoid the testWidgets() + File.readAsString() hang bug
      print('[SetupAll] Reading level manifest file...');
      manifestContent = await File('assets/levels/level_manifest.json').readAsString();
      print('[SetupAll] Reading level_01.json file...');
      level1Content = await File('assets/levels/level_01.json').readAsString();
      print('[SetupAll] Files read successfully');
      
      // CRITICAL FIX: Register all game entities in the test environment
      // This populates the ComponentRegistry with component types and behavior factories
      print('[SetupAll] Registering all game entities...');
      registerAllGameEntities();
      print('[SetupAll] Game entities registered successfully');
    });

    Future<ProviderContainer> pumpGameScreenWithOverrides(WidgetTester tester) async {
      print('[Test Setup] Starting pumpGameScreenWithOverrides...');

      // 1. Create all mock services
      final mockAssetManager = MockAssetManager();
      final mockAnimationScheduler = MockAnimationScheduler();
      final mockAudioService = MockAudioService();
      final mockPrefs = await SharedPreferences.getInstance();

      // 2. Prime the mock asset manager with the pre-read level files
      print('[Test Setup] Priming MockAssetManager with pre-read files...');
      mockAssetManager.primeFile('assets/levels/level_manifest.json', manifestContent);
      mockAssetManager.primeFile('assets/levels/level_01.json', level1Content);

      // 3. Create LevelManagerNotifier directly and load level data
      print('[Test Setup] Creating LevelManagerNotifier and loading level...');
      final levelManager = LevelManagerNotifier(mockPrefs, mockAssetManager);
      await levelManager.init();
      final loadedLevel = await levelManager.loadLevelByIndex(0);
      expect(loadedLevel, isNotNull, reason: "Test setup failed: Level 1 could not be loaded.");
      level1 = loadedLevel!;
      print('[Test Setup] Level loaded successfully: ${level1.id}');

      // 4. Create the main ProviderContainer with ALL overrides
      print('[Test Setup] Creating main ProviderContainer with all overrides...');
      final container = ProviderContainer(
        overrides: [
          assetManagerProvider.overrideWith((_) => mockAssetManager),
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          levelManagerProvider.overrideWith((ref) => levelManager),
          // This override replaces the autoDispose provider with a regular provider,
          // preventing premature disposal during tests.
          gameEngineProvider(level1).overrideWith(
            (ref) => GameEngineNotifier(
              initialLevel: level1,
              animationScheduler: mockAnimationScheduler,
              audioService: mockAudioService,
            ),
          ),
        ],
      );

      // ROBUSTNESS FIX: Manually create a listener to keep the provider alive
      // for the duration of the test. This prevents autoDispose from firing prematurely.
      final subscription = container.listen(gameEngineProvider(level1), (_, __) {});

      // Ensure both the listener and the container are disposed at the end of the test.
      addTearDown(subscription.close);
      addTearDown(container.dispose);
      print('[Test Setup] ProviderContainer created and addTearDown registered.');

      // 5. Build the widget tree
      print('[Test Setup] Building widget tree...');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: GameScreen(levelIndex: 0),
          ),
        ),
      );

      print('[Test Setup] Pumping and settling...');
      await tester.pumpAndSettle();
      print('[Test Setup] Setup complete!');

      return container; // Return the container for the test to use
    }

    testWidgets(
      'TC-L1-01: Toggle switch interaction',
      (WidgetTester tester) async {
        print('[Test] Starting TC-L1-01...');
        final container = await pumpGameScreenWithOverrides(tester);
        // NEW: Read notifier from container
        final gameEngineNotifier = container.read(gameEngineProvider(level1).notifier);
        final scheduler = gameEngineNotifier.animationScheduler as MockAnimationScheduler; // Access scheduler via notifier
        final level = level1; // Use the level1 variable from the group scope

        print('[Test] Finding switch component...');
        // FIXED: Get switch component from the actual GameEngineNotifier state
        final switchComponent = Level1TestHelper.findComponentById(container, level, 'switch1');
        expect(switchComponent, isNotNull);
        final initialSwitchClosed = Level1TestHelper.getSwitchState(switchComponent!);
        print('[Test] Initial switch state: $initialSwitchClosed');

        final tapOffset = Offset(switchComponent.c * cellSize + cellSize / 2, switchComponent.r * cellSize + cellSize / 2);
        print('[Test] Tapping switch at offset: $tapOffset');
        await Level1TestHelper.tapComponent(tester, tapOffset);

        // Give the animation a chance to start
        await tester.pump();

        // If animation is running, let it complete automatically
        if (scheduler.isRunning) {
          print('[Test] Animation running, waiting for completion...');
          int attempts = 0;
          while (scheduler.isRunning && attempts < 100) {
            await tester.pump(const Duration(milliseconds: 16)); // 16ms = 60fps
            attempts++;
          }

          // If still running after reasonable time, force complete it
          if (scheduler.isRunning) {
            print('[Test] Forcing animation completion...');
            scheduler.completeAnimation();
            await tester.pump();
          }
        }

        print('[Test] Final pump and settle...');
        await tester.pumpAndSettle();

        print('[Test] Checking final switch state...');
        // FIXED: Get the updated switch component from the GameEngineNotifier's current state
        final currentState = gameEngineNotifier.state;
        final updatedSwitchComponent = currentState.grid.componentsById['switch1'];
        expect(updatedSwitchComponent, isNotNull, reason: 'Switch component should exist after tap');

        final finalSwitchClosed = Level1TestHelper.getSwitchState(updatedSwitchComponent!);
        print('[Test] Final switch state: $finalSwitchClosed');

        expect(finalSwitchClosed, !initialSwitchClosed, reason: 'Switch state should toggle after tap');
        print('[Test] TC-L1-01 completed successfully!');
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'TC-L1-02: Move timer component',
      (WidgetTester tester) async {
        print('[Test] Starting TC-L1-02...');
        final container = await pumpGameScreenWithOverrides(tester);
        // NEW: Read notifier from container
        final gameEngineNotifier = container.read(gameEngineProvider(level1).notifier);
        final scheduler = gameEngineNotifier.animationScheduler as MockAnimationScheduler; // Access scheduler via notifier
        final level = level1; // Use the level1 variable from the group scope

        print('[Test] Finding timer component...');
        final timerComponent = Level1TestHelper.findComponentById(container, level, 'timer1');
        expect(timerComponent, isNotNull);
        expect(timerComponent!.isDraggable, isTrue);
        print('[Test] Timer component found at (${timerComponent.r}, ${timerComponent.c})');

        final fromOffset = Offset(timerComponent.c * cellSize + cellSize / 2, timerComponent.r * cellSize + cellSize / 2);
        const toOffset = Offset(3 * cellSize + cellSize / 2, 2 * cellSize + cellSize / 2);
        print('[Test] Dragging from $fromOffset to $toOffset');

        await Level1TestHelper.dragComponent(tester, fromOffset, toOffset);

        // Handle any animation from the drag operation
        await tester.pump();
        if (scheduler.isRunning) {
          print('[Test] Animation running after drag, completing...');
          scheduler.completeAnimation();
          await tester.pump();
        }

        print('[Test] Final pump and settle...');
        await tester.pumpAndSettle();

        print('[Test] Checking moved component position...');
        // FIXED: Get the moved component from the GameEngineNotifier's current state
        final currentState = gameEngineNotifier.state;
        final movedComponent = currentState.grid.componentsById['timer1'];
        expect(movedComponent, isNotNull, reason: 'Timer component should exist after drag');

        print('[Test] Component moved to (${movedComponent!.r}, ${movedComponent.c})');

        expect(movedComponent.r, equals(2), reason: 'Timer should be at row 2 after drag');
        expect(movedComponent.c, equals(3), reason: 'Timer should be at column 3 after drag');
        print('[Test] TC-L1-02 completed successfully!');
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });
}