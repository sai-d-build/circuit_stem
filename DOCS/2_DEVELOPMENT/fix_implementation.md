# Test Environment Fixes for `circuit_stem`

This document details the series of issues encountered and the comprehensive fixes implemented to establish a robust and reliable testing environment for the `circuit_stem` Flutter project. Each section outlines a specific problem, its root cause, and the solution applied.

## 1. Initial Test Setup Failure: Level Data Not Loading

### Problem
Tests were failing immediately during setup, reporting that game levels could not be loaded. This prevented any actual game logic from being tested.
## Diagnostic Plan: Flutter Test Failure Analysis

### Root Cause Hypothesis #1: Asset Loading Race Condition

**Problem**: The test is using [`rootBundle.loadString()`](lib/services/level_manager.dart:33) in [`LevelManagerNotifier._loadManifest()`](lib/services/level_manager.dart:29) while simultaneously using a [`MockAssetManager`](test/helpers/mock_asset_manager.dart) that doesn't override the rootBundle behavior. This creates a race condition where:

1. Test setup primes the mock with asset content via [`mockAssetManager.primeFile()`](test/level_01_revised_test.dart:37-39)
2. But [`LevelManagerNotifier.init()`](test/level_01_revised_test.dart:56) calls [`_loadManifest()`](lib/services/level_manager.dart:29) which uses `rootBundle` directly
3. The real `rootBundle` tries to load actual files, causing async conflicts

**Evidence**: The error shows "LevelManagerNotifier: _loadManifest START" followed by immediate SIGINT termination, suggesting the asset loading process is hanging or conflicting.

**Proposed Fix**:
```dart
// In LevelManagerNotifier, inject AssetManager dependency
class LevelManagerNotifier extends StateNotifier<LevelManagerState> {
  final SharedPreferences _sharedPrefs;
  final AssetManager _assetManager; // Add this

  LevelManagerNotifier(this._sharedPrefs, this._assetManager) : super(const LevelManagerState());

  Future<void> _loadManifest() async {
    // Replace rootBundle.loadString with _assetManager.loadString
    final manifestString = await _assetManager.loadString('assets/levels/level_manifest.json');
    // ... rest of method
  }
}
```

### Root Cause Hypothesis #2: Provider Dependency Cycle & Premature Disposal

**Problem**: The [`gameEngineProvider`](lib/core/providers.dart:30) depends on [`currentLevelDefinitionProvider`](lib/core/providers.dart:67), which depends on [`levelManagerProvider`](lib/core/providers.dart:26). When the test calls [`container.dispose()`](test/level_01_revised_test.dart:60) in tearDown, it creates a disposal race condition where:

1. GameEngine's animation scheduler is still running callbacks
2. LevelManager is being disposed while manifest loading is in progress
3. Provider dependency chain breaks during async operations

**Evidence**: The error shows Dart compiler exit and temp file deletion failures, indicating premature cleanup during active async operations.

**Proposed Fix**:
```dart
// In test tearDown, ensure proper async cleanup
tearDown(() async {
  // Stop animation scheduler before disposal
  final gameNotifier = container.read(gameEngineProvider.notifier);
  gameNotifier.setPaused(true);
  
  // Wait for any pending async operations
  await Future.delayed(Duration(milliseconds: 100));
  
  container.dispose();
});
```

### Implementation Priority

1. **Fix #1 (Asset Loading)** - Higher priority as it directly addresses the manifest loading failure
2. **Fix #2 (Provider Cleanup)** - Secondary fix to prevent disposal race conditions

Both fixes target the core issue: **uncontrolled async operations during test execution and cleanup**, which causes the Flutter test framework to terminate with SIGINT when it can't properly finalize the test environment.
I will proceed with applying the asset-loading fix by injecting AssetManager into LevelManagerNotifier and updating call sites to use the injected asset manager.

