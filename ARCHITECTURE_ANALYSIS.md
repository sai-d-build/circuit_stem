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