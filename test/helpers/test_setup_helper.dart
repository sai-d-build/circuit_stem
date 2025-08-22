
// test/helpers/test_setup_helper.dart
import 'dart:convert';
import 'dart:io';

import 'package:circuit_stem/core/providers.dart';
import 'package:circuit_stem/engine/game_engine_notifier.dart';
import 'package:circuit_stem/main.dart';
import 'package:circuit_stem/models/level_definition.dart';
import 'package:circuit_stem/services/level_manager.dart';
import 'package:circuit_stem/ui/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'mock_asset_manager.dart';
import 'mock_services.dart';

/// A record to hold the results of the test setup.
/// This bundle provides the test with all the necessary tools and state.
typedef TestSetup = ({
  ProviderContainer container,
  MockAnimationScheduler scheduler,
  MockAudioService audioService,
  LevelDefinition level
});

/// A helper class to provide a standardized, stable, and reusable setup
/// for all widget tests in the application.
class TestSetupHelper {
  // A static map to cache pre-read file content.
  static final Map<String, String> _fileCache = {};

  /// Pre-reads all level files defined in the manifest and registers game entities.
  /// This MUST be called once in a `setUpAll` block before any tests run.
  static Future<void> initializeTestEnvironment() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Set up mock shared preferences.
    SharedPreferences.setMockInitialValues({});

    // Register all component and goal behaviors.
    registerAllGameEntities();

    // Read the manifest file to discover all level files.
    final manifestPath = 'assets/levels/level_manifest.json';
    final manifestContent = await File(manifestPath).readAsString();
    _fileCache[manifestPath] = manifestContent;

    final manifestJson = jsonDecode(manifestContent) as Map<String, dynamic>;
    final levels = manifestJson['levels'] as List;

    // Read each level file listed in the manifest.
    for (final levelInfo in levels) {
      final levelId = levelInfo['id'] as String;
      final levelPath = 'assets/levels/$levelId.json';
      _fileCache[levelPath] = await File(levelPath).readAsString();
    }
  }

  /// Implements the "Pre-Initialize Providers" strategy for any given level.
  /// This function creates a fully mocked and controlled environment for testing the GameScreen.
  static Future<TestSetup> pumpGameScreenForLevel(
    WidgetTester tester,
    int levelIndex,
  ) async {
    // 1. Create all mock services.
    final mockAssetManager = MockAssetManager();
    final mockAnimationScheduler = MockAnimationScheduler();
    final mockAudioService = MockAudioService();
    final mockPrefs = await SharedPreferences.getInstance();

    // 2. Prime the mock asset manager with the pre-read file cache.
    _fileCache.forEach((path, content) {
      mockAssetManager.primeFile(path, content);
    });

    // 3. Create a temporary container to initialize services BEFORE the UI is built.
    // This avoids race conditions and ensures data is ready.
    final tempContainer = ProviderContainer(
      overrides: [
        assetManagerProvider.overrideWith((_) => mockAssetManager),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
    );

    // 4. Initialize the level manager and load the requested level data.
    await tempContainer.read(levelManagerProvider.notifier).init();
    final loadedLevel = await tempContainer.read(levelManagerProvider.notifier).loadLevelByIndex(levelIndex);
    expect(loadedLevel, isNotNull, reason: "Test setup failed: Level at index $levelIndex could not be loaded.");
    
    final level = loadedLevel!;

    // 5. Dispose the temporary container as it's no longer needed.
    tempContainer.dispose();

    // 6. Now, build the actual widget tree for the test with a new container.
    final testContainer = ProviderContainer(
      overrides: [
        assetManagerProvider.overrideWith((_) => mockAssetManager),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        audioServiceProvider.overrideWithValue(mockAudioService),
        
        // Provide the already-initialized level manager.
        levelManagerProvider.overrideWith((ref) {
          final manager = LevelManagerNotifier(mockPrefs, mockAssetManager);
          manager.state = tempContainer.read(levelManagerProvider); // Use state from disposed container
          manager.setCurrentLevel(level);
          return manager;
        }),
        
        // Provide the game engine with the pre-loaded level and mocks.
        gameEngineProvider(level).overrideWith((ref) {
          return GameEngineNotifierV2(
            initialLevel: level,
            audioService: mockAudioService,
          );
        }),
      ],
    );

    // 7. Pump the GameScreen widget.
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: testContainer,
        child: MaterialApp(
          home: GameScreen(levelIndex: levelIndex),
        ),
      ),
    );
    
    await tester.pumpAndSettle();
    
    // 8. Return the complete test setup bundle.
    return (
      container: testContainer,
      scheduler: mockAnimationScheduler,
      audioService: mockAudioService,
      level: level
    );
  }
}
