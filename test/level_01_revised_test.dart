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

// A record to hold the results of the test setup
typedef TestSetup = ({ProviderContainer container, MockAnimationScheduler scheduler});

// TC-L1-01: Toggle switch interaction
// TC-L1-02: Move timer component

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
      
      // Read files here in setUpAll to avoid the testWidgets() File.readAsString() hang bug
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

    // This setup function implements the "Pre-Initialize Providers" strategy
    // with files pre-read to avoid the Flutter testWidgets() + File.readAsString() hang bug
    Future<TestSetup> pumpGameScreenWithOverrides(WidgetTester tester) async {
      print('[Test Setup] Starting pumpGameScreenWithOverrides...');
      
      // 1. Create all mock services (EXCEPT SharedPreferences)
      print('[Test Setup] Creating MockAssetManager...');
      mockAssetManager = MockAssetManager();
      
      print('[Test Setup] Creating MockAnimationScheduler...');
      mockAnimationScheduler = MockAnimationScheduler();
      
      print('[Test Setup] Creating MockAudioService...');
      mockAudioService = MockAudioService();
      
      // 2. Get SharedPreferences instance (should work since we called setMockInitialValues)
      print('[Test Setup] Getting SharedPreferences instance...');
      mockPrefs = await SharedPreferences.getInstance();
      print('[Test Setup] SharedPreferences instance obtained successfully');

      // 3. Prime the mock asset manager with the pre-read level files
      print('[Test Setup] Priming MockAssetManager with pre-read files...');
      mockAssetManager.primeFile('assets/levels/level_manifest.json', manifestContent);
      mockAssetManager.primeFile('assets/levels/level_01.json', level1Content);

      // 4. Create a temporary container to initialize services BEFORE the UI is built
      print('[Test Setup] Creating temporary ProviderContainer...');
      final tempContainer = ProviderContainer(
        overrides: [
          assetManagerProvider.overrideWith((_) => mockAssetManager),
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
        ],
      );

      // 5. Initialize the level manager and load the level data
      print('[Test Setup] Initializing level manager...');
      await tempContainer.read(levelManagerProvider.notifier).init();
      print('[Test Setup] Loading level by index...');
      final loadedLevel = await tempContainer.read(levelManagerProvider.notifier).loadLevelByIndex(0);
      expect(loadedLevel, isNotNull, reason: "Test setup failed: Level 1 could not be loaded.");
      level1 = loadedLevel!;
      print('[Test Setup] Level loaded successfully: ${level1.id}');

      // 6. Dispose the temporary container
      print('[Test Setup] Disposing temporary container...');
      tempContainer.dispose();

      // 7. Now, build the actual widget tree for the test
      print('[Test Setup] Creating test ProviderContainer...');
      final testContainer = ProviderContainer(
        overrides: [
          assetManagerProvider.overrideWith((_) => mockAssetManager),
          sharedPreferencesProvider.overrideWithValue(mockPrefs),
          // Provide the already-initialized level manager
          levelManagerProvider.overrideWith((ref) {
            final manager = LevelManagerNotifier(mockPrefs, mockAssetManager);
            manager.state = tempContainer.read(levelManagerProvider);
            manager.setCurrentLevel(level1);
            return manager;
          }),
          // Provide the game engine with the pre-loaded level
          gameEngineProvider(level1).overrideWith((ref) {
            return GameEngineNotifier(
              initialLevel: level1,
              animationScheduler: mockAnimationScheduler,
              audioService: mockAudioService,
            );
          }),
        ],
      );

      print('[Test Setup] Building widget tree...');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: testContainer,
          child: const MaterialApp(
            home: GameScreen(levelIndex: 0),
          ),
        ),
      );
      
      print('[Test Setup] Pumping and settling...');
      await tester.pumpAndSettle();
      print('[Test Setup] Setup complete!');
      
      return (container: testContainer, scheduler: mockAnimationScheduler);
    }

    testWidgets(
      'TC-L1-01: Toggle switch interaction',
      (WidgetTester tester) async {
        print('[Test] Starting TC-L1-01...');
        final setup = await pumpGameScreenWithOverrides(tester);
        final container = setup.container;
        final scheduler = setup.scheduler;

        print('[Test] Finding switch component...');
        final switchComponent = Level1TestHelper.findComponentById(container, level1, 'switch1');
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
        final newSwitchComponent = Level1TestHelper.findComponentById(container, level1, 'switch1')!;
        final finalSwitchClosed = Level1TestHelper.getSwitchState(newSwitchComponent);
        print('[Test] Final switch state: $finalSwitchClosed');

        expect(finalSwitchClosed, !initialSwitchClosed);
        print('[Test] TC-L1-01 completed successfully!');
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );

    testWidgets(
      'TC-L1-02: Move timer component',
      (WidgetTester tester) async {
        print('[Test] Starting TC-L1-02...');
        final setup = await pumpGameScreenWithOverrides(tester);
        final container = setup.container;
        final scheduler = setup.scheduler;

        print('[Test] Finding timer component...');
        final timerComponent = Level1TestHelper.findComponentById(container, level1, 'timer1');
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
        final movedComponent = Level1TestHelper.findComponentById(container, level1, 'timer1')!;
        print('[Test] Component moved to (${movedComponent.r}, ${movedComponent.c})');
        
        expect(movedComponent.r, equals(2));
        expect(movedComponent.c, equals(3));
        print('[Test] TC-L1-02 completed successfully!');
      },
      timeout: const Timeout(Duration(seconds: 30)),
    );
  });
}