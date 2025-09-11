# Circuit STEM - Clean Architecture with Use Case Patterns

## Overview

This document describes the clean architecture implementation in Circuit STEM, focusing on the use case patterns that provide proper separation of concerns and maintainable code structure.

## Architecture Layers

### 1. Presentation Layer
**Location**: `lib/presentation/`
**Responsibility**: UI rendering and user interaction handling

#### Key Components:
- **Controllers**: Handle UI state and user gestures
- **Widgets**: Render UI components
- **Helpers**: Provide abstracted access to business logic

#### Use Case Integration:
```dart
// Presentation controllers use abstracted methods
class CanvasInteractionController {
  final InteractionUseCase _interactionUseCase;

  Future<void> _placeComponent(GridPosition position, ComponentType type) async {
    // Use abstracted use case instead of direct provider access
    await CreateComponentUseCase.placeComponent(
      type, position.row, position.col,
      _notifiers, _transaction
    );
  }
}
```

### 2. Application Layer
**Location**: `lib/application/`
**Responsibility**: Business logic orchestration and use case implementation

#### Key Components:
- **Use Cases**: Business logic encapsulation
- **Application Services**: Cross-cutting concerns
- **State Notifiers**: State management coordination

#### Use Case Patterns:

##### InteractionUseCase
```dart
class InteractionUseCase {
  final WidgetRef ref;
  final String levelId;

  // Abstracted service access
  FeedbackService getFeedbackService() => ref.read(feedbackServiceProvider);
  PathfindingService getPathfindingService() => ref.read(pathfindingServiceProvider(levelId));
  WireNetworkService getWireNetworkService() => ref.read(wireNetworkServiceProvider(levelId));

  // Business logic methods
  Future<Result<List<GridPosition>>> findPath(GridPosition start, GridPosition end) async {
    // Implementation using abstracted services
  }

  Future<Result<dynamic>> createWireNetwork(ComponentPort startPort, ComponentPort endPort, List<GridPosition> path) async {
    // Implementation using abstracted services
  }
}
```

##### CreateComponentUseCase
```dart
class CreateComponentUseCase extends NotifierIntegratedUseCase<CreateComponentFromTemplateAction> {
  final PowerSimulationService _simulation;
  final ComponentFactory _factory;

  @override
  Future<Result<void>> executeWithNotifiers(
    CreateComponentFromTemplateAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    // Business logic implementation
    // - Position validation
    // - Inventory management
    // - Component creation
    // - State updates via commands
  }

  // Static convenience method for easy access
  static Future<Result<void>> placeComponent(
    ComponentType type,
    int row,
    int col,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    final useCase = CreateComponentUseCase(PowerSimulationService(), ComponentFactory());
    final action = CreateComponentFromTemplateAction(
      templateId: type.name,
      row: row,
      col: col,
    );
    return useCase.executeWithNotifiers(action, notifiers, transaction);
  }
}
```

### 3. Domain Layer
**Location**: `lib/domain/`
**Responsibility**: Business entities and rules

#### Key Components:
- **Entities**: Business objects (Component, Grid, Level)
- **Value Objects**: Immutable data structures
- **Business Rules**: Domain logic

### 4. Infrastructure Layer
**Location**: `lib/core/`, `lib/infrastructure/`
**Responsibility**: External concerns and implementations

#### Key Components:
- **Services**: External service implementations
- **Repositories**: Data access abstractions
- **Providers**: Dependency injection

## Use Case Pattern Implementation

### Pattern Structure

```
Presentation Layer
    ↓ (abstracted calls)
Application Layer (Use Cases)
    ↓ (business logic)
Domain Layer (Entities & Rules)
    ↓ (data access)
Infrastructure Layer (Services & Data)
```

### Key Patterns Implemented

#### 1. Abstracted Provider Access
```dart
// ❌ BEFORE: Direct provider access (tight coupling)
final gameState = ref.read(providers_v3.enhancedGameStateNotifierProvider);

// ✅ AFTER: Abstracted through use case
final gameState = _interactionUseCase.getGameState();
```