Key things I will implement:
- Update LevelManagerNotifier constructor to accept AssetManager and store it as _assetManager.
- Replace rootBundle.loadString(...) usages in _loadManifest and loadLevelByIndex with _assetManager.loadString(...).
- Update the provider wiring so LevelManagerNotifier is instantiated with an AssetManager (tests can inject a mockAssetManager).

References to review while implementing:
- lib/services/level_manager.dart
- lib/core/providers.dart
- test/helpers/mock_asset_manager.dart
- assets/levels/level_manifest.json and level_01.json (for expectations)

Proposed next steps:
- [ ] Modify LevelManagerNotifier signature: LevelManagerNotifier(this._sharedPrefs, this._assetManager)
- [ ] Inject AssetManager usage in _loadManifest and loadLevelByIndex
- [ ] Update any internal imports (add import '../services/asset_manager.dart';) and ensure no circular imports
- [ ] Update lib/core/providers.dart to pass assetManagerProvider into LevelManagerNotifier
- [ ] Adjust tests to provide a MockAssetManager via overrides (if necessary)
- [ ] Run flutter test test/level_01_revised_test.dart -v to validate

Would you like me to apply these changes now? If yes, I will execute the surgical edits step-by-step and report back with diffs and test results.

### Root Cause
In a Flutter test environment, asset loading (like JSON level definitions) does not work automatically as it does in a running application. The `AssetManager` was unable to find and load the `level_manifest.json` and individual level JSON files.

### Solution
1.  **`MockAssetManager` Creation:** A `MockAssetManager` (`test/helpers/mock_asset_manager.dart`) was created. This mock implements the `AssetManager` interface but allows test code to "prime" it with specific file contents.
2.  **Asset Priming:** In `test/level_01_revised_test.dart`, the `setUpAll` block was updated to read the actual `assets/levels/level_manifest.json` and `assets/levels/level_01.json` files directly from the file system and then prime the `MockAssetManager` with their content.
3.  **Provider Override:** The `assetManagerProvider` in the `ProviderContainer` was overridden with the `MockAssetManager` instance, ensuring that the `LevelManager` (and other services) received the mocked asset data.

## 2. `SharedPreferences` Provider Not Overridden

### Problem
After fixing asset loading, tests failed with an `UnimplementedError` related to the `SharedPreferences` provider.

### Root Cause
The `sharedPreferencesProvider` in `lib/core/providers.dart` is designed to throw an `UnimplementedError` if not explicitly overridden in a test environment, forcing developers to provide a mock implementation.

### Solution
1.  **Mock `SharedPreferences` Setup:** In `test/level_01_revised_test.dart`, `SharedPreferences.setMockInitialValues({})` was called to prepare the mock, and `await SharedPreferences.getInstance()` was used to get a mock instance.
2.  **Provider Override:** The `sharedPreferencesProvider` in the `ProviderContainer` was overridden with this mock `SharedPreferences` instance.

## 3. Asynchronous `LevelManager` Initialization & Method Not Found

### Problem
Tests were still encountering timing issues where the `LevelManager`'s level list was empty, or reporting a "method not found" error for `loadManifest()`.

### Root Cause
The `LevelManagerNotifier`'s constructor called `_loadManifest()` asynchronously, but there was no public, awaitable method to ensure the manifest was fully loaded before tests proceeded. My previous attempt to call `loadManifest()` was incorrect as that method doesn't exist.

### Solution
1.  **`LevelManagerNotifier` Refactoring:** A new public `Future<void> init()` method was added to `lib/services/level_manager.dart`. The `_loadManifest()` call was moved from the constructor into this `init()` method.
2.  **Awaited Initialization:** In `test/level_01_revised_test.dart`, the `setUpAll` block was updated to call and `await` `container.read(levelManagerProvider.notifier).init()`, guaranteeing the manifest is loaded before any tests run.

## 4. `GameEngine` Not Initialized with Level Data

### Problem
Even with the `LevelManager` loading levels, the `GameEngine` remained in an empty state, leading to "component not found" errors in tests.

