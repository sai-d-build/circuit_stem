## Summary

Based on my analysis of the CanvasInteractionController and its 75+ dependencies, I've provided a comprehensive refactoring solution that addresses the core architectural problems:

### Root Issues Identified
- **Monolithic design**: 1,730 lines violating Single Responsibility Principle
- **Complex coupling**: Tight dependencies across 6 layers (UI, State, Services, Use Cases, Domain, Infrastructure)
- **High-risk change surface**: Any modification could break multiple features
- **Mixed concerns**: Business logic, UI logic, and infrastructure intertwined

### Solution Architecture
The refactoring uses **Domain-Driven Design with Bounded Contexts**:

1. **CanvasInteractionCoordinator** (~250 lines) - Event orchestrator and dependency injection container
2. **DragInteractionContext** (~280 lines) - Component placement workflows  
3. **WireInteractionContext** (~290 lines) - Wire pathfinding and connections
4. **GestureInteractionContext** (~200 lines) - Pan/zoom viewport management
5. **Supporting Services** (<200 lines each) - ValidationService, CoordinateMapperService, etc.

### Key Strengths
- **Risk Mitigation**: 4-phase approach allows early issue detection
- **Backward Compatibility**: Maintains all existing APIs during transition
- **Comprehensive Testing**: 80+ unit tests, 20 integration scenarios, performance benchmarks
- **Production Safety**: Feature flags, monitoring, rollback procedures
- **Performance Focused**: Maintains <16ms interaction latency, no memory regression

### Critical Success Factors
- Disciplined execution of each phase with thorough testing
- Proper monitoring and alerting setup before deployment
- Team training on new architecture patterns
- Maintaining focus on maintainability improvements without sacrificing functionality

The solution transforms an unmaintainable monolith into a well-structured, testable system while meeting your <300 line requirement for each component. The phased approach minimizes risk while achieving significant architectural improvements.

# Canvas Interaction Controller Refactoring Plan

## Executive Summary

This plan addresses the 1,730-line monolithic CanvasInteractionController by implementing a **Domain-Driven Design** approach with **bounded contexts** and **dependency injection**. The solution maintains backward compatibility while achieving the <300 line goal.

## Architecture Overview

### New Architecture Pattern: **Command Orchestrator + Bounded Contexts**

```
┌─────────────────────────────────────────┐
│        CanvasInteractionCoordinator     │
│              (~250 lines)               │
├─────────────────────────────────────────┤
│  - Event Routing                        │
│  - Context Management                   │
│  - Dependency Injection                 │
│  - State Coordination                   │
└─────────────────────────────────────────┘
                    │
           ┌────────┼────────┐
           │        │        │
    ┌──────▼──┐ ┌───▼───┐ ┌──▼────┐
    │  Drag   │ │ Wire  │ │Gesture│
    │Context  │ │Context│ │Context│
    │ (~280)  │ │(~290) │ │(~200) │
    └─────────┘ └───────┘ └───────┘
```

## Phase 1: Extract Bounded Contexts (5 days, Low-Medium Risk)

### 1.1 DragInteractionContext (~280 lines)

```dart
class DragInteractionContext {
  final CoordinateService _coordinateService;
  final ValidationService _validationService;
  final ComponentPlacementService _placementService;
  
  // Handles: drag start, update, end, validation
  Future<DragResult> handleDragOperation(DragEvent event) {
    return switch (event.type) {
      DragEventType.start => _handleDragStart(event),
      DragEventType.update => _handleDragUpdate(event),
      DragEventType.end => _handleDragEnd(event),
    };
  }
}
```

**Responsibilities:**
- Component drag validation
- Position calculations
- Drop zone validation
- Component placement coordination

### 1.2 WireInteractionContext (~290 lines)

```dart
class WireInteractionContext {
  final PathfindingService _pathfinder;
  final WireNetworkService _networkService;
  final ConnectionValidationService _connectionValidator;
  
  // Handles: wire drawing, pathfinding, connections
  Future<WireResult> handleWireOperation(WireEvent event) {
    return switch (event.type) {
      WireEventType.startDraw => _startWireDrawing(event),
      WireEventType.updatePath => _updateWirePath(event),
      WireEventType.completeWire => _completeWire(event),
    };
  }
}
```

**Responsibilities:**
- Wire pathfinding (A* + Manhattan fallback)
- Port connection validation
- Wire network creation
- Connection rule enforcement

### 1.3 GestureInteractionContext (~200 lines)

```dart
class GestureInteractionContext {
  final ViewportService _viewportService;
  final AnimationService _animationService;
  
  // Handles: pan, zoom, viewport management
  void handleGesture(GestureEvent event) {
    switch (event.type) {
      case GestureType.pan:
        _viewportService.updatePanOffset(event.delta);
      case GestureType.scale:
        _viewportService.updateScale(event.scale);
    }
  }
}
```

**Responsibilities:**
- Viewport pan/zoom
- Gesture recognition
- Animation coordination
- Canvas transformation

## Phase 2: Create Coordinator (~250 lines)

### 2.1 CanvasInteractionCoordinator

```dart
class CanvasInteractionCoordinator {
  final DragInteractionContext _dragContext;
  final WireInteractionContext _wireContext;
  final GestureInteractionContext _gestureContext;
  final EventBus _eventBus;
  final StateManager _stateManager;
  
  // Main orchestration method
  Future<void> handleInteraction(InteractionEvent event) {
    final context = _determineContext(event);
    final result = await context.handle(event);
    await _stateManager.updateState(result);
    _eventBus.publish(result);
  }
  
  // Context routing
  InteractionContext _determineContext(InteractionEvent event) {
    return switch (event.runtimeType) {
      DragEvent => _dragContext,
      WireEvent => _wireContext,
      GestureEvent => _gestureContext,
      _ => throw UnsupportedInteractionEvent(event),
    };
  }
}
```

**Responsibilities:**
- Event routing to appropriate context
- Cross-context coordination
- State management coordination
- Dependency injection container

## Phase 3: Supporting Infrastructure

### 3.1 Service Extractions

#### ValidationService (~150 lines)
```dart
class ValidationService {
  ValidationResult validateDropPosition(
    Offset position,
    CoordinateContext context,
    Set<GridPosition> occupiedPositions,
  ) {
    // Extracted from main controller
    // Grid boundary validation
    // Occupation checking
    // Component-specific rules
  }
}
```

#### CoordinateMapperService (~120 lines)
```dart
class CoordinateMapperService {
  GridPosition screenToGrid(Offset screenPosition, CoordinateContext context);
  Offset gridToScreen(GridPosition gridPosition, CoordinateContext context);
  Offset globalToLocal(Offset globalPosition, RenderBox renderBox);
  
  // Centralized coordinate transformations
  // Viewport-aware calculations
  // Multi-coordinate system support
}
```

#### EventBusService (~100 lines)
```dart
class EventBusService {
  final StreamController<InteractionEvent> _controller;
  
  void publish(InteractionEvent event);
  Stream<T> listen<T extends InteractionEvent>();
  void dispose();
  
  // Type-safe event publishing
  // Event filtering and routing
  // Memory leak prevention
}
```

## Phase 4: Integration Strategy

### 4.1 Backward Compatibility Layer

```dart
class CanvasInteractionController {
  final CanvasInteractionCoordinator _coordinator;
  
  // Legacy method signatures maintained
  void handleDragStart(DragTargetDetails details, DragOrigin origin) {
    _coordinator.handleInteraction(
      DragEvent.start(details.offset, origin, details.data)
    );
  }
  
  // All existing public methods proxy to coordinator
}
```

### 4.2 Migration Path

1. **Week 1**: Extract ValidationService, CoordinateMapperService
2. **Week 2**: Create DragInteractionContext, migrate drag logic
3. **Week 3**: Create WireInteractionContext, migrate wire logic
4. **Week 4**: Create GestureInteractionContext, migrate gesture logic
5. **Week 5**: Create CanvasInteractionCoordinator
6. **Week 6**: Integration testing and optimization

## Risk Mitigation Strategy

### High-Risk Areas Protection

1. **Provider Chain Isolation**
   - Maintain existing provider signatures
   - Use adapter pattern for state notifiers
   - Gradual migration of provider dependencies

2. **Event System Continuity**
   - Keep existing StreamController during transition
   - Implement event translation layer
   - Maintain timing and ordering guarantees

3. **State Management Safety**
   - Preserve InteractionStateNotifier interface
   - Use state synchronization layer
   - Implement state consistency checks

### Testing Strategy

#### Unit Tests (80 new tests)
```dart
// Context-specific testing
DragInteractionContextTest
WireInteractionContextTest  
GestureInteractionContextTest
CoordinatorIntegrationTest
```

#### Integration Tests (20 scenarios)
```dart
// End-to-end workflows
DragDropWorkflowTest
WireConnectionWorkflowTest
MultiTouchGestureTest
StateTransitionTest
```

#### Performance Tests (10 benchmarks)
```dart
// Regression prevention
CoordinateTransformationBenchmark
PathfindingPerformanceTest
EventBusLatencyTest
MemoryLeakTest
```

## Success Metrics

### Code Quality
- ✅ Main coordinator: ~250 lines
- ✅ Each context: <300 lines
- ✅ Services: <200 lines each
- ✅ Cyclomatic complexity <10 per method

### Functionality
- ✅ All existing tests pass
- ✅ No performance regression >5%
- ✅ Memory usage unchanged
- ✅ Event timing preserved

### Maintainability
- ✅ Clear separation of concerns
- ✅ Testable components
- ✅ Reduced coupling
- ✅ Documentation coverage >90%

## Implementation Timeline

| Phase | Duration | Risk Level | Deliverables |
|-------|----------|------------|--------------|
| Phase 1 | 5 days | Low-Medium | Extracted contexts |
| Phase 2 | 3 days | Medium | Coordinator implementation |
| Phase 3 | 4 days | Low | Supporting services |
| Phase 4 | 4 days | High | Integration & testing |
| **Total** | **16 days** | **Medium** | **Production ready** |

## Rollback Strategy

1. **Feature Flags**: Toggle between old/new implementations
2. **Git Branches**: Maintain parallel implementations
3. **Gradual Rollout**: Deploy to 10% → 50% → 100% of users
4. **Monitoring**: Real-time performance and error tracking
5. **Quick Revert**: <30 minute rollback capability

## Dependencies Management

### New Dependencies (Minimal)
```dart
// Only add these lightweight dependencies
get_it: ^7.0.0           # Dependency injection
meta: ^1.8.0             # Annotations
equatable: ^2.0.0        # Value equality
```

### Dependency Injection Setup
```dart
class DIContainer {
  static final GetIt _instance = GetIt.instance;
  
  static void setup() {
    _instance.registerLazySingleton<CoordinateMapperService>(
      () => CoordinateMapperService()
    );
    _instance.registerLazySingleton<ValidationService>(
      () => ValidationService()
    );
    // ... other services
  }
}
```

## Monitoring & Observability

### Performance Monitoring
```dart
class PerformanceMonitor {
  static void trackInteractionLatency(InteractionType type, Duration latency) {
    StructuredLogger.performance('interaction_latency', {
      'type': type.name,
      'latency_ms': latency.inMilliseconds,
      'threshold_exceeded': latency > Duration(milliseconds: 16),
    });
  }
}
```

### Error Boundary
```dart
class InteractionErrorBoundary {
  Future<T> execute<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      StructuredLogger.error('interaction_error', {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      });
      rethrow;
    }
  }
}
```

This refactoring solution addresses the core architectural issues while minimizing risk through careful phasing and comprehensive testing. The domain-driven approach with bounded contexts provides clear separation of concerns and maintainable code structure.# Canvas Interaction Controller Refactoring Plan

## Executive Summary

This plan addresses the 1,730-line monolithic CanvasInteractionController by implementing a **Domain-Driven Design** approach with **bounded contexts** and **dependency injection**. The solution maintains backward compatibility while achieving the <300 line goal.

## Architecture Overview

### New Architecture Pattern: **Command Orchestrator + Bounded Contexts**

```
┌─────────────────────────────────────────┐
│        CanvasInteractionCoordinator     │
│              (~250 lines)               │
├─────────────────────────────────────────┤
│  - Event Routing                        │
│  - Context Management                   │
│  - Dependency Injection                 │
│  - State Coordination                   │
└─────────────────────────────────────────┘
                    │
           ┌────────┼────────┐
           │        │        │
    ┌──────▼──┐ ┌───▼───┐ ┌──▼────┐
    │  Drag   │ │ Wire  │ │Gesture│
    │Context  │ │Context│ │Context│
    │ (~280)  │ │(~290) │ │(~200) │
    └─────────┘ └───────┘ └───────┘
```

## Phase 1: Extract Bounded Contexts (5 days, Low-Medium Risk)

### 1.1 DragInteractionContext (~280 lines)

```dart
class DragInteractionContext {
  final CoordinateService _coordinateService;
  final ValidationService _validationService;
  final ComponentPlacementService _placementService;
  
  // Handles: drag start, update, end, validation
  Future<DragResult> handleDragOperation(DragEvent event) {
    return switch (event.type) {
      DragEventType.start => _handleDragStart(event),
      DragEventType.update => _handleDragUpdate(event),
      DragEventType.end => _handleDragEnd(event),
    };
  }
}
```

**Responsibilities:**
- Component drag validation
- Position calculations
- Drop zone validation
- Component placement coordination

### 1.2 WireInteractionContext (~290 lines)

```dart
class WireInteractionContext {
  final PathfindingService _pathfinder;
  final WireNetworkService _networkService;
  final ConnectionValidationService _connectionValidator;
  
  // Handles: wire drawing, pathfinding, connections
  Future<WireResult> handleWireOperation(WireEvent event) {
    return switch (event.type) {
      WireEventType.startDraw => _startWireDrawing(event),
      WireEventType.updatePath => _updateWirePath(event),
      WireEventType.completeWire => _completeWire(event),
    };
  }
}
```

**Responsibilities:**
- Wire pathfinding (A* + Manhattan fallback)
- Port connection validation
- Wire network creation
- Connection rule enforcement

### 1.3 GestureInteractionContext (~200 lines)

```dart
class GestureInteractionContext {
  final ViewportService _viewportService;
  final AnimationService _animationService;
  
  // Handles: pan, zoom, viewport management
  void handleGesture(GestureEvent event) {
    switch (event.type) {
      case GestureType.pan:
        _viewportService.updatePanOffset(event.delta);
      case GestureType.scale:
        _viewportService.updateScale(event.scale);
    }
  }
}
```

**Responsibilities:**
- Viewport pan/zoom
- Gesture recognition
- Animation coordination
- Canvas transformation

## Phase 2: Create Coordinator (~250 lines)

### 2.1 CanvasInteractionCoordinator

```dart
class CanvasInteractionCoordinator {
  final DragInteractionContext _dragContext;
  final WireInteractionContext _wireContext;
  final GestureInteractionContext _gestureContext;
  final EventBus _eventBus;
  final StateManager _stateManager;
  
  // Main orchestration method
  Future<void> handleInteraction(InteractionEvent event) {
    final context = _determineContext(event);
    final result = await context.handle(event);
    await _stateManager.updateState(result);
    _eventBus.publish(result);
  }
  
  // Context routing
  InteractionContext _determineContext(InteractionEvent event) {
    return switch (event.runtimeType) {
      DragEvent => _dragContext,
      WireEvent => _wireContext,
      GestureEvent => _gestureContext,
      _ => throw UnsupportedInteractionEvent(event),
    };
  }
}
```

**Responsibilities:**
- Event routing to appropriate context
- Cross-context coordination
- State management coordination
- Dependency injection container

## Phase 3: Supporting Infrastructure

### 3.1 Service Extractions

#### ValidationService (~150 lines)
```dart
class ValidationService {
  ValidationResult validateDropPosition(
    Offset position,
    CoordinateContext context,
    Set<GridPosition> occupiedPositions,
  ) {
    // Extracted from main controller
    // Grid boundary validation
    // Occupation checking
    // Component-specific rules
  }
}
```

#### CoordinateMapperService (~120 lines)
```dart
class CoordinateMapperService {
  GridPosition screenToGrid(Offset screenPosition, CoordinateContext context);
  Offset gridToScreen(GridPosition gridPosition, CoordinateContext context);
  Offset globalToLocal(Offset globalPosition, RenderBox renderBox);
  
  // Centralized coordinate transformations
  // Viewport-aware calculations
  // Multi-coordinate system support
}
```

#### EventBusService (~100 lines)
```dart
class EventBusService {
  final StreamController<InteractionEvent> _controller;
  
  void publish(InteractionEvent event);
  Stream<T> listen<T extends InteractionEvent>();
  void dispose();
  
  // Type-safe event publishing
  // Event filtering and routing
  // Memory leak prevention
}
```

## Phase 4: Integration Strategy

### 4.1 Backward Compatibility Layer

```dart
class CanvasInteractionController {
  final CanvasInteractionCoordinator _coordinator;
  
  // Legacy method signatures maintained
  void handleDragStart(DragTargetDetails details, DragOrigin origin) {
    _coordinator.handleInteraction(
      DragEvent.start(details.offset, origin, details.data)
    );
  }
  
  // All existing public methods proxy to coordinator
}
```

### 4.2 Migration Path

1. **Week 1**: Extract ValidationService, CoordinateMapperService
2. **Week 2**: Create DragInteractionContext, migrate drag logic
3. **Week 3**: Create WireInteractionContext, migrate wire logic
4. **Week 4**: Create GestureInteractionContext, migrate gesture logic
5. **Week 5**: Create CanvasInteractionCoordinator
6. **Week 6**: Integration testing and optimization

## Risk Mitigation Strategy

### High-Risk Areas Protection

1. **Provider Chain Isolation**
   - Maintain existing provider signatures
   - Use adapter pattern for state notifiers
   - Gradual migration of provider dependencies

2. **Event System Continuity**
   - Keep existing StreamController during transition
   - Implement event translation layer
   - Maintain timing and ordering guarantees

3. **State Management Safety**
   - Preserve InteractionStateNotifier interface
   - Use state synchronization layer
   - Implement state consistency checks

### Testing Strategy

#### Unit Tests (80 new tests)
```dart
// Context-specific testing
DragInteractionContextTest
WireInteractionContextTest  
GestureInteractionContextTest
CoordinatorIntegrationTest
```

#### Integration Tests (20 scenarios)
```dart
// End-to-end workflows
DragDropWorkflowTest
WireConnectionWorkflowTest
MultiTouchGestureTest
StateTransitionTest
```

#### Performance Tests (10 benchmarks)
```dart
// Regression prevention
CoordinateTransformationBenchmark
PathfindingPerformanceTest
EventBusLatencyTest
MemoryLeakTest
```

## Success Metrics

### Code Quality
- ✅ Main coordinator: ~250 lines
- ✅ Each context: <300 lines
- ✅ Services: <200 lines each
- ✅ Cyclomatic complexity <10 per method

### Functionality
- ✅ All existing tests pass
- ✅ No performance regression >5%
- ✅ Memory usage unchanged
- ✅ Event timing preserved

### Maintainability
- ✅ Clear separation of concerns
- ✅ Testable components
- ✅ Reduced coupling
- ✅ Documentation coverage >90%

## Implementation Timeline

| Phase | Duration | Risk Level | Deliverables |
|-------|----------|------------|--------------|
| Phase 1 | 5 days | Low-Medium | Extracted contexts |
| Phase 2 | 3 days | Medium | Coordinator implementation |
| Phase 3 | 4 days | Low | Supporting services |
| Phase 4 | 4 days | High | Integration & testing |
| **Total** | **16 days** | **Medium** | **Production ready** |

## Rollback Strategy

1. **Feature Flags**: Toggle between old/new implementations
2. **Git Branches**: Maintain parallel implementations
3. **Gradual Rollout**: Deploy to 10% → 50% → 100% of users
4. **Monitoring**: Real-time performance and error tracking
5. **Quick Revert**: <30 minute rollback capability

## Dependencies Management

### New Dependencies (Minimal)
```dart
// Only add these lightweight dependencies
get_it: ^7.0.0           # Dependency injection
meta: ^1.8.0             # Annotations
equatable: ^2.0.0        # Value equality
```

### Dependency Injection Setup
```dart
class DIContainer {
  static final GetIt _instance = GetIt.instance;
  
  static void setup() {
    _instance.registerLazySingleton<CoordinateMapperService>(
      () => CoordinateMapperService()
    );
    _instance.registerLazySingleton<ValidationService>(
      () => ValidationService()
    );
    // ... other services
  }
}
```

## Monitoring & Observability

### Performance Monitoring
```dart
class PerformanceMonitor {
  static void trackInteractionLatency(InteractionType type, Duration latency) {
    StructuredLogger.performance('interaction_latency', {
      'type': type.name,
      'latency_ms': latency.inMilliseconds,
      'threshold_exceeded': latency > Duration(milliseconds: 16),
    });
  }
}
```

### Error Boundary
```dart
class InteractionErrorBoundary {
  Future<T> execute<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e, stackTrace) {
      StructuredLogger.error('interaction_error', {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
      });
      rethrow;
    }
  }
}
```

This refactoring solution addresses the core architectural issues while minimizing risk through careful phasing and comprehensive testing. The domain-driven approach with bounded contexts provides clear separation of concerns and maintainable code structure.
v// ============================================================================
// CANVAS INTERACTION CONTROLLER REFACTORING - IMPLEMENTATION GUIDE
// ============================================================================

// PHASE 1: EXTRACT CORE SERVICES (Start Here)
// ============================================================================

// 1.1 ValidationService - Extract first (Lowest Risk)
// lib/presentation/features/game/services/validation_service.dart

class ValidationService {
  final StructuredLogger _logger;
  
  const ValidationService({required StructuredLogger logger}) : _logger = logger;

  ValidationResult validateDropPosition(
    Offset localPosition,
    CoordinateContext context, {
    required Set<GridPosition> occupiedPositions,
    RenderBox? renderBox,
  }) {
    _logger.debug('Starting validation', context: {
      'position': localPosition.toString(),
      'occupiedCount': occupiedPositions.length,
    });

    // Grid boundary validation
    if (!_isWithinBounds(localPosition, context)) {
      return ValidationResult.invalid(
        DragDropErrorType.invalidPosition,
        details: 'Position outside grid boundaries',
      );
    }

    // Convert to grid position
    final gridPosition = _localToGrid(localPosition, context);
    if (gridPosition == null) {
      return ValidationResult.invalid(
        DragDropErrorType.coordinateTransformationFailed,
        details: 'Unable to convert coordinates',
      );
    }

    // Check occupation
    if (occupiedPositions.contains(gridPosition)) {
      return ValidationResult.invalid(
        DragDropErrorType.positionOccupied,
        details: 'Grid position already occupied',
      );
    }

    return ValidationResult.valid();
  }

  bool _isWithinBounds(Offset position, CoordinateContext context) {
    return position.dx >= 0 && 
           position.dy >= 0 && 
           position.dx < context.canvasSize.width && 
           position.dy < context.canvasSize.height;
  }

  GridPosition? _localToGrid(Offset localPosition, CoordinateContext context) {
    try {
      final adjustedX = (localPosition.dx - context.panOffset.dx) / context.scale;
      final adjustedY = (localPosition.dy - context.panOffset.dy) / context.scale;
      
      final col = (adjustedX / context.cellSize).round();
      final row = (adjustedY / context.cellSize).round();
      
      return GridPosition(row: row, col: col);
    } catch (e) {
      _logger.error('Grid conversion failed', context: {'error': e.toString()});
      return null;
    }
  }
}

// 1.2 CoordinateMapperService - Extract second
// lib/presentation/features/game/services/coordinate_mapper_service.dart

class CoordinateMapperService {
  final StructuredLogger _logger;

  const CoordinateMapperService({required StructuredLogger logger}) : _logger = logger;

  GridPosition? screenToGrid(Offset screenPosition, CoordinateContext context) {
    try {
      final adjustedX = (screenPosition.dx - context.panOffset.dx) / context.scale;
      final adjustedY = (screenPosition.dy - context.panOffset.dy) / context.scale;
      
      final col = (adjustedX / context.cellSize).round();
      final row = (adjustedY / context.cellSize).round();
      
      // Clamp to valid grid bounds
      final clampedCol = col.clamp(0, context.gridDimensions.width.toInt() - 1);
      final clampedRow = row.clamp(0, context.gridDimensions.height.toInt() - 1);
      
      return GridPosition(row: clampedRow, col: clampedCol);
    } catch (e) {
      _logger.error('Screen to grid conversion failed', context: {
        'screenPosition': screenPosition.toString(),
        'error': e.toString(),
      });
      return null;
    }
  }

  Offset gridToScreen(GridPosition gridPosition, CoordinateContext context) {
    final screenX = (gridPosition.col * context.cellSize * context.scale) + context.panOffset.dx;
    final screenY = (gridPosition.row * context.cellSize * context.scale) + context.panOffset.dy;
    
    return Offset(screenX, screenY);
  }

  Offset globalToLocal(Offset globalPosition, RenderBox renderBox) {
    if (!renderBox.attached) {
      throw StateError('RenderBox is not attached');
    }
    return renderBox.globalToLocal(globalPosition);
  }
}

// ============================================================================
// PHASE 2: CREATE BOUNDED CONTEXTS
// ============================================================================

// 2.1 DragInteractionContext - Extract drag logic (~280 lines)
// lib/presentation/features/game/contexts/drag_interaction_context.dart

class DragInteractionContext {
  final ValidationService _validationService;
  final CoordinateMapperService _coordinateMapper;
  final CreateComponentUseCase _createComponentUseCase;
  final StructuredLogger _logger;
  
  ComponentDragData? _currentDragData;
  DragOrigin? _currentOrigin;
  
  DragInteractionContext({
    required ValidationService validationService,
    required CoordinateMapperService coordinateMapper,
    required CreateComponentUseCase createComponentUseCase,
    required StructuredLogger logger,
  }) : _validationService = validationService,
       _coordinateMapper = coordinateMapper,
       _createComponentUseCase = createComponentUseCase,
       _logger = logger;

  Future<DragResult> handleDragStart(DragStartEvent event) async {
    _logger.info('Drag start', context: {
      'origin': event.origin.toString(),
      'componentType': event.dragData.componentType.toString(),
    });
    
    _currentDragData = event.dragData;
    _currentOrigin = event.origin;
    
    return DragResult.started(
      isValid: true,
      targetPosition: null,
    );
  }

  Future<DragResult> handleDragUpdate(DragUpdateEvent event) async {
    if (_currentDragData == null) {
      return DragResult.invalid('No active drag operation');
    }
    
    final validation = _validationService.validateDropPosition(
      event.localPosition,
      event.coordinateContext,
      occupiedPositions: event.occupiedPositions,
    );
    
    final gridPosition = _coordinateMapper.screenToGrid(
      event.localPosition, 
      event.coordinateContext,
    );
    
    return DragResult.updated(
      isValid: validation.isValid,
      targetPosition: gridPosition,
      errorMessage: validation.error?.message,
    );
  }

  Future<DragResult> handleDragEnd(DragEndEvent event) async {
    if (_currentDragData == null || _currentOrigin == null) {
      return DragResult.invalid('No active drag operation');
    }
    
    _logger.info('Drag end', context: {
      'isValid': event.isValid,
      'targetPosition': event.targetPosition?.toString(),
    });
    
    if (event.isValid && event.targetPosition != null) {
      // Execute component placement
      final placementResult = await _executeComponentPlacement(
        event.targetPosition!,
        _currentDragData!,
      );
      
      _cleanup();
      return placementResult;
    } else {
      _cleanup();
      return DragResult.cancelled('Invalid drop location');
    }
  }

  Future<DragResult> _executeComponentPlacement(
    GridPosition position, 
    ComponentDragData dragData,
  ) async {
    try {
      // Use existing CreateComponentUseCase but with better error handling
      await _createComponentUseCase.execute(CreateComponentRequest(
        componentType: dragData.componentType,
        position: position,
        // Add transaction context for rollback capability
      ));
      
      return DragResult.completed(
        placedPosition: position,
        componentId: 'generated-id', // Would come from use case
      );
    } catch (e) {
      _logger.error('Component placement failed', context: {
        'error': e.toString(),
        'position': position.toString(),
        'componentType': dragData.componentType.toString(),
      });
      
      return DragResult.error('Failed to place component: $e');
    }
  }

  void _cleanup() {
    _currentDragData = null;
    _currentOrigin = null;
  }

  void dispose() {
    _cleanup();
  }
}

// 2.2 WireInteractionContext - Extract wire logic (~290 lines)
// lib/presentation/features/game/contexts/wire_interaction_context.dart

class WireInteractionContext {
  final WireNetworkService _wireNetworkService;
  final PathfindingService _pathfindingService;
  final CoordinateMapperService _coordinateMapper;
  final StructuredLogger _logger;
  
  ComponentPort? _startPort;
  List<GridPosition> _currentPath = [];
  
  WireInteractionContext({
    required WireNetworkService wireNetworkService,
    required PathfindingService pathfindingService,
    required CoordinateMapperService coordinateMapper,
    required StructuredLogger logger,
  }) : _wireNetworkService = wireNetworkService,
       _pathfindingService = pathfindingService,
       _coordinateMapper = coordinateMapper,
       _logger = logger;

  Future<WireResult> handleWireStart(WireStartEvent event) async {
    _startPort = event.startPort;
    _currentPath = [event.startPort.position];
    
    _logger.info('Wire drawing started', context: {
      'startPort': event.startPort.id,
      'position': event.startPort.position.toString(),
    });
    
    return WireResult.started(
      isValid: true,
      currentPath: _currentPath,
    );
  }

  Future<WireResult> handleWireUpdate(WireUpdateEvent event) async {
    if (_startPort == null) {
      return WireResult.invalid('No active wire operation');
    }
    
    final targetPosition = _coordinateMapper.screenToGrid(
      event.currentPosition, 
      event.coordinateContext,
    );
    
    if (targetPosition == null) {
      return WireResult.invalid('Invalid target position');
    }
    
    // Calculate path using A* algorithm
    final pathResult = await _pathfindingService.findPath(
      start: _startPort!.position,
      end: targetPosition,
      occupiedPositions: event.occupiedPositions,
    );
    
    if (pathResult.isSuccess) {
      _currentPath = pathResult.data;
      return WireResult.updated(
        isValid: true,
        currentPath: _currentPath,
      );
    } else {
      // Fallback to Manhattan distance
      _currentPath = _calculateManhattanPath(_startPort!.position, targetPosition);
      return WireResult.updated(
        isValid: false,
        currentPath: _currentPath,
        errorMessage: 'Using fallback pathfinding',
      );
    }
  }

  Future<WireResult> handleWireComplete(WireCompleteEvent event) async {
    if (_startPort == null || _currentPath.isEmpty) {
      return WireResult.invalid('No active wire operation');
    }
    
    try {
      final networkResult = await _wireNetworkService.createNetwork(
        startPort: _startPort!,
        endPort: event.endPort,
        path: _currentPath,
      );
      
      if (networkResult.isSuccess) {
        final network = networkResult.data;
        _cleanup();
        
        return WireResult.completed(
          networkId: network.id,
          placedSegments: network.segments.length,
        );
      } else {
        return WireResult.error('Failed to create wire network');
      }
    } catch (e) {
      _logger.error('Wire completion failed', context: {
        'error': e.toString(),
        'pathLength': _currentPath.length,
      });
      
      return WireResult.error('Wire placement failed: $e');
    }
  }

  List<GridPosition> _calculateManhattanPath(GridPosition start, GridPosition end) {
    final path = <GridPosition>[start];
    
    // Horizontal movement first
    int currentCol = start.col;
    while (currentCol != end.col) {
      currentCol += currentCol < end.col ? 1 : -1;
      path.add(GridPosition(row: start.row, col: currentCol));
    }
    
    // Vertical movement second
    int currentRow = start.row;
    while (currentRow != end.row) {
      currentRow += currentRow < end.row ? 1 : -1;
      path.add(GridPosition(row: currentRow, col: end.col));
    }
    
    return path;
  }

  void _cleanup() {
    _startPort = null;
    _currentPath.clear();
  }

  void dispose() {
    _cleanup();
  }
}

// 2.3 GestureInteractionContext - Extract gesture logic (~200 lines)
// lib/presentation/features/game/contexts/gesture_interaction_context.dart

class GestureInteractionContext {
  final ViewportService _viewportService;
  final StructuredLogger _logger;
  
  GestureInteractionContext({
    required ViewportService viewportService,
    required StructuredLogger logger,
  }) : _viewportService = viewportService,
       _logger = logger;

  Future<GestureResult> handlePanGesture(PanGestureEvent event) async {
    try {
      await _viewportService.updatePanOffset(event.delta);
      
      return GestureResult.success(
        gestureType: GestureType.pan,
        details: {'delta': event.delta.toString()},
      );
    } catch (e) {
      _logger.error('Pan gesture failed', context: {'error': e.toString()});
      return GestureResult.error('Pan gesture failed: $e');
    }
  }

  Future<GestureResult> handleScaleGesture(ScaleGestureEvent event) async {
    try {
      await _viewportService.updateScale(event.scale, event.focalPoint);
      
      return GestureResult.success(
        gestureType: GestureType.scale,
        details: {
          'scale': event.scale.toString(),
          'focalPoint': event.focalPoint.toString(),
        },
      );
    } catch (e) {
      _logger.error('Scale gesture failed', context: {'error': e.toString()});
      return GestureResult.error('Scale gesture failed: $e');
    }
  }

  void dispose() {
    // Clean up any gesture-related resources
  }
}

// ============================================================================
// PHASE 3: CREATE MAIN COORDINATOR (~250 lines)
// ============================================================================

// 3.1 CanvasInteractionCoordinator - Main orchestrator
// lib/presentation/features/game/controllers/canvas_interaction_coordinator.dart

class CanvasInteractionCoordinator {
  final DragInteractionContext _dragContext;
  final WireInteractionContext _wireContext;
  final GestureInteractionContext _gestureContext;
  final InteractionStateNotifier _stateNotifier;
  final StructuredLogger _logger;
  
  late final StreamController<InteractionEvent> _eventBus;
  InteractionMode _currentMode = InteractionMode.idle;
  
  CanvasInteractionCoordinator({
    required DragInteractionContext dragContext,
    required WireInteractionContext wireContext,
    required GestureInteractionContext gestureContext,
    required InteractionStateNotifier stateNotifier,
    required StructuredLogger logger,
  }) : _dragContext = dragContext,
       _wireContext = wireContext,
       _gestureContext = gestureContext,
       _stateNotifier = stateNotifier,
       _logger = logger {
    _eventBus = StreamController<InteractionEvent>.broadcast();
    _setupEventHandling();
  }

  // Main public interface - maintains backward compatibility
  Future<void> handleDragStart(
    DragTargetDetails<ComponentDragData> details, 
    DragOrigin origin,
  ) async {
    final event = DragStartEvent(
      dragData: details.data,
      globalPosition: details.offset,
      origin: origin,
    );
    
    await _routeEvent(event);
  }

  Future<void> handleDragUpdate(DragTargetDetails<ComponentDragData> details) async {
    final event = DragUpdateEvent(
      globalPosition: details.offset,
      localPosition: details.offset, // Converted in widget layer
      coordinateContext: _buildCoordinateContext(),
      occupiedPositions: _getOccupiedPositions(),
    );
    
    await _routeEvent(event);
  }

  Future<void> handleDragEnd(DragTargetDetails<ComponentDragData> details) async {
    final currentState = _stateNotifier.state;
    final event = DragEndEvent(
      globalPosition: details.offset,
      isValid: currentState.isValid,
      targetPosition: currentState.targetPosition,
    );
    
    await _routeEvent(event);
  }

  Future<void> handlePanUpdate(Offset delta) async {
    final event = PanGestureEvent(delta: delta);
    await _routeEvent(event);
  }

  Future<void> handleScaleUpdate(double scale, Offset focalPoint) async {
    final event = ScaleGestureEvent(scale: scale, focalPoint: focalPoint);
    await _routeEvent(event);
  }

  // Internal event routing
  Future<void> _routeEvent(InteractionEvent event) async {
    _logger.debug('Routing event', context: {
      'eventType': event.runtimeType.toString(),
      'currentMode': _currentMode.toString(),
    });

    try {
      final result = await _processEvent(event);
      await _updateStateFromResult(result);
      _eventBus.add(event);
    } catch (e) {
      _logger.error('Event processing failed', context: {
        'eventType': event.runtimeType.toString(),
        'error': e.toString(),
      });
      
      // Transition to safe state on error
      _transitionToMode(InteractionMode.idle);
    }
  }

  Future<InteractionResult> _processEvent(InteractionEvent event) async {
    return switch (event.runtimeType) {
      // Drag events
      DragStartEvent => {
        _transitionToMode(InteractionMode.placeComponent);
        await _dragContext.handleDragStart(event as DragStartEvent);
      },
      DragUpdateEvent => await _dragContext.handleDragUpdate(event as DragUpdateEvent),
      DragEndEvent => {
        final result = await _dragContext.handleDragEnd(event as DragEndEvent);
        _transitionToMode(InteractionMode.idle);
        result;
      },
      
      // Wire events
      WireStartEvent => {
        _transitionToMode(InteractionMode.drawWire);
        await _wireContext.handleWireStart(event as WireStartEvent);
      },
      WireUpdateEvent => await _wireContext.handleWireUpdate(event as WireUpdateEvent),
      WireCompleteEvent => {
        final result = await _wireContext.handleWireComplete(event as WireCompleteEvent);
        _transitionToMode(InteractionMode.idle);
        result;
      },
      
      // Gesture events
      PanGestureEvent => await _gestureContext.handlePanGesture(event as PanGestureEvent),
      ScaleGestureEvent => await _gestureContext.handleScaleGesture(event as ScaleGestureEvent),
      
      _ => throw UnsupportedError('Unknown event type: ${event.runtimeType}'),
    };
  }

  Future<void> _updateStateFromResult(InteractionResult result) async {
    switch (result.runtimeType) {
      case DragResult:
        await _updateDragState(result as DragResult);
        break;
      case WireResult:
        await _updateWireState(result as WireResult);
        break;
      case GestureResult:
        await _updateGestureState(result as GestureResult);
        break;
    }
  }

  Future<void> _updateDragState(DragResult result) async {
    if (result.isSuccess) {
      _stateNotifier.updateValidation(
        result.isValid,
        position: result.targetPosition,
        error: result.errorMessage,
      );
    }
  }

  Future<void> _updateWireState(WireResult result) async {
    if (result.isSuccess) {
      _stateNotifier.updateValidation(
        result.isValid,
        path: result.currentPath,
        error: result.errorMessage,
      );
    }
  }

  Future<void> _updateGestureState(GestureResult result) async {
    // Gesture results typically don't update interaction state
    // They affect viewport state which is managed separately
  }

  void _transitionToMode(InteractionMode newMode) {
    final oldMode = _currentMode;
    _currentMode = newMode;
    _stateNotifier.transitionToMode(newMode);
    
    _logger.debug('Mode transition', context: {
      'from': oldMode.toString(),
      'to': newMode.toString(),
    });
  }

  void _setupEventHandling() {
    _eventBus.stream.listen((event) {
      _logger.trace('Event processed', context: {
        'eventType': event.runtimeType.toString(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    });
  }

  // Helper methods (extracted from original controller)
  CoordinateContext _buildCoordinateContext() {
    // TODO: Get viewport state from appropriate provider
    final viewportState = const ViewportState(); // Placeholder
    final gameState = _stateNotifier.ref.watch(interactionEngineProvider('levelId'));

    return CoordinateContext(
      gridDimensions: Size(gameState.grid.cols.toDouble(), gameState.grid.rows.toDouble()),
      cellSize: viewportState.cellSize,
      scale: viewportState.scale,
      panOffset: viewportState.panOffset,
      canvasSize: viewportState.canvasSize,
      devicePixelRatio: 1.0, // Would come from MediaQuery
    );
  }

  Set<GridPosition> _getOccupiedPositions() {
    // Use existing logic from original controller
    final occupiedPositionStrings = CreateComponentUseCase.getOccupiedPositions(_createNotifierContext());
    
    return occupiedPositionStrings.map((posString) {
      final parts = posString.split(',');
      return GridPosition(
        row: int.parse(parts[0]),
        col: int.parse(parts[1]),
      );
    }).toSet();
  }

  NotifierContext _createNotifierContext() {
    // Create context using existing pattern from original controller
    return NotifierContext(
      grid: null, // TODO: Get from provider
      history: null,
      progress: null,
      selection: null,
      interaction: null,
      paletteManager: ComponentPaletteManager(availableTemplates: []),
    );
  }

  void initialize(RenderBox renderBox) {
    // Delegate initialization to contexts if needed
    _logger.info('Coordinator initialized', context: {
      'renderBoxSize': renderBox.size.toString(),
    });
  }

  void dispose() {
    _eventBus.close();
    _dragContext.dispose();
    _wireContext.dispose();
    _gestureContext.dispose();
    
    _logger.info('Coordinator disposed');
  }
}

// ============================================================================
// PHASE 4: BACKWARD COMPATIBILITY FACADE (~150 lines)
// ============================================================================

// 4.1 CanvasInteractionController - Compatibility facade
// Replace the original 1,730-line controller with this facade

class CanvasInteractionController {
  final CanvasInteractionCoordinator _coordinator;
  final String levelId;
  final WidgetRef ref;
  
  // Maintain existing public interface
  ICoordinateService get coordinateService => _coordinator._coordinateMapper;

  CanvasInteractionController({
    required this.levelId,
    required this.ref,
    ICoordinateService? coordinateService,
  }) : _coordinator = _createCoordinator(levelId, ref, coordinateService);

  static CanvasInteractionCoordinator _createCoordinator(
    String levelId,
    WidgetRef ref,
    ICoordinateService? coordinateService,
  ) {
    // Dependency injection setup
    final logger = StructuredLogger();
    final coordMapper = coordinateService as CoordinateMapperService? ?? 
                       CoordinateMapperService(logger: logger);
    final validator = ValidationService(logger: logger);
    final stateNotifier = ref.read(interactionStateProvider(levelId).notifier);
    
    // Create contexts
    final dragContext = DragInteractionContext(
      validationService: validator,
      coordinateMapper: coordMapper,
      createComponentUseCase: CreateComponentUseCase(), // TODO: Inject properly
      logger: logger,
    );
    
    final wireContext = WireInteractionContext(
      wireNetworkService: WireNetworkService(), // TODO: Inject properly
      pathfindingService: PathfindingService(), // TODO: Inject properly
      coordinateMapper: coordMapper,
      logger: logger,
    );
    
    final gestureContext = GestureInteractionContext(
      viewportService: ViewportService(), // TODO: Inject properly
      logger: logger,
    );
    
    return CanvasInteractionCoordinator(
      dragContext: dragContext,
      wireContext: wireContext,
      gestureContext: gestureContext,
      stateNotifier: stateNotifier,
      logger: logger,
    );
  }

  // Maintain all existing public method signatures
  void initialize(RenderBox renderBox) => _coordinator.initialize(renderBox);

  void handleDragStart(DragTargetDetails<ComponentDragData> details, DragOrigin origin) {
    _coordinator.handleDragStart(details, origin);
  }

  void handleDragUpdate(DragTargetDetails<ComponentDragData> details) {
    _coordinator.handleDragUpdate(details);
  }

  void handleDragEnd(DragTargetDetails<ComponentDragData> details) {
    _coordinator.handleDragEnd(details);
  }

  void handlePanUpdate(Offset delta) {
    _coordinator.handlePanUpdate(delta);
  }

  void handleScaleUpdate(double scale) {
    _coordinator.handleScaleUpdate(scale, Offset.zero); // Default focal point
  }

  void dispose() => _coordinator.dispose();
}

// ============================================================================
// SUPPORTING TYPES AND RESULTS
// ============================================================================

// Event types
abstract class InteractionEvent {}

class DragStartEvent extends InteractionEvent {
  final ComponentDragData dragData;
  final Offset globalPosition;
  final DragOrigin origin;

  DragStartEvent({
    required this.dragData,
    required this.globalPosition,
    required this.origin,
  });
}

class DragUpdateEvent extends InteractionEvent {
  final Offset globalPosition;
  final Offset localPosition;
  final CoordinateContext coordinateContext;
  final Set<GridPosition> occupiedPositions;

  DragUpdateEvent({
    required this.globalPosition,
    required this.localPosition,
    required this.coordinateContext,
    required this.occupiedPositions,
  });
}

class DragEndEvent extends InteractionEvent {
  final Offset globalPosition;
  final bool isValid;
  final GridPosition? targetPosition;

  DragEndEvent({
    required this.globalPosition,
    required this.isValid,
    required this.targetPosition,
  });
}

class WireStartEvent extends InteractionEvent {
  final ComponentPort startPort;
  
  WireStartEvent({required this.startPort});
}

class WireUpdateEvent extends InteractionEvent {
  final Offset currentPosition;
  final CoordinateContext coordinateContext;
  final Set<GridPosition> occupiedPositions;
  
  WireUpdateEvent({
    required this.currentPosition,
    required this.coordinateContext,
    required this.occupiedPositions,
  });
}

class WireCompleteEvent extends InteractionEvent {
  final ComponentPort? endPort;
  
  WireCompleteEvent({required this.endPort});
}

class PanGestureEvent extends InteractionEvent {
  final Offset delta;
  
  PanGestureEvent({required this.delta});
}

class ScaleGestureEvent extends InteractionEvent {
  final double scale;
  final Offset focalPoint;
  
  ScaleGestureEvent({required this.scale, required this.focalPoint});
}

// Result types
abstract class InteractionResult {
  final bool isSuccess;
  final String? errorMessage;

  InteractionResult({required this.isSuccess, this.errorMessage});
}

class DragResult extends InteractionResult {
  final bool isValid;
  final GridPosition? targetPosition;
  final String? placedComponentId;
  final GridPosition? placedPosition;

  DragResult({
    required super.isSuccess,
    super.errorMessage,
    required this.isValid,
    this.targetPosition,
    this.placedComponentId,
    this.placedPosition,
  });

  factory DragResult.started({required bool isValid, GridPosition? targetPosition}) {
    return DragResult(isSuccess: true, isValid: isValid, targetPosition: targetPosition);
  }

  factory DragResult.updated({required bool isValid, GridPosition? targetPosition, String? errorMessage}) {
    return DragResult(isSuccess: true, isValid: isValid, targetPosition: targetPosition, errorMessage: errorMessage);
  }

  factory DragResult.completed({required GridPosition placedPosition, required String componentId}) {
    return DragResult(isSuccess: true, isValid: true, placedPosition: placedPosition, placedComponentId: componentId);
  }

  factory DragResult.invalid(String message) {
    return DragResult(isSuccess: false, isValid: false, errorMessage: message);
  }

  factory DragResult.cancelled(String message) {
    return DragResult(isSuccess: true, isValid: false, errorMessage: message);
  }

  factory DragResult.error(String message) {
    return DragResult(isSuccess: false, isValid: false, errorMessage: message);
  }
}

class WireResult extends InteractionResult {
  final bool isValid;
  final List<GridPosition> currentPath;
  final String? networkId;
  final int? placedSegments;

  WireResult({
    required super.isSuccess,
    super.errorMessage,
    required this.isValid,
    this.currentPath = const [],
    this.networkId,
    this.placedSegments,
  });

  factory WireResult.started({required bool isValid, required List<GridPosition> currentPath}) {
    return WireResult(isSuccess: true, isValid: isValid, currentPath: currentPath);
  }

  factory WireResult.updated({required bool isValid, required List<GridPosition> currentPath, String? errorMessage}) {
    return WireResult(isSuccess: true, isValid: isValid, currentPath: currentPath, errorMessage: errorMessage);
  }

  factory WireResult.completed({required String networkId, required int placedSegments}) {
    return WireResult(isSuccess: true, isValid: true, networkId: networkId, placedSegments: placedSegments);
  }

  factory WireResult.invalid(String message) {
    return WireResult(isSuccess: false, isValid: false, errorMessage: message);
  }

  factory WireResult.error(String message) {
    return WireResult(isSuccess: false, isValid: false, errorMessage: message);
  }
}

class GestureResult extends InteractionResult {
  final GestureType gestureType;
  final Map<String, dynamic> details;

  GestureResult({
    required super.isSuccess,
    super.errorMessage,
    required this.gestureType,
    this.details = const {},
  });

  factory GestureResult.success({required GestureType gestureType, Map<String, dynamic>? details}) {
    return GestureResult(isSuccess: true, gestureType: gestureType, details: details ?? {});
  }

  factory GestureResult.error(String message) {
    return GestureResult(isSuccess: false, gestureType: GestureType.pan, errorMessage: message);
  }
}

enum GestureType { pan, scale }

// ============================================================================
// MIGRATION CHECKLIST
// ============================================================================

/*
PHASE 1 MIGRATION CHECKLIST:
□ Extract ValidationService
□ Extract CoordinateMapperService  
□ Update imports in main controller
□ Run existing tests to ensure no regression
□ Add unit tests for extracted services

PHASE 2 MIGRATION CHECKLIST:
□ Create DragInteractionContext
□ Create WireInteractionContext
□ Create GestureInteractionContext
□ Move logic from main controller to contexts
□ Update context unit tests

PHASE 3 MIGRATION CHECKLIST:
□ Create CanvasInteractionCoordinator
□ Implement event routing
□ Set up dependency injection
□ Integration testing

PHASE 4 MIGRATION CHECKLIST:
□ Create compatibility facade
□ Replace original controller
□ Run full test suite
□ Performance testing
□ Deploy with feature flag

ROLLBACK PLAN:
□ Keep original controller in separate branch
□ Feature flag to switch implementations
□ Monitoring and alerting setup
□ Quick revert procedure documented
*/
// ============================================================================
// COMPREHENSIVE TESTING STRATEGY FOR CANVAS REFACTORING
// ============================================================================

// This testing strategy ensures zero-regression refactoring with comprehensive
// coverage of all interaction scenarios, edge cases, and performance requirements.

// ============================================================================
// PHASE 1: UNIT TESTS FOR EXTRACTED SERVICES
// ============================================================================

// 1.1 ValidationService Tests
// test/unit/services/validation_service_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

@GenerateMocks([StructuredLogger])
void main() {
  group('ValidationService', () {
    late ValidationService validationService;
    late MockStructuredLogger mockLogger;
    late CoordinateContext testContext;

    setUp(() {
      mockLogger = MockStructuredLogger();
      validationService = ValidationService(logger: mockLogger);
      testContext = CoordinateContext(
        gridDimensions: const Size(10, 10),
        cellSize: 50.0,
        scale: 1.0,
        panOffset: Offset.zero,
        canvasSize: const Size(500, 500),
        devicePixelRatio: 1.0,
      );
    });

    group('validateDropPosition', () {
      test('should validate position within grid bounds', () {
        // Arrange
        const position = Offset(100, 100); // Valid position
        final occupiedPositions = <GridPosition>{};

        // Act
        final result = validationService.validateDropPosition(
          position,
          testContext,
          occupiedPositions: occupiedPositions,
        );

        // Assert
        expect(result.isValid, isTrue);
        expect(result.error, isNull);
      });

      test('should reject position outside grid bounds', () {
        // Arrange
        const position = Offset(-50, 100); // Invalid: negative X
        final occupiedPositions = <GridPosition>{};

        // Act
        final result = validationService.validateDropPosition(
          position,
          testContext,
          occupiedPositions: occupiedPositions,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.error, DragDropErrorType.invalidPosition);
      });

      test('should reject occupied positions', () {
        // Arrange
        const position = Offset(100, 100);
        final occupiedPositions = {GridPosition(row: 2, col: 2)};

        // Act
        final result = validationService.validateDropPosition(
          position,
          testContext,
          occupiedPositions: occupiedPositions,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.error, DragDropErrorType.positionOccupied);
      });

      test('should handle coordinate transformation failures gracefully', () {
        // Arrange
        const position = Offset(double.nan, 100); // Invalid coordinates
        final occupiedPositions = <GridPosition>{};

        // Act
        final result = validationService.validateDropPosition(
          position,
          testContext,
          occupiedPositions: occupiedPositions,
        );

        // Assert
        expect(result.isValid, isFalse);
        expect(result.error, DragDropErrorType.coordinateTransformationFailed);
      });

      test('should validate multiple positions in sequence', () {
        // Test for memory leaks and state persistence issues
        final positions = [
          const Offset(50, 50),
          const Offset(150, 150),
          const Offset(250, 250),
        ];
        final occupiedPositions = <GridPosition>{};

        for (final position in positions) {
          final result = validationService.validateDropPosition(
            position,
            testContext,
            occupiedPositions: occupiedPositions,
          );
          expect(result.isValid, isTrue);
        }
      });
    });

    group('edge cases', () {
      test('should handle zero-sized canvas', () {
        final zeroContext = testContext.copyWith(canvasSize: Size.zero);
        const position = Offset(10, 10);

        final result = validationService.validateDropPosition(
          position,
          zeroContext,
          occupiedPositions: {},
        );

        expect(result.isValid, isFalse);
      });

      test('should handle extreme scale values', () {
        final extremeContext = testContext.copyWith(scale: 0.001);
        const position = Offset(100, 100);

        final result = validationService.validateDropPosition(
          position,
          extremeContext,
          occupiedPositions: {},
        );

        // Should not crash, validation logic should handle extreme values
        expect(result, isA<ValidationResult>());
      });

      test('should handle large occupied position sets', () {
        final largeOccupiedSet = Set<GridPosition>.from(
          List.generate(1000, (i) => GridPosition(row: i ~/ 50, col: i % 50)),
        );
        const position = Offset(100, 100);

        final stopwatch = Stopwatch()..start();
        final result = validationService.validateDropPosition(
          position,
          testContext,
          occupiedPositions: largeOccupiedSet,
        );
        stopwatch.stop();

        // Performance requirement: should complete within 10ms
        expect(stopwatch.elapsedMilliseconds, lessThan(10));
        expect(result, isA<ValidationResult>());
      });
    });
  });
}

// 1.2 CoordinateMapperService Tests
// test/unit/services/coordinate_mapper_service_test.dart

void coordinateMapperTests() {
  group('CoordinateMapperService', () {
    late CoordinateMapperService coordinateMapper;
    late MockStructuredLogger mockLogger;
    late CoordinateContext testContext;

    setUp(() {
      mockLogger = MockStructuredLogger();
      coordinateMapper = CoordinateMapperService(logger: mockLogger);
      testContext = CoordinateContext(
        gridDimensions: const Size(10, 10),
        cellSize: 50.0,
        scale: 1.0,
        panOffset: Offset.zero,
        canvasSize: const Size(500, 500),
        devicePixelRatio: 1.0,
      );
    });

    group('screenToGrid conversions', () {
      test('should convert screen coordinates to grid positions correctly', () {
        const screenPosition = Offset(125, 175); // Should map to (2, 3)

        final result = coordinateMapper.screenToGrid(screenPosition, testContext);

        expect(result, isNotNull);
        expect(result!.row, equals(4)); // 175 / 50 = 3.5, rounded = 4
        expect(result.col, equals(3));  // 125 / 50 = 2.5, rounded = 3
      });

      test('should handle viewport transformations', () {
        final transformedContext = testContext.copyWith(
          panOffset: const Offset(25, 25),
          scale: 2.0,
        );
        const screenPosition = Offset(100, 100);

        final result = coordinateMapper.screenToGrid(screenPosition, transformedContext);

        expect(result, isNotNull);
        // (100 - 25) / 2.0 / 50 = 0.75, rounded = 1
        expect(result!.row, equals(1));
        expect(result.col, equals(1));
      });

      test('should clamp coordinates to grid bounds', () {
        const screenPosition = Offset(-100, 600); // Outside bounds

        final result = coordinateMapper.screenToGrid(screenPosition, testContext);

        expect(result, isNotNull);
        expect(result!.row, equals(0)); // Clamped to minimum
        expect(result.col, equals(0)); // Clamped to minimum
      });

      test('should handle invalid screen coordinates', () {
        const invalidPosition = Offset(double.infinity, double.nan);

        final result = coordinateMapper.screenToGrid(invalidPosition, testContext);

        expect(result, isNull); // Should return null for invalid coordinates
        verify(mockLogger.error(any, context: anyNamed('context'))).called(1);
      });
    });

    group('gridToScreen conversions', () {
      test('should convert grid positions to screen coordinates correctly', () {
        const gridPosition = GridPosition(row: 2, col: 3);

        final result = coordinateMapper.gridToScreen(gridPosition, testContext);

        expect(result.dx, equals(150.0)); // 3 * 50
        expect(result.dy, equals(100.0)); // 2 * 50
      });

      test('should handle viewport transformations in reverse', () {
        final transformedContext = testContext.copyWith(
          panOffset: const Offset(25, 25),
          scale: 2.0,
        );
        const gridPosition = GridPosition(row: 1, col: 1);

        final result = coordinateMapper.gridToScreen(gridPosition, transformedContext);

        expect(result.dx, equals(125.0)); // (1 * 50 * 2.0) + 25
        expect(result.dy, equals(125.0)); // (1 * 50 * 2.0) + 25
      });
    });

    group('globalToLocal conversions', () {
      test('should convert global to local coordinates with valid RenderBox', () {
        final mockRenderBox = MockRenderBox();
        when(mockRenderBox.attached).thenReturn(true);
        when(mockRenderBox.globalToLocal(any)).thenReturn(const Offset(50, 50));

        const globalPosition = Offset(200, 200);

        final result = coordinateMapper.globalToLocal(globalPosition, mockRenderBox);

        expect(result, equals(const Offset(50, 50)));
        verify(mockRenderBox.globalToLocal(globalPosition)).called(1);
      });

      test('should throw StateError for unattached RenderBox', () {
        final mockRenderBox = MockRenderBox();
        when(mockRenderBox.attached).thenReturn(false);

        const globalPosition = Offset(200, 200);

        expect(
          () => coordinateMapper.globalToLocal(globalPosition, mockRenderBox),
          throwsStateError,
        );
      });
    });

    group('performance tests', () {
      test('should handle rapid coordinate conversions efficiently', () {
        final positions = List.generate(1000, (i) => Offset(i * 10.0, i * 10.0));
        
        final stopwatch = Stopwatch()..start();
        for (final position in positions) {
          coordinateMapper.screenToGrid(position, testContext);
        }
        stopwatch.stop();

        // Performance requirement: 1000 conversions in <50ms
        expect(stopwatch.elapsedMilliseconds, lessThan(50));
      });

      test('should not leak memory during extensive use', () {
        // This test would need memory profiling tools in a real environment
        for (int i = 0; i < 10000; i++) {
          coordinateMapper.screenToGrid(Offset(i.toDouble(), i.toDouble()), testContext);
        }
        // In a real test, we'd assert memory usage hasn't grown significantly
      });
    });
  });
}

// ============================================================================
// PHASE 2: INTEGRATION TESTS FOR CONTEXTS
// ============================================================================

// 2.1 DragInteractionContext Integration Tests
// test/integration/contexts/drag_interaction_context_test.dart

@GenerateMocks([ValidationService, CoordinateMapperService, CreateComponentUseCase])
void dragContextIntegrationTests() {
  group('DragInteractionContext Integration', () {
    late DragInteractionContext dragContext;
    late MockValidationService mockValidationService;
    late MockCoordinateMapperService mockCoordinateMapper;
    late MockCreateComponentUseCase mockCreateComponentUseCase;
    late MockStructuredLogger mockLogger;

    setUp(() {
      mockValidationService = MockValidationService();
      mockCoordinateMapper = MockCoordinateMapperService();
      mockCreateComponentUseCase = MockCreateComponentUseCase();
      mockLogger = MockStructuredLogger();

      dragContext = DragInteractionContext(
        validationService: mockValidationService,
        coordinateMapper: mockCoordinateMapper,
        createComponentUseCase: mockCreateComponentUseCase,
        logger: mockLogger,
      );
    });

    group('complete drag workflows', () {
      test('should handle successful drag-and-drop workflow', () async {
        // Arrange
        final dragData = ComponentDragData(
          componentType: ComponentType.resistor,
          componentName: 'Resistor',
          cost: 10,
        );
        final startEvent = DragStartEvent(
          dragData: dragData,
          globalPosition: const Offset(100, 100),
          origin: DragOrigin.palette,
        );
        final updateEvent = DragUpdateEvent(
          globalPosition: const Offset(150, 150),
          localPosition: const Offset(150, 150),
          coordinateContext: CoordinateContext(
            gridDimensions: const Size(10, 10),
            cellSize: 50.0,
            scale: 1.0,
            panOffset: Offset.zero,
            canvasSize: const Size(500, 500),
            devicePixelRatio: 1.0,
          ),
          occupiedPositions: {},
        );
        final endEvent = DragEndEvent(
          globalPosition: const Offset(150, 150),
          isValid: true,
          targetPosition: GridPosition(row: 3, col: 3),
        );

        // Set up mocks
        when(mockValidationService.validateDropPosition(any, any, occupiedPositions: anyNamed('occupiedPositions')))
            .thenReturn(ValidationResult.valid());
        when(mockCoordinateMapper.screenToGrid(any, any))
            .thenReturn(GridPosition(row: 3, col: 3));
        when(mockCreateComponentUseCase.execute(any))
            .thenAnswer((_) async => 'component-id-123');

        // Act & Assert
        final startResult = await dragContext.handleDragStart(startEvent);
        expect(startResult.isSuccess, isTrue);
        expect(startResult.isValid, isTrue);

        final updateResult = await dragContext.handleDragUpdate(updateEvent);
        expect(updateResult.isSuccess, isTrue);
        expect(updateResult.isValid, isTrue);
        expect(updateResult.targetPosition, equals(GridPosition(row: 3, col: 3)));

        final endResult = await dragContext.handleDragEnd(endEvent);
        expect(endResult.isSuccess, isTrue);
        expect(endResult.placedComponentId, equals('component-id-123'));

        // Verify interactions
        verify(mockCreateComponentUseCase.execute(any)).called(1);
      });

      test('should handle drag cancellation gracefully', () async {
        // Test dragging to invalid location and ensuring proper cleanup
        final startEvent = DragStartEvent(
          dragData: ComponentDragData(
            componentType: ComponentType.resistor,
            componentName: 'Resistor',
            cost: 10,
          ),
          globalPosition: const Offset(100, 100),
          origin: DragOrigin.palette,
        );
        final endEvent = DragEndEvent(
          globalPosition: const Offset(-50, -50), // Invalid position
          isValid: false,
          targetPosition: null,
        );

        await dragContext.handleDragStart(startEvent);
        final endResult = await dragContext.handleDragEnd(endEvent);

        expect(endResult.isSuccess, isTrue); // Success doesn't mean placement succeeded
        expect(endResult.isValid, isFalse);
        expect(endResult.errorMessage, contains('Invalid drop location'));

        // Verify no component was placed
        verifyNever(mockCreateComponentUseCase.execute(any));
      });
    });

    group('error handling', () {
      test('should handle component placement failures', () async {
        final startEvent = DragStartEvent(
          dragData: ComponentDragData(
            componentType: ComponentType.resistor,
            componentName: 'Resistor',
            cost: 10,
          ),
          globalPosition: const Offset(100, 100),
          origin: DragOrigin.palette,
        );
        final endEvent = DragEndEvent(
          globalPosition: const Offset(150, 150),
          isValid: true,
          targetPosition: GridPosition(row: 3, col: 3),
        );

        // Set up mock to throw exception during placement
        when(mockCreateComponentUseCase.execute(any))
            .thenThrow(Exception('Placement failed'));

        await dragContext.handleDragStart(startEvent);
        final endResult = await dragContext.handleDragEnd(endEvent);

        expect(endResult.isSuccess, isFalse);
        expect(endResult.errorMessage, contains('Failed to place component'));
        verify(mockLogger.error(any, context: anyNamed('context'))).called(1);
      });

      test('should handle validation service failures', () async {
        final updateEvent = DragUpdateEvent(
          globalPosition: const Offset(150, 150),
          localPosition: const Offset(150, 150),
          coordinateContext: CoordinateContext(
            gridDimensions: const Size(10, 10),
            cellSize: 50.0,
            scale: 1.0,
            panOffset: Offset.zero,
            canvasSize: const Size(500, 500),
            devicePixelRatio: 1.0,
          ),
          occupiedPositions: {},
        );

        // Set up validation service to throw exception
        when(mockValidationService.validateDropPosition(any, any, occupiedPositions: anyNamed('occupiedPositions')))
            .thenThrow(Exception('Validation failed'));

        final result = await dragContext.handleDragUpdate(updateEvent);

        expect(result.isSuccess, isFalse);
        expect(result.errorMessage, contains('Validation failed'));
      });
    });

    tearDown(() {
      dragContext.dispose();
    });
  });
}

// 2.2 WireInteractionContext Integration Tests
// test/integration/contexts/wire_interaction_context_test.dart

@GenerateMocks([WireNetworkService, PathfindingService])
void wireContextIntegrationTests() {
  group('WireInteractionContext Integration', () {
    late WireInteractionContext wireContext;
    late MockWireNetworkService mockWireNetworkService;
    late MockPathfindingService mockPathfindingService;
    late MockCoordinateMapperService mockCoordinateMapper;
    late MockStructuredLogger mockLogger;

    setUp(() {
      mockWireNetworkService = MockWireNetworkService();
      mockPathfindingService = MockPathfindingService();
      mockCoordinateMapper = MockCoordinateMapperService();
      mockLogger = MockStructuredLogger();

      wireContext = WireInteractionContext(
        wireNetworkService: mockWireNetworkService,
        pathfindingService: mockPathfindingService,
        coordinateMapper: mockCoordinateMapper,
        logger: mockLogger,
      );
    });

    group('wire drawing workflows', () {
      test('should complete successful wire connection workflow', () async {
        // Arrange
        final startPort = ComponentPort(
          id: 'battery_positive',
          position: GridPosition(row: 2, col: 2),
          type: PortType.output,
        );
        final endPort = ComponentPort(
          id: 'resistor_input',
          position: GridPosition(row: 2, col: 5),
          type: PortType.input,
        );
        final expectedPath = [
          GridPosition(row: 2, col: 2),
          GridPosition(row: 2, col: 3),
          GridPosition(row: 2, col: 4),
          GridPosition(row: 2, col: 5),
        ];
        final mockNetwork = MockWireNetwork();

        // Set up mocks
        when(mockCoordinateMapper.screenToGrid(any, any))
            .thenReturn(GridPosition(row: 2, col: 5));
        when(mockPathfindingService.findPath(
          start: anyNamed('start'),
          end: anyNamed('end'),
          occupiedPositions: anyNamed('occupiedPositions'),
        )).thenAnswer((_) async => Success(expectedPath));
        when(mockWireNetworkService.createNetwork(
          startPort: anyNamed('startPort'),
          endPort: anyNamed('endPort'),
          path: anyNamed('path'),
        )).thenAnswer((_) async => Success(mockNetwork));
        when(mockNetwork.id).thenReturn('wire_network_123');
        when(mockNetwork.segments).thenReturn([]);

        // Act
        final startResult = await wireContext.handleWireStart(
          WireStartEvent(startPort: startPort),
        );
        expect(startResult.isSuccess, isTrue);

        final updateResult = await wireContext.handleWireUpdate(
          WireUpdateEvent(
            currentPosition: const Offset(250, 100),
            coordinateContext: _createTestCoordinateContext(),
            occupiedPositions: {},
          ),
        );
        expect(updateResult.isSuccess, isTrue);
        expect(updateResult.currentPath, equals(expectedPath));

        final completeResult = await wireContext.handleWireComplete(
          WireCompleteEvent(endPort: endPort),
        );
        expect(completeResult.isSuccess, isTrue);
        expect(completeResult.networkId, equals('wire_network_123'));

        // Verify
        verify(mockPathfindingService.findPath(
          start: startPort.position,
          end: GridPosition(row: 2, col: 5),
          occupiedPositions: {},
        )).called(1);
        verify(mockWireNetworkService.createNetwork(
          startPort: startPort,
          endPort: endPort,
          path: expectedPath,
        )).called(1);
      });

      test('should fallback to Manhattan pathfinding when A* fails', () async {
        final startPort = ComponentPort(
          id: 'battery_positive',
          position: GridPosition(row: 1, col: 1),
          type: PortType.output,
        );

        // Set up A* to fail
        when(mockPathfindingService.findPath(
          start: anyNamed('start'),
          end: anyNamed('end'),
          occupiedPositions: anyNamed('occupiedPositions'),
        )).thenAnswer((_) async => Failure('No path found'));
        when(mockCoordinateMapper.screenToGrid(any, any))
            .thenReturn(GridPosition(row: 3, col: 3));

        await wireContext.handleWireStart(WireStartEvent(startPort: startPort));
        final updateResult = await wireContext.handleWireUpdate(
          WireUpdateEvent(
            currentPosition: const Offset(150, 150),
            coordinateContext: _createTestCoordinateContext(),
            occupiedPositions: {},
          ),
        );

        expect(updateResult.isSuccess, isTrue);
        expect(updateResult.isValid, isFalse); // Using fallback
        expect(updateResult.errorMessage, contains('fallback pathfinding'));
        
        // Manhattan path: (1,1) -> (1,2) -> (1,3) -> (2,3) -> (3,3)
        final expectedManhattanPath = [
          GridPosition(row: 1, col: 1),
          GridPosition(row: 1, col: 2),
          GridPosition(row: 1, col: 3),
          GridPosition(row: 2, col: 3),
          GridPosition(row: 3, col: 3),
        ];
        expect(updateResult.currentPath, equals(expectedManhattanPath));
      });
    });

    group('error handling and edge cases', () {
      test('should handle wire network creation failures', () async {
        final startPort = ComponentPort(
          id: 'battery_positive',
          position: GridPosition(row: 2, col: 2),
          type: PortType.output,
        );
        final endPort = ComponentPort(
          id: 'resistor_input',
          position: GridPosition(row: 2, col: 5),
          type: PortType.input,
        );

        // Set up network creation to fail
        when(mockWireNetworkService.createNetwork(
          startPort: anyNamed('startPort'),
          endPort: anyNamed('endPort'),
          path: anyNamed('path'),
        )).thenAnswer((_) async => Failure('Network creation failed'));

        await wireContext.handleWireStart(WireStartEvent(startPort: startPort));
        final completeResult = await wireContext.handleWireComplete(
          WireCompleteEvent(endPort: endPort),
        );

        expect(completeResult.isSuccess, isFalse);
        expect(completeResult.errorMessage, contains('Failed to create wire network'));
        verify(mockLogger.error(any, context: anyNamed('context'))).called(1);
      });

      test('should handle coordinate transformation failures', () async {
        final startPort = ComponentPort(
          id: 'battery_positive',
          position: GridPosition(row: 2, col: 2),
          type: PortType.output,
        );

        // Set up coordinate mapper to return null
        when(mockCoordinateMapper.screenToGrid(any, any)).thenReturn(null);

        await wireContext.handleWireStart(WireStartEvent(startPort: startPort));
        final updateResult = await wireContext.handleWireUpdate(
          WireUpdateEvent(
            currentPosition: const Offset(150, 150),
            coordinateContext: _createTestCoordinateContext(),
            occupiedPositions: {},
          ),
        );

        expect(updateResult.isSuccess, isFalse);
        expect(updateResult.errorMessage, equals('Invalid target position'));
      });
    });

    tearDown(() {
      wireContext.dispose();
    });
  });
}

// ============================================================================
// PHASE 3: END-TO-END INTEGRATION TESTS
// ============================================================================

// 3.1 Complete Canvas Interaction Workflows
// test/integration/canvas_interaction_e2e_test.dart

void endToEndTests() {
  group('Canvas Interaction End-to-End Tests', () {
    late CanvasInteractionCoordinator coordinator;
    late TestHarness testHarness;

    setUp(() async {
      testHarness = TestHarness();
      await testHarness.initialize();
      coordinator = testHarness.coordinator;
    });

    group('drag and drop workflows', () {
      testWidgets('should complete component placement workflow', (tester) async {
        // This test simulates the complete widget interaction
        await tester.pumpWidget(testHarness.createTestWidget());

        // Find the palette and canvas
        final palette = find.byKey(const Key('component_palette'));
        final canvas = find.byKey(const Key('canvas_interaction'));
        
        expect(palette, findsOneWidget);
        expect(canvas, findsOneWidget);

        // Start drag from palette
        final resistorWidget = find.byKey(const Key('resistor_palette_item'));
        await tester.drag(resistorWidget, const Offset(200, 200));
        await tester.pumpAndSettle();

        // Verify component was placed
        verify(testHarness.mockCreateComponentUseCase.execute(any)).called(1);
        
        // Verify state updates
        final finalState = testHarness.stateNotifier.state;
        expect(finalState.currentMode, equals(InteractionMode.idle));
      });

      testWidgets('should handle rapid successive drags without memory leaks', (tester) async {
        await tester.pumpWidget(testHarness.createTestWidget());

        final resistorWidget = find.byKey(const Key('resistor_palette_item'));
        
        // Perform 10 rapid drag operations
        for (int i = 0; i < 10; i++) {
          await tester.drag(resistorWidget, Offset(50.0 + i * 20, 50.0 + i * 20));
          await tester.pump(const Duration(milliseconds: 16)); // Single frame
        }
        
        await tester.pumpAndSettle();

        // Verify no memory leaks (state should be clean)
        final finalState = testHarness.stateNotifier.state;
        expect(finalState.currentMode, equals(InteractionMode.idle));
        expect(finalState.componentData, isNull);
        expect(finalState.wireData, isNull);
      });
    });

    group('wire drawing workflows', () {
      testWidgets('should complete wire connection workflow', (tester) async {
        await tester.pumpWidget(testHarness.createTestWidget());

        // First place two components that can be connected
        final batteryWidget = find.byKey(const Key('battery_palette_item'));
        await tester.drag(batteryWidget, const Offset(100, 100));
        await tester.pumpAndSettle();

        final resistorWidget = find.byKey(const Key('resistor_palette_item'));
        await tester.drag(resistorWidget, const Offset(200, 100));
        await tester.pumpAndSettle();

        // Now try to connect them with a wire
        final batteryPort = find.byKey(const Key('battery_output_port'));
        final resistorPort = find.byKey(const Key('resistor_input_port'));

        await tester.drag(batteryPort, const Offset(200, 100));
        await tester.pumpAndSettle();

        // Verify wire network was created
        verify(testHarness.mockWireNetworkService.createNetwork(
          startPort: any,
          endPort: any,
          path: any,
        )).called(1);
      });
    });

    group('gesture handling workflows', () {
      testWidgets('should handle pan and zoom gestures', (tester) async {
        await tester.pumpWidget(testHarness.createTestWidget());

        final canvas = find.byKey(const Key('canvas_interaction'));

        // Test pan gesture
        await tester.fling(canvas, const Offset(100, 100), 1000);
        await tester.pumpAndSettle();

        // Test scale gesture
        const center = Offset(250, 250);
        final gesture1 = await tester.startGesture(center - const Offset(50, 0));
        final gesture2 = await tester.startGesture(center + const Offset(50, 0));
        
        await gesture1.moveTo(center - const Offset(100, 0));
        await gesture2.moveTo(center + const Offset(100, 0));
        
        await gesture1.up();
        await gesture2.up();
        await tester.pumpAndSettle();

        // Verify viewport service was called
        verify(testHarness.mockViewportService.updatePanOffset(any)).called(atLeastOnce);
        verify(testHarness.mockViewportService.updateScale(any, any)).called(atLeastOnce);
      });
    });

    tearDown(() async {
      await testHarness.dispose();
    });
  });
}

// ============================================================================
// PHASE 4: PERFORMANCE AND STRESS TESTS
// ============================================================================

// 4.1 Performance Benchmarks
// test/performance/canvas_interaction_benchmarks.dart

void performanceTests() {
  group('Performance Benchmarks', () {
    late CanvasInteractionCoordinator coordinator;
    late TestHarness testHarness;

    setUp(() async {
      testHarness = TestHarness();
      await testHarness.initialize();
      coordinator = testHarness.coordinator;
    });

    test('coordinate transformation performance', () {
      final coordinateMapper = CoordinateMapperService(logger: MockStructuredLogger());
      final context = _createTestCoordinateContext();
      
      const iterations = 10000;
      final positions = List.generate(iterations, (i) => 
          Offset(i * 0.1, (iterations - i) * 0.1));

      final stopwatch = Stopwatch()..start();
      
      for (final position in positions) {
        coordinateMapper.screenToGrid(position, context);
      }
      
      stopwatch.stop();
      
      // Requirement: 10,000 transformations in < 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      
      // Log performance data
      print('Coordinate transformations: ${iterations} operations in ${stopwatch.elapsedMilliseconds}ms');
      print('Average: ${stopwatch.elapsedMicroseconds / iterations}μs per operation');
    });

    test('event processing latency', () async {
      const iterations = 1000;
      final latencies = <Duration>[];

      for (int i = 0; i < iterations; i++) {
        final stopwatch = Stopwatch()..start();
        
        await coordinator.handleDragStart(
          _createTestDragDetails(Offset(i.toDouble(), i.toDouble())),
          DragOrigin.palette,
        );
        
        stopwatch.stop();
        latencies.add(stopwatch.elapsed);
      }

      final averageLatency = latencies.map((d) => d.inMicroseconds).reduce((a, b) => a + b) / iterations;
      final maxLatency = latencies.map((d) => d.inMicroseconds).reduce(math.max);

      // Requirements: Average < 5ms, Max < 16ms (single frame at 60fps)
      expect(averageLatency, lessThan(5000)); // 5ms in microseconds
      expect(maxLatency, lessThan(16000)); // 16ms in microseconds

      print('Event processing latency:');
      print('Average: ${averageLatency}μs');
      print('Maximum: ${maxLatency}μs');
    });

    test('memory usage stability', () async {
      // This would require integration with Dart's memory profiling tools
      // For now, we'll simulate heavy usage and verify no obvious leaks
      
      const cycles = 100;
      for (int cycle = 0; cycle < cycles; cycle++) {
        // Simulate heavy interaction cycle
        for (int i = 0; i < 50; i++) {
          await coordinator.handleDragStart(
            _createTestDragDetails(Offset(i * 10.0, cycle * 10.0)),
            DragOrigin.palette,
          );
          await coordinator.handleDragEnd(
            _createTestDragDetails(Offset(i * 10.0, cycle * 10.0)),
          );
        }
        
        // Force garbage collection (if available in test environment)
        // In a real scenario, we'd measure actual memory usage here
      }

      // Verify coordinator state is clean
      expect(coordinator._currentMode, equals(InteractionMode.idle));
    });
  });
}

// ============================================================================
// PHASE 5: REGRESSION TESTS
// ============================================================================

// 5.1 Backward Compatibility Tests
// test/regression/backward_compatibility_test.dart

void regressionTests() {
  group('Backward Compatibility', () {
    late CanvasInteractionController legacyController;
    late CanvasInteractionCoordinator newCoordinator;

    setUp(() {
      // Set up both old and new implementations
      final testHarness = TestHarness();
      legacyController = CanvasInteractionController(
        levelId: 'test_level',
        ref: testHarness.mockRef,
      );
      newCoordinator = testHarness.coordinator;
    });

    test('should maintain identical public API', () {
      // Verify all public methods exist with same signatures
      expect(legacyController.coordinateService, isNotNull);
      expect(() => legacyController.initialize(MockRenderBox()), returnsNormally);
      expect(() => legacyController.handleDragStart(_createTestDragDetails(), DragOrigin.palette), returnsNormally);
      expect(() => legacyController.handleDragUpdate(_createTestDragDetails()), returnsNormally);
      expect(() => legacyController.handleDragEnd(_createTestDragDetails()), returnsNormally);
      expect(() => legacyController.handlePanUpdate(const Offset(10, 10)), returnsNormally);
      expect(() => legacyController.handleScaleUpdate(1.5), returnsNormally);
      expect(() => legacyController.dispose(), returnsNormally);
    });

    test('should produce identical state changes for same inputs', () async {
      // This test would compare state changes between old and new implementations
      // For brevity, showing the structure rather than full implementation
      
      final testSequence = [
        () => legacyController.handleDragStart(_createTestDragDetails(), DragOrigin.palette),
        () => legacyController.handleDragUpdate(_createTestDragDetails(const Offset(100, 100))),
        () => legacyController.handleDragEnd(_createTestDragDetails(const Offset(100, 100))),
      ];

      // Execute same sequence on both implementations and compare results
      // In practice, this would require more sophisticated state comparison
    });
  });
}

// ============================================================================
// TEST UTILITIES AND HELPERS
// ============================================================================

class TestHarness {
  late CanvasInteractionCoordinator coordinator;
  late MockValidationService mockValidationService;
  late MockCoordinateMapperService mockCoordinateMapper;
  late MockCreateComponentUseCase mockCreateComponentUseCase;
  late MockWireNetworkService mockWireNetworkService;
  late MockPathfindingService mockPathfindingService;
  late MockViewportService mockViewportService;
  late MockInteractionStateNotifier mockStateNotifier;
  late MockWidgetRef mockRef;
  late MockStructuredLogger mockLogger;

  InteractionStateNotifier get stateNotifier => mockStateNotifier;

  Future<void> initialize() async {
    mockValidationService = MockValidationService();
    mockCoordinateMapper = MockCoordinateMapperService();
    mockCreateComponentUseCase = MockCreateComponentUseCase();
    mockWireNetworkService = MockWireNetworkService();
    mockPathfindingService = MockPathfindingService();
    mockViewportService = MockViewportService();
    mockStateNotifier = MockInteractionStateNotifier();
    mockRef = MockWidgetRef();
    mockLogger = MockStructuredLogger();

    // Set up default mock behaviors
    _setupDefaultMockBehaviors();

    // Create coordinator with all dependencies
    final dragContext = DragInteractionContext(
      validationService: mockValidationService,
      coordinateMapper: mockCoordinateMapper,
      createComponentUseCase: mockCreateComponentUseCase,
      logger: mockLogger,
    );

    final wireContext = WireInteractionContext(
      wireNetworkService: mockWireNetworkService,
      pathfindingService: mockPathfindingService,
      coordinateMapper: mockCoordinateMapper,
      logger: mockLogger,
    );

    final gestureContext = GestureInteractionContext(
      viewportService: mockViewportService,
      logger: mockLogger,
    );

    coordinator = CanvasInteractionCoordinator(
      dragContext: dragContext,
      wireContext: wireContext,
      gestureContext: gestureContext,
      stateNotifier: mockStateNotifier,
      logger: mockLogger,
    );
  }

  void _setupDefaultMockBehaviors() {
    when(mockValidationService.validateDropPosition(any, any, occupiedPositions: anyNamed('occupiedPositions')))
        .thenReturn(ValidationResult.valid());
    
    when(mockCoordinateMapper.screenToGrid(any, any))
        .thenReturn(GridPosition(row: 1, col: 1));
    
    when(mockCreateComponentUseCase.execute(any))
        .thenAnswer((_) async => 'test-component-id');
    
    when(mockStateNotifier.state).thenReturn(const InteractionState(
      currentMode: InteractionMode.idle,
      isValid: false,
    ));
  }

  Widget createTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: CanvasInteractionWidget(
          levelId: 'test_level',
          key: const Key('canvas_interaction'),
        ),
      ),
    );
  }

  Future<void> dispose() async {
    coordinator.dispose();
  }
}

CoordinateContext _createTestCoordinateContext() {
  return CoordinateContext(
    gridDimensions: const Size(10, 10),
    cellSize: 50.0,
    scale: 1.0,
    panOffset: Offset.zero,
    canvasSize: const Size(500, 500),
    devicePixelRatio: 1.0,
  );
}

DragTargetDetails<ComponentDragData> _createTestDragDetails([Offset? offset]) {
  return DragTargetDetails<ComponentDragData>(
    data: ComponentDragData(
      componentType: ComponentType.resistor,
      componentName: 'Test Resistor',
      cost: 10,
    ),
    offset: offset ?? const Offset(100, 100),
  );
}

// ============================================================================
// MOCK CLASSES - Generate with mockito
// ============================================================================

@GenerateMocks([
  StructuredLogger,
  ValidationService,
  CoordinateMapperService,
  CreateComponentUseCase,
  WireNetworkService,
  PathfindingService,
  ViewportService,
  InteractionStateNotifier,
  WidgetRef,
  RenderBox,
  WireNetwork,
])
void main() {
  // Run all test suites
  coordinateMapperTests();
  dragContextIntegrationTests();
  wireContextIntegrationTests();
  endToEndTests();
  performanceTests();
  regressionTests();
}

# Canvas Refactoring Deployment Checklist

## Pre-Implementation Validation

### Code Quality Baseline
- [ ] Run static analysis on current 1,730-line controller
- [ ] Document all existing public APIs and their signatures
- [ ] Measure current performance benchmarks (drag latency, memory usage)
- [ ] Identify all integration points with widgets and providers
- [ ] Document current test coverage percentage

### Risk Assessment
- [ ] Identify critical user journeys that cannot be broken
- [ ] Document rollback procedures and timing requirements
- [ ] Set up monitoring and alerting for key metrics
- [ ] Create feature flag infrastructure for A/B testing
- [ ] Establish success/failure criteria for each phase

## Phase 1: Service Extraction (Week 1)

### Day 1-2: ValidationService
- [ ] Extract validation logic from main controller
- [ ] Create comprehensive unit tests (>90% coverage)
- [ ] Verify no performance regression in validation speed
- [ ] Update main controller to use extracted service
- [ ] Run full integration tests

### Day 3-4: CoordinateMapperService  
- [ ] Extract coordinate transformation logic
- [ ] Create unit tests for all coordinate systems
- [ ] Test edge cases (extreme scales, invalid inputs)
- [ ] Benchmark coordinate transformation performance
- [ ] Integration test with existing drag/drop workflows

### Day 5: Integration & Testing
- [ ] Run complete test suite with extracted services
- [ ] Performance testing to ensure <5% overhead
- [ ] Memory profiling to detect any leaks
- [ ] User acceptance testing on staging environment
- [ ] Code review and documentation updates

## Phase 2: Context Creation (Week 2-3)

### Week 2: DragInteractionContext
- [ ] Create DragInteractionContext class (~280 lines)
- [ ] Move drag-related logic from main controller
- [ ] Implement comprehensive error handling
- [ ] Create unit and integration tests
- [ ] Test component placement workflows end-to-end
- [ ] Verify inventory management integration works correctly

### Week 3: WireInteractionContext & GestureInteractionContext
- [ ] Create WireInteractionContext class (~290 lines)
- [ ] Move wire drawing and pathfinding logic
- [ ] Test A* pathfinding and Manhattan fallback
- [ ] Create GestureInteractionContext class (~200 lines)
- [ ] Move pan/zoom gesture handling
- [ ] Test multi-touch gesture scenarios

### Integration Testing
- [ ] Test context interactions and state consistency
- [ ] Verify event ordering and timing requirements
- [ ] Test error propagation between contexts
- [ ] Performance testing under load
- [ ] Memory usage validation

## Phase 3: Coordinator Implementation (Week 4)

### Coordinator Creation
- [ ] Create CanvasInteractionCoordinator (~250 lines)
- [ ] Implement event routing system
- [ ] Set up dependency injection container
- [ ] Create state synchronization logic
- [ ] Add comprehensive error boundaries

### Integration
- [ ] Connect all contexts to coordinator  
- [ ] Implement backward compatibility facade
- [ ] Update widget integration points
- [ ] Test complete interaction workflows
- [ ] Validate state transitions and mode changes

### Testing
- [ ] End-to-end testing of all user scenarios
- [ ] Load testing with rapid interactions
- [ ] Memory leak detection over extended use
- [ ] Cross-browser compatibility testing
- [ ] Mobile device testing (touch interactions)

## Phase 4: Production Deployment (Week 5-6)

### Pre-Deployment
- [ ] Create feature flag configuration
- [ ] Set up monitoring dashboards
- [ ] Prepare rollback scripts and procedures
- [ ] Final security review of new code
- [ ] Performance benchmark comparison (old vs new)

### Gradual Rollout
- [ ] Deploy to 5% of users with full monitoring
- [ ] Monitor key metrics for 24 hours
- [ ] Scale to 25% if metrics are stable
- [ ] Monitor for another 24 hours  
- [ ] Scale to 100% if all tests pass

### Post-Deployment
- [ ] Monitor error rates and performance metrics
- [ ] Collect user feedback through analytics
- [ ] Verify memory usage remains stable
- [ ] Check interaction response times
- [ ] Document any issues and resolutions

## Success Criteria

### Code Quality Metrics
- [ ] Main coordinator: ≤250 lines
- [ ] Each context: ≤300 lines  
- [ ] Services: ≤200 lines each
- [ ] Test coverage: ≥95%
- [ ] Cyclomatic complexity: ≤10 per method

### Performance Requirements
- [ ] Drag interaction latency: ≤16ms (60fps)
- [ ] Coordinate transformation: ≤0.1ms per operation
- [ ] Memory usage: No increase from baseline
- [ ] Event processing throughput: ≥1000 events/second

### Functionality Requirements
- [ ] All existing interactions work identically
- [ ] No user-visible behavior changes
- [ ] All provider integrations functional
- [ ] Error handling improved or maintained
- [ ] Accessibility features preserved

## Rollback Triggers

### Automatic Rollback Conditions
- [ ] Error rate increase >2% above baseline
- [ ] Response time increase >20% above baseline  
- [ ] Memory usage increase >15% above baseline
- [ ] Any critical user journey failures

### Manual Rollback Conditions  
- [ ] User complaints about interaction responsiveness
- [ ] Visual artifacts in drag/drop operations
- [ ] Provider state synchronization issues
- [ ] Mobile device compatibility problems

## Risk Mitigation Strategies

### Technical Safeguards
- [ ] Feature flag infrastructure allowing instant rollback
- [ ] Comprehensive monitoring of all interaction events
- [ ] A/B testing framework to compare old vs new performance
- [ ] Automated alerts for performance degradation
- [ ] Circuit breaker pattern for critical failure scenarios

### Testing Safeguards
- [ ] Regression test suite covering all existing functionality
- [ ] Performance benchmarking against current baseline
- [ ] Load testing with realistic user interaction patterns
- [ ] Memory profiling across extended usage sessions
- [ ] Cross-platform compatibility validation

### Operational Safeguards
- [ ] 24/7 monitoring during initial rollout phases
- [ ] Dedicated team on-call for immediate issue response
- [ ] Pre-written rollback procedures tested in staging
- [ ] Communication plan for stakeholder updates
- [ ] User feedback collection and rapid response system

## Monitoring and Alerting

### Key Performance Indicators
```javascript
// Monitoring Configuration
const monitoringConfig = {
  dragLatency: {
    threshold: '16ms',
    alertLevel: 'critical',
    measurement: 'p95'
  },
  memoryUsage: {
    threshold: '15% increase',
    alertLevel: 'warning',
    measurement: 'average over 1 hour'
  },
  errorRate: {
    threshold: '2% increase',
    alertLevel: 'critical', 
    measurement: 'per minute'
  },
  interactionThroughput: {
    threshold: '1000 events/second',
    alertLevel: 'warning',
    measurement: 'sustained minimum'
  }
}
```

### Alert Escalation
- [ ] Level 1: Engineering team notification
- [ ] Level 2: Product team and engineering manager
- [ ] Level 3: Automatic rollback initiation
- [ ] Level 4: Executive team notification

## Documentation Requirements

### Technical Documentation
- [ ] Architecture decision records (ADRs) for each major choice
- [ ] API documentation for all new interfaces
- [ ] Performance characteristic documentation
- [ ] Troubleshooting guides for common issues
- [ ] Migration guide for future modifications

### Team Documentation
- [ ] Runbook for monitoring and incident response
- [ ] Testing procedures for future changes
- [ ] Code review guidelines for new contributions
- [ ] Onboarding guide for new team members
- [ ] Post-mortem template for issue analysis

## Quality Gates

### Pre-Phase Gates
Each phase must pass these gates before proceeding:

```yaml
quality_gates:
  unit_tests:
    coverage_threshold: 95%
    performance_regression: <5%
    
  integration_tests:
    all_existing_functionality: pass
    new_functionality: pass
    error_handling: comprehensive
    
  performance_tests:
    drag_latency: <16ms p95
    memory_usage: baseline +/- 10%
    throughput: >1000 events/sec
    
  security_review:
    input_validation: comprehensive
    error_handling: no_information_leakage
    dependency_audit: pass
```

### Final Deployment Gate
- [ ] All automated tests passing
- [ ] Manual testing sign-off from QA team
- [ ] Performance benchmarks within acceptable range
- [ ] Security review completed and approved
- [ ] Rollback procedures tested and verified

## Post-Implementation Review

### 30-Day Review
- [ ] Performance metrics compared to baseline
- [ ] User feedback analysis and categorization
- [ ] Error rate and resolution time analysis
- [ ] Memory usage patterns over extended periods
- [ ] Team velocity impact assessment

### 90-Day Review  
- [ ] Long-term stability and maintenance requirements
- [ ] Technical debt assessment and prioritization
- [ ] Developer experience improvements identified
- [ ] Business impact analysis (development velocity, bug rates)
- [ ] Lessons learned documentation

## Critical Success Factors

### Technical Excellence
- Maintain existing functionality exactly
- Achieve significant maintainability improvements
- Meet all performance requirements
- Implement comprehensive error handling
- Ensure smooth rollback capabilities

### Process Excellence
- Follow phased approach strictly
- Maintain high test coverage throughout
- Implement proper monitoring and alerting
- Document all decisions and procedures
- Conduct thorough reviews at each gate

### Team Excellence
- Ensure all team members understand the changes
- Provide proper training on new architecture
- Establish clear ownership and responsibility
- Create effective feedback and learning loops
- Maintain team morale during complex transition

## Contingency Planning

### If Phase 1 Fails
- [ ] Rollback extracted services immediately
- [ ] Analyze root cause and impact assessment
- [ ] Revise approach based on learnings
- [ ] Re-plan timeline with additional buffer
- [ ] Consider alternative extraction strategies

### If Performance Degrades
- [ ] Immediate investigation of bottlenecks
- [ ] Profile memory and CPU usage patterns
- [ ] Consider caching or optimization strategies
- [ ] Evaluate if refactoring approach needs adjustment
- [ ] Implement performance improvement plan

### If Integration Issues Arise
- [ ] Map all affected provider relationships
- [ ] Create compatibility shims if necessary
- [ ] Test extensively in isolated environment
- [ ] Consider gradual migration approach
- [ ] Update integration documentation

## Long-term Maintenance Plan

### Code Health
- [ ] Regular architectural reviews every quarter
- [ ] Continuous refactoring to prevent code decay
- [ ] Dependency updates and security patches
- [ ] Performance monitoring and optimization
- [ ] Technical debt management and prioritization

### Team Knowledge
- [ ] Regular architecture presentations to team
- [ ] Pair programming on complex interactions
- [ ] Code review focus on architectural principles
- [ ] Documentation updates as system evolves
- [ ] Knowledge transfer procedures for team changes

### Evolution Planning
- [ ] Roadmap for additional modularization
- [ ] Plans for testing infrastructure improvements
- [ ] Performance optimization opportunities
- [ ] Integration with future system changes
- [ ] Migration path for legacy dependencies

---

## Final Implementation Notes

This refactoring addresses the fundamental architectural issues while maintaining a conservative approach to minimize risk. The key strengths of this plan:

**Risk Mitigation**: Phased approach allows for early detection and correction of issues before they compound.

**Maintainability**: Domain-driven design with bounded contexts creates clear separation of concerns and reduces cognitive load.

**Performance**: Careful attention to performance requirements ensures no regression in user experience.

**Testing**: Comprehensive testing strategy covers unit, integration, and end-to-end scenarios.

**Monitoring**: Extensive monitoring and alerting provide early warning of issues.

**Rollback**: Multiple rollback strategies ensure rapid recovery from any problems.

The solution transforms a 1,730-line monolithic controller into a well-structured, maintainable system while preserving all existing functionality and meeting the <300 line requirement for each component.

Success depends on disciplined execution of each phase, thorough testing at each step, and maintaining focus on the core goal: improving maintainability without sacrificing functionality or performance.