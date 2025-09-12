# CircuitSTEM Drag-and-Drop Refinement: CanvasInteractionController Architecture

## Executive Summary: StateNotifier Wins Over Singleton

**Updated Decision**: After comprehensive analysis, the CanvasInteractionController (StateNotifier) pattern is superior to the DragService (Singleton) approach. This aligns with Flutter best practices, Riverpod architecture, and the project's existing documentation.

## Architecture Decisions

### ✅ CORRECT APPROACH: CanvasInteractionController (StateNotifier)
- **Pros**: Scoped lifecycle, reactive updates, testable, Riverpod-compatible
- **Cons**: None significant - this is the modern Flutter standard
- **Evidence**: Matches project's architecture documentation, StateNotifier pattern

### ❌ AVOIDED APPROACH: DragService (Singleton)
- **Pros**: Seemed simple initially
- **Cons**: Global mutable state, bypasses Riverpod, hard to test
- **Evidence**: Anti-pattern in modern Flutter, violates dependency injection principles

---

## Table of Contents

### [Phase 1: Foundation Establishment (Week 1)](#phase-1-foundation-establishment-week-1)
### [Phase 2: Conflict Elimination (Week 1-2)](#phase-2-conflict-elimination-week-1-2)
### [Phase 3: Validation Enhancement (Week 3)](#phase-3-validation-enhancement-week-3)
### [Phase 4: Reliability & Monitoring (Week 4)](#phase-4-reliability--monitoring-week-4)
### [Phase 5: Testing & Optimization (Ongoing)](#phase-5-testing--optimization-ongoing)
### [Verification Checklists](#verification-checklists)
### [Rollback Procedures](#rollback-procedures)
### [Success Metrics](#success-metrics)

---

## Phase 1: Foundation Establishment (Week 1)

### 📋 Phase 1 Objectives
- [ ] Eliminate singleton anti-pattern from canvas_interaction_widget.dart
- [ ] Consolidate all drag logic in CanvasInteractionController
- [ ] Establish clear separation of concerns
- [ ] Preserve existing functionality during transition

### 🔧 Technical Implementation

#### Step 1.1: Remove DragService Integration

**File: `lib/presentation/features/game/widgets/canvas_interaction_widget.dart`**

**BEFORE (Current problematic implementation):**
```dart
// Line 32-33: Singleton instantiation
late final drag_service.DragService _dragService;

// Line 43-44: Direct instantiation (anti-pattern)
_dragService = drag_service.DragService();

// Lines 47-122: Bypassing Riverpod state management
_dragService.setDropValidator((dragData, position) {
  // Complex validation logic mixed with global state
});
```

**AFTER (StateNotifier-first approach):**
```dart
// ✅ CORRECT: Rely on existing controller integration
// Remove all DragService imports and usage
// Controller handles everything through StateNotifier pattern

class CanvasInteractionWidget extends ConsumerStatefulWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final interactionState = ref.watch(interactionStateProvider(levelId));

    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          onScaleStart: _handleScaleStart,
          onScaleUpdate: _handleScaleUpdate,
          onScaleEnd: _handleScaleEnd,
          child: DragTarget<ComponentDragData>(
            onWillAcceptWithDetails: (details) => _controller.canAcceptDrag(details),
            onAcceptWithDetails: (details) => _controller.handleDragEnd(details),
            builder: (context, candidateData, rejectedData) {
              return _buildCanvas(interactionState);
            },
          ),
        );
      },
    );
  }
}
```

#### Step 1.2: Consolidate Controller Methods

**Enhance CanvasInteractionController with consolidated validation:**

```dart
class CanvasInteractionController {
  // Enhanced validation combining both widget logics
  bool canAcceptDrag(DragTargetDetails<ComponentDragData> details) {
    // Consolidated validation from both canvas_drag_drop_layer and canvas_interaction_widget
    return _validateComponentType(details.data) &&
           _validatePosition(details.offset) &&
           _validateInventory(details.data);
  }

  // Single drag end handler
  void handleDragEnd(DragTargetDetails<ComponentDragData> details) {
    if (_stateNotifier.isValid) {
      _placeComponent(details);
    } else {
      _handleInvalidDrop();
    }
  }
}
```