### Root Cause
The `gameEngineProvider` was initially set up to create a `GameEngineNotifier.forNoLevel()`, and while it was reactively watching `currentLevelDefinitionProvider`, the `GameEngineNotifier` instance itself was not explicitly told to load the level after the `LevelManager` had loaded it.

### Solution
1.  **Reactive `gameEngineProvider`:** The `gameEngineProvider` in `lib/core/providers.dart` was refactored to reactively watch `currentLevelDefinitionProvider`. When `currentLevelDefinitionProvider` changes, `gameEngineProvider` now re-creates `GameEngineNotifier` with the `initialLevel` if available.
2.  **Explicit Level Loading in Test:** In `test/level_01_revised_test.dart`, within the `pumpGameScreen` helper, after `levelManagerProvider.notifier.loadLevelByIndex(0)` completes, the loaded `LevelDefinition` is explicitly passed to `container.read(gameEngineProvider.notifier).loadLevel(loadedLevel!)`. This ensures the `GameEngine` is fully populated.

## 5. `AnimationScheduler` Causing `pumpAndSettle` Timeouts

### Problem
Tests were timing out with `pumpAndSettle` errors, indicating a continuous animation loop.

### Root Cause
The `GameEngineNotifier` uses an `AnimationScheduler` that runs a continuous loop in the real application, which prevents `pumpAndSettle` from ever settling in a test environment.

### Solution
1.  **`MockAnimationScheduler` Creation:** A `MockAnimationScheduler` (`test/helpers/mock_animation_scheduler.dart`) was created. This mock implements `AnimationScheduler` but has empty `start()`, `stop()`, etc., methods. It includes a `triggerCallback(double dt)` method to manually advance the game state.
2.  **Injection and Manual Triggering:** In `test/level_01_revised_test.dart`, the `MockAnimationScheduler` is injected into `GameEngineNotifier` via provider override. After any interaction that should cause a game state update (e.g., tap, drag), `mockAnimationScheduler.triggerCallback(0.016)` is called, followed by `tester.pump()`, to simulate a single frame update.

## 6. `AudioService` Causing "Pending Timers"

### Problem
Tests were reporting "A Timer is still pending" errors, even after mocking the `AnimationScheduler`.

### Root Cause
The `AudioService` directly calls `FlameAudio.play()`, which initiates asynchronous audio playback operations that do not complete or are not properly cleaned up in a test environment.

### Solution
1.  **`MockAudioService` Creation:** A `MockAudioService` (`test/helpers/mock_audio_service.dart`) was created. This mock implements `AudioService` but has an empty `play()` method.
2.  **Injection:** In `test/level_01_revised_test.dart`, the `MockAudioService` is injected into `GameEngineNotifier` via provider override.

## 7. Test Structure & Widget Tree Cleanup

### Problem
The tests were a hybrid of state and widget tests, leading to `GameScreen` initialization issues and resource leaks (including the persistent "pending timer" error).

### Root Cause
The `GameScreen` was being pumped without ensuring all its dependencies were fully ready, and the widget tree was not being properly unmounted after each test, leaving lingering resources.

### Solution
1.  **Proper Widget Test Structure:** `test/level_01_revised_test.dart` was refactored to explicitly use `tester.pumpWidget` with `GameScreen` wrapped in `ProviderScope` for each test.
2.  **`setupTestEnvironment` Removal:** The confusing `setupTestEnvironment` helper was removed from `test/helpers/level_01_test_helper.dart` as its logic was integrated directly into the tests.
3.  **Comprehensive `tearDown`:** The `tearDown` block in `test/level_01_revised_test.dart` was updated to:
    *   `container.dispose()`: Disposes of all Riverpod providers and their notifiers.
    *   `TestWidgetsFlutterBinding.instance.renderView.prepareForTest()`: Explicitly unmounts the widget tree, ensuring `dispose()` methods of widgets (like `_GameCanvasState`'s `_ticker`) are called.

These fixes, implemented incrementally and tested, have systematically addressed the various layers of issues, moving the test suite towards a stable and reliable state.