#### 2. Use Case Orchestration
```dart
// Use cases coordinate multiple services
class InteractionUseCase {
  Future<Result<List<GridPosition>>> findPath(GridPosition start, GridPosition end) async {
    try {
      final result = await getPathfindingService().findPath(
        start, end,
        algorithm: PathfindingAlgorithm.astar,
        occupiedPositions: <GridPosition>{},
        maxNodes: 500,
      );

      return result.success
        ? Success(result.path)
        : Failure('Pathfinding failed');
    } catch (e) {
      return Failure('Pathfinding error: $e');
    }
  }
}
```

#### 3. Command Pattern Integration
```dart
// Use cases dispatch commands for state changes
class CreateComponentUseCase {
  @override
  Future<Result<void>> executeWithNotifiers(action, notifiers, transaction) async {
    // Business logic validation
    // ...

    // Dispatch command for state update
    transaction.onCommit(() async {
      final updatedGrid = _simulation.simulatePowerFlow(newGrid);
      notifiers.grid.setState(updatedGrid);
    });
  }
}
```

#### 4. Service Abstraction
```dart
// Services abstracted through use case methods
class InteractionUseCase {
  FeedbackService getFeedbackService() => ref.read(feedbackServiceProvider);
  PathfindingService getPathfindingService() => ref.read(pathfindingServiceProvider(levelId));
  WireNetworkService getWireNetworkService() => ref.read(wireNetworkServiceProvider(levelId));
}
```

## Benefits Achieved

### 1. Loose Coupling
- Presentation layer no longer directly depends on providers
- Services can be easily mocked and tested
- Changes in infrastructure don't affect presentation

### 2. Testability
- Use cases can be unit tested independently
- Services can be mocked easily
- Business logic isolated from UI concerns

### 3. Maintainability
- Clear separation of concerns
- Business logic centralized in use cases
- Easy to modify and extend functionality

### 4. Reusability
- Use cases can be reused across different UI components
- Business logic abstracted from presentation details
- Consistent behavior across the application

## Implementation Examples

### Drag and Drop Flow
```
1. User drags component (Presentation)
2. CanvasInteractionController receives gesture
3. Controller calls InteractionUseCase.placeComponent()
4. Use case validates position and inventory
5. Use case dispatches CreateComponentCommand
6. Command updates grid state
7. UI reflects changes through providers
```

### Wire Drawing Flow
```
1. User draws wire path (Presentation)
2. Controller calls InteractionUseCase.findPath()
3. Use case uses PathfindingService to calculate path
4. Use case calls InteractionUseCase.createWireNetwork()
5. WireNetworkService creates network from path
6. State updated through commands
```

## Testing Strategy

### Unit Tests
```dart
void main() {
  test('InteractionUseCase should find path successfully', () async {
    final useCase = InteractionUseCase(mockRef, 'test_level');
    final result = await useCase.findPath(start, end);

    expect(result.isSuccess, isTrue);
    expect(result.data, isNotEmpty);
  });
}
```

### Integration Tests
```dart
void main() {
  test('UnifiedCoordinateService should handle transformations correctly', () {
    final config = GridConfiguration(rows: 10, cols: 10, cellSize: 60.0, scale: 1.0, panOffset: Offset.zero);
    final screenPos = Offset(120.0, 180.0);
    final gridPos = UnifiedCoordinateService().screenToGrid(screenPos, config);

    expect(gridPos.dx, closeTo(2.0, 0.1));
    expect(gridPos.dy, closeTo(3.0, 0.1));
  });
}
```

## Migration Guide

### For New Features
1. Create use case in `lib/application/use_cases/`
2. Implement business logic with service abstractions
3. Add static convenience methods for easy access
4. Update presentation controllers to use use case methods
5. Add comprehensive tests

### For Existing Code
1. Identify direct provider access in presentation layer
2. Create corresponding use case method
3. Replace direct calls with use case calls
4. Update tests to use new patterns
5. Remove deprecated direct access patterns

## Conclusion

The use case pattern implementation provides:
- **Clean Architecture**: Proper layer separation
- **Maintainable Code**: Centralized business logic
- **Testable Design**: Easy mocking and testing
- **Flexible Structure**: Easy to modify and extend
- **Consistent Patterns**: Uniform approach across the application

This architecture ensures the Circuit STEM application remains maintainable and scalable as it grows in complexity.