### ✅ Phase 1 Success Criteria
- [ ] No DragService imports in canvas_interaction_widget.dart
- [ ] Single DragTarget interaction point
- [ ] All validation logic consolidated in controller
- [ ] Existing user functionality preserved
- [ ] No breaking changes detected

---

## Phase 2: Conflict Elimination (Week 1-2)

### 📋 Phase 2 Objectives
- [ ] Completely eliminate canvas_drag_drop_layer.dart DragTarget
- [ ] Consolidate validation logic from both widgets
- [ ] Merge event handling approaches
- [ ] Ensure single source of truth for drag operations

### 🔧 Technical Implementation

#### Step 2.1: Deprecate CanvasDragDropLayer

**File: `lib/presentation/features/game/widgets/canvas_drag_drop_layer.dart`**

Add deprecation notice and feature flag:

```dart
// DEPRECATED: This will be removed in Phase 2 completion
class CanvasDragDropLayer extends ConsumerStatefulWidget {
  const CanvasDragDropLayer({
    super.key,
    required this.child,
    required this.levelId,
    @deprecated this.useLegacyMode = false, // Feature flag for gradual removal
  });

  final bool useLegacyMode;

  @override
  ConsumerState<CanvasDragDropLayer> createState() => _CanvasDragDropLayerState();
}

class _CanvasDragDropLayerState extends ConsumerState<CanvasDragDropLayer> {
  @override
  Widget build(BuildContext context) {
    if (widget.useLegacyMode) {
      return _buildLegacyDragTarget();
    }

    // Phase 2: Return child directly (no DragTarget)
    return widget.child;
  }

  Widget _buildDeprecatedDragTarget() {
    // TEMPORARY: Legacy implementation with warnings
    StructuredLogger.warning(
      'CanvasDragDropLayer: Using deprecated drag target',
      context: {
        'levelId': widget.levelId,
        'phase': 'transition',
        'recommendation': 'Consolidate into CanvasInteractionController',
      }
    );

    return DragTarget<ComponentDragData>(
      // ... existing but deprecated logic ...
    );
  }
}
```

#### Step 2.2: Migrate Validation Rules

**Create unified validation service:**

```dart
class ConsolidatedDragValidation {
  static const Duration VALIDATION_THROTTLE = Duration(milliseconds: 100);

  // Singleton pattern replaced with service locator
  static ConsolidatedDragValidation? _instance;

  static ConsolidatedDragValidation get instance {
    _instance ??= ConsolidatedDragValidation._();
    return _instance;
  }

  ConsolidatedDragValidation._();

  bool validateComponentDrop(ComponentDragData data, Offset position, GameState gameState) {
    // Consolidated validation from both widgets
    final gridPosition = _convertToGridPosition(position);
    if (gridPosition == null) return false;

    return _validateBoundaries(gridPosition, gameState) &&
           _validateOccupation(gridPosition, gameState) &&
           _validateInventory(data.componentType, gameState);
  }

  bool _validateBoundaries(Offset? position, GameState gameState) {
    if (position == null) return false;
    return position.dx >= 0 && position.dy >= 0 &&
           position.dx < gameState.grid.cols && position.dy < gameState.grid.rows;
  }

  bool _validateOccupation(Offset position, GameState gameState) {
    return gameState.grid.components.values
        .where((component) => component.row == position.dy.round() &&
                             component.col == position.dx.round())
        .isEmpty;
  }

  Map<String, dynamic> _validateInventory(ComponentType type, GameState gameState) {
    // Return detailed inventory validation result
    // Combines logic from both original widgets
  }
}
```

### ✅ Phase 2 Success Criteria
- [ ] canvas_drag_drop_layer.dart no longer handles DragTarget events
- [ ] Feature flag allows gradual rollback if needed
- [ ] All validation logic centralized in one place
- [ ] No duplicate gesture handling
- [ ] Clear transition path for rollback

---

## Phase 3: Validation Enhancement (Week 3)

### 📋 Phase 3 Objectives
- [ ] Implement robust error handling
- [ ] Add user feedback mechanisms
- [ ] Enhance state transitions
- [ ] Add business logic validation

