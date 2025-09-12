# GameCanvas God Object Refactoring Plan

## Critical Analysis: Architectural Anti-Patterns

The `GameCanvas` widget violates multiple SOLID principles and exhibits classic God Object symptoms:

- **1,200+ lines** of mixed responsibilities
- **7 distinct concerns** crammed into one class (rendering, gesture handling, state management, coordinate conversion, drag/drop, context menus, level loading)
- **Violation of SRP**: Single widget handles UI, business logic, and service coordination
- **Violation of DIP**: Direct dependencies on concrete implementations rather than abstractions

# 1. Deep Analysis: The Anatomy of a God Object

The `_GameCanvasState` class has become a God Object, violating the Single Responsibility Principle (SRP). It currently manages rendering, input processing, state management, business logic, and UI feedback, leading to a tightly coupled and fragile system.

### 1.1. Dependency and Import Analysis

The `GameCanvas` widget has a large and complex web of dependencies, which is a primary source of its rigidity.

**Direct Imports and Their Purpose:**

| Import File                          | Purpose                                                              | Coupling Concern                                                                                             |
| ------------------------------------ | -------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------ |
| `flutter/material.dart`              | Core Flutter widgets, themes, and UI primitives.                     | **Necessary**, but the widget mixes framework code directly with business logic.                             |
| `flutter_riverpod/flutter_riverpod.dart` | State management and dependency injection.                           | **High.** The widget is a `ConsumerStatefulWidget`, deeply tying its lifecycle and logic to Riverpod.         |
| `game_canvas_controller.dart`        | A `ChangeNotifier` for pan/zoom state.                               | **High.** Tightly coupled to a secondary state management solution, creating multiple sources of truth.      |
| `game_state.dart`                    | `GameState` model.                                                   | **High.** The widget directly manipulates and reads from this complex state object.                          |
| `palette_state.dart`                 | `PaletteState` model.                                                | **High.** Another state object the widget is directly coupled to for inventory logic.                        |
| `core_providers.dart`                | Access to application-wide services like `levelServiceProvider`.     | **High.** The widget acts as a service locator, pulling in dependencies instead of having them provided.      |
| `entities.dart`                      | Domain models like `ComponentModel`.                                 | **Medium.** The widget converts domain models to presentation models, which is a misplaced responsibility. |
| `circuit_components_painter.dart`    | A `CustomPainter` for rendering.                                     | **High.** The widget is directly responsible for instantiating and providing data to this painter.           |
| `feedback_utils.dart`                | Utility for haptic/sound feedback.                                   | **Medium.** Couples the widget to a specific feedback implementation.                                        |
| `grid_service.dart` / `coordinate_service.dart` | Services for grid and coordinate logic.                      | **High.** The widget directly calls these services, mixing view concerns with spatial calculations.          |

**"Invisible" Dependencies (via Riverpod `ref`):**

-   `enhancedGameStateNotifierProvider`: The primary source of truth for the game's state. `GameCanvas` both reads from (`ref.watch`) and writes to (`ref.read(...).notifier`) this provider, mixing read and write concerns.
-   `paletteStateProvider`: Manages the state of the component palette, including inventory.
-   `levelServiceProvider`: Used to load the initial level data.
-   `paletteDragActiveProvider`: A boolean flag to control gesture handling.

**Justification for Concern:**

This deep entanglement of dependencies means:
1.  **Testing is Nearly Impossible:** To test a single function like `_processComponentDrop`, you must construct a `WidgetTester`, mock multiple Riverpod providers, create a valid `BuildContext`, and simulate a drag event. In a clean architecture, you could test the underlying logic in a pure Dart class.
2.  **High Risk of Regression:** A change to input handling (`_handleScaleUpdate`) could inadvertently break rendering logic or state validation because the code is so intertwined and shares state variables (`_isDraggingComponent`, `_dragPosition`).
3.  **Poor Reusability:** No part of `GameCanvas` can be reused. The input handling, rendering, and state logic are all trapped inside this one widget.


## Phase 1: Immediate Architectural Redesign

### 1.1 Create Presentation Layer Orchestrator

**New File**: `lib/presentation/features/game/controllers/game_canvas_orchestrator.dart`

```dart
class GameCanvasOrchestrator extends StateNotifier<GameCanvasState> {
  final GameInteractionService _interactionService;
  final ComponentPlacementService _placementService;
  final CanvasRenderingService _renderingService;
  final LevelCoordinator _levelCoordinator;

  GameCanvasOrchestrator({
    required GameInteractionService interactionService,
    required ComponentPlacementService placementService,
    required CanvasRenderingService renderingService,
    required LevelCoordinator levelCoordinator,
  }) : _interactionService = interactionService,
       _placementService = placementService,
       _renderingService = renderingService,
       _levelCoordinator = levelCoordinator,
       super(GameCanvasState.initial());

  // Pure orchestration - no business logic
  Future<void> initializeLevel(String levelId) async {
    state = state.copyWith(isLoading: true);
    final level = await _levelCoordinator.loadLevel(levelId);
    state = state.copyWith(
      currentLevel: level,
      isLoading: false,
      renderingData: _renderingService.buildRenderingData(level),
    );
  }

  void handleGestureInput(GestureInputEvent event) {
    final result = _interactionService.processGesture(event, state);
    state = result.newState;
    
    // Execute side effects without mixing with state
    for (final sideEffect in result.sideEffects) {
      _executeSideEffect(sideEffect);
    }
  }
}
```

### 1.2 Extract Pure UI Widget

**Refactored**: `lib/presentation/features/game/widgets/game_canvas.dart`

```dart
class GameCanvas extends ConsumerWidget {
  final String levelId;
  
  const GameCanvas({super.key, required this.levelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(gameCanvasOrchestratorProvider(levelId));
    final theme = Theme.of(context).extension<CircuitColorScheme>()!;
    
    return CanvasContainer(
      theme: theme,
      child: CanvasGestureLayer(
        onGestureEvent: (event) => ref
            .read(gameCanvasOrchestratorProvider(levelId).notifier)
            .handleGestureInput(event),
        child: CanvasRenderingLayer(
          renderingData: canvasState.renderingData,
          interactionState: canvasState.interactionState,
        ),
      ),
    );
  }
}
```

## Phase 2: Service Layer Decomposition

### 2.1 Game Interaction Service (Replace GameCanvasController)

**New File**: `lib/application/services/game_interaction_service.dart`

```dart
abstract class GameInteractionService {
  GestureProcessingResult processGesture(
    GestureInputEvent event, 
    GameCanvasState currentState
  );
}

class DefaultGameInteractionService implements GameInteractionService {
  final CoordinateTransformationService _coordinateService;
  final GestureStateMachine _gestureStateMachine;
  final CanvasViewportService _viewportService;

  @override
  GestureProcessingResult processGesture(
    GestureInputEvent event, 
    GameCanvasState currentState
  ) {
    // Pure functional processing - no side effects
    return _gestureStateMachine.process(event, currentState);
  }
}
```

### 2.2 Component Placement Service

**New File**: `lib/application/services/component_placement_service.dart`

```dart
abstract class ComponentPlacementService {
  PlacementValidationResult validatePlacement(
    ComponentType type,
    GridPosition position,
    GameState gameState,
  );
  
  PlacementExecutionResult executeComponentPlacement(
    ComponentPlacementRequest request
  );
}

class DefaultComponentPlacementService implements ComponentPlacementService {
  final ComponentInventoryService _inventoryService;
  final GridValidationService _gridValidationService;
  final GameStateService _gameStateService;

  @override
  PlacementValidationResult validatePlacement(
    ComponentType type,
    GridPosition position,
    GameState gameState,
  ) {
    final inventoryCheck = _inventoryService.checkAvailability(type);
    final gridCheck = _gridValidationService.validatePosition(position, gameState);
    
    return PlacementValidationResult(
      isValid: inventoryCheck.isValid && gridCheck.isValid,
      reason: inventoryCheck.reason ?? gridCheck.reason,
    );
  }
}
```

### 2.3 Canvas Rendering Service

**New File**: `lib/application/services/canvas_rendering_service.dart`

```dart
abstract class CanvasRenderingService {
  CanvasRenderingData buildRenderingData(LevelDefinition level);
  ComponentRenderingData convertComponentsForPainter(List<ComponentModel> components);
  WireRenderingData convertConnectionsForPainter(Map<String, Set<String>> connections);
}

class DefaultCanvasRenderingService implements CanvasRenderingService {
  @override
  CanvasRenderingData buildRenderingData(LevelDefinition level) {
    // Pure transformation logic - no dependencies on Flutter framework
    return CanvasRenderingData(
      components: convertComponentsForPainter(level.components.available),
      wires: convertConnectionsForPainter(level.connections ?? {}),
      gridConfiguration: GridConfiguration.fromLevel(level),
    );
  }
}
```

## Phase 3: State Management Consolidation

### 3.1 Unified Canvas State

**New File**: `lib/application/states/game_canvas_state.dart`

```dart
@freezed
class GameCanvasState with _$GameCanvasState {
  const factory GameCanvasState({
    required LevelDefinition? currentLevel,
    required CanvasRenderingData renderingData,
    required InteractionState interactionState,
    required ViewportState viewportState,
    @Default(false) bool isLoading,
    @Default(null) String? errorMessage,
  }) = _GameCanvasState;
  
  factory GameCanvasState.initial() => const GameCanvasState(
    currentLevel: null,
    renderingData: CanvasRenderingData.empty(),
    interactionState: InteractionState.idle(),
    viewportState: ViewportState.default(),
  );
}
```

### 3.2 Replace GameCanvasController Responsibilities

**New Files Structure:**
```
lib/application/services/viewport/
├── viewport_service.dart              # Pan, zoom, coordinate transforms
├── viewport_state.dart               # Immutable viewport state
├── coordinate_transformation_service.dart  # Screen ↔ Grid conversions
└── viewport_constraints_service.dart     # Bounds checking
```

## Phase 4: Gesture Handling Architecture

### 4.1 Gesture State Machine

**New File**: `lib/application/services/gestures/gesture_state_machine.dart`

```dart
enum GestureMode { idle, panning, draggingComponent, placingComponent, drawingWire }

class GestureStateMachine {
  GestureProcessingResult process(GestureInputEvent event, GameCanvasState state) {
    return switch ((state.interactionState.mode, event.type)) {
      (GestureMode.idle, GestureEventType.tapDown) => _handleIdleTap(event, state),
      (GestureMode.idle, GestureEventType.dragStart) => _handleDragStart(event, state),
      (GestureMode.draggingComponent, GestureEventType.dragUpdate) => _handleComponentDrag(event, state),
      (GestureMode.panning, GestureEventType.dragUpdate) => _handleCanvasPan(event, state),
      // ... other state transitions
      _ => GestureProcessingResult.noChange(state),
    };
  }
}
```

### 4.2 Decouple Gesture Input from UI

**New File**: `lib/presentation/features/game/widgets/canvas_gesture_layer.dart`

```dart
class CanvasGestureLayer extends StatelessWidget {
  final Function(GestureInputEvent) onGestureEvent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => onGestureEvent(
        GestureInputEvent.tapDown(details.localPosition)
      ),
      onScaleStart: (details) => onGestureEvent(
        GestureInputEvent.scaleStart(details.localFocalPoint, details.pointerCount)
      ),
      // Convert all Flutter gestures to domain events
      child: child,
    );
  }
}
```

## Phase 5: Additional Classes Requiring Refactoring

### 5.1 GameCanvasController → Multiple Services

**Current Problems:**
- Mixed viewport management with interaction state
- ChangeNotifier pattern conflicts with Riverpod
- 500+ lines of mixed responsibilities

**Refactoring Strategy:**
```
GameCanvasController →
├── ViewportService (pan, zoom, scale)
├── CoordinateTransformationService (screen ↔ grid)  
├── InteractionModeService (FSM for gestures)
└── CanvasConstraintsService (bounds checking)
```

### 5.2 Providers Reorganization

**Current Problems:**
- `providers_v3.dart` and `core_providers.dart` have overlapping responsibilities
- Service locator anti-pattern

**Refactoring Strategy:**
```
lib/application/providers/
├── game_canvas_providers.dart      # Canvas-specific providers
├── interaction_providers.dart      # Gesture and interaction services
├── rendering_providers.dart        # Painter and rendering services
└── level_management_providers.dart # Level loading and coordination
```

### 5.3 Painter Instantiation Decoupling

**Current Problem**: Direct painter instantiation in widget build method

**Solution**: 
```dart
// New abstraction
abstract class CanvasRenderingLayer extends StatelessWidget {
  final CanvasRenderingData renderingData;
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _createPainter(renderingData),
    );
  }
  
  CustomPainter _createPainter(CanvasRenderingData data); // Factory method
}
```

## Phase 6: Integration & Testing Strategy

### 6.1 Provider Architecture

```dart
// Centralized provider for GameCanvas
final gameCanvasOrchestratorProvider = StateNotifierProvider.family
  GameCanvasOrchestrator, 
  GameCanvasState,
  String  // levelId
>((ref, levelId) {
  return GameCanvasOrchestrator(
    interactionService: ref.watch(gameInteractionServiceProvider),
    placementService: ref.watch(componentPlacementServiceProvider),
    renderingService: ref.watch(canvasRenderingServiceProvider),
    levelCoordinator: ref.watch(levelCoordinatorProvider),
  );
});
```

### 6.2 Testing Strategy

```dart
// Each service can be unit tested in isolation
class MockGameInteractionService extends Mock implements GameInteractionService {}

void main() {
  testWidgets('GameCanvas handles component placement', (tester) async {
    // Test individual services, not the God Object
    final mockInteractionService = MockGameInteractionService();
    // ... clean, focused tests
  });
}
```

## Migration Strategy

### Week 1: Extract Services
1. Create `GameCanvasOrchestrator`
2. Extract `GameInteractionService`
3. Create basic service interfaces

### Week 2: State Consolidation  
1. Replace `GameCanvasController` with viewport services
2. Consolidate state into `GameCanvasState`
3. Update providers

### Week 3: UI Refactoring
1. Split `GameCanvas` into focused widgets
2. Create gesture abstraction layer
3. Decouple painters from direct instantiation

### Week 4: Testing & Integration
1. Add comprehensive unit tests for services
2. Integration testing for orchestrator
3. Performance validation

This refactoring eliminates the God Object anti-pattern while leveraging your existing clean architecture structure, making the codebase more maintainable, testable, and extensible.## Critical Analysis & Additional Considerations

While the refactoring plan addresses the core God Object issues, there are several important considerations for successful implementation:

### Potential Risks & Mitigation Strategies

**1. Over-Engineering Risk**
The proposed service decomposition could introduce unnecessary complexity if not implemented incrementally. The current codebase might benefit from a more gradual extraction approach:

- Start with **GameCanvasOrchestrator** only
- Extract one service at a time (begin with `ComponentPlacementService`)
- Validate each extraction with integration tests before proceeding

**2. Performance Implications**
The current direct manipulation approach in `GameCanvas` may be more performant than the proposed service layer:

- **Mitigation**: Profile gesture handling performance before/after refactoring
- Consider keeping coordinate transformations in-widget for high-frequency operations
- Use `RepaintBoundary` widgets strategically around extracted components

**3. State Synchronization Complexity**
Moving from direct state manipulation to orchestrated state updates introduces potential race conditions:

```dart
// Potential issue: Multiple gesture events in rapid succession
void handleGestureInput(GestureInputEvent event) {
  final result = _interactionService.processGesture(event, state);
  state = result.newState; // What if another event arrives here?
}
```

**Mitigation**: Implement state update queuing or use synchronous processing for gesture events.

### Missing Dependencies for Complete Refactoring

Your analysis focused on `GameCanvas`, but several other classes require immediate attention:

**1. CircuitComponentsPainter Dependencies**
- **File**: `lib/presentation/features/game/painters/circuit_components_painter.dart`  
- **Issue**: Tightly coupled to `ComponentModel` domain objects
- **Refactoring Need**: Create `PainterDataAdapter` service to convert domain models to painter-specific DTOs

**2. Enhanced Game State Notifier (V3)**
- **File**: `lib/application/game_engine/v3/game_engine_notifier_v3.dart`
- **Issue**: Likely contains business logic mixed with state management
- **Refactoring Need**: Split into domain services + pure state notifier

**3. Palette State Provider**
- **File**: `lib/presentation/state/palette_state.dart`
- **Issue**: Presentation state handling business inventory logic
- **Refactoring Need**: Extract `ComponentInventoryService`

### Architecture Validation Concerns

**1. Circular Dependencies**
The proposed service architecture could introduce circular dependencies:

```dart
GameCanvasOrchestrator -> GameInteractionService -> GameCanvasState
```

**Solution**: Introduce clear dependency direction with interfaces and events.

**2. Riverpod Provider Explosion** 
The plan creates 10+ new providers, which could complicate dependency injection:

**Recommendation**: Group related services into fewer, coarser-grained providers:

```dart
final gameCanvasServicesProvider = Provider((ref) => GameCanvasServices(
  interaction: DefaultGameInteractionService(...),
  placement: DefaultComponentPlacementService(...),
  rendering: DefaultCanvasRenderingService(...),
));
```

### Implementation Priority Adjustment

Based on your existing architecture, I recommend this revised priority order:

**Phase 1A (Immediate)**:
1. Extract `ComponentPlacementService` first (highest business value)
2. Create `GameCanvasOrchestrator` (without full service decomposition)
3. Consolidate gesture handling into simple state machine

**Phase 1B (Next Sprint)**:
1. Extract viewport management from `GameCanvasController`
2. Create rendering data transformation service
3. Split UI widget into focused components

This approach reduces risk while delivering immediate architectural improvements. The current `GameCanvas` implementation, while problematic, is functional - a gradual refactoring ensures you don't introduce regressions while improving the architecture.# GameCanvas God Object Refactoring Plan

## Critical Analysis: Architectural Anti-Patterns

The `GameCanvas` widget violates multiple SOLID principles and exhibits classic God Object symptoms:

- **1,200+ lines** of mixed responsibilities
- **7 distinct concerns** crammed into one class (rendering, gesture handling, state management, coordinate conversion, drag/drop, context menus, level loading)
- **Violation of SRP**: Single widget handles UI, business logic, and service coordination
- **Violation of DIP**: Direct dependencies on concrete implementations rather than abstractions

## Phase 1: Immediate Architectural Redesign

### 1.1 Create Presentation Layer Orchestrator

**New File**: `lib/presentation/features/game/controllers/game_canvas_orchestrator.dart`

```dart
class GameCanvasOrchestrator extends StateNotifier<GameCanvasState> {
  final GameInteractionService _interactionService;
  final ComponentPlacementService _placementService;
  final CanvasRenderingService _renderingService;
  final LevelCoordinator _levelCoordinator;

  GameCanvasOrchestrator({
    required GameInteractionService interactionService,
    required ComponentPlacementService placementService,
    required CanvasRenderingService renderingService,
    required LevelCoordinator levelCoordinator,
  }) : _interactionService = interactionService,
       _placementService = placementService,
       _renderingService = renderingService,
       _levelCoordinator = levelCoordinator,
       super(GameCanvasState.initial());

  // Pure orchestration - no business logic
  Future<void> initializeLevel(String levelId) async {
    state = state.copyWith(isLoading: true);
    final level = await _levelCoordinator.loadLevel(levelId);
    state = state.copyWith(
      currentLevel: level,
      isLoading: false,
      renderingData: _renderingService.buildRenderingData(level),
    );
  }

  void handleGestureInput(GestureInputEvent event) {
    final result = _interactionService.processGesture(event, state);
    state = result.newState;
    
    // Execute side effects without mixing with state
    for (final sideEffect in result.sideEffects) {
      _executeSideEffect(sideEffect);
    }
  }
}
```

### 1.2 Extract Pure UI Widget

**Refactored**: `lib/presentation/features/game/widgets/game_canvas.dart`

```dart
class GameCanvas extends ConsumerWidget {
  final String levelId;
  
  const GameCanvas({super.key, required this.levelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(gameCanvasOrchestratorProvider(levelId));
    final theme = Theme.of(context).extension<CircuitColorScheme>()!;
    
    return CanvasContainer(
      theme: theme,
      child: CanvasGestureLayer(
        onGestureEvent: (event) => ref
            .read(gameCanvasOrchestratorProvider(levelId).notifier)
            .handleGestureInput(event),
        child: CanvasRenderingLayer(
          renderingData: canvasState.renderingData,
          interactionState: canvasState.interactionState,
        ),
      ),
    );
  }
}
```

## Phase 2: Service Layer Decomposition

### 2.1 Game Interaction Service (Replace GameCanvasController)

**New File**: `lib/application/services/game_interaction_service.dart`

```dart
abstract class GameInteractionService {
  GestureProcessingResult processGesture(
    GestureInputEvent event, 
    GameCanvasState currentState
  );
}

class DefaultGameInteractionService implements GameInteractionService {
  final CoordinateTransformationService _coordinateService;
  final GestureStateMachine _gestureStateMachine;
  final CanvasViewportService _viewportService;

  @override
  GestureProcessingResult processGesture(
    GestureInputEvent event, 
    GameCanvasState currentState
  ) {
    // Pure functional processing - no side effects
    return _gestureStateMachine.process(event, currentState);
  }
}
```

### 2.2 Component Placement Service

**New File**: `lib/application/services/component_placement_service.dart`

```dart
abstract class ComponentPlacementService {
  PlacementValidationResult validatePlacement(
    ComponentType type,
    GridPosition position,
    GameState gameState,
  );
  
  PlacementExecutionResult executeComponentPlacement(
    ComponentPlacementRequest request
  );
}

class DefaultComponentPlacementService implements ComponentPlacementService {
  final ComponentInventoryService _inventoryService;
  final GridValidationService _gridValidationService;
  final GameStateService _gameStateService;

  @override
  PlacementValidationResult validatePlacement(
    ComponentType type,
    GridPosition position,
    GameState gameState,
  ) {
    final inventoryCheck = _inventoryService.checkAvailability(type);
    final gridCheck = _gridValidationService.validatePosition(position, gameState);
    
    return PlacementValidationResult(
      isValid: inventoryCheck.isValid && gridCheck.isValid,
      reason: inventoryCheck.reason ?? gridCheck.reason,
    );
  }
}
```

### 2.3 Canvas Rendering Service

**New File**: `lib/application/services/canvas_rendering_service.dart`

```dart
abstract class CanvasRenderingService {
  CanvasRenderingData buildRenderingData(LevelDefinition level);
  ComponentRenderingData convertComponentsForPainter(List<ComponentModel> components);
  WireRenderingData convertConnectionsForPainter(Map<String, Set<String>> connections);
}

class DefaultCanvasRenderingService implements CanvasRenderingService {
  @override
  CanvasRenderingData buildRenderingData(LevelDefinition level) {
    // Pure transformation logic - no dependencies on Flutter framework
    return CanvasRenderingData(
      components: convertComponentsForPainter(level.components.available),
      wires: convertConnectionsForPainter(level.connections ?? {}),
      gridConfiguration: GridConfiguration.fromLevel(level),
    );
  }
}
```

## Phase 3: State Management Consolidation

### 3.1 Unified Canvas State

**New File**: `lib/application/states/game_canvas_state.dart`

```dart
@freezed
class GameCanvasState with _$GameCanvasState {
  const factory GameCanvasState({
    required LevelDefinition? currentLevel,
    required CanvasRenderingData renderingData,
    required InteractionState interactionState,
    required ViewportState viewportState,
    @Default(false) bool isLoading,
    @Default(null) String? errorMessage,
  }) = _GameCanvasState;
  
  factory GameCanvasState.initial() => const GameCanvasState(
    currentLevel: null,
    renderingData: CanvasRenderingData.empty(),
    interactionState: InteractionState.idle(),
    viewportState: ViewportState.default(),
  );
}
```

### 3.2 Replace GameCanvasController Responsibilities

**New Files Structure:**
```
lib/application/services/viewport/
├── viewport_service.dart              # Pan, zoom, coordinate transforms
├── viewport_state.dart               # Immutable viewport state
├── coordinate_transformation_service.dart  # Screen ↔ Grid conversions
└── viewport_constraints_service.dart     # Bounds checking
```

## Phase 4: Gesture Handling Architecture

### 4.1 Gesture State Machine

**New File**: `lib/application/services/gestures/gesture_state_machine.dart`

```dart
enum GestureMode { idle, panning, draggingComponent, placingComponent, drawingWire }

class GestureStateMachine {
  GestureProcessingResult process(GestureInputEvent event, GameCanvasState state) {
    return switch ((state.interactionState.mode, event.type)) {
      (GestureMode.idle, GestureEventType.tapDown) => _handleIdleTap(event, state),
      (GestureMode.idle, GestureEventType.dragStart) => _handleDragStart(event, state),
      (GestureMode.draggingComponent, GestureEventType.dragUpdate) => _handleComponentDrag(event, state),
      (GestureMode.panning, GestureEventType.dragUpdate) => _handleCanvasPan(event, state),
      // ... other state transitions
      _ => GestureProcessingResult.noChange(state),
    };
  }
}
```

### 4.2 Decouple Gesture Input from UI

**New File**: `lib/presentation/features/game/widgets/canvas_gesture_layer.dart`

```dart
class CanvasGestureLayer extends StatelessWidget {
  final Function(GestureInputEvent) onGestureEvent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (details) => onGestureEvent(
        GestureInputEvent.tapDown(details.localPosition)
      ),
      onScaleStart: (details) => onGestureEvent(
        GestureInputEvent.scaleStart(details.localFocalPoint, details.pointerCount)
      ),
      // Convert all Flutter gestures to domain events
      child: child,
    );
  }
}
```

## Phase 5: Additional Classes Requiring Refactoring

### 5.1 GameCanvasController → Multiple Services

**Current Problems:**
- Mixed viewport management with interaction state
- ChangeNotifier pattern conflicts with Riverpod
- 500+ lines of mixed responsibilities

**Refactoring Strategy:**
```
GameCanvasController →
├── ViewportService (pan, zoom, scale)
├── CoordinateTransformationService (screen ↔ grid)  
├── InteractionModeService (FSM for gestures)
└── CanvasConstraintsService (bounds checking)
```

### 5.2 Providers Reorganization

**Current Problems:**
- `providers_v3.dart` and `core_providers.dart` have overlapping responsibilities
- Service locator anti-pattern

**Refactoring Strategy:**
```
lib/application/providers/
├── game_canvas_providers.dart      # Canvas-specific providers
├── interaction_providers.dart      # Gesture and interaction services
├── rendering_providers.dart        # Painter and rendering services
└── level_management_providers.dart # Level loading and coordination
```

### 5.3 Painter Instantiation Decoupling

**Current Problem**: Direct painter instantiation in widget build method

**Solution**: 
```dart
// New abstraction
abstract class CanvasRenderingLayer extends StatelessWidget {
  final CanvasRenderingData renderingData;
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _createPainter(renderingData),
    );
  }
  
  CustomPainter _createPainter(CanvasRenderingData data); // Factory method
}
```

## Phase 6: Integration & Testing Strategy

### 6.1 Provider Architecture

```dart
// Centralized provider for GameCanvas
final gameCanvasOrchestratorProvider = StateNotifierProvider.family
  GameCanvasOrchestrator, 
  GameCanvasState,
  String  // levelId
>((ref, levelId) {
  return GameCanvasOrchestrator(
    interactionService: ref.watch(gameInteractionServiceProvider),
    placementService: ref.watch(componentPlacementServiceProvider),
    renderingService: ref.watch(canvasRenderingServiceProvider),
    levelCoordinator: ref.watch(levelCoordinatorProvider),
  );
});
```

### 6.2 Testing Strategy

```dart
// Each service can be unit tested in isolation
class MockGameInteractionService extends Mock implements GameInteractionService {}

void main() {
  testWidgets('GameCanvas handles component placement', (tester) async {
    // Test individual services, not the God Object
    final mockInteractionService = MockGameInteractionService();
    // ... clean, focused tests
  });
}
```

## Migration Strategy

### Week 1: Extract Services
1. Create `GameCanvasOrchestrator`
2. Extract `GameInteractionService`
3. Create basic service interfaces

### Week 2: State Consolidation  
1. Replace `GameCanvasController` with viewport services
2. Consolidate state into `GameCanvasState`
3. Update providers

### Week 3: UI Refactoring
1. Split `GameCanvas` into focused widgets
2. Create gesture abstraction layer
3. Decouple painters from direct instantiation

### Week 4: Testing & Integration
1. Add comprehensive unit tests for services
2. Integration testing for orchestrator
3. Performance validation

This refactoring eliminates the God Object anti-pattern while leveraging your existing clean architecture structure, making the codebase more maintainable, testable, and extensible.## Critical Analysis & Additional Considerations

While the refactoring plan addresses the core God Object issues, there are several important considerations for successful implementation:

### Potential Risks & Mitigation Strategies

**1. Over-Engineering Risk**
The proposed service decomposition could introduce unnecessary complexity if not implemented incrementally. The current codebase might benefit from a more gradual extraction approach:

- Start with **GameCanvasOrchestrator** only
- Extract one service at a time (begin with `ComponentPlacementService`)
- Validate each extraction with integration tests before proceeding

**2. Performance Implications**
The current direct manipulation approach in `GameCanvas` may be more performant than the proposed service layer:

- **Mitigation**: Profile gesture handling performance before/after refactoring
- Consider keeping coordinate transformations in-widget for high-frequency operations
- Use `RepaintBoundary` widgets strategically around extracted components

**3. State Synchronization Complexity**
Moving from direct state manipulation to orchestrated state updates introduces potential race conditions:

```dart
// Potential issue: Multiple gesture events in rapid succession
void handleGestureInput(GestureInputEvent event) {
  final result = _interactionService.processGesture(event, state);
  state = result.newState; // What if another event arrives here?
}
```

**Mitigation**: Implement state update queuing or use synchronous processing for gesture events.

### Missing Dependencies for Complete Refactoring

Your analysis focused on `GameCanvas`, but several other classes require immediate attention:

**1. CircuitComponentsPainter Dependencies**
- **File**: `lib/presentation/features/game/painters/circuit_components_painter.dart`  
- **Issue**: Tightly coupled to `ComponentModel` domain objects
- **Refactoring Need**: Create `PainterDataAdapter` service to convert domain models to painter-specific DTOs

**2. Enhanced Game State Notifier (V3)**
- **File**: `lib/application/game_engine/v3/game_engine_notifier_v3.dart`
- **Issue**: Likely contains business logic mixed with state management
- **Refactoring Need**: Split into domain services + pure state notifier

**3. Palette State Provider**
- **File**: `lib/presentation/state/palette_state.dart`
- **Issue**: Presentation state handling business inventory logic
- **Refactoring Need**: Extract `ComponentInventoryService`

### Architecture Validation Concerns

**1. Circular Dependencies**
The proposed service architecture could introduce circular dependencies:

```dart
GameCanvasOrchestrator -> GameInteractionService -> GameCanvasState
```

**Solution**: Introduce clear dependency direction with interfaces and events.

**2. Riverpod Provider Explosion** 
The plan creates 10+ new providers, which could complicate dependency injection:

**Recommendation**: Group related services into fewer, coarser-grained providers:

```dart
final gameCanvasServicesProvider = Provider((ref) => GameCanvasServices(
  interaction: DefaultGameInteractionService(...),
  placement: DefaultComponentPlacementService(...),
  rendering: DefaultCanvasRenderingService(...),
));
```

### Implementation Priority Adjustment

Based on your existing architecture, I recommend this revised priority order:

**Phase 1A (Immediate)**:
1. Extract `ComponentPlacementService` first (highest business value)
2. Create `GameCanvasOrchestrator` (without full service decomposition)
3. Consolidate gesture handling into simple state machine

**Phase 1B (Next Sprint)**:
1. Extract viewport management from `GameCanvasController`
2. Create rendering data transformation service
3. Split UI widget into focused components

This approach reduces risk while delivering immediate architectural improvements. The current `GameCanvas` implementation, while problematic, is functional - a gradual refactoring ensures you don't introduce regressions while improving the architecture.

# GameCanvas God Object Refactoring: Complete Implementation Plan

## Executive Summary

The current `GameCanvas` widget is a classic God Object anti-pattern with 1,200+ lines mixing UI rendering, business logic, state management, and service coordination. This plan provides a comprehensive architectural refactoring that maintains the existing clean architecture while eliminating tight coupling and responsibility violations.

## Current Architecture Problems

### God Object Violations
- **Single Responsibility Principle**: GameCanvas handles 7+ distinct concerns
- **Dependency Inversion Principle**: Direct coupling to concrete implementations  
- **Open/Closed Principle**: Changes require modifying the monolithic widget
- **Mixed State Management**: Riverpod StateNotifiers + ChangeNotifier controllers
- **Business Logic in Presentation**: Component placement logic in UI widgets

### Tight Coupling Analysis
1. **enhancedGameStateNotifierProvider** - Direct state manipulation from UI
2. **GameCanvasController** - Conflicting state management patterns
3. **paletteStateProvider** - Business logic mixed with rendering
4. **Service Locator Pattern** - Direct service calls from widgets
5. **Painter Coupling** - Direct instantiation of rendering components

## Phase 1: Architectural Foundation

### 1.1 Create Presentation Orchestrator

**File**: `lib/presentation/features/game/controllers/game_canvas_orchestrator.dart`

```dart
class GameCanvasOrchestrator extends StateNotifier<GameCanvasState> {
  final GameInteractionService _interactionService;
  final ComponentPlacementService _placementService;
  final CanvasRenderingService _renderingService;
  final LevelCoordinator _levelCoordinator;

  GameCanvasOrchestrator({
    required GameInteractionService interactionService,
    required ComponentPlacementService placementService,
    required CanvasRenderingService renderingService,
    required LevelCoordinator levelCoordinator,
  }) : _interactionService = interactionService,
       _placementService = placementService,
       _renderingService = renderingService,
       _levelCoordinator = levelCoordinator,
       super(GameCanvasState.initial());

  /// Pure orchestration - delegates to services without business logic
  Future<void> initializeLevel(String levelId) async {
    state = state.copyWith(isLoading: true);
    
    try {
      final level = await _levelCoordinator.loadLevel(levelId);
      final renderingData = _renderingService.buildRenderingData(level);
      
      state = state.copyWith(
        currentLevel: level,
        isLoading: false,
        renderingData: renderingData,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load level: ${e.toString()}',
      );
    }
  }

  void handleGestureInput(GestureInputEvent event) {
    final result = _interactionService.processGesture(event, state);
    state = result.newState;
    
    // Execute side effects through dedicated handlers
    for (final sideEffect in result.sideEffects) {
      _executeSideEffect(sideEffect);
    }
  }

  void _executeSideEffect(SideEffect sideEffect) {
    switch (sideEffect) {
      case ComponentPlacementSideEffect():
        _placementService.executeComponentPlacement(sideEffect.request);
      case ViewportUpdateSideEffect():
        // Handle viewport changes
        break;
      case FeedbackSideEffect():
        // Handle haptic/audio feedback
        break;
    }
  }
}
```

### 1.2 Refactored GameCanvas Widget

**File**: `lib/presentation/features/game/widgets/game_canvas.dart`

```dart
class GameCanvas extends ConsumerWidget {
  final String levelId;
  
  const GameCanvas({super.key, required this.levelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canvasState = ref.watch(gameCanvasOrchestratorProvider(levelId));
    final theme = Theme.of(context).extension<CircuitColorScheme>()!;
    
    // Initialize level on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(gameCanvasOrchestratorProvider(levelId).notifier)
          .initializeLevel(levelId);
    });
    
    if (canvasState.isLoading) {
      return const CanvasLoadingIndicator();
    }
    
    if (canvasState.error != null) {
      return CanvasErrorDisplay(error: canvasState.error!);
    }
    
    return CanvasContainer(
      theme: theme,
      child: CanvasGestureLayer(
        onGestureEvent: (event) => ref
            .read(gameCanvasOrchestratorProvider(levelId).notifier)
            .handleGestureInput(event),
        child: CanvasRenderingLayer(
          renderingData: canvasState.renderingData,
          interactionState: canvasState.interactionState,
          viewportState: canvasState.viewportState,
        ),
      ),
    );
  }
}
```

## Phase 2: Service Layer Decomposition

### 2.1 Game Interaction Service

**File**: `lib/application/services/game_interaction_service.dart`

```dart
abstract class GameInteractionService {
  GestureProcessingResult processGesture(
    GestureInputEvent event, 
    GameCanvasState currentState
  );
}

class DefaultGameInteractionService implements GameInteractionService {
  final CoordinateTransformationService _coordinateService;
  final GestureStateMachine _gestureStateMachine;
  final ComponentHitTestService _hitTestService;

  DefaultGameInteractionService({
    required CoordinateTransformationService coordinateService,
    required GestureStateMachine gestureStateMachine,
    required ComponentHitTestService hitTestService,
  }) : _coordinateService = coordinateService,
       _gestureStateMachine = gestureStateMachine,
       _hitTestService = hitTestService;

  @override
  GestureProcessingResult processGesture(
    GestureInputEvent event, 
    GameCanvasState currentState
  ) {
    // Convert screen coordinates to grid coordinates
    final gridPosition = _coordinateService.screenToGrid(
      event.position, 
      currentState.viewportState
    );
    
    // Determine what's at this position
    final hitTestResult = _hitTestService.hitTest(
      gridPosition, 
      currentState.renderingData
    );
    
    // Process through state machine
    final enrichedEvent = event.copyWith(
      gridPosition: gridPosition,
      hitTestResult: hitTestResult,
    );
    
    return _gestureStateMachine.process(enrichedEvent, currentState);
  }
}
```

### 2.2 Component Placement Service

**File**: `lib/application/services/component_placement_service.dart`

```dart
abstract class ComponentPlacementService {
  PlacementValidationResult validatePlacement(
    ComponentType type,
    GridPosition position,
    GameState gameState,
  );
  
  Future<PlacementExecutionResult> executeComponentPlacement(
    ComponentPlacementRequest request
  );
}

class DefaultComponentPlacementService implements ComponentPlacementService {
  final ComponentInventoryService _inventoryService;
  final GridValidationService _gridValidationService;
  final GameStateRepository _gameStateRepository;
  final EventBus _eventBus;

  @override
  PlacementValidationResult validatePlacement(
    ComponentType type,
    GridPosition position,
    GameState gameState,
  ) {
    // Business rule: Check inventory availability
    final inventoryCheck = _inventoryService.checkAvailability(type);
    if (!inventoryCheck.isValid) {
      return PlacementValidationResult.invalid(inventoryCheck.reason);
    }
    
    // Business rule: Check grid position validity
    final gridCheck = _gridValidationService.validatePosition(position, gameState);
    if (!gridCheck.isValid) {
      return PlacementValidationResult.invalid(gridCheck.reason);
    }
    
    // Business rule: Check placement constraints (level-specific rules)
    final constraintCheck = _validatePlacementConstraints(type, position, gameState);
    
    return constraintCheck;
  }

  @override
  Future<PlacementExecutionResult> executeComponentPlacement(
    ComponentPlacementRequest request
  ) async {
    // Validate before execution
    final validation = validatePlacement(
      request.componentType, 
      request.position, 
      request.currentGameState
    );
    
    if (!validation.isValid) {
      return PlacementExecutionResult.failed(validation.reason);
    }
    
    try {
      // Execute placement atomically
      final updatedGameState = await _gameStateRepository.placeComponent(
        request.componentType,
        request.position,
        request.currentGameState,
      );
      
      // Update inventory
      await _inventoryService.consumeComponent(request.componentType);
      
      // Emit domain event
      _eventBus.emit(ComponentPlacedEvent(
        componentType: request.componentType,
        position: request.position,
        timestamp: DateTime.now(),
      ));
      
      return PlacementExecutionResult.success(updatedGameState);
    } catch (e) {
      return PlacementExecutionResult.failed('Placement execution failed: $e');
    }
  }

  PlacementValidationResult _validatePlacementConstraints(
    ComponentType type,
    GridPosition position,
    GameState gameState,
  ) {
    // Example: Tutorial level constraints
    if (gameState.currentLevel?.metadata.difficulty == 'tutorial') {
      return _validateTutorialConstraints(type, position, gameState);
    }
    
    return PlacementValidationResult.valid();
  }
}
```

### 2.3 Canvas Rendering Service

**File**: `lib/application/services/canvas_rendering_service.dart`

```dart
abstract class CanvasRenderingService {
  CanvasRenderingData buildRenderingData(LevelDefinition level);
  ComponentRenderingData convertComponentsForPainter(List<ComponentModel> components);
  WireRenderingData convertConnectionsForPainter(Map<String, Set<String>> connections);
}

class DefaultCanvasRenderingService implements CanvasRenderingService {
  final ComponentModelToRenderingDataConverter _componentConverter;
  final ConnectionModelToRenderingDataConverter _connectionConverter;
  final GridConfigurationBuilder _gridConfigBuilder;

  @override
  CanvasRenderingData buildRenderingData(LevelDefinition level) {
    return CanvasRenderingData(
      components: convertComponentsForPainter(level.components.available),
      wires: convertConnectionsForPainter(level.connections ?? {}),
      gridConfiguration: _gridConfigBuilder.buildFromLevel(level),
      backgroundAssets: _buildBackgroundAssets(level),
      effectsData: _buildEffectsData(level),
    );
  }

  @override
  ComponentRenderingData convertComponentsForPainter(List<ComponentModel> components) {
    return ComponentRenderingData(
      circuitComponents: components
          .map(_componentConverter.convertToCircuitComponent)
          .toList(),
      selectionStates: _buildSelectionStates(components),
      animationStates: _buildAnimationStates(components),
    );
  }

  @override
  WireRenderingData convertConnectionsForPainter(
    Map<String, Set<String>> connections
  ) {
    final circuitWires = <CircuitWire>[];
    
    connections.forEach((sourceId, connectedIds) {
      for (final targetId in connectedIds) {
        if (sourceId.hashCode < targetId.hashCode) { // Avoid duplicates
          circuitWires.add(_connectionConverter.convert(sourceId, targetId));
        }
      }
    });
    
    return WireRenderingData(
      circuitWires: circuitWires,
      activeConnections: _determineActiveConnections(connections),
      animationData: _buildWireAnimations(connections),
    );
  }
}
```

## Phase 3: State Management Consolidation

### 3.1 Unified Canvas State

**File**: `lib/application/states/game_canvas_state.dart`

```dart
@freezed
class GameCanvasState with _$GameCanvasState {
  const factory GameCanvasState({
    required LevelDefinition? currentLevel,
    required CanvasRenderingData renderingData,
    required InteractionState interactionState,
    required ViewportState viewportState,
    required List<SideEffect> pendingSideEffects,
    @Default(false) bool isLoading,
    @Default(null) String? error,
    @Default({}) Map<String, dynamic> debugInfo,
  }) = _GameCanvasState;
  
  factory GameCanvasState.initial() => const GameCanvasState(
    currentLevel: null,
    renderingData: CanvasRenderingData.empty(),
    interactionState: InteractionState.idle(),
    viewportState: ViewportState.defaultViewport(),
    pendingSideEffects: [],
  );
}

@freezed
class InteractionState with _$InteractionState {
  const factory InteractionState({
    required GestureMode mode,
    @Default(null) String? selectedComponentId,
    @Default(null) String? draggedComponentId,
    @Default(null) ComponentType? placingComponentType,
    @Default(null) GridPosition? dragStartPosition,
    @Default(null) GridPosition? currentDragPosition,
  }) = _InteractionState;
  
  factory InteractionState.idle() => const InteractionState(
    mode: GestureMode.idle,
  );
}

@freezed
class ViewportState with _$ViewportState {
  const factory ViewportState({
    required double scale,
    required Offset panOffset,
    required Size canvasSize,
    required GridConfiguration gridConfiguration,
  }) = _ViewportState;
  
  factory ViewportState.defaultViewport() => const ViewportState(
    scale: 1.0,
    panOffset: Offset.zero,
    canvasSize: Size(800, 600),
    gridConfiguration: GridConfiguration.standard(),
  );
}
```

### 3.2 Viewport Service Replacement

**File**: `lib/application/services/viewport_service.dart`

```dart
abstract class ViewportService {
  ViewportState updatePan(ViewportState current, Offset delta);
  ViewportState updateScale(ViewportState current, double scaleDelta);
  ViewportState centerOnGrid(ViewportState current);
  ViewportState focusOnComponent(ViewportState current, GridPosition position);
}

class DefaultViewportService implements ViewportService {
  final ViewportConstraintsService _constraintsService;
  
  @override
  ViewportState updatePan(ViewportState current, Offset delta) {
    final newPanOffset = current.panOffset + delta;
    final constrainedOffset = _constraintsService.constrainPan(
      newPanOffset, 
      current
    );
    
    return current.copyWith(panOffset: constrainedOffset);
  }

  @override
  ViewportState updateScale(ViewportState current, double scaleDelta) {
    final newScale = (current.scale * scaleDelta).clamp(0.5, 3.0);
    final adjustedState = current.copyWith(scale: newScale);
    
    // Recalculate pan to keep content centered
    final recenteredState = _recenterAfterScale(adjustedState, current.scale);
    
    return recenteredState;
  }

  @override
  ViewportState centerOnGrid(ViewportState current) {
    final gridPixelSize = Size(
      current.gridConfiguration.cols * current.gridConfiguration.cellSize * current.scale,
      current.gridConfiguration.rows * current.gridConfiguration.cellSize * current.scale,
    );
    
    final centerOffset = Offset(
      (current.canvasSize.width - gridPixelSize.width) / 2,
      (current.canvasSize.height - gridPixelSize.height) / 2,
    );
    
    return current.copyWith(panOffset: centerOffset);
  }
}
```

## Phase 4: Gesture Handling Architecture

### 4.1 Gesture State Machine

**File**: `lib/application/services/gestures/gesture_state_machine.dart`

```dart
enum GestureMode { 
  idle, 
  panning, 
  draggingExistingComponent, 
  placingNewComponent, 
  drawingWire,
  multiTouchScaling 
}

class GestureStateMachine {
  GestureProcessingResult process(GestureInputEvent event, GameCanvasState state) {
    return switch ((state.interactionState.mode, event.type)) {
      // Idle state transitions
      (GestureMode.idle, GestureEventType.tapDown) => 
        _handleIdleTap(event, state),
      (GestureMode.idle, GestureEventType.longPressStart) => 
        _handleIdleLongPress(event, state),
      (GestureMode.idle, GestureEventType.dragStart) => 
        _handleIdleDragStart(event, state),
      
      // Dragging component transitions
      (GestureMode.draggingExistingComponent, GestureEventType.dragUpdate) => 
        _handleComponentDragUpdate(event, state),
      (GestureMode.draggingExistingComponent, GestureEventType.dragEnd) => 
        _handleComponentDragEnd(event, state),
      
      // Panning transitions
      (GestureMode.panning, GestureEventType.dragUpdate) => 
        _handleCanvasPanUpdate(event, state),
      (GestureMode.panning, GestureEventType.dragEnd) => 
        _handleCanvasPanEnd(event, state),
      
      // Multi-touch scaling
      (_, GestureEventType.scaleStart) when event.pointerCount > 1 => 
        _handleMultiTouchScaleStart(event, state),
      (GestureMode.multiTouchScaling, GestureEventType.scaleUpdate) => 
        _handleMultiTouchScaleUpdate(event, state),
      (GestureMode.multiTouchScaling, GestureEventType.scaleEnd) => 
        _handleMultiTouchScaleEnd(event, state),
      
      // Fallback
      _ => GestureProcessingResult.noChange(state),
    };
  }

  GestureProcessingResult _handleIdleTap(GestureInputEvent event, GameCanvasState state) {
    if (event.hitTestResult.hasComponent) {
      // Component selected
      final newInteractionState = state.interactionState.copyWith(
        selectedComponentId: event.hitTestResult.componentId,
      );
      
      return GestureProcessingResult(
        newState: state.copyWith(interactionState: newInteractionState),
        sideEffects: [
          FeedbackSideEffect(FeedbackType.componentSelected),
        ],
      );
    } else {
      // Empty space tapped - clear selection
      final newInteractionState = state.interactionState.copyWith(
        selectedComponentId: null,
      );
      
      return GestureProcessingResult(
        newState: state.copyWith(interactionState: newInteractionState),
        sideEffects: [],
      );
    }
  }

  GestureProcessingResult _handleIdleDragStart(GestureInputEvent event, GameCanvasState state) {
    if (event.hitTestResult.hasComponent) {
      // Start dragging existing component
      final newInteractionState = state.interactionState.copyWith(
        mode: GestureMode.draggingExistingComponent,
        draggedComponentId: event.hitTestResult.componentId,
        dragStartPosition: event.gridPosition,
        currentDragPosition: event.gridPosition,
      );
      
      return GestureProcessingResult(
        newState: state.copyWith(interactionState: newInteractionState),
        sideEffects: [
          FeedbackSideEffect(FeedbackType.dragStarted),
        ],
      );
    } else {
      // Start canvas panning
      final newInteractionState = state.interactionState.copyWith(
        mode: GestureMode.panning,
        dragStartPosition: event.gridPosition,
      );
      
      return GestureProcessingResult(
        newState: state.copyWith(interactionState: newInteractionState),
        sideEffects: [],
      );
    }
  }

  GestureProcessingResult _handleComponentDragUpdate(GestureInputEvent event, GameCanvasState state) {
    final newInteractionState = state.interactionState.copyWith(
      currentDragPosition: event.gridPosition,
    );
    
    return GestureProcessingResult(
      newState: state.copyWith(interactionState: newInteractionState),
      sideEffects: [
        ComponentDragUpdateSideEffect(
          componentId: state.interactionState.draggedComponentId!,
          newPosition: event.gridPosition!,
        ),
      ],
    );
  }
}
```

### 4.2 Gesture Input Events

**File**: `lib/application/services/gestures/gesture_input_event.dart`

```dart
@freezed
class GestureInputEvent with _$GestureInputEvent {
  const factory GestureInputEvent({
    required GestureEventType type,
    required Offset position,
    required int pointerCount,
    @Default(null) GridPosition? gridPosition,
    @Default(null) HitTestResult? hitTestResult,
    @Default(null) Offset? delta,
    @Default(null) double? scale,
  }) = _GestureInputEvent;

  factory GestureInputEvent.tapDown(Offset position) => GestureInputEvent(
    type: GestureEventType.tapDown,
    position: position,
    pointerCount: 1,
  );

  factory GestureInputEvent.dragStart(Offset position) => GestureInputEvent(
    type: GestureEventType.dragStart,
    position: position,
    pointerCount: 1,
  );

  factory GestureInputEvent.dragUpdate(Offset position, Offset delta) => GestureInputEvent(
    type: GestureEventType.dragUpdate,
    position: position,
    delta: delta,
    pointerCount: 1,
  );
}

enum GestureEventType {
  tapDown,
  longPressStart,
  dragStart,
  dragUpdate,
  dragEnd,
  scaleStart,
  scaleUpdate,
  scaleEnd,
}

@freezed
class GestureProcessingResult with _$GestureProcessingResult {
  const factory GestureProcessingResult({
    required GameCanvasState newState,
    required List<SideEffect> sideEffects,
  }) = _GestureProcessingResult;

  factory GestureProcessingResult.noChange(GameCanvasState currentState) =>
    GestureProcessingResult(
      newState: currentState,
      sideEffects: [],
    );
}
```

## Phase 5: Additional Refactoring Requirements

### 5.1 Painter Architecture Refactoring

**Current Problem**: Direct painter instantiation in build method

**File**: `lib/presentation/features/game/widgets/canvas_rendering_layer.dart`

```dart
abstract class CanvasRenderingLayer extends StatelessWidget {
  final CanvasRenderingData renderingData;
  final InteractionState interactionState;
  final ViewportState viewportState;
  
  const CanvasRenderingLayer({
    super.key,
    required this.renderingData,
    required this.interactionState,
    required this.viewportState,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Grid background layer
        CustomPaint(
          painter: _createGridPainter(),
          size: Size.infinite,
        ),
        
        // Components layer
        CustomPaint(
          painter: _createComponentsPainter(),
          size: Size.infinite,
        ),
        
        // Wires layer
        CustomPaint(
          painter: _createWiresPainter(),
          size: Size.infinite,
        ),
        
        // Interaction overlays layer
        CustomPaint(
          painter: _createInteractionPainter(),
          size: Size.infinite,
        ),
      ],
    );
  }

  // Factory methods for painters - dependency injection ready
  CustomPainter _createGridPainter() => GridBackgroundPainter(
    gridConfiguration: viewportState.gridConfiguration,
    viewportState: viewportState,
  );

  CustomPainter _createComponentsPainter() => CircuitComponentsPainter(
    renderingData: renderingData.components,
    interactionState: interactionState,
    viewportState: viewportState,
  );

  CustomPainter _createWiresPainter() => CircuitWiresPainter(
    renderingData: renderingData.wires,
    viewportState: viewportState,
  );

  CustomPainter _createInteractionPainter() => InteractionOverlaysPainter(
    interactionState: interactionState,
    viewportState: viewportState,
  );
}
```

### 5.2 Provider Architecture Consolidation

**File**: `lib/application/providers/game_canvas_providers.dart`

```dart
// ============================================================================
// GAME CANVAS ORCHESTRATION PROVIDERS
// ============================================================================

// Main orchestrator provider
final gameCanvasOrchestratorProvider = StateNotifierProvider.family<
  GameCanvasOrchestrator, 
  GameCanvasState,
  String  // levelId
>((ref, levelId) {
  return GameCanvasOrchestrator(
    interactionService: ref.watch(gameInteractionServiceProvider),
    placementService: ref.watch(componentPlacementServiceProvider),
    renderingService: ref.watch(canvasRenderingServiceProvider),
    levelCoordinator: ref.watch(levelCoordinatorProvider),
  );
});

// ============================================================================
// SERVICE PROVIDERS
// ============================================================================

// Interaction service provider
final gameInteractionServiceProvider = Provider<GameInteractionService>((ref) {
  return DefaultGameInteractionService(
    coordinateService: ref.watch(coordinateTransformationServiceProvider),
    gestureStateMachine: ref.watch(gestureStateMachineProvider),
    hitTestService: ref.watch(componentHitTestServiceProvider),
  );
});

// Component placement service provider
final componentPlacementServiceProvider = Provider<ComponentPlacementService>((ref) {
  return DefaultComponentPlacementService(
    inventoryService: ref.watch(componentInventoryServiceProvider),
    gridValidationService: ref.watch(gridValidationServiceProvider),
    gameStateRepository: ref.watch(gameStateRepositoryProvider),
    eventBus: ref.watch(eventBusProvider),
  );
});

// Canvas rendering service provider
final canvasRenderingServiceProvider = Provider<CanvasRenderingService>((ref) {
  return DefaultCanvasRenderingService(
    componentConverter: ref.watch(componentModelConverterProvider),
    connectionConverter: ref.watch(connectionModelConverterProvider),
    gridConfigBuilder: ref.watch(gridConfigurationBuilderProvider),
  );
});

// ============================================================================
// VIEWPORT PROVIDERS
// ============================================================================

// Coordinate transformation service provider
final coordinateTransformationServiceProvider = Provider<CoordinateTransformationService>((ref) {
  return DefaultCoordinateTransformationService();
});

// Viewport service provider
final viewportServiceProvider = Provider<ViewportService>((ref) {
  return DefaultViewportService(
    constraintsService: ref.watch(viewportConstraintsServiceProvider),
  );
});

// ============================================================================
// GESTURE PROVIDERS
// ============================================================================

// Gesture state machine provider
final gestureStateMachineProvider = Provider<GestureStateMachine>((ref) {
  return GestureStateMachine();
});

// Component hit test service provider
final componentHitTestServiceProvider = Provider<ComponentHitTestService>((ref) {
  return DefaultComponentHitTestService();
});
```

### 5.3 Legacy Provider Migration

**Files to Refactor**:
- `lib/application/game_engine/v3/providers_v3.dart` → Merge into specific domain providers
- `lib/application/providers/core_providers.dart` → Split by domain concern

**Migration Strategy**:
```dart
// Old approach (service locator anti-pattern)
final gameState = ref.read(enhancedGameStateNotifierProvider);
final paletteState = ref.read(paletteStateProvider(levelId));

// New approach (orchestrated)
final canvasState = ref.watch(gameCanvasOrchestratorProvider(levelId));
// All state is consolidated and managed by the orchestrator
```

## Phase 6: Testing Strategy

### 6.1 Unit Testing Services

```dart
// Each service can be tested in complete isolation
class GameInteractionServiceTest {
  late GameInteractionService service;
  late MockCoordinateTransformationService mockCoordinateService;
  late MockGestureStateMachine mockGestureStateMachine;
  late MockComponentHitTestService mockHitTestService;

  setUp() {
    mockCoordinateService = MockCoordinateTransformationService();
    mockGestureStateMachine = MockGestureStateMachine();
    mockHitTestService = MockComponentHitTestService();
    
    service = DefaultGameInteractionService(
      coordinateService: mockCoordinateService,
      gestureStateMachine: mockGestureStateMachine,
      hitTestService: mockHitTestService,
    );
  }

  test('processes tap on component correctly', () {
    // Arrange
    final event = GestureInputEvent.tapDown(Offset(100, 100));
    final state = GameCanvasState.initial();
    
    when(mockCoordinateService.screenToGrid(any, any))
        .thenReturn(GridPosition(1, 1));
    when(mockHitTestService.hitTest(any, any))
        .thenReturn(HitTestResult.component('component-123'));
    when(mockGestureStateMachine.process(any, any))
        .thenReturn(GestureProcessingResult(...));
    
    // Act
    final result = service.processGesture(event, state);
    
    // Assert
    expect(result.newState.interactionState.selectedComponentId, 'component-123');
    verify(mockCoordinateService.screenToGrid(event.position, state.viewportState));
    verify(mockHitTestService.hitTest(GridPosition(1, 1), state.renderingData));
  });
}
```

### 6.2 Integration Testing Orchestrator

```dart
class GameCanvasOrchestratorIntegrationTest {
  late ProviderContainer container;

  setUp() {
    container = ProviderContainer(
      overrides: [
        // Override with test implementations
        gameInteractionServiceProvider.overrideWithValue(MockGameInteractionService()),
        componentPlacementServiceProvider.overrideWithValue(MockComponentPlacementService()),
      ],
    );
  }

  test('initializes level correctly', () async {
    // Act
    await container
        .read(gameCanvasOrchestratorProvider('test-level').notifier)
        .initializeLevel('test-level');
    
    // Assert
    final state = container.read(gameCanvasOrchestratorProvider('test-level'));
    expect(state.isLoading, false);
    expect(state.currentLevel?.levelId, 'test-level');
  });
}
```

## Migration Implementation Timeline

### Week 1: Foundation Services
- [ ] Create `GameCanvasOrchestrator`
- [ ] Extract `GameInteractionService` interface and implementation
- [ ] Create `GestureStateMachine` and `GestureInputEvent` abstractions
- [ ] Basic unit tests for services

### Week 2: State Consolidation  
- [ ] Create unified `GameCanvasState` with Freezed
- [ ] Replace `GameCanvasController` with `ViewportService`
- [ ] Extract `ComponentPlacementService`
- [ ] Update provider architecture

### Week 3: UI Refactoring
- [ ] Split `GameCanvas` into focused widgets (`CanvasContainer`, `CanvasGestureLayer`, `CanvasRenderingLayer`)
- [ ] Create painter factory system
- [ ] Decouple gesture handling from UI widgets
- [ ] Integration testing

### Week 4: Performance & Validation
- [ ] Performance testing and optimization
- [ ] Complete unit test coverage
- [ ] End-to-end testing
- [ ] Documentation updates

## Success Metrics

### Before Refactoring
- **GameCanvas.dart**: 1,200+ lines
- **Responsibilities**: 7+ mixed concerns
- **Dependencies**: 15+ direct imports
- **Testability**: Monolithic, difficult to test
- **Maintainability**: High coupling, low cohesion

### After Refactoring
- **GameCanvas.dart**: <100 lines (pure UI widget)
- **Responsibilities**: Single responsibility (UI composition)
- **Services**: 6+ focused, testable services
- **Test Coverage**: >90% unit test coverage
- **Maintainability**: Loose coupling, high cohesion

This refactoring transforms the GameCanvas God Object into a clean, modular, and maintainable architecture while leveraging the existing project structure and maintaining all current functionality.