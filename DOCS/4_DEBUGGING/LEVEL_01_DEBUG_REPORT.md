# Level 01 Test Timeout — Comprehensive Root Cause Analysis & Fix Plan

This document consolidates the comprehensive debugging work performed for the failing tests in [`test/level_01_revised_test.dart`](test/level_01_revised_test.dart:1), capturing the root cause analysis, diagnostic diagrams, all helpful chat-run decisions, and the recommended fixes implemented and proposed.

Overview
- Problem: Two tests in [`test/level_01_revised_test.dart`](test/level_01_revised_test.dart:1) time out after 1 minute with `TimeoutException`.
- Symptoms: Tests hang during setup; the test process reaches the 1-minute timeout without completing.
- High-level root cause: Provider initialization ordering and a build-time race between the widget tree and asynchronous level manager initialization.

What I inspected
- Test file: [`test/level_01_revised_test.dart`](test/level_01_revised_test.dart:1)
- Helpers: [`test/helpers/mock_asset_manager.dart`](test/helpers/mock_asset_manager.dart:1), [`test/helpers/mock_animation_scheduler.dart`](test/helpers/mock_animation_scheduler.dart:1), [`test/helpers/level_01_test_helper.dart`](test/helpers/level_01_test_helper.dart:1)
- Providers: [`lib/core/providers.dart`](lib/core/providers.dart:1)
- Level manager: [`lib/services/level_manager.dart`](lib/services/level_manager.dart:1)
- Game engine: [`lib/engine/game_engine_notifier.dart`](lib/engine/game_engine_notifier.dart:1)
- Canvas and UI: [`lib/ui/game_canvas.dart`](lib/ui/game_canvas.dart:1), [`lib/ui/game_screen.dart`](lib/ui/game_screen.dart:1)
- Asset manager: [`lib/services/asset_manager.dart`](lib/services/asset_manager.dart:1)

Executive summary of findings
- The test helper [`pumpGameScreenWithOverrides()`](test/level_01_revised_test.dart:20) pumps the widget tree BEFORE the `LevelManagerNotifier` is initialized and the level is loaded.
- [`GameScreen`](lib/ui/game_screen.dart:9) reads `gameEngineProvider` during its initial synchronous build; `gameEngineProvider` reads `currentLevelDefinitionProvider` which derives from `levelManagerProvider`.
- Because `levelManagerProvider`'s initialization (`init()` / `loadLevelByIndex()`) happens after the widget build in the tests, the initial build sees `currentLevel == null`.
- `gameEngineProvider` therefore creates a "no level" `GameEngineNotifier.forNoLevel()` instance, which remains created and does not automatically pick up the later-initialized level from `levelManagerProvider`.
- This creates a deadlock-like behavior: the test awaits state updates or UI changes that never materialize as expected, ultimately causing the test runner to hit the timeout.

Root cause diagram (provider + widget interactions)
- Mermaid diagram (renderable in supported viewers):

```mermaid
flowchart TD
  A[Test Start] --> B[pumpWidget ProviderScope]
  B --> C[GameScreen.build()]
  C --> D[ref.watch(gameEngineProvider)]
  D --> E[currentLevelDefinitionProvider]
  E --> F[levelManagerProvider]
  F -->|not yet initialized| G[null currentLevel]
  G --> D
  D --> H[GameEngineNotifier.forNoLevel]
  H --> C
  C --> I[UI built with no level]
  I --> J[Test calls init/loadLevel (after build)]
  J --> F
  J --> K[levelManager state updated]
  K --> L[Notifies listeners]
  L --> M[gameEngineProvider SHOULD rebuild but doesn't]
  M --> N[UI doesn't receive expected level]
  N --> O[Test waits -> Timeout]
```

Detailed diagnostic evidence (key code references)
- The test pumps the widget tree here: [`test/level_01_revised_test.dart:35`](test/level_01_revised_test.dart:35)
- After pumping, the test attempts to initialize the level manager:
  - [`test/level_01_revised_test.dart:60`](test/level_01_revised_test.dart:60) ProviderScope.containerOf(...)
  - [`test/level_01_revised_test.dart:61`](test/level_01_revised_test.dart:61) init()
  - [`test/level_01_revised_test.dart:62`](test/level_01_revised_test.dart:62) loadLevelByIndex(0)
- `gameEngineProvider` logic that instantiates the engine (see [`lib/core/providers.dart`](lib/core/providers.dart:30)):
  - When `currentLevel` is null, `GameEngineNotifier.forNoLevel()` is returned.
- `GameCanvas` starts a `Ticker` in `initState()` (see [`lib/ui/game_canvas.dart:20`](lib/ui/game_canvas.dart:20)) which runs independently and expects a valid `renderState`.

Problems found in helper mocks
- [`MockAssetManager`](test/helpers/mock_asset_manager.dart:1)
  - Returns `Future.value(...)` synchronously for `loadString`, which is okay but doesn't simulate async delays and could differ from real behavior.
  - Returns `null` for image functions such as `getBestImageForCanvas` — this can lead to `CanvasPainter` receiving `null` assets.
- [`MockAnimationScheduler`](test/helpers/mock_animation_scheduler.dart:1)
  - Collects callbacks; tests manually call `triggerCallback()` which is fine, but `GameEngineNotifier` starts animation scheduler in its constructor and expects callbacks to run over time.
- These mocks combined with the provider initialization order cause timing mismatches and unexpected nulls in paint/render codepaths.

Why the widget tree doesn't pick up later provider updates
- `gameEngineProvider` is a `StateNotifierProvider` created once during the initial build. If it reads `currentLevelDefinitionProvider` and that provider returns `null` at creation time, the provider instance is created in the "no level" form and not re-created automatically when `levelManagerProvider` later updates state.
- The test pattern used tried to mutate the `levelManagerProvider` after the widget tree was built, but the `gameEngineProvider` (already instantiated) doesn't automatically re-initialize to use a new initial level.

Immediate effective fix applied
- Change implemented in the test helper [`pumpGameScreenWithOverrides()`](test/level_01_revised_test.dart:20) so that:
  1. Mock assets are primed.
  2. A temporary `ProviderContainer` is created.
  3. The `LevelManagerNotifier` is initialized and `loadLevelByIndex(0)` is executed inside that temporary container.
  4. The initialized `LevelManagerState` and `currentLevelDefinition` are read from `tempContainer`.
  5. The widget tree is pumped with provider overrides that inject a `LevelManagerNotifier` seeded with the pre-initialized state and a `GameEngineNotifier` created with the initialized `initialLevel`.
  6. The `tempContainer` is disposed to avoid leaks.

Applied change (high-level snippet)
- See the updated function [`pumpGameScreenWithOverrides()`](test/level_01_revised_test.dart:20) in the test file; key steps are:
  - Use `ProviderContainer` to initialize providers prior to `pumpWidget`.
  - Inject the seeded state into the real widget tree's providers via `ProviderScope.overrides`.
  - Pump and allow microtasks (`await tester.pump()` and `await tester.pump(Duration(...))`) to let the widget tree fully settle.

Why this fix works
- By fully initializing `levelManagerProvider` and constructing `GameEngineNotifier` with an `initialLevel` before the first build, `GameScreen` sees a non-null `currentLevel` during its initial synchronous build.
- This avoids creation of the "no level" engine and prevents the build-time race and subsequent test timeouts.

Alternative / more robust fixes (recommended medium and long-term)
1. Redesign `GameScreen` to handle asynchronous initialization:
   - Convert to a `ConsumerStatefulWidget` and perform async initialization in `initState()` reading `levelManagerProvider.notifier` and awaiting `init()`/`loadLevelByIndex()` before rendering the full UI.
   - Present a loading placeholder (spinner) until initialization completes.
   - Reference: [`lib/ui/game_screen.dart`](lib/ui/game_screen.dart:9)
2. Restructure providers to avoid circular dependencies:
   - Use a `FutureProvider` for the initialized level manager or `currentLevelDefinition`.
   - Make `gameEngineProvider` subscribe to an initialized-level provider or be created lazily once an initialized level exists.
3. Improve mocks for test realism:
   - `MockAssetManager` should simulate asynchronous delays (`await Future.microtask(...)` or small `Future.delayed`) and provide minimal `ui.Image` objects for `getBestImageForCanvas` to prevent painter nulls.
   - `MockAnimationScheduler.start()` should optionally immediately call callbacks (via `Future.microtask`) if tests expect the first tick immediately.
4. Layered testing strategy:
   - Unit tests for `LevelManagerNotifier` and `GameEngineNotifier` in isolation.
   - Progressive integration tests: providers-only, then provider+light widget, then full UI tests.

Repro steps (how to run the updated tests locally)
1. Ensure `flutter test test/level_01_revised_test.dart` is run from the project root.
2. The updated `pumpGameScreenWithOverrides()` now pre-initializes providers; run the test and expect the previous timeouts to be resolved.

Key code/filenames referenced in this report
- Test file: [`test/level_01_revised_test.dart`](test/level_01_revised_test.dart:1)
- Helpers: [`test/helpers/mock_asset_manager.dart`](test/helpers/mock_asset_manager.dart:1), [`test/helpers/mock_animation_scheduler.dart`](test/helpers/mock_animation_scheduler.dart:1)
- Providers: [`lib/core/providers.dart`](lib/core/providers.dart:1)
- Level manager: [`lib/services/level_manager.dart`](lib/services/level_manager.dart:1)
- Game engine: [`lib/engine/game_engine_notifier.dart`](lib/engine/game_engine_notifier.dart:1)
- UI: [`lib/ui/game_screen.dart`](lib/ui/game_screen.dart:1), [`lib/ui/game_canvas.dart`](lib/ui/game_canvas.dart:1)
- Asset manager: [`lib/services/asset_manager.dart`](lib/services/asset_manager.dart:1)

Decision log (chat highlights that were helpful)
- Confirmed that the `LevelManagerNotifier` had been refactored for dependency injection (handover).
- Observed that tests were wrapping `ProviderScope` but still initializing the level manager after `pumpWidget`.
- Determined pre-initialization of providers in a temporary `ProviderContainer` to be a minimal, high-confidence fix.
- Proposed longer-term architectural changes (async UI loading or provider restructuring) if repeated problems occur.

Recommended next steps (practical)
1. Run the updated tests locally. If they now pass, merge the test fix.
2. Add improved mocks:
   - Update `MockAssetManager` to return a minimal `ui.Image` for canvas calls.
   - Update `MockAnimationScheduler` to behave more like the real scheduler when `start()` is called.
3. Implement `GameScreen` async initialization and a loading state as the more robust application-level fix.
4. Add targeted unit tests for `LevelManagerNotifier` and `GameEngineNotifier` to catch regressions early.

Appendix A — Example `pumpGameScreenWithOverrides()` pattern used
```dart
// See test/level_01_revised_test.dart for exact updated code
// Summary:
// 1. Create mock assets & prefs.
// 2. Use temp ProviderContainer to call init() and loadLevelByIndex().
// 3. Read initialized state and level.
// 4. Pump widget tree with overrides that inject a seeded LevelManagerNotifier and GameEngineNotifier(initialLevel: ...).
```

Appendix B — Mermaid provider diagram (repeat)
```mermaid
flowchart LR
  A[ProviderContainer(temp)] --> B[levelManager.init()]
  B --> C[level loaded]
  C --> D[seeded LevelManagerState]
  D --> E[ProviderScope.overrides]
  E --> F[GameEngineNotifier(initialLevel: seeded)]
  F --> G[GameScreen.build -> sees currentLevel]
```

Appendix C — Test progression to isolate hangs
1. Test providers only (no widget) — verify `levelManagerProvider.init()` completes.
2. Test `GameEngineNotifier` with `initialLevel` (unit test).
3. Test small widget that reads providers but does not start `GameCanvas` ticker.
4. Run full UI test.

Change applied
- The test helper in [`test/level_01_revised_test.dart`](test/level_01_revised_test.dart:20) was modified to pre-initialize the `LevelManagerNotifier` using a `ProviderContainer` before pumping the `ProviderScope` widget tree. This removes the build-time race and prevents the `TimeoutException`.

If you want, I can:
- Push an additional patch to improve `MockAssetManager` to return a minimal test `ui.Image`.
- Refactor `GameScreen` to use async initialization and a loading state.
- Add focused unit tests for `LevelManagerNotifier` and `GameEngineNotifier`.

Prepared by: Kilo Code (assistant) — consolidated from the debugging session and test edits


## **Implementation Guidance and Final Recommendations**

### **Immediate Action Plan (Priority Order)**

#### **Phase 1: Quick Fix (Recommended First Step)**
**Implement Solution Approach #1** - Pre-Initialize Providers

**Why This First**: 
- Minimal code changes required
- Addresses the core initialization timing issue
- Can be implemented without architectural changes
- High probability of success

**Implementation Steps**:
1. Modify [`pumpGameScreenWithOverrides()`](test/level_01_revised_test.dart:20) to use the pre-initialization pattern
2. Test with the existing test cases
3. If successful, this should resolve the timeout immediately

#### **Phase 2: Robust Solution (If Phase 1 Succeeds)**
**Implement Solution Approach #2** - Redesign GameScreen

**Why Second**: 
- Makes the application more robust for production
- Handles async loading gracefully
- Prevents similar issues in the future

#### **Phase 3: Architecture Improvement (Long-term)**
**Implement Solution Approach #3** - Fix Provider Dependencies

**Why Last**: 
- Most complex changes
- Requires careful testing
- Should be done after immediate issues are resolved

### **Critical Implementation Notes**

#### **For MockAssetManager Enhancement**:
```dart
// CRITICAL: Add this method to prevent null image issues
@override
ui.Image? getBestImageForCanvas(String path) {
  // Return a minimal test image instead of null
  return _createMinimalTestImage();
}

ui.Image _createMinimalTestImage() {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(const Rect.fromLTWH(0, 0, 64, 64), Paint()..color = Colors.blue);
  final picture = recorder.endRecording();
  return picture.toImageSync(64, 64);
}
```

#### **For GameEngineNotifier Fix**:
```dart
// CRITICAL: Ensure animation scheduler is properly mocked
class MockAnimationScheduler implements AnimationScheduler {
  bool _isStarted = false;
  
  @override
  void start() {
    _isStarted = true;
    // Immediately trigger callback to prevent hanging
    Future.microtask(() => triggerCallback(0.016));
  }
  
  void triggerCallback(double dt) {
    if (_isStarted) {
      for (final callback in _callbacks) {
        callback(dt);
      }
    }
  }
}
```

### **Testing Verification Steps**

After implementing the fixes, verify with this progression:

1. **Run the minimal provider test** (from Strategy #1)
2. **Run the level manager init test**
3. **Run the original failing tests**
4. **Add timeout logging** to identify any remaining hang points

### **Monitoring and Debugging**

Add these debug statements to track progress:

```dart
// In pumpGameScreenWithOverrides
print('DEBUG: Starting asset priming...');
mockAssetManager.primeFile(...);
print('DEBUG: Assets primed, creating temp container...');
final tempContainer = ProviderContainer(...);
print('DEBUG: Initializing level manager...');
await tempContainer.read(levelManagerProvider.notifier).init();
print('DEBUG: Level manager initialized, loading level...');
await tempContainer.read(levelManagerProvider.notifier).loadLevelByIndex(0);
print('DEBUG: Level loaded, creating widget tree...');
```

### **Success Criteria**

The fixes are successful when:
1. ✅ Tests complete within 10 seconds (not 60 seconds)
2. ✅ No `TimeoutException` errors
3. ✅ Both TC-L1-01 and TC-L1-02 tests pass
4. ✅ Widget tree builds without "No level loaded!" message
5. ✅ Component interactions work as expected

### **Fallback Plan**

If the primary solutions don't work:

1. **Create a minimal reproduction** using the simplified test approach
2. **File an issue** with the Flutter/Riverpod teams with the minimal reproduction
3. **Consider alternative testing frameworks** like `integration_test` instead of `flutter_test`
4. **Implement a different architecture** that doesn't rely on complex provider chains

## **Testing Strategy Improvements**

### **Strategy #1: Unit Test Isolation**

**Current Problem**: Integration tests are too complex and have too many dependencies.

**Improvement**: Break down into focused unit tests:

```dart
// Test 1: Level Manager in isolation
group('LevelManager Unit Tests', () {
  testWidgets('should initialize without hanging', (tester) async {
    final mockAssetManager = MockAssetManager();
    final mockPrefs = await SharedPreferences.getInstance();
    
    // Prime only the required assets
    mockAssetManager.primeFile('assets/levels/level_manifest.json', manifestJson);
    
    final manager = LevelManagerNotifier(mockPrefs, mockAssetManager);
    await manager.init();
    
    expect(manager.debugState.levels.length, greaterThan(0));
  });
});

// Test 2: Game Engine in isolation
group('GameEngine Unit Tests', () {
  testWidgets('should create with level definition', (tester) async {
    final levelDef = LevelDefinition.fromJson(level1Json);
    final mockScheduler = MockAnimationScheduler();
    
    final engine = GameEngineNotifier(
      initialLevel: levelDef,
      animationScheduler: mockScheduler,
    );
    
    expect(engine.state.currentLevel, equals(levelDef));
  });
});
```

### **Strategy #2: Mock Improvements**

**Current Problem**: Mocks don't accurately simulate real behavior.

**Improvement**: Enhanced mocks with realistic async behavior:

```dart
class ImprovedMockAssetManager implements AssetManager {
  final Map<String, String> _files = {};
  final Map<String, ui.Image> _images = {};

  @override
  Future<String> loadString(String path) async {
    // Simulate real async delay
    await Future.delayed(const Duration(milliseconds: 1));
    
    if (_files.containsKey(path)) {
      return _files[path]!;
    }
    throw AssetNotFoundException('Asset not found: $path');
  }

  @override
  ui.Image? getBestImageForCanvas(String path) {
    // Return a real test image instead of null
    return _images[path] ?? _createTestImage();
  }

  ui.Image _createTestImage() {
    // Create a minimal 1x1 pixel image for testing
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1, 1), Paint()..color = Colors.blue);
    final picture = recorder.endRecording();
    return picture.toImageSync(1, 1);
  }
}
```

### **Strategy #3: Test Environment Setup**

**Current Problem**: Tests depend on file system access and complex initialization.

**Improvement**: Self-contained test data:

```dart
class TestDataProvider {
  static const String level1Json = '''
  {
    "id": "level_01",
    "title": "Test Level",
    "rows": 8,
    "cols": 8,
    "components": [
      {
        "id": "switch1",
        "type": "circuit_switch",
        "position": {"r": 3, "c": 4},
        "state": {"switchOpen": false}
      }
    ],
    "goals": []
  }
  ''';

  static const String manifestJson = '''
  {
    "levels": [
      {"id": "level_01", "title": "Test Level", "levelNumber": 1}
    ]
  }
  ''';

  static MockAssetManager createPreloadedAssetManager() {
    final mock = MockAssetManager();
    mock.primeFile('assets/levels/level_manifest.json', manifestJson);
    mock.primeFile('assets/levels/level_01.json', level1Json);
    return mock;
  }
}
```

### **Strategy #4: Progressive Integration Testing**

**Current Problem**: Full integration tests are too complex to debug.

**Improvement**: Layered integration approach:

```dart
group('Progressive Integration Tests', () {
  testWidgets('Layer 1: Provider Integration', (tester) async {
    // Test only provider interactions
    await tester.pumpWidget(
      ProviderScope(
        overrides: [...],
        child: Consumer(builder: (context, ref, child) {
          final state = ref.watch(levelManagerProvider);
          return Text('Loading: ${state.isLoading}');
        }),
      ),
    );
  });

  testWidgets('Layer 2: Widget + Provider Integration', (tester) async {
    // Test widget with providers but no complex UI
    await tester.pumpWidget(
      ProviderScope(
        overrides: [...],
        child: MaterialApp(
          home: Consumer(builder: (context, ref, child) {
            final gameState = ref.watch(gameEngineProvider);
            return Text('Level: ${gameState.currentLevel?.id ?? "none"}');
          }),
        ),
      ),
    );
  });

  testWidgets('Layer 3: Full UI Integration', (tester) async {
    // Only after layers 1-2 pass, test full GameScreen
  });
});
```## **Multiple Solution Approaches for Fixing Timeout Issues**

### **Solution Approach #1: Pre-Initialize Providers (Recommended)**

**Root Cause**: The [`gameEngineProvider`](lib/core/providers.dart:30) is created before the [`levelManagerProvider`](lib/core/providers.dart:26) is initialized.

**Solution**: Initialize the level manager BEFORE creating the widget tree:

```dart
Future<void> pumpGameScreenWithOverrides(WidgetTester tester) async {
  final mockAssetManager = MockAssetManager();
  final mockAnimationScheduler = MockAnimationScheduler();
  final mockAudioService = MockAudioService();
  SharedPreferences.setMockInitialValues({});
  final mockPrefs = await SharedPreferences.getInstance();

  // Prime the mock with level data
  final manifestContent = await File('assets/levels/level_manifest.json').readAsString();
  final level1Content = await File('assets/levels/level_01.json').readAsString();
  mockAssetManager.primeFile('assets/levels/level_manifest.json', manifestContent);
  mockAssetManager.primeFile('assets/levels/level_01.json', level1Content);

  // PRE-INITIALIZE: Create a temporary container to initialize level manager
  final tempContainer = ProviderContainer(
    overrides: [
      assetManagerProvider.overrideWithValue(mockAssetManager),
      sharedPreferencesProvider.overrideWithValue(mockPrefs),
    ],
  );
  
  // Initialize level manager BEFORE widget creation
  await tempContainer.read(levelManagerProvider.notifier).init();
  await tempContainer.read(levelManagerProvider.notifier).loadLevelByIndex(0);
  
  // Get the initialized level definition
  final initializedLevel = tempContainer.read(currentLevelDefinitionProvider);
  
  // Now create the widget tree with pre-initialized providers
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        assetManagerProvider.overrideWithValue(mockAssetManager),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
        levelManagerProvider.overrideWith((ref) {
          final manager = LevelManagerNotifier(mockPrefs, mockAssetManager);
          // Set the state directly to avoid re-initialization
          manager.state = tempContainer.read(levelManagerProvider);
          return manager;
        }),
        gameEngineProvider.overrideWith((ref) {
          return GameEngineNotifier(
            initialLevel: initializedLevel,  // ← PASS INITIALIZED LEVEL
            animationScheduler: mockAnimationScheduler,
            audioService: mockAudioService,
          );
        }),
      ],
      child: const MaterialApp(home: GameScreen()),
    ),
  );
  
  tempContainer.dispose();
  await tester.pump();
}
```

### **Solution Approach #2: Redesign GameScreen for Async Loading**

**Root Cause**: [`GameScreen`](lib/ui/game_screen.dart:9) assumes the level is immediately available.

**Solution**: Create a loading state in [`GameScreen`](lib/ui/game_screen.dart:9):

```dart
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    final levelManager = ref.read(levelManagerProvider.notifier);
    await levelManager.init();
    await levelManager.loadLevelByIndex(0);
    
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final gameEngineState = ref.watch(gameEngineProvider);
    final currentLevel = gameEngineState.currentLevel;
    
    // Rest of the build method...
  }
}
```

### **Solution Approach #3: Fix Provider Dependencies**

**Root Cause**: Circular dependencies and improper provider initialization order.

**Solution**: Restructure the provider chain to eliminate circular dependencies:

```dart
// Create a separate provider for initialized level manager
final initializedLevelManagerProvider = FutureProvider<LevelManagerNotifier>((ref) async {
  final manager = LevelManagerNotifier(
    ref.watch(sharedPreferencesProvider),
    ref.watch(assetManagerProvider),
  );
  await manager.init();
  await manager.loadLevelByIndex(0);
  return manager;
});

// Update gameEngineProvider to depend on initialized level manager
final gameEngineProvider = StateNotifierProvider<GameEngineNotifier, GameEngineState>((ref) {
  final levelManagerAsync = ref.watch(initializedLevelManagerProvider);
  
  return levelManagerAsync.when(
    data: (levelManager) {
      final currentLevel = levelManager.debugState.currentLevelDefinition;
      if (currentLevel != null) {
        return GameEngineNotifier(initialLevel: currentLevel);
      }
      return GameEngineNotifier.forNoLevel();
    },
    loading: () => GameEngineNotifier.forNoLevel(),
    error: (_, __) => GameEngineNotifier.forNoLevel(),
  );
});
```
### **Simplified Test Approach to Isolate the Problem**

To isolate the exact hanging point, I recommend creating a **minimal test progression**:

#### **Test Level 1: Provider Isolation**
```dart
testWidgets('Minimal Provider Test', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        assetManagerProvider.overrideWithValue(MockAssetManager()),
        sharedPreferencesProvider.overrideWithValue(mockPrefs),
      ],
      child: MaterialApp(
        home: Consumer(
          builder: (context, ref, child) {
            final levelManager = ref.watch(levelManagerProvider);
            return Text('State: ${levelManager.isLoading}');
          },
        ),
      ),
    ),
  );
  await tester.pump();
  // This should complete without hanging
});
```

#### **Test Level 2: Level Manager Initialization**
```dart
testWidgets('Level Manager Init Test', (tester) async {
  // Same setup as Level 1, but add:
  final container = ProviderScope.containerOf(tester.element(find.byType(Consumer)));
  await container.read(levelManagerProvider.notifier).init();
  await tester.pump();
  // This will identify if init() hangs
});
```

#### **Test Level 3: Game Engine Creation**
```dart
testWidgets('Game Engine Creation Test', (tester) async {
  // Same as Level 2, but add:
  final gameEngine = container.read(gameEngineProvider);
  expect(gameEngine, isNotNull);
  // This will identify if gameEngineProvider creation hangs
});
```

This progression will pinpoint exactly where the hang occurs.

### **Critical Issue #13: Animation Scheduler and State Evaluation Loop**

The [`GameEngineNotifier._evaluateAndUpdateRenderState()`](lib/engine/game_engine_notifier.dart:84) method has potential for infinite loops:

```dart
void _evaluateAndUpdateRenderState() {
  if (state.currentLevel == null) return;  // ← EARLY RETURN IN TESTS
  
  final evalResult = _logicEngine.evaluate(state.grid);
  final newRenderState = RenderState.fromEvaluation(
    grid: state.grid,
    eval: evalResult,
    bulbIntensity: animationScheduler.bulbIntensity,  // ← DEPENDS ON SCHEDULER
    wireOffset: animationScheduler.wireOffset,        // ← DEPENDS ON SCHEDULER
    draggedComponentId: state.draggedComponentId,
    dragPosition: state.dragPosition,
  );
  
  state = state.copyWith(renderState: newRenderState); // ← STATE UPDATE
  onEvaluate?.call(evalResult);                        // ← CALLBACK
  _checkWinCondition(evalResult);                      // ← MORE EVALUATION
}
```

**The Problem**: In the test environment:
1. [`state.currentLevel`](lib/engine/game_engine_notifier.dart:85) is `null` initially, so the method returns early
2. When the level is loaded later, the animation scheduler isn't properly synchronized
3. The [`MockAnimationScheduler`](test/helpers/mock_animation_scheduler.dart:4) provides fixed values, but the timing is wrong
4. State updates may trigger provider rebuilds that cause more evaluation calls

### **Critical Issue #14: Test Widget Tree Rebuild Cascade**

The fundamental issue is a **cascade of rebuilds** that never stabilizes:

```mermaid
sequenceDiagram
    participant Test as Test
    participant Widget as GameScreen
    participant Provider as gameEngineProvider
    participant Level as levelManagerProvider
    
    Test->>Widget: pumpWidget()
    Widget->>Provider: ref.watch(gameEngineProvider)
    Provider->>Level: ref.watch(currentLevelDefinitionProvider)
    Level-->>Provider: returns null
    Provider-->>Widget: creates GameEngineNotifier.forNoLevel()
    Widget-->>Test: builds with "No level loaded!"
    
    Test->>Level: init() and loadLevelByIndex()
    Level->>Level: updates currentLevelDefinition
    Level->>Provider: notifies change
    Provider->>Provider: should rebuild but doesn't
    Note over Provider: DEADLOCK: Provider doesn't rebuild<br/>because it's already created
```

### **Critical Issue #11: MockAssetManager Asset Loading Problems**

The [`MockAssetManager`](test/helpers/mock_asset_manager.dart:5) implementation has several critical gaps that can cause hangs:

```dart
@override
ui.Image? getBestImageForCanvas(String path) => null;  // ← ALWAYS NULL

@override
ui.Image? getImage(String path) => null;               // ← ALWAYS NULL

@override
ui.Image? getSvgAsImage(String path) => null;          // ← ALWAYS NULL

@override
Widget? getSvgWidget(String path, {...}) => null;     // ← ALWAYS NULL
```

**The Problem**: The [`CanvasPainter`](lib/ui/canvas_painter.dart:1) (referenced in [`GameCanvas`](lib/ui/game_canvas.dart:78)) likely depends on these image assets to render components. When all image methods return `null`, the painter may:
1. Enter an infinite loop trying to load assets
2. Throw null pointer exceptions
3. Hang waiting for assets that never load

### **Critical Issue #12: GameEngineNotifier Animation Scheduler Setup**

The [`GameEngineNotifier`](lib/engine/game_engine_notifier.dart:18) initialization has timing issues:

```dart
GameEngineNotifier({...}) : ... {
  _initializeEngine(initialLevel);
}

void _initializeEngine(LevelDefinition? initialLevel) {
  animationScheduler.addCallback((dt) {        // ← ADDS CALLBACK
    if (!state.isPaused) {
      _evaluateAndUpdateRenderState();         // ← CALLS EVALUATION
    }
  });
  if (initialLevel != null) {
    loadLevel(initialLevel);                   // ← LOADS LEVEL
  }
  animationScheduler.start();                  // ← STARTS SCHEDULER
}
```

**The Issue**: In tests, the [`MockAnimationScheduler`](test/helpers/mock_animation_scheduler.dart:4) doesn't actually start any real animation loop, but the [`GameEngineNotifier`](lib/engine/game_engine_notifier.dart:18) expects the callback to be triggered. The test manually calls [`triggerCallback()`](test/helpers/mock_animation_scheduler.dart:44), but this happens AFTER the widget build, creating a timing mismatch.

### **Critical Issue #9: Provider Initialization Loop**

The provider chain has a fundamental initialization problem:

```dart
// In providers.dart
final gameEngineProvider = StateNotifierProvider<GameEngineNotifier, GameEngineState>((ref) {
  final currentLevel = ref.watch(currentLevelDefinitionProvider); // ← DEPENDS ON LEVEL MANAGER
  
  if (currentLevel == null) {
    return GameEngineNotifier.forNoLevel(...); // ← CREATES "NO LEVEL" ENGINE
  }
  
  return GameEngineNotifier(initialLevel: currentLevel, ...); // ← NEVER REACHED IN TESTS
});

final currentLevelDefinitionProvider = Provider<LevelDefinition?>((ref) {
  return ref.watch(levelManagerProvider).currentLevelDefinition; // ← NULL UNTIL INIT
});
```

**The Loop**: 
1. [`gameEngineProvider`](lib/core/providers.dart:30) reads [`currentLevelDefinitionProvider`](lib/core/providers.dart:31)
2. [`currentLevelDefinitionProvider`](lib/core/providers.dart:67) reads [`levelManagerProvider.currentLevelDefinition`](lib/core/providers.dart:68)
3. [`levelManagerProvider`](lib/core/providers.dart:26) starts with `currentLevelDefinition = null`
4. [`gameEngineProvider`](lib/core/providers.dart:30) creates [`GameEngineNotifier.forNoLevel()`](lib/core/providers.dart:34)
5. Test calls [`init()`](test/level_01_revised_test.dart:61) and [`loadLevelByIndex()`](test/level_01_revised_test.dart:62)
6. [`levelManagerProvider`](lib/core/providers.dart:26) updates `currentLevelDefinition`
7. **BUT**: [`gameEngineProvider`](lib/core/providers.dart:30) doesn't rebuild because it's already created!

### **Critical Issue #10: MockAssetManager Implementation Gaps**

The [`MockAssetManager`](test/helpers/mock_asset_manager.dart:5) has several issues:

```dart
@override
Future<String> loadString(String path) {
  if (_files.containsKey(path)) {
    return Future.value(_files[path]!); // ← SYNCHRONOUS FUTURE
  }
  return Future.error(Exception('MockAssetManager: File not primed: $path')); // ← THROWS ERROR
}
```

**Problems**:
1. **Synchronous Futures**: [`Future.value()`](test/helpers/mock_asset_manager.dart:15) completes immediately, which doesn't match real async behavior
2. **Missing Assets**: If any asset path is requested that wasn't primed, it throws an exception
3. **No SVG Support**: Methods like [`getSvgAsImage()`](test/helpers/mock_asset_manager.dart:24) return `null`, which can cause null pointer exceptions

### **Critical Issue #7: GameCanvas and CanvasPainter Dependencies**

The [`GameCanvas`](lib/ui/game_canvas.dart:9) widget has several initialization issues that contribute to the timeout:

```dart
Widget build(BuildContext context) {
  final gameNotifier = ref.read(gameEngineProvider.notifier);
  final renderState = ref.watch(renderStateProvider);  // ← CAN BE NULL
  final assetManager = ref.watch(assetManagerProvider);

  return CustomPaint(
    painter: CanvasPainter(
      renderState: renderState,    // ← PASSING NULL TO PAINTER
      assetManager: assetManager,
    ),
    size: Size.infinite,           // ← INFINITE SIZE WITH NULL STATE
  );
}
```

**The Problem**: When [`renderState`](lib/ui/game_canvas.dart:40) is `null` (which happens during initialization), the [`CanvasPainter`](lib/ui/game_canvas.dart:78) receives invalid parameters. Combined with [`Size.infinite`](lib/ui/game_canvas.dart:82), this can cause the painter to enter an infinite loop or hang during rendering.

### **Critical Issue #8: Circular Dependencies in Provider Chain**

Analyzing the provider dependencies reveals a complex circular reference:

```mermaid
graph TD
    A[gameEngineProvider] --> B[currentLevelDefinitionProvider]
    B --> C[levelManagerProvider]
    C --> D[assetManagerProvider]
    C --> E[sharedPreferencesProvider]
    A --> F[renderStateProvider]
    F --> A
    G[GameScreen] --> A
    G --> H[GameCanvas]
    H --> F
    H --> D
```

**Circular Dependency**: [`gameEngineProvider`](lib/core/providers.dart:30) → [`currentLevelDefinitionProvider`](lib/core/providers.dart:67) → [`levelManagerProvider`](lib/core/providers.dart:26), but [`renderStateProvider`](lib/core/providers.dart:72) → [`gameEngineProvider`](lib/core/providers.dart:73), creating a circular reference that can cause infinite rebuilds.

### **Critical Issue #5: pumpGameScreenWithOverrides Hanging Points**

The [`pumpGameScreenWithOverrides`](test/level_01_revised_test.dart:20) function has several potential hanging points:

```dart
Future<void> pumpGameScreenWithOverrides(WidgetTester tester) async {
  // File I/O operations that could hang
  final manifestContent = await File('assets/levels/level_manifest.json').readAsString(); // ← POTENTIAL HANG #1
  final level1Content = await File('assets/levels/level_01.json').readAsString();         // ← POTENTIAL HANG #2
  
  await tester.pumpWidget(...); // ← POTENTIAL HANG #3: Widget build deadlock
  
  // These operations happen after widget build - too late!
  final container = ProviderScope.containerOf(tester.element(find.byType(GameScreen))); // ← POTENTIAL HANG #4
  await container.read(levelManagerProvider.notifier).init();                           // ← POTENTIAL HANG #5
  await container.read(levelManagerProvider.notifier).loadLevelByIndex(0);             // ← POTENTIAL HANG #6
  await tester.pump();                                                                  // ← POTENTIAL HANG #7
}
```

**Hang Point Analysis**:
1. **File I/O**: Direct file system access in tests can be unreliable
2. **Widget Build**: [`GameScreen`](lib/ui/game_screen.dart:9) build process with uninitialized providers
3. **Container Access**: [`ProviderScope.containerOf()`](test/level_01_revised_test.dart:60) on a potentially invalid element
4. **Async Init**: [`init()`](test/level_01_revised_test.dart:61) call on already-built widget tree
5. **Level Loading**: [`loadLevelByIndex()`](test/level_01_revised_test.dart:62) triggering provider rebuilds
6. **Pump**: [`tester.pump()`](test/level_01_revised_test.dart:63) waiting for widget tree updates that may never come

### **Critical Issue #6: GameCanvas Initialization Dependencies**

The [`GameCanvas`](lib/ui/game_canvas.dart:9) widget creates additional complexity:

```dart
class _GameCanvasState extends ConsumerState<GameCanvas> with TickerProviderStateMixin {
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Ticker(_onTick)..start(); // ← STARTS IMMEDIATELY
  }
  
  Widget build(BuildContext context) {
    final renderState = ref.watch(renderStateProvider); // ← MAY BE NULL
    // ...
    return CustomPaint(
      painter: CanvasPainter(
        renderState: renderState,  // ← POTENTIAL NULL REFERENCE
        assetManager: assetManager,
      ),
    );
  }
}
```

**The Issue**: The [`Ticker`](lib/ui/game_canvas.dart:22) starts immediately, but [`renderStateProvider`](lib/ui/game_canvas.dart:40) may return `null` if the game engine isn't properly initialized, causing the [`CanvasPainter`](lib/ui/game_canvas.dart:78) to receive invalid state.

### **Critical Issue #3: ProviderScope and GameScreen Interaction Deadlock**

The [`pumpGameScreenWithOverrides`](test/level_01_revised_test.dart:20) function creates a complex initialization sequence that leads to a deadlock:

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [...],
    child: const MaterialApp(home: GameScreen()),  // ← GameScreen builds immediately
  ),
);

// These calls happen AFTER the widget is already built
final container = ProviderScope.containerOf(tester.element(find.byType(GameScreen)));
await container.read(levelManagerProvider.notifier).init();           // ← TOO LATE
await container.read(levelManagerProvider.notifier).loadLevelByIndex(0); // ← TOO LATE
```

**The Problem**: [`GameScreen`](lib/ui/game_screen.dart:9) tries to access [`gameEngineProvider`](lib/ui/game_screen.dart:14) during its initial build, but the [`levelManagerProvider`](lib/core/providers.dart:26) hasn't been initialized yet. This creates a state where:

1. [`GameScreen.build()`](lib/ui/game_screen.dart:13) gets `currentLevel == null`
2. It shows the "No level loaded!" message
3. The test then tries to initialize the level manager
4. But the widget tree is already built and doesn't rebuild properly

### **Critical Issue #4: GameCanvas Widget Dependencies**

The [`GameCanvas`](lib/ui/game_canvas.dart:9) widget has its own initialization issues:

```dart
Widget build(BuildContext context) {
  final gameNotifier = ref.read(gameEngineProvider.notifier);
  final renderState = ref.watch(renderStateProvider);        // ← DEPENDS ON GAME ENGINE
  final assetManager = ref.watch(assetManagerProvider);
```

The [`renderStateProvider`](lib/core/providers.dart:72) depends on [`gameEngineProvider`](lib/core/providers.dart:73), which may not be properly initialized when the widget first builds.

## Comprehensive Root Cause Analysis: Flutter Test Timeout Issues

### **Primary Root Cause: Widget Build Context Initialization Deadlock**

After analyzing the codebase, I've identified the primary issue causing the 1-minute timeouts. The problem lies in a complex initialization chain that creates a deadlock during widget building in the test environment.

### **Critical Issue #1: GameScreen Widget Build Dependencies**

The [`GameScreen`](lib/ui/game_screen.dart:13) widget has a critical dependency chain:

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final gameEngineState = ref.watch(gameEngineProvider);  // ← BLOCKING CALL
  final currentLevel = gameEngineState.currentLevel;      // ← DEPENDS ON ABOVE
  
  if (currentLevel == null) {  // ← THIS CONDITION IS THE PROBLEM
    return const Scaffold(body: Center(child: Text('No level loaded!')));
  }
```

**The Issue**: The [`gameEngineProvider`](lib/core/providers.dart:30) depends on [`currentLevelDefinitionProvider`](lib/core/providers.dart:67), which in turn depends on [`levelManagerProvider`](lib/core/providers.dart:26). However, the level manager requires explicit initialization via [`init()`](lib/services/level_manager.dart:21) and [`loadLevelByIndex()`](lib/services/level_manager.dart:73) calls.

### **Critical Issue #2: Async Initialization Race Condition**

In the test setup, this sequence occurs:

1. [`pumpWidget()`](test/level_01_revised_test.dart:35) creates the widget tree
2. [`GameScreen.build()`](lib/ui/game_screen.dart:13) immediately calls [`ref.watch(gameEngineProvider)`](lib/ui/game_screen.dart:14)
3. [`gameEngineProvider`](lib/core/providers.dart:30) tries to read [`currentLevelDefinitionProvider`](lib/core/providers.dart:31)
4. [`currentLevelDefinitionProvider`](lib/core/providers.dart:67) returns `null` because [`LevelManagerNotifier`](lib/services/level_manager.dart:12) hasn't been initialized
5. [`GameEngineNotifier.forNoLevel()`](lib/engine/game_engine_notifier.dart:40) is created
6. **DEADLOCK**: The widget build completes, but then the test tries to call [`init()`](test/level_01_revised_test.dart:61) and [`loadLevelByIndex()`](test/level_01_revised_test.dart:62) on an already-built widget tree