### 🔧 Technical Implementation

#### Step 3.1: Enhanced Error Handling

**Create comprehensive error types:**

```dart
enum DragDropErrorType {
  invalidPosition('Drop position outside grid boundaries'),
  positionOccupied('Grid position already occupied'),
  insufficientInventory('Not enough components in inventory'),
  coordinateTransformationFailed('Unable to convert screen coordinates'),
  componentValidationFailed('Component type validation error'),
  gameStateInaccessible('Cannot access current game state'),
  renderBoxUnavailable('Canvas rendering context unavailable');

  const DragDropErrorType(this.message);
  final String message;
}

class DragDropException implements Exception {
  final DragDropErrorType type;
  final String? details;
  final Map<String, dynamic>? context;

  const DragDropException(this.type, {this.details, this.context});

  @override
  String toString() => 'DragDropException: ${type.name} - ${type.message}${details != null ? ' ($details)' : ''}';
}
```

#### Step 3.2: User Feedback Integration

**Enhanced state with user feedback:**

```dart
@freezed
class InteractionState with _$InteractionState {
  const factory InteractionState({
    required InteractionMode currentMode,
    ComponentDragData? componentData,
    GridPosition? targetPosition,
    @Default(false) bool isValid,
    @Default(<GridPosition>[]) List<GridPosition> path,
    DragDropErrorType? errorType,
    String? errorMessage,
    FeedbackType? userFeedback,
    @Default(false) bool showErrorOverlay,
    DateTime? lastErrorTime,
  }) = _InteractionState;
}

enum FeedbackType {
  success('Component placed successfully'),
  error('Unable to place component'),
  warning('Component placement requires adjustment'),
  info('Drag to place component on grid');

  const FeedbackType(this.message);
  final String message;
}
```

#### Step 3.3: Business Logic Validation

**Enhanced validation service:**

```dart
class EnhancedDragValidator {
  final DragStateManager _stateManager;
  final CoordinateSystemService _coordinateService;

  ValidationResult validateComplete(ComponentDragData data, Offset screenPosition) {
    // Step 1: Coordinate transformation
    final transformResult = _validateCoordinateTransformation(screenPosition);
    if (!transformResult.isValid) {
      return ValidationResult.invalid(
        DragDropErrorType.coordinateTransformationFailed,
        details: transformResult.errorMessage
      );
    }

    // Step 2: Grid position validation
    final gridPosition = transformResult.gridPosition!;
    final gridResult = _validateGridPosition(gridPosition);
    if (!gridResult.isValid) {
      return gridResult;
    }

    // Step 3: Business rule validation
    final businessResult = _validateBusinessRules(data, gridPosition);
    if (!businessResult.isValid) {
      return businessResult;
    }

    return ValidationResult.valid(gridPosition: gridPosition);
  }

  ValidationResult _validateBusinessRules(ComponentDragData data, GridPosition position) {
    // Implement component-specific business rules
    switch (data.componentType) {
      case ComponentType.battery:
        return _validateBatteryPlacement(data, position);
      case ComponentType.wire:
        return _validateWirePlacement(data, position);
      case ComponentType.resistor:
        return _validateResistorPlacement(data, position);
      default:
        return ValidationResult.valid();
    }
  }
}
```

### ✅ Phase 3 Success Criteria
- [ ] Comprehensive error types defined
- [ ] User feedback working through UI
- [ ] Business logic validation complete
- [ ] State transitions validated
- [ ] Error recovery mechanisms in place

---

## Phase 4: Reliability & Monitoring (Week 4)

### 📋 Phase 4 Objectives
- [ ] Implement comprehensive logging
- [ ] Add performance monitoring
- [ ] Create diagnostic tools
- [ ] Establish monitoring dashboards

### 🔧 Technical Implementation

#### Step 4.1: Comprehensive Logging

