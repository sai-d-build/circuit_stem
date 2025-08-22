## Game Engine Architecture Refactor (2025-08-22)

### 1. Problem Statement (Observations & Analysis)
The original `GameEngineNotifier` had grown into a "god class," coupling UI concerns (gesture handling, `Offset` positions), core engine logic (state commits, undo/redo, win conditions), simulation logic (`_SimpleLogicSimulator`), and audio feedback. This tight coupling led to:
- Reduced testability (difficult to unit test simulation or input logic in isolation).
- Poor extensibility (adding new input methods or simulation models was complex).
- Increased cognitive load and maintenance burden.
- Inconsistent coordinate handling (global vs. local grid coordinates).

### 2. Proposed Solution & Rationale
The chosen approach was to apply the **separation of concerns** principle by breaking down the `GameEngineNotifier` into specialized, single-responsibility managers. This aligns with the existing component-behavior model and promotes a **thin orchestrator** pattern for `GameEngineNotifier`.

**Key Principles:**
- **Domain-Driven Separation:** Responsibilities are split by logical domain (Core, Input, Simulation, Audio).
- **Coordinate Translation:** UI-level coordinate translation (`Offset` to grid coordinates) is handled closer to the UI layer or within the `InputManager`'s domain.
- **Behavior-Driven Integration:** Existing behaviors (`MovableBehavior`, `InteractionBehavior`) now integrate cleanly with the new managers.
- **Testability:** Each manager is designed to be independently testable.

### 3. Class-Level Changes Implemented

#### New Classes Created:
- **`lib/engine/audio_manager.dart`**
    - **Purpose:** Centralizes audio playback.
    - **Key Methods:** `playSelection()`, `playPlacement()`, `playWin()`, `playLose()`, `stopAll()`. (Note: Specific methods may vary based on `AudioService` API).
    - **Dependencies:** `AudioService`.
- **`lib/engine/simulation_manager.dart`**
    - **Purpose:** Pure logic for circuit power propagation (BFS).
    - **Key Methods:** `evaluate(Grid grid)`.
    - **Dependencies:** `Grid`, `ComponentModel`, `PowerSourceBehavior`.
- **`lib/engine/game_engine_core.dart`**
    - **Purpose:** The pure engine core; applies updates and produces new `GameEngineState`. Owns the "single source of truth" for the grid.
    - **Key Methods:** `commit(GameEngineState oldState, Grid newGrid, { ... })`.
    - **Dependencies:** `SimulationManager`, `Grid`, `ComponentModel`, `GameEngineState`, `RenderState`, `LogicBehavior`.
- **`lib/engine/input_manager.dart`**
    - **Purpose:** Translates raw UI input (taps, drags) into specific game actions. It is stateless and does not manage `GameEngineState` directly.
    - **Key Methods:** `handleTap(ComponentModel comp)`, `handleMove(String componentId, int newRow, int newCol)`.
    - **Dependencies:** Callbacks to `GameEngineNotifier` methods.

#### Refactored Class (`lib/engine/game_engine_notifier.dart`):
- **Purpose:** Now acts as a thin orchestrator, instantiating and wiring up `GameEngineCore`, `InputManager`, and `AudioManager`. It is the sole owner of the `GameEngineState`.
- **Key Changes:**
    - Constructor now takes `AudioService` and `initialLevel`.
    - Instantiates `GameEngineCore(SimulationManager())`, `AudioManager(audioService)`, and `InputManager` (with callbacks to its own methods).
    - `_init` method wires up `InputManager` callbacks (`onComponentTapped`, `onComponentMoved`) to private methods (`_handleTap`, `_moveComponent`).
    - Public methods like `loadLevel`, `reset`, `selectPaletteComponent`, `restartLevel`, `undo`, `togglePause` now delegate to the appropriate manager or handle state updates via `core.commit()`.
    - Removed direct handling of `Offset` and drag logic; this is now handled by `InputManager` and the UI layer.

#### Modified Existing Files:
- **`lib/core/providers.dart`**
    - Updated `gameEngineProvider` to use `GameEngineNotifier` (formerly `GameEngineNotifierV2`).
    - Removed `animationScheduler` parameter from `GameEngineNotifier` constructor call as it's no longer directly managed by the notifier.
    - Updated import path for `GameEngineNotifier`.
- **`lib/ui/game_canvas.dart`**
    - `onTap` callback for `ComponentWidget` now calls `gameNotifier.inputManager.handleTap(component)`.
    - `DragTarget`'s `onAcceptWithDetails` now calls `gameNotifier.inputManager.handleMove(component.id, row, col)`.
    - `MovableBehavior` and `DragBehavior` are now initialized with the `gameNotifier` which exposes the `inputManager`.
- **`lib/ui/game_screen.dart`**
    - Calls to `gameNotifier.selectPaletteComponent`, `gameNotifier.restartLevel`, `gameNotifier.undo`, and `gameNotifier.togglePause` now correctly invoke the methods on the refactored `GameEngineNotifier`.

### 4. Future Considerations
- Further refine `InputManager` to be completely Flutter-independent by passing raw data (e.g., grid coordinates) instead of `Offset`.
- Implement actual undo/redo logic within `GameEngineCore`.

# Root Cause Analysis: Missing Component Behaviors

## Problem Summary
Components loaded from JSON have empty `behaviors: []` arrays, causing:
- "No DrawingBehavior found" → components don't render
- "No LogicBehavior found" → logic evaluation fails
- "renderState is null" → canvas painter skips drawing

## Architecture Analysis

### Current Flow (Broken)
1. **Registration Phase** (main.dart): `registerAllGameEntities()` calls component registration functions
   - `registerBulb()` → calls `registerBehavior<BulbDrawingBehavior>()` + `ComponentRegistry.register()`
   - Stores behavior **factories** in `_behaviorFactories` map
   - Stores component **types** in `_behaviors` map

2. **Level Loading** (game_engine_notifier.dart:119): 
   ```dart
   final grid = Grid(rows: level.rows, cols: level.cols, components: level.initialComponents);
   ```
   - `level.initialComponents` comes from JSON deserialization
   - `ComponentModel.fromJson()` creates components with `behaviors: []` (default)
   - **NO behavior attachment happens here**

3. **Runtime Usage**: Components try to use behaviors via `component.getBehavior<T>()`
   - Returns `null` because `behaviors` list is empty
   - Causes all the "No XBehavior found" messages

### Root Cause
**Behavior attachment is missing during deserialization.** The system has two separate creation paths:

1. **Programmatic Creation**: `ComponentRegistry.create()` → attaches behaviors ✅
2. **JSON Deserialization**: `ComponentModel.fromJson()` → NO behavior attachment ❌

## Architectural Solutions

### Option 1: Fix at Deserialization Point (Recommended)
Modify `GameEngineNotifier.loadLevel()` to attach behaviors after JSON parsing:

```dart
void loadLevel(LevelDefinition level) {
  // Attach behaviors to initial components
  final componentsWithBehaviors = level.initialComponents.map((component) {
    final behaviorInstances = ComponentRegistry.instantiateBehaviorsFor(component.type);
    return component.copyWith(behaviors: behaviorInstances);
  }).toList();
  
  // Attach behaviors to palette components  
  final paletteWithBehaviors = level.paletteComponents.map((component) {
    final behaviorInstances = ComponentRegistry.instantiateBehaviorsFor(component.type);
    return component.copyWith(behaviors: behaviorInstances);
  }).toList();
  
  final grid = Grid(rows: level.rows, cols: level.cols, components: componentsWithBehaviors);
  final updatedLevel = level.copyWith(
    initialComponents: componentsWithBehaviors,
    paletteComponents: paletteWithBehaviors
  );
  
  state = GameEngineState.initial(updatedLevel).copyWith(grid: grid);
  _evaluateGrid();
}
```

### Option 2: Modify ComponentModel.fromJson() (Alternative)
Add behavior attachment directly in the model:

```dart
factory ComponentModel.fromJson(Map<String, dynamic> json) {
  final component = ComponentModel(/* existing fields */);
  final behaviorInstances = ComponentRegistry.instantiateBehaviorsFor(component.type);
  return component.copyWith(behaviors: behaviorInstances);
}
```

**Pros/Cons:**
- Option 1: Clean separation, explicit control ✅
- Option 2: Automatic but couples model to registry ❌

## Implementation Plan

### Step 1: Add Helper to ComponentRegistry
```dart
List<dynamic> instantiateBehaviorsFor(String componentType) {
  final behaviorTypes = _behaviors[componentType];
  if (behaviorTypes == null) {
    Logger.log('ComponentRegistry: No behavior types for: $componentType');
    return [];
  }
  
  return behaviorTypes.map((type) {
    final instance = getBehaviorByType(type);
    if (instance == null) {
      Logger.log('ComponentRegistry: No factory for behavior type: $type');
    }
    return instance;
  }).where((i) => i != null).toList();
}
```

### Step 2: Fix GameEngineNotifier.loadLevel()
Attach behaviors to both `initialComponents` and `paletteComponents` before creating Grid.

### Step 3: Fix addComponent() Method
Ensure dynamically added components also get behaviors:
```dart
void addComponent(ComponentModel paletteComponent, int r, int c) {
  final behaviorInstances = ComponentRegistry.instantiateBehaviorsFor(paletteComponent.type);
  final componentWithBehaviors = paletteComponent.copyWith(behaviors: behaviorInstances);
  final newComponent = componentWithBehaviors.copyWith(id: newId, r: r, c: c);
  // ... rest of method
}
```

## Expected Outcome
After fixes:
- Components will have populated `behaviors` arrays
- `component.getBehavior<DrawingBehavior>()` will return instances
- Canvas painter will find drawing behaviors and render components
- Logic evaluation will find logic behaviors and execute properly
- Grid will be visible with interactive components

## Files to Modify
1. `lib/core/component_registry.dart` - Add `instantiateBehaviorsFor()` helper
2. `lib/engine/game_engine_notifier.dart` - Fix `loadLevel()` and `addComponent()`
3. Test with `flutter run -d chrome` to verify grid renders