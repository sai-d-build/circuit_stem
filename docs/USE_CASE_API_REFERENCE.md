# Circuit STEM - Use Case API Reference

## Overview

This document provides comprehensive API reference for all use case interfaces implemented in the Circuit STEM application. Use cases provide abstracted access to business logic while maintaining clean architecture principles.

## InteractionUseCase

### Class Overview
```dart
class InteractionUseCase {
  final WidgetRef ref;
  final String levelId;

  const InteractionUseCase(this.ref, this.levelId);
}
```

### Constructor
```dart
InteractionUseCase(WidgetRef ref, String levelId)
```
- **ref**: WidgetRef for accessing Riverpod providers
- **levelId**: Current level identifier for scoped providers

### Methods

#### Service Access Methods

##### `FeedbackService getFeedbackService()`
Returns the feedback service for showing user notifications.

**Returns**: `FeedbackService` instance

**Example**:
```dart
final feedbackService = interactionUseCase.getFeedbackService();
await feedbackService.showSuccess(context, 'Component placed successfully');
```

##### `PathfindingService getPathfindingService()`
Returns the pathfinding service for calculating wire paths.

**Returns**: `PathfindingService` instance

**Example**:
```dart
final pathfindingService = interactionUseCase.getPathfindingService();
final result = await pathfindingService.findPath(start, end);
```

##### `WireNetworkService getWireNetworkService()`
Returns the wire network service for managing circuit connections.

**Returns**: `WireNetworkService` instance

**Example**:
```dart
final wireService = interactionUseCase.getWireNetworkService();
await wireService.createNetworkFromPath(startPort, endPort, path);
```

##### `GameState getGameState()`
Returns the current game state.

**Returns**: `GameState` instance

**Example**:
```dart
final gameState = interactionUseCase.getGameState();
final componentCount = gameState.grid.components.length;
```

##### `GameStateNotifier getGameStateNotifier()`
Returns the game state notifier for state updates.

**Returns**: `GameStateNotifier` instance

**Example**:
```dart
final notifier = interactionUseCase.getGameStateNotifier();
await notifier.placeComponent(ComponentType.resistor, 1, 2);
```

##### `InteractionStateNotifier getInteractionStateNotifier(String levelId)`
Returns the interaction state notifier for the specified level.

**Parameters**:
- `levelId`: Level identifier

**Returns**: `InteractionStateNotifier` instance

**Example**:
```dart
final interactionNotifier = interactionUseCase.getInteractionStateNotifier('level_1');
await interactionNotifier.updateMode(InteractionMode.placing);
```

##### `HistoryNotifier getHistoryNotifier()`
Returns the history notifier for undo/redo functionality.

**Returns**: `HistoryNotifier` instance

**Example**:
```dart
final historyNotifier = interactionUseCase.getHistoryNotifier();
await historyNotifier.undo();
```

##### `GameProgressNotifier getProgressNotifier()`
Returns the progress notifier for tracking game progress.

**Returns**: `GameProgressNotifier` instance

**Example**:
```dart
final progressNotifier = interactionUseCase.getProgressNotifier();
await progressNotifier.updateScore(100);
```

##### `ComponentSelectionNotifier getSelectionNotifier()`
Returns the selection notifier for component selection management.

**Returns**: `ComponentSelectionNotifier` instance

**Example**:
```dart
final selectionNotifier = interactionUseCase.getSelectionNotifier();
await selectionNotifier.selectComponent('component_123');
```

##### `ViewportState getViewportState()`
Returns the current viewport state.

**Returns**: `ViewportState` instance

**Example**:
```dart
final viewportState = interactionUseCase.getViewportState();
final currentZoom = viewportState.scale;
```

##### `ViewportServiceNotifier getViewportServiceNotifier()`
Returns the viewport service notifier for viewport updates.

**Returns**: `ViewportServiceNotifier` instance

**Example**:
```dart
final viewportNotifier = interactionUseCase.getViewportServiceNotifier();
await viewportNotifier.updateScale(1.5);
```

#### Business Logic Methods

##### `Future<Result<List<GridPosition>>> findPath(GridPosition start, GridPosition end, {Set<GridPosition>? occupiedPositions})`
Finds a path between two grid positions using A* algorithm.

**Parameters**:
- `start`: Starting grid position
- `end`: Ending grid position
- `occupiedPositions`: Optional set of occupied positions to avoid

**Returns**: `Future<Result<List<GridPosition>>>`

**Example**:
```dart
final result = await interactionUseCase.findPath(
  GridPosition(row: 0, col: 0),
  GridPosition(row: 5, col: 5),
  occupiedPositions: occupiedPositions,
);

if (result.isSuccess) {
  final path = result.data;
  // Use path for wire drawing
}
```

##### `Future<Result<WireNetwork>> createWireNetwork(ComponentPort startPort, ComponentPort endPort, List<GridPosition> path)`
Creates a wire network between two component ports along the specified path.

**Parameters**:
- `startPort`: Starting component port
- `endPort`: Ending component port
- `path`: List of grid positions for the wire path

**Returns**: `Future<Result<WireNetwork>>`

**Example**:
```dart
final result = await interactionUseCase.createWireNetwork(
  startPort,
  endPort,
  path,
);

if (result.isSuccess) {
  final network = result.data;
  // Network created successfully
}
```

##### `void showSuccessFeedback(BuildContext context, String message)`
Shows success feedback to the user.

**Parameters**:
- `context`: Build context for showing feedback
- `message`: Success message to display

**Example**:
```dart
interactionUseCase.showSuccessFeedback(context, 'Component placed successfully!');
```

##### `void showErrorFeedback(BuildContext context, String message)`
Shows error feedback to the user.

**Parameters**:
- `context`: Build context for showing feedback
- `message`: Error message to display

**Example**:
```dart
interactionUseCase.showErrorFeedback(context, 'Invalid placement position');
```

##### `void updateViewportPan(Offset delta)`
Updates the viewport pan by the specified delta.

**Parameters**:
- `delta`: Offset delta for panning

**Example**:
```dart
interactionUseCase.updateViewportPan(Offset(10.0, -5.0));
```

##### `void updateViewportScale(double scale)`
Updates the viewport scale.

**Parameters**:
- `scale`: New scale value

**Example**:
```dart
interactionUseCase.updateViewportScale(1.2);
```

## CreateComponentUseCase

### Class Overview
```dart
class CreateComponentUseCase extends NotifierIntegratedUseCase<CreateComponentFromTemplateAction> {
  final PowerSimulationService _simulation;
  final ComponentFactory _factory;

  const CreateComponentUseCase(this._simulation, this._factory);
}
```

### Constructor
```dart
CreateComponentUseCase(PowerSimulationService simulation, ComponentFactory factory)
```
- **simulation**: Power simulation service for circuit analysis
- **factory**: Component factory for creating circuit components

### Static Methods

##### `Future<Result<void>> placeComponent(ComponentType type, int row, int col, NotifierContext notifiers, GameTransaction transaction)`
Convenience method for placing a component on the grid.

**Parameters**:
- `type`: Type of component to place
- `row`: Grid row position
- `col`: Grid column position
- `notifiers`: Notifier context for state management
- `transaction`: Game transaction for rollback support

**Returns**: `Future<Result<void>>`

**Example**:
```dart
final result = await CreateComponentUseCase.placeComponent(
  ComponentType.resistor,
  1, 2,
  notifierContext,
  transaction,
);

if (result.isSuccess) {
  // Component placed successfully
}
```

### Instance Methods

##### `Future<Result<void>> executeWithNotifiers(CreateComponentFromTemplateAction action, NotifierContext notifiers, GameTransaction transaction)`
Executes the use case with the provided action and context.

**Parameters**:
- `action`: Create component action with template and position
- `notifiers`: Notifier context for state management
- `transaction`: Game transaction for rollback support

**Returns**: `Future<Result<void>>`

## UnifiedCoordinateService

### Class Overview
```dart
class UnifiedCoordinateService {
  static final UnifiedCoordinateService _instance = UnifiedCoordinateService._();
  factory UnifiedCoordinateService() => _instance;
  UnifiedCoordinateService._();
}
```

Singleton service for coordinate transformations.

### Methods

##### `Offset screenToGrid(Offset screenPos, GridConfiguration config, {RenderBox? renderBox})`
Converts screen coordinates to grid coordinates.

**Parameters**:
- `screenPos`: Screen position to convert
- `config`: Grid configuration
- `renderBox`: Optional render box for local coordinate conversion

**Returns**: `Offset` (grid coordinates)

**Example**:
```dart
final gridPos = UnifiedCoordinateService().screenToGrid(
  Offset(120.0, 180.0),
  gridConfig,
);
```

##### `Offset gridToScreen(Offset gridPos, GridConfiguration config)`
Converts grid coordinates to screen coordinates.

**Parameters**:
- `gridPos`: Grid position to convert
- `config`: Grid configuration

**Returns**: `Offset` (screen coordinates)

**Example**:
```dart
final screenPos = UnifiedCoordinateService().gridToScreen(
  Offset(2.0, 3.0),
  gridConfig,
);
```

##### `Offset snapToGrid(Offset screenPos, GridConfiguration config, {RenderBox? renderBox})`
Snaps screen coordinates to the nearest grid cell center.

**Parameters**:
- `screenPos`: Screen position to snap
- `config`: Grid configuration
- `renderBox`: Optional render box for local coordinate conversion

**Returns**: `Offset` (snapped screen coordinates)

**Example**:
```dart
final snappedPos = UnifiedCoordinateService().snapToGrid(
  Offset(125.0, 175.0),
  gridConfig,
);
```

##### `bool isWithinGridBounds(Offset screenPosition, GridConfiguration config, {RenderBox? renderBox})`
Checks if screen coordinates are within grid bounds.

**Parameters**:
- `screenPosition`: Screen position to check
- `config`: Grid configuration
- `renderBox`: Optional render box for local coordinate conversion

**Returns**: `bool`

**Example**:
```dart
final isValid = UnifiedCoordinateService().isWithinGridBounds(
  Offset(120.0, 180.0),
  gridConfig,
);
```

##### `Offset? getValidGridPosition(Offset screenPosition, GridConfiguration config, {RenderBox? renderBox})`
Gets valid grid position from screen coordinates, returns null if out of bounds.

**Parameters**:
- `screenPosition`: Screen position to convert
- `config`: Grid configuration
- `renderBox`: Optional render box for local coordinate conversion

**Returns**: `Offset?` (grid coordinates or null)

**Example**:
```dart
final gridPos = UnifiedCoordinateService().getValidGridPosition(
  Offset(120.0, 180.0),
  gridConfig,
);
if (gridPos != null) {
  // Valid position
}
```

##### `List<Offset> getGridPositionsInScreenRect(Rect screenRect, GridConfiguration config, {RenderBox? renderBox})`
Gets all grid positions within a screen rectangle.

**Parameters**:
- `screenRect`: Screen rectangle to check
- `config`: Grid configuration
- `renderBox`: Optional render box for local coordinate conversion

**Returns**: `List<Offset>` (grid positions)

**Example**:
```dart
final positions = UnifiedCoordinateService().getGridPositionsInScreenRect(
  Rect.fromLTRB(0, 0, 300, 300),
  gridConfig,
);
```

##### `Rect calculateVisibleGridBounds(GridConfiguration config, Size screenSize)`
Calculates the visible grid bounds for the current screen size.

**Parameters**:
- `config`: Grid configuration
- `screenSize`: Screen size

**Returns**: `Rect` (visible grid bounds)

**Example**:
```dart
final visibleBounds = UnifiedCoordinateService().calculateVisibleGridBounds(
  gridConfig,
  Size(800, 600),
);
```

##### `void clearCache()`
Clears the coordinate transformation cache.

**Example**:
```dart
UnifiedCoordinateService().clearCache();
```

## GridConfiguration

### Class Overview
```dart
class GridConfiguration {
  final int rows;
  final int cols;
  final double cellSize;
  final double scale;
  final Offset panOffset;

  const GridConfiguration({
    required this.rows,
    required this.cols,
    required this.cellSize,
    required this.scale,
    required this.panOffset,
  });
}
```

Configuration class for grid operations.

### Constructors

##### `GridConfiguration({required int rows, required int cols, required double cellSize, required double scale, required Offset panOffset})`
Creates a grid configuration with the specified parameters.

##### `GridConfiguration.fromCanvas({required int rows, required int cols, required double cellSize, required double scale, required Offset panOffset})`
Creates a grid configuration from canvas parameters.

### Methods

##### `GridConfiguration copyWith({int? rows, int? cols, double? cellSize, double? scale, Offset? panOffset})`
Creates a copy with modified values.

**Returns**: `GridConfiguration`

**Example**:
```dart
final newConfig = config.copyWith(scale: 1.5);
```

## Result<T>

### Class Overview
Generic result type for use case operations.

### Constructors

##### `Success(T data)`
Creates a successful result with data.

##### `Failure(String error)`
Creates a failed result with error message.

### Properties

##### `bool get isSuccess`
Returns true if the result is successful.

##### `bool get isFailure`
Returns true if the result is a failure.

##### `T get data`
Returns the data for successful results.

##### `String get error`
Returns the error message for failed results.

### Example Usage
```dart
Future<Result<List<GridPosition>>> findPath(GridPosition start, GridPosition end) async {
  try {
    final path = await calculatePath(start, end);
    return Success(path);
  } catch (e) {
    return Failure('Path calculation failed: $e');
  }
}

// Usage
final result = await findPath(start, end);
if (result.isSuccess) {
  final path = result.data;
  // Use path
} else {
  final error = result.error;
  // Handle error
}
```

## Error Handling

All use case methods return `Result<T>` types to provide consistent error handling:

- **Success**: Contains the operation result data
- **Failure**: Contains an error message describing what went wrong

This approach ensures:
- Predictable error handling across the application
- Clear separation between success and failure cases
- Easy testing of both success and error scenarios

## Testing Examples

### Unit Testing Use Cases
```dart
void main() {
  test('InteractionUseCase should find path successfully', () async {
    final useCase = InteractionUseCase(mockRef, 'test_level');
    final result = await useCase.findPath(start, end);

    expect(result.isSuccess, isTrue);
    expect(result.data, isNotEmpty);
  });

  test('CreateComponentUseCase should handle invalid positions', () async {
    final result = await CreateComponentUseCase.placeComponent(
      ComponentType.resistor, -1, -1, notifiers, transaction
    );

    expect(result.isFailure, isTrue);
    expect(result.error, contains('Invalid position'));
  });
}
```

### Integration Testing
```dart
void main() {
  test('Coordinate transformations should be consistent', () {
    final config = GridConfiguration(
      rows: 10, cols: 10, cellSize: 60.0, scale: 1.0, panOffset: Offset.zero
    );

    final original = Offset(180.0, 240.0);
    final grid = UnifiedCoordinateService().screenToGrid(original, config);
    final back = UnifiedCoordinateService().gridToScreen(grid, config);

    expect(back.dx, closeTo(original.dx, 1.0));
    expect(back.dy, closeTo(original.dy, 1.0));
  });
}
```

This API reference provides comprehensive documentation for all use case interfaces, enabling developers to effectively use the clean architecture patterns implemented in Circuit STEM.