```dart
class DragDropLogger {
  static const String component = 'CanvasInteractionController';

  void logDragInitiation(ComponentDragData data, Offset startPosition) {
    StructuredLogger.info(
      'Drag operation initiated',
      context: {
        'component': component,
        'operation': 'drag_start',
        'componentType': data.componentType.toString(),
        'componentName': data.componentName,
        'startPosition': startPosition.toString(),
        'cost': data.cost,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      tags: ['drag', 'interaction', 'canvas'],
    );
  }

  void logValidationStep(String step, bool success, Map<String, dynamic> context) {
    StructuredLogger.debug(
      'Validation step completed',
      context: {
        'component': component,
        'operation': 'validation',
        'step': step,
        'success': success,
        ...context,
      },
      tags: ['drag', 'validation', success ? 'success' : 'failure'],
    );
  }

  void logErrorCondition(DragDropErrorType errorType, Map<String, dynamic> context) {
    StructuredLogger.error(
      'Drag operation error',
      context: {
        'component': component,
        'errorType': errorType.name,
        'errorMessage': errorType.message,
        ...context,
      },
      tags: ['drag', 'error', errorType.name],
    );
  }
}
```

#### Step 4.2: Performance Monitoring

```dart
class DragPerformanceMonitor {
  final Map<String, List<int>> _operationDurations = {};
  final Map<String, DateTime> _operationStartTimes = {};

  void startTiming(String operationId, String operationType) {
    _operationStartTimes[operationId] = DateTime.now();

    StructuredLogger.performance(
      'Drag operation started',
      context: {
        'operationId': operationId,
        'operationType': operationType,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      tags: ['performance', 'drag', operationType],
    );
  }

  void endTiming(String operationId, String operationType, {Map<String, dynamic>? metrics}) {
    final startTime = _operationStartTimes.remove(operationId);
    if (startTime == null) return;

    final duration = DateTime.now().difference(startTime).inMilliseconds;
    _operationDurations[operationType] ??= [];
    _operationDurations[operationType]!.add(duration);

    if (_shouldReportMetrics(operationType)) {
      _reportPerformanceMetrics(operationType);
    }

    StructuredLogger.performance(
      'Drag operation completed',
      context: {
        'operationId': operationId,
        'operationType': operationType,
        'durationMs': duration,
        'performanceRating': _getPerformanceRating(duration),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        ...?metrics,
      },
      tags: ['performance', 'drag', operationType, _getPerformanceRating(duration)],
    );
  }

  String _getPerformanceRating(int durationMs) {
    if (durationMs < 16) return 'excellent';      // < 60fps
    if (durationMs < 33) return 'good';           // < 30fps
    if (durationMs < 66) return 'acceptable';     // < 15fps
    return 'poor';                                // > 15fps
  }

  bool _shouldReportMetrics(String operationType) {
    final durations = _operationDurations[operationType] ?? [];
    return durations.length >= 100; // Report every 100 operations
  }

  void _reportPerformanceMetrics(String operationType) {
    final durations = _operationDurations[operationType]!;
    final average = durations.reduce((a, b) => a + b) / durations.length;
    final p95 = _calculatePercentile(durations, 95);
    final p99 = _calculatePercentile(durations, 99);

    StructuredLogger.performance(
      'Performance metrics report',
      context: {
        'operationType': operationType,
        'sampleCount': durations.length,
        'averageMs': average.toStringAsFixed(2),
        'p95Ms': p95,
        'p99Ms': p99,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      },
      tags: ['performance', 'metrics', operationType],
    );

    // Reset for next reporting period
    _operationDurations[operationType]!.clear();
  }

  int _calculatePercentile(List<int> durations, int percentile) {
    final sorted = List<int>.from(durations)..sort();
    final index = ((percentile / 100.0) * (sorted.length - 1)).round();
    return sorted[index];
  }
}
```

---

## Phase 5: Testing & Optimization (Ongoing)

### 📋 Phase 5 Objectives
- [ ] Complete test suite coverage
- [ ] Performance optimization
- [ ] Accessibility improvements
- [ ] Documentation completion

### 🔧 Technical Implementation

#### Step 5.1: Comprehensive Test Suite

```dart
void main() {
  group('Drag and Drop Integration Tests', () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();

    testWidgets('Complete drag-drop-place workflow', (tester) async {
      // Given: Component in palette
      final app = createTestApp();
      await tester.pumpWidget(app);

      final component = find.byKey(Key('resistor-palette-item'));
      expect(component, findsOneWidget);

      // When: Drag to grid
      final dragStartPoint = tester.getCenter(component);
      await tester.drag(component, dragStartPoint);

      final dropTarget = find.byKey(Key('grid-drop-zone'));
      await tester.dropAt(dropTarget, dragStartPoint);

      // Then: Component placed successfully
      await tester.pumpAndSettle();
      expect(find.byKey(Key('placed-resistor')), findsOneWidget);
      expect(find.text('Component placed successfully'), findsOneWidget);
    });

    testWidgets('Invalid drop shows error feedback', (tester) async {
      // Given: Drag outside grid boundaries
      final app = createTestApp();
      await tester.pumpWidget(app);

      final component = find.byKey(Key('resistor-palette-item'));
      await tester.drag(component, tester.getCenter(component));

      // When: Drop at invalid location
      await tester.dropAt(tester.getCenter(find.byType(Scaffold)), Offset(-100, -100));

      // Then: Error feedback displayed
      await tester.pumpAndSettle();
      expect(find.text('Drop position outside grid boundaries'), findsOneWidget);
    });
  });
}
```

#### Step 5.2: Performance Benchmarks

```dart
void main() {
  group('DragDrop Performance Benchmarks', () {
    test('Coordinate transformation within frame budget', () async {
      final service = CoordinateSystemService();
      final context = _createTestContext();

      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < 1000; i++) {
        final testPosition = Offset(i % 50 * 10.0, i ~/ 50 * 10.0);
        service.screenToGrid(testPosition, context);
      }
      stopwatch.stop();

      final averageTime = stopwatch.elapsedMilliseconds / 1000;
      expect(averageTime, lessThan(16)); // Must be < 60fps
    });

    test('Validation pipeline performance', () async {
      final validator = EnhancedDragValidator();
      final testData = ComponentDragData.test();
      final testPositions = _generateTestPositions(200); // High frequency

      final stopwatch = Stopwatch()..start();
      for (final position in testPositions) {
        validator.validateComplete(testData, position);
      }
      stopwatch.stop();

      final totalOps = testPositions.length;
      final totalTime = stopwatch.elapsedMilliseconds;
      final avgTimePerOp = totalTime / totalOps;

      expect(avgTimePerOp, lessThan(5)); // < 5ms per validation
      expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // < 2 seconds for 200 validations
    });
  });
}
```

---

## Verification Checklists

### Pre-Phase Implementation Checklist
- [ ] Team alignment on StateNotifier decision
- [ ] Backup procedures tested and documented
- [ ] Rollback scripts prepared
- [ ] Feature flag configuration confirmed
- [ ] Existing functionality regression tests passing

### Phase 1 Verification
- [ ] `canvas_interaction_widget.dart` contains no DragService references
- [ ] Single DragTarget implementation confirmed
- [ ] CanvasInteractionController methods functioning correctly
- [ ] Existing user workflows preserved
- [ ] Basic end-to-end drag-drop functionality verified

### Phase 2 Verification
- [ ] `canvas_drag_drop_layer.dart` DragTarget disabled
- [ ] Coordinate transformation logic consolidated
- [ ] Event handling unified
- [ ] Feature flag rollback ready
- [ ] No performance degradation detected
- [ ] Error handling maintains user experience

### Phase 3 Verification
- [ ] Comprehensive error types implemented
- [ ] User feedback mechanisms working
- [ ] Validation logic handles all edge cases
- [ ] State transitions properly managed
- [ ] Business rules correctly enforced

### Phase 4 Verification
- [ ] Structured logging implemented
- [ ] Performance monitoring active
- [ ] Error tracking and reporting working
- [ ] Metrics collection functioning

### Phase 5 Verification
- [ ] Test coverage > 90% for drag/drop functionality
- [ ] Performance benchmarks passing
- [ ] Integration tests passing
- [ ] Accessibility compliance maintained
- [ ] Documentation updated and accurate

---

## Rollback Procedures

### Emergency Rollback (Phase 1-2)
```bash
# Immediately revert all changes
git revert HEAD~3 --no-edit
git push origin main

# Restore from backup if needed
kubectl rollout undo deployment/circuit-stem-app
```

### Feature Flag Rollback (Phase 3+)
```yaml
# Update ConfigMap
apiVersion: v1
kind: ConfigMap
metadata:
  name: circuit-stem-config
data:
  # Set to true to revert to canvas_drag_drop_layer logic
  USE_LEGACY_DRAG_LAYER: "true"
  # Set to false to restore singleton if needed (not recommended)
  UNIFIED_DRAG_SERVICE: "false"
```

### Partial Rollback Procedures

#### Rollback Phase 2 (Eliminate CanvasDragDropLayer)
```dart
// In canvas_drag_drop_layer.dart
class _CanvasDragDropLayerState extends ConsumerState<CanvasDragDropLayer> {
  @override
  Widget build(BuildContext context) {
    // ROLLBACK: Reactivate original DragTarget
    return DragTarget<ComponentDragData>(
      // Original working logic...
      onWillAcceptWithDetails: _originalCanAcceptDrop,
      onAcceptWithDetails: _originalHandleDrop,
      builder: (context, candidateData, rejectedData) => widget.child,
    );
  }
}
```

#### Rollback Phase 3 (Enhanced Validation)
```dart
// Revert to simple validation in CanvasInteractionController
class CanvasInteractionController {
  DropValidationResult validateDropPosition(ComponentDragData data, Offset position) {
    // ROLLBACK: Simple validation only
    final gridPosition = _coordinateService.validateDropPosition(data, position, context, _renderBox, occupiedPositions);
    return gridPosition.isValid ? DropValidationResult.valid() : DropValidationResult.invalid('Position unavailable');
  }
}
```

---

## Success Metrics

### Technical Metrics
- **Performance**: Coordinate transformation < 16ms (60fps)
- **Reliability**: Drag success rate > 95%
- **Memory**: No memory leaks in 1-hour continuous testing
- **Testing**: Test coverage > 90% for drag/drop logic

### User Experience Metrics
- **Drag Initiation Time**: < 100ms perceptible lag
- **Drop Validation Feedback**: Instant (< 50ms)
- **Error Recovery**: Single click to retry failed drop
- **Accessibility**: Full screen reader support

### Business Impact Metrics
- **User Flow Completion**: 100% preservation of existing workflows
- **Error Rate Reduction**: 60% reduction in drag-and-drop failures
- **Developer Velocity**: 40% faster bug resolution with better logging
- **Maintenance Cost**: 50% reduction with unified architecture

### Monitoring Dashboard Setup
```yaml
# Prometheus metrics configuration
metrics:
  - name: drag_operation_duration_seconds
    type: histogram
    labels: ['operation_type', 'success']
  - name: drag_error_total
    type: counter
    labels: ['error_type', 'component_type']
  - name: drag_validation_cache_hit_ratio
    type: gauge
  - name: drag_coordinate_transform_time_seconds
    type: histogram
  - name: user_drag_interaction_success_rate
    type: gauge
```

---

## Final Architecture State

### 📋 Architecture Overview
```
┌─────────────────┐    ┌─────────────────────┐    ┌─────────────────┐
│   Horizontal    │───▶│ CanvasInteraction  │───▶│  CanvasPainter  │
│  Component     │    │    Controller      │    │                 │
│   Palette      │    │  (StateNotifier)   │    │                 │
└─────────────────┘    └─────────────────────┘    └─────────────────┘
                              │
                              ▼
                       ┌─────────────────────┐
                       │   Enhanced Drag    │
                       │   Validation       │
                       │   Service          │
                       └─────────────────────┘
                              │
                              ▼
                       ┌─────────────────────┐
                       │   Game State       │
                       │   Notifier         │
                       └─────────────────────┘
```

### 🚀 Benefits Achieved
- **Unified State Management**: Single source of truth with Riverpod
- **Enhanced Testability**: Proper dependency injection and mocking
- **Reactive UI**: Automatic updates through StateNotifier
- **Comprehensive Monitoring**: Built-in performance and error tracking
- **Future-Ready Architecture**: Extensible for new features

This plan represents the complete implementation approach using best practices and should achieve all project refactoring goals while maintaining backward compatibility and adding robust error handling.