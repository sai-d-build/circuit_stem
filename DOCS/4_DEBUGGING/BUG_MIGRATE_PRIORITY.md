Root Cause Analysis:

LevelSelectScreen Errors (lib/presentation/features/menus/screens/level_select.dart):

Problem: The code attempts to access levels, completedLevelIds, errorMessage, and isLoading directly from LevelManagerNotifier (obtained via ref.watch(levelManagerProvider)), and uses undefined local variables levelManager and levelManagerState.
Comparison to Plan: levelManagerProvider was changed to StateNotifierProvider<LevelManagerNotifier, LevelManagerState>, meaning ref.watch(levelManagerProvider) now yields the LevelManagerNotifier instance, whose state is accessed via .state. Additionally, levelsProvider and completedLevelIdsProvider were introduced for direct access to level data.
Root Cause: level_select.dart has not been updated to use the .state property for LevelManagerNotifier's state or to leverage the new dedicated levelsProvider and completedLevelIdsProvider.
game_state.dart Error (lib/presentation/state/game_state.dart):

Problem: The gameEngineProvider attempts to pass the LevelManagerNotifier instance (from ref.watch(levelManagerProvider)) to GameEngineNotifier's constructor, but GameEngineNotifier's levelManager parameter expects a LevelManagerState.
Comparison to Plan: levelManagerProvider now provides the LevelManagerNotifier instance.
Root Cause: A type mismatch in the GameEngineNotifier constructor's levelManager parameter. It needs to be updated to accept the LevelManagerNotifier directly, which is the idiomatic Riverpod pattern for passing notifiers.
Test Setup Errors (test/helpers/test_setup_helper.dart, test/levels/level_01_test.dart):

Problem: Calls to registerAllGameEntities() are made directly or on TestSetupHelper, leading to Undefined name 'ComponentRegistry' or The method 'registerAllGameEntities' isn't defined errors.
Comparison to Plan: ComponentRegistry.registerAllGameEntities() is the correct static method call.
Root Cause: Test files have not been updated to use the fully qualified static method call ComponentRegistry.registerAllGameEntities().
Proposed Plan to Fix:

For LevelSelectScreen (lib/presentation/features/menus/screens/level_select.dart):

Update all accesses to levels, completedLevelIds, errorMessage, and isLoading to use ref.watch(levelsProvider), ref.watch(completedLevelIdsProvider), ref.watch(levelManagerProvider).state.errorMessage, and ref.watch(levelManagerProvider).state.isLoading respectively.
Remove any redundant local variable declarations for levelManager or levelManagerState.
For game_state.dart (lib/presentation/state/game_state.dart):

Modify the GameEngineNotifier constructor (in lib/application/game_engine_notifier.dart) to accept LevelManagerNotifier as its levelManager parameter.
Ensure game_state.dart passes the levelManager (which is ref.watch(levelManagerProvider)) directly to the GameEngineNotifier constructor

Looking at the root cause analysis, I can see several critical issues that need systematic fixes. The problems stem from inconsistent provider usage and type mismatches during the migration. Here's a robust fix plan:The core issue is a **fundamental misunderstanding of Riverpod provider access patterns** during migration. The problems cascade from inconsistent usage of `.state` vs `.notifier` access.

## Critical Fixes (In Priority Order)

### 1. **Fix Type Mismatch in GameEngineNotifier** (Highest Priority)

The constructor expects `LevelManagerNotifier` but receives `LevelManagerState`:

```dart
// CURRENT BROKEN CODE in game_state.dart:
final levelManager = ref.watch(levelManagerProvider); // Returns LevelManagerState
return GameEngineNotifier(levelManager: levelManager); // Type error

// CORRECT FIX:
final levelManagerNotifier = ref.watch(levelManagerProvider.notifier); // Returns LevelManagerNotifier  
return GameEngineNotifier(levelManager: levelManagerNotifier); // Correct type
```

### 2. **Fix LevelSelectScreen State Access** (High Priority)

Remove undefined variables and use consistent provider access:

```dart
// REMOVE these undefined variables:
// final isLoading = levelManager.state.isLoading;  // levelManager undefined
// final levels = levelManager.state.levels;        // levelManager undefined

// REPLACE with proper provider access:
final levels = ref.watch(levelsProvider);
final completedLevelIds = ref.watch(completedLevelIdsProvider);  
final levelManagerState = ref.watch(levelManagerProvider);
final isLoading = levelManagerState.isLoading;
final errorMessage = levelManagerState.errorMessage;
```

### 3. **Fix Test Static Method Calls** (Medium Priority)

```dart
// Change from:
registerAllGameEntities();
// To:
ComponentRegistry.registerAllGameEntities();
```

## Fundamental Pattern Rule

**For StateNotifierProvider access:**
- `ref.watch(provider)` → Gets the state object
- `ref.watch(provider.notifier)` → Gets the notifier instance

**Usage Guidelines:**
- Use `.notifier` when passing to constructors that expect the notifier class
- Use direct watching for accessing state properties
- Use dedicated providers (`levelsProvider`, `completedLevelIdsProvider`) when available

## Implementation Order

1. **Fix game_state.dart provider** - prevents constructor type errors
2. **Fix LevelSelectScreen state access** - removes undefined variable errors  
3. **Fix test files** - enables testing

This addresses the root cause: the migration mixed old direct property access with new provider patterns without establishing consistent access rules. The fix standardizes on proper Riverpod patterns throughout.

# Robust Fix Plan for State Management Migration Issues

## Issue Analysis Summary

The migration has three critical problems:
1. **State Access Pattern Inconsistency** - Direct property access instead of using `.state`
2. **Type Mismatch in Constructor** - Passing `LevelManagerState` where `LevelManagerNotifier` expected
3. **Missing Static Method Calls** in tests

## Root Cause: Mixed Migration Patterns

The current code mixes old and new patterns inconsistently, creating a fragile state. We need to establish **one consistent pattern** throughout.

## Solution Strategy: Provider Access Standardization

### Fix 1: Standardize LevelSelectScreen State Access

**Problem**: Mixed access patterns and undefined variables
**File**: `lib/presentation/features/menus/screens/level_select.dart`

```dart
// CURRENT BROKEN CODE:
final isLoading = levelManager.state.isLoading;        // ❌ undefined levelManager
final levels = levelManager.state.levels;             // ❌ undefined levelManager
final completedLevelIds = levelManager.state.completedLevelIds; // ❌ undefined

// ROBUST FIX - Use dedicated providers consistently:
@override
Widget build(BuildContext context) {
  // Use specific providers for each piece of data
  final levels = ref.watch(levelsProvider);
  final completedLevelIds = ref.watch(completedLevelIdsProvider);
  final levelManagerState = ref.watch(levelManagerProvider);
  final isLoading = levelManagerState.isLoading;
  final errorMessage = levelManagerState.errorMessage;

  // Rest of widget logic unchanged...
}
```

**Why This Works**: 
- Uses dedicated providers where available (`levelsProvider`, `completedLevelIdsProvider`)
- Accesses complex state through the notifier provider consistently
- No undefined variables

### Fix 2: Correct GameEngineNotifier Constructor Type

**Problem**: Type mismatch - passing `LevelManagerState` where `LevelManagerNotifier` expected
**Files**: `lib/application/game_engine_notifier.dart` and `lib/presentation/state/game_state.dart`

**Step 2A: Update GameEngineNotifier Constructor**
```dart
// FILE: lib/application/game_engine_notifier.dart
// CURRENT:
GameEngineNotifier({
  required AudioService audioService,
  required this.animationScheduler,
  required LevelManagerNotifier levelManager,  // ✅ This is correct
})

// ISSUE: The constructor parameter type is correct, but usage in game_state.dart is wrong
```

**Step 2B: Fix Provider Usage in game_state.dart**
```dart
// FILE: lib/presentation/state/game_state.dart
// CURRENT BROKEN:
final gameEngineProvider =
    StateNotifierProvider<GameEngineNotifier, GameEngineState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final levelManager = ref.watch(levelManagerProvider); // ❌ This returns LevelManagerState
  
  return GameEngineNotifier(
    audioService: audioService,
    levelManager: levelManager, // ❌ Type mismatch
    animationScheduler: AnimationScheduler(),
  );
});

// ROBUST FIX:
final gameEngineProvider =
    StateNotifierProvider<GameEngineNotifier, GameEngineState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final levelManagerNotifier = ref.watch(levelManagerProvider.notifier); // ✅ Get notifier, not state
  
  return GameEngineNotifier(
    audioService: audioService,
    levelManager: levelManagerNotifier, // ✅ Correct type
    animationScheduler: AnimationScheduler(),
  );
});
```

**Key Insight**: 
- `ref.watch(provider)` gets the state
- `ref.watch(provider.notifier)` gets the notifier instance
- Constructor needs the notifier, not the state

### Fix 3: Correct Test Static Method Calls

**Problem**: Missing class qualification for static method
**Files**: `test/helpers/test_setup_helper.dart`, `test/levels/level_01_test.dart`

```dart
// CURRENT BROKEN:
registerAllGameEntities();  // ❌ Undefined function
TestSetupHelper.registerAllGameEntities(); // ❌ Method doesn't exist on class

// ROBUST FIX:
import 'package:circuit_stem/application/services/component_registry.dart';

ComponentRegistry.registerAllGameEntities(); // ✅ Correct static call
```

## Implementation Steps (In Order)

### Step 1: Fix Test Files First (Lowest Risk)
```bash
# Update test files to prevent build failures
# File: test/helpers/test_setup_helper.dart
# File: test/levels/level_01_test.dart
```

### Step 2: Fix GameEngineNotifier Provider
```dart
# File: lib/presentation/state/game_state.dart
# Change: ref.watch(levelManagerProvider) 
# To: ref.watch(levelManagerProvider.notifier)
```

### Step 3: Fix LevelSelectScreen State Access
```dart
# File: lib/presentation/features/menus/screens/level_select.dart  
# Remove: undefined variable usage
# Add: proper provider watching
```

## Robust Provider Pattern Standards

### Establish Clear Access Rules

```dart
// RULE 1: For getting state data, use specific providers when available
final levels = ref.watch(levelsProvider);              // ✅ Preferred
final completedIds = ref.watch(completedLevelIdsProvider); // ✅ Preferred

// RULE 2: For complex state, watch the provider and access .state
final managerState = ref.watch(levelManagerProvider);   // Gets LevelManagerState
final isLoading = managerState.isLoading;               // Access properties

// RULE 3: For passing notifiers to constructors, use .notifier
final notifier = ref.watch(levelManagerProvider.notifier); // Gets LevelManagerNotifier
```

### Updated game_state.dart (Complete File)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/game_engine_notifier.dart';
import '../../infrastructure/audio/audio_service.dart';
import '../../infrastructure/persistence/level_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../application/animation_scheduler.dart';
import '../../infrastructure/rendering/asset_manager.dart';
import '../../infrastructure/rendering/asset_manager_state.dart';
import '../../domain/entities/level_metadata.dart';
import '../../domain/entities/grid.dart';
import '../../application/game_engine_state.dart';
import '../../infrastructure/persistence/level_manager_state.dart';

// Provider for SharedPreferences
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Provider for AudioService  
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

// Provider for AssetManager
final assetManagerProvider =
    StateNotifierProvider<AssetManagerNotifier, AssetState>((ref) {
  return AssetManagerNotifier();
});

// Provider for LevelManager
final levelManagerProvider = StateNotifierProvider<LevelManagerNotifier, LevelManagerState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).asData!.value;
  final assetManager = ref.watch(assetManagerProvider.notifier);
  return LevelManagerNotifier(prefs, assetManager);
});

// FIXED: GameEngine provider with correct notifier access
final gameEngineProvider =
    StateNotifierProvider<GameEngineNotifier, GameEngineState>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final levelManagerNotifier = ref.watch(levelManagerProvider.notifier); // ✅ Get notifier
  
  return GameEngineNotifier(
    audioService: audioService,
    levelManager: levelManagerNotifier, // ✅ Correct type
    animationScheduler: AnimationScheduler(),
  );
});

// Convenience providers for UI
final isGameWonProvider = Provider<bool>((ref) {
  return ref.watch(gameEngineProvider.select((s) => s.isWin));
});

final levelsProvider = Provider<List<LevelMetadata>>((ref) {
  return ref.watch(levelManagerProvider).levels;
});

final completedLevelIdsProvider = Provider<Set<String>>((ref) {
  return ref.watch(levelManagerProvider).completedLevelIds;
});

final gridProvider = Provider<Grid>((ref) {
  return ref.watch(gameEngineProvider.select((state) => state.grid));
});
```

### Updated LevelSelectScreen (Key Sections)

```dart
class _LevelSelectScreenState extends ConsumerState<LevelSelectScreen>
    with TickerProviderStateMixin {
  
  @override
  Widget build(BuildContext context) {
    // FIXED: Use proper provider access patterns
    final levels = ref.watch(levelsProvider);
    final completedLevelIds = ref.watch(completedLevelIdsProvider);
    final levelManagerState = ref.watch(levelManagerProvider);
    final isLoading = levelManagerState.isLoading;
    final errorMessage = levelManagerState.errorMessage;

    // Error handling
    if (errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Text(
            errorMessage,
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    // Loading state
    if (isLoading && levels.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Rest of the build method remains the same...
  }
}
```

## Testing Strategy

### Validation Checklist
```bash
# 1. Build test
flutter clean && flutter pub get && flutter build debug

# 2. Static analysis  
flutter analyze

# 3. Unit tests
flutter test test/helpers/test_setup_helper.dart
flutter test test/levels/level_01_test.dart

# 4. Integration test
# Start app and navigate to level select screen
# Verify no runtime errors
```

## Risk Mitigation

### Rollback Plan
- Keep backup copies of modified files
- Each fix is isolated and can be reverted independently
- Test each fix before proceeding to the next

### Future Prevention
1. **Consistent Provider Patterns**: Always use `.notifier` for constructors, direct watching for state
2. **Type Safety**: Use explicit type annotations in provider declarations  
3. **Test Coverage**: Add tests for provider access patterns

This approach fixes the immediate issues while establishing consistent patterns that prevent similar problems in the future.