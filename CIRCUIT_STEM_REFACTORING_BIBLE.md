# 📖 CIRCUIT_STEM_REFACTORING_BIBLE (v2.0)

## **1. Executive Summary**

**Vision**: The architectural goal of a **Unified Interaction Engine** is correct. It will solve our systemic issues in the long term.

**Revised Plan**: Our previous plan was overly ambitious. This revised roadmap adopts a more pragmatic, two-track approach:
1.  **Track 1 (Immediate Stability):** Execute immediate, tactical code fixes to stop data corruption and crashes *now*. This addresses the critical issues you identified with minimal architectural change.
2.  **Track 2 (Strategic Refactoring):** With the system stabilized, we will then begin the strategic evolution of our codebase, refactoring the *existing* `InteractionUseCaseInjected` into the target-state `InteractionEngine`.

This document provides concrete, code-level implementation details for both tracks, ensuring we fix today's problems while building tomorrow's architecture correctly.

---

## **Phase 1: Tactical Stabilization (Fix It First)**

**Goal**: Stop the bleeding. No more "ghost components" or out-of-bounds errors. These fixes are targeted and designed for immediate implementation.

### **Step 1.1: Fix Boundary Validation (Addresses Issue C2)**
**File**: `lib/presentation/features/game/widgets/circuit_grid.dart`

**Action**: Add explicit, early-exit boundary validation before any placement logic is attempted.

```dart
// ✅ FIXED: Add boundary validation before placement
Future<void> _handleDrop(DragTargetDetails<ComponentDragData> details) async {
  // ... existing coordinate calculation ...

  if (gridPosition == null) {
    _showErrorSnackBar(context, 'Cannot place component: Invalid position');
    return;
  }

  final row = gridPosition.row;
  final col = gridPosition.col;
  final gridConfig = ref.read(gridConfigurationProvider);

  // ✅ NEW: Validate boundaries before any state changes
  if (row < 0 || row >= gridConfig.rows || col < 0 || col >= gridConfig.cols) {
    StructuredLogger.error('Boundary validation failed', context: {
      'requestedPosition': {'row': row, 'col': col},
      'gridBounds': {'rows': gridConfig.rows, 'cols': gridConfig.cols},
    });
    _showErrorSnackBar(context, 'Cannot place component: Position out of bounds');
    return; // CRITICAL: Early exit
  }

  // Proceed with validated coordinates
  // ... rest of placement logic ...
}
```

### **Step 1.2: Fix Transaction Atomicity (Addresses Issue C1)**
**File**: `lib/presentation/features/game/widgets/circuit_grid.dart`

**Action**: Wrap the inventory and grid placement calls in a transaction. Crucially, the inventory is only decremented on `commit` after a successful placement and is restored on `rollback`.

```dart
// ✅ FIXED: Move inventory decrement into a transaction
Future<bool> _placeComponentSafely(ComponentType type, int row, int col, String componentTypeString) async {
  final transaction = GameTransaction();
  final gridService = ref.read(gridInteractionServiceProvider(widget.levelId));

  // ✅ NEW: Inventory decrement happens ONLY on successful commit
  transaction.onCommit(() {
    gridService.useComponent(componentTypeString);
  });

  // ✅ NEW: Inventory is restored if placement fails
  transaction.onRollback(() {
    gridService.returnComponent(componentTypeString);
  });

  // Attempt grid placement
  final result = await CreateComponentUseCase.placeComponent(
    type, row, col, ref.read(notifierContextProvider), transaction,
  );

  if (result.isSuccess) {
    await transaction.commit();
    return true;
  } else {
    await transaction.rollback(); // This prevents ghost components
    return false;
  }
}
```

### **Step 1.3: Fix Grid Dimension Sync (Addresses Issue C3)**
**File**: `lib/presentation/features/game/widgets/game_canvas.dart`

**Action**: Remove hardcoded grid dimensions and derive them from the single source of truth: the level configuration.

```dart
// ✅ FIXED: Synchronize with level configuration
@override
Widget build(BuildContext context, WidgetRef ref) {
  final gameState = ref.watch(unifiedGameStateProvider);

  // ✅ NEW: Get dimensions directly from the current level state
  final level = gameState.currentLevel;
  final gridRows = level?.grid.height ?? 20;  // Fallback for safety
  final gridCols = level?.grid.width ?? 20;   // Fallback for safety

  final gridConfig = GridConfiguration(
    rows: gridRows,
    cols: gridCols,
    cellSize: 60,
  );
  // ... rest of build method uses this synchronized gridConfig ...
}
```

### **Step 1.4: Harden Coordinate Service (Addresses Issue #7)**
**File**: `lib/core/services/coordinate_system_service.dart`

**Action**: Add comprehensive null-checking and error handling to prevent crashes when the `RenderBox` is unavailable.

```dart
// ✅ FIXED: Robust coordinate transformation with comprehensive error handling
GridPosition? calculateGridPosition(...) {
    if (gridRenderBox == null) {
      StructuredLogger.error('RenderBox is null - cannot calculate coordinates');
      return null; // Graceful failure
    }

    if (!gridRenderBox.attached) {
      StructuredLogger.warning('RenderBox not attached to render tree');
      return null; // Graceful failure
    }

    try {
      // ... rest of calculation
    } catch (e, stackTrace) {
      StructuredLogger.error('Coordinate calculation failed', context: {'error': e.toString()});
      return null; // Graceful failure
    }
}
```

---

## **Phase 2: Architectural Evolution (The Strategic Refactor)**

**Goal**: Evolve the existing `InteractionUseCaseInjected` into the `InteractionEngine`, centralizing state and logic.

### **Step 2.1: Evolve `InteractionUseCaseInjected`**
**File**: `lib/application/use_cases/interaction_use_case.dart`

**Action**: Refactor `InteractionUseCaseInjected` from a passive service into an active `StateNotifier`. This is an evolution, not a replacement, leveraging existing dependency injection.

```dart
// ✅ EVOLVED: From passive use case to active state engine

// 1. Define the provider as a StateNotifierProvider
final interactionEngineProvider = StateNotifierProvider.family<InteractionEngine, GameState, String>(
  (ref, levelId) => InteractionEngine(ref, levelId)
);

// 2. Rename and change class to extend StateNotifier
class InteractionEngine extends StateNotifier<GameState> {
  final Ref _ref;
  final String _levelId;

  // Dependencies are injected as before
  late final ViewportService _viewportService;
  late final PathfindingService _pathfindingService;
  // ... other services

  InteractionEngine(this._ref, this._levelId) : super(GameState.initial()) {
    // Initialize dependencies using ref
    _viewportService = _ref.read(viewportServiceProvider(_levelId));
    // ... and so on
    
    // Load initial state
    _loadInitialState();
  }

  void _loadInitialState() {
    // ... logic to load level and set initial GameState ...
    state = loadedState;
  }

  // ... All future interaction methods will go here ...
}
```

### **Step 2.2: Specialize Complex Sub-systems (Addresses Issue #6)**
**Action**: Acknowledge that wire routing is complex. The Engine will own the high-level interaction, but delegate the complex pathfinding algorithm to a dedicated service.

```dart
// In InteractionEngine class...

// Dependency on a specialized service
late final WireRoutingService _wireRoutingService;

void onWireDrawStart(Offset globalStart) {
  // ... update state to show wire drawing has started ...
}

void onWireDrawEnd(Offset globalEnd) {
  // 1. Engine determines start and end nodes
  final startNode = _coordinateService.getNodeAt(state.wireDrawStartPos);
  final endNode = _coordinateService.getNodeAt(globalEnd);

  // 2. Delegate complex algorithm to the specialist service
  final pathResult = _wireRoutingService.findPath(startNode, endNode, state.grid);

  // 3. Engine consumes the result and updates the final state
  if (pathResult.isSuccess) {
    state = state.copyWith(wires: [...state.wires, pathResult.wire]);
  } else {
    // show error to user
  }
}
```

### **Step 2.3: Migrate One Flow: "Drag from Palette"**
**Action**: Implement the first full interaction in the new Engine. Widgets will now call the engine instead of containing logic.

```dart
// In InteractionEngine class...
void handlePaletteDragEnd(ComponentDragData dragData, Offset globalPosition) {
    final dropPosition = _coordinateService.globalToGrid(globalPosition);

    // CENTRALIZED VALIDATION
    if (dropPosition == null || !_isValidPlacement(dropPosition) || !_inventoryHas(dragData.type)) {
      state = state.copyWith(error: 'Invalid placement');
      return;
    }

    // ATOMIC STATE UPDATE
    final newComponent = ComponentModel.fromDragData(dragData, dropPosition);
    state = state.copyWith(
      grid: state.grid.withComponent(newComponent),
      inventory: state.inventory.decremented(dragData.type)
    );
}

// In your GameCanvas widget...
// ... onPanEnd from a palette drag ...
ref.read(interactionEngineProvider(levelId).notifier).handlePaletteDragEnd(dragData, details.globalPosition);
```

---

## **Phase 3: Hardening & Advanced Practices**

**Goal**: Address performance, advanced testing, and error handling to build a production-grade system.

### **Step 3.1: Implement Performance Monitoring & Optimization (Addresses Issue #4)**
**Action**: Proactively manage performance.
1.  **Baseline**: Use Flutter DevTools to record and save performance profiles of current drag interactions.
2.  **Optimize Rebuilds**: Wrap static or complex parts of the grid/UI in `RepaintBoundary` widgets to prevent unnecessary repainting during drags.
3.  **Use `select`**: When watching the engine, use `ref.watch(provider.select((s) => s.field))` to ensure widgets only rebuild when the specific data they care about changes.

### **Step 3.2: Implement Advanced Testing Strategy (Addresses Issue #5)**
**Action**: Go beyond happy-path testing.
*   **Unit Tests for Engine**: Test failure scenarios explicitly.
    ```dart
    test('handlePaletteDragEnd should NOT place component if inventory is zero', () {
      // Arrange: setup engine with zero inventory
      // Act: call handlePaletteDragEnd
      // Assert: expect state.grid.components is still empty and state.error is set
    });
    ```
*   **Performance Tests**: Benchmark critical functions.
    ```dart
    test('Wire routing algorithm should be performant', () {
      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 100; i++) {
        wireRoutingService.findPath(...);
      }
      stopwatch.stop();
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });
    ```

### **Step 3.3: Implement Graceful Error Recovery (Addresses Issue #7)**
**Action**: Plan for failures.
*   **Engine State**: Add an `error` field to your `GameState`.
*   **Error Handling**: When an operation in the engine fails (e.g., invalid placement, pathfinding fails), update the state with an error message.
*   **UI Feedback**: Create a dedicated widget that `watches` `interactionEngineProvider.select((s) => s.error)` and displays a snackbar or dialog when an error is present, providing clear feedback to the user.

---

## **4. Final Validation Checklist**

- ✅ **Phase 1 Complete**: All critical data corruption and crash bugs from the original analysis are resolved.
- ✅ **Phase 2 Complete**: The `InteractionEngine` is the source of truth for component placement. Old logic in widgets has been removed.
- ✅ **Phase 3 Complete**: Performance is profiled and optimized. Test coverage exceeds 80% for the Engine, including failure and edge cases.
- ✅ **Final State**: The application is stable, the architecture is clean and centralized, and the codebase is ready for future feature development.