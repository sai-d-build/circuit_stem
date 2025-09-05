# Grid Logic Refactoring Plan

## Overview
Refactor all grid-related logic into a cohesive `GridService` module to eliminate code duplication, improve maintainability, and ensure consistent behavior across the application.

## Current State Analysis

### Core Grid Classes
- **`Grid`** (`lib/domain/entities/core/grid.dart`)
  - Component placement/removal/movement
  - Connection management
  - Grid validation and bounds checking
- **`GridCell`** (`lib/domain/entities/core/grid_cell.dart`) - Simple coordinate holder
- **`GridNotifier`** (`lib/application/grid_notifier.dart`) - State management

### Distributed Logic (To Be Centralized)
- **`CoordinateTranslator`** (`lib/presentation/core/utils/coordinate_translator.dart`)
  - Screen ↔ Grid coordinate conversion
- **`GameCanvasController`** (`lib/presentation/features/game/controllers/game_canvas_controller.dart`)
  - Screen ↔ Grid coordinate conversion
  - Bounds checking and snapping
- **`GridWidget/GridPainter`** (`lib/presentation/features/game/widgets/grid_widget.dart`)
  - Grid rendering and drawing logic
- **Canvas Painters** (`lib/presentation/features/game/painters/`)
  - Grid line drawing with constants duplication
  - Component positioning on grid
- **`MoveBehavior` Classes** (`lib/domain/behaviors/move_behavior.dart`)
  - Movement validation logic
- **`GoalCheckingBehavior`** (`lib/domain/behaviors/goal_checking_behavior.dart`)
  - Goal validation using grid state

## Proposed Architecture

### New GridService Structure
```dart
// lib/core/services/grid_service.dart
class GridService {
  // Coordinate translation utilities
  // Grid rendering utilities
  // Position validation utilities
  // Component operation utilities
}
```

### Key Interfaces

#### 1. Coordinate Operations
```dart
abstract class GridCoordinateManager {
  Offset screenToGrid(Offset screenPos, GridConfiguration config);
  Offset gridToScreen(Offset gridPos, GridConfiguration config);
  Offset snapToGrid(Offset screenPos, GridConfiguration config);
  bool isInGridBounds(Offset gridPos, GridConfiguration config);
}
```

#### 2. Grid Rendering
```dart
abstract class GridRenderer {
  void paintGrid(Canvas canvas, Size size, GridConfiguration config, RenderConfiguration renderConfig);
  void paintGridLines(Canvas canvas, Size size, GridConfiguration config);
  void paintGridCoordinates(Canvas canvas, Size size, GridConfiguration config);
}
```

#### 3. Component Operations
```dart
abstract class ComponentGridOperations {
  bool canPlaceComponent(ComponentModel component, int row, int col, Grid grid);
  bool canMoveComponent(ComponentModel component, int newRow, int newCol, Grid grid);
  GridPath findPath(ComponentModel component, Offset start, Offset end, Grid grid);
}
```

### Configuration Classes
```dart
class GridConfiguration {
  final int rows;
  final int cols;
  final double cellSize;
  final double scale;
  final Offset panOffset;

  // Factory constructors for different contexts
  factory GridConfiguration.fromGrid(Grid grid);
  factory GridConfiguration.fromCanvas(GameCanvasController controller);
}

class RenderConfiguration {
  final Color gridLineColor;
  final Color majorGridLineColor;
  final double strokeWidth;
  final int majorGridInterval;
  final bool showCoordinates;
  final bool showOrigin;
}
```

## Refactoring Strategy

### Phase 1: Create Core GridService
1. Create `lib/core/services/grid_service.dart` with coordinate translation logic
2. Implement grid validation and bounds checking methods
3. Add component operation utilities

### Phase 2: Extract Rendering Logic
1. Move grid painting logic from `GridPainter` to GridService
2. Consolidate grid constants from multiple painters
3. Create unified grid rendering API

### Phase 3: Update Existing Classes
1. Update `CoordinateTranslator` to use GridService (backward compatible)
2. Update `GameCanvasController` methods to delegate to GridService
3. Update `Grid` class to use GridService for complex operations

### Phase 4: Update Behaviors and Use Cases
1. Update `MoveBehavior` classes to use GridService validation
2. Update `GoalCheckingBehavior` to use GridService queries
3. Update all use cases and commands to use GridService

### Phase 5: Update UI Components
1. Update `GridWidget` to use GridService rendering
2. Update canvas painters to use GridService
3. Update game canvas to use GridService for coordinate operations

### Phase 6: Refinement
1. Remove obsolete classes/code
2. Ensure backward compatibility
3. Add comprehensive documentation
4. Test all scenarios

## Benefits

### Maintainability
- **Single Source of Truth**: All grid logic centralized
- **Reduced Duplication**: Eliminate repeated coordinate conversion logic
- **Consistent Behavior**: Unified grid operations across UI and business logic

### Performance
- **Efficient Rendering**: Consolidated grid painting reduces canvas operations
- **Memory Optimization**: Shared coordinate caching and validation

### Developer Experience
- **Clear API**: Well-defined interfaces for grid operations
- **Easy Testing**: Centralized logic easier to unit test
- **Extensibility**: New grid features added in one place

## Risks & Mitigation

### Breaking Changes
- **Mitigation**: Maintain backward compatibility during transition
- **Strategy**: Keep existing APIs as facades over new GridService

### Performance Regression
- **Mitigation**: Profile before/after refactoring
- **Strategy**: Incremental changes with testing at each step

### Complex Integration
- **Mitigation**: Start with lowest-risk components (utils)
- **Strategy**: Phase-by-phase implementation with rollback points

## Detailed Implementation Plan: File-by-File Changes

### Phase 1: Create Core GridService (2 days)
**CREATE:** `lib/core/services/grid_service.dart`
- New file with coordinate translation, validation, and utility methods
- Dependencies: `Grid`, `ComponentModel`, `Canvas`, `Offset`

**REMAINING IMPACT:** No changes to existing files

### Phase 2: Extract Coordinate Logic (2 days)
**UPDATE:** `lib/presentation/core/utils/coordinate_translator.dart`
- Add GridService dependency injection
- Keep existing API for backward compatibility
- Delegate coordinate operations to GridService
- Dependencies: GridService (new)

**UPDATE:** `lib/presentation/features/game/controllers/game_canvas_controller.dart`
- Add GridService dependency injection
- Delegate coordinate methods to GridService
- Keep existing API unchanged
- Dependencies: GridService (new)

### Phase 3: Extract Rendering Logic (3 days)
**UPDATE:** `lib/presentation/features/game/widgets/grid_widget.dart`
- Add GridService dependency injection
- Extract painting logic to GridService methods
- Delegate to GridService.renderGrid()
- Dependencies: GridService (new)

**UPDATE:** `lib/presentation/features/game/painters/canvas_painter.dart`
- Extract grid constants to GridService
- Delegate grid drawing to GridService
- Keep component-specific painting local
- Dependencies: GridService (new)

**UPDATE:** `lib/presentation/features/game/painters/wire_painter.dart`
- Extract grid coordinate calculations to GridService
- Dependencies: GridService (new)

**UPDATE:** `lib/presentation/features/game/painters/component_painter.dart`
- Extract grid coordinate calculations to GridService
- Dependencies: GridService (new)

### Phase 4: Update Core Entity Classes (3 days)
**UPDATE:** `lib/domain/entities/core/grid.dart`
- Add GridService dependency injection
- Extract complex validation to GridService methods
- Delegate coordinate calculations to GridService
- Keep basic CRUD operations local
- Dependencies: GridService (new)

**UPDATE:** `lib/domain/behaviors/move_behavior.dart`
- Add GridService dependency injection
- Delegate movement validation to GridService
- Keep behavior-specific logic local
- Dependencies: GridService (new)

### Phase 5: Update Application Layer (2 days)
**UPDATE:** `lib/application/grid_notifier.dart`
- Add GridService dependency injection
- Delegate complex operations to GridService
- Keep state management local
- Dependencies: GridService (new)

**UPDATE:** `lib/application/services/power_simulation_service.dart`
- Add GridService for coordinate validation
- Delegate position checks to GridService
- Dependencies: GridService (new)

### Phase 6: Update Goal and Use Case Layer (2 days)
**UPDATE:** `lib/domain/behaviors/goal_checking_behavior.dart`
- Add GridService dependency injection
- Delegate grid operations to GridService
- Dependencies: GridService (new)

**UPDATE:** `lib/application/use_cases/create_component_use_case.dart`
- Add GridService dependency injection
- Delegate placement validation to GridService
- Dependencies: GridService (new)

**UPDATE:** `lib/application/use_cases/move_component_use_case.dart`
- Add GridService dependency injection
- Delegate movement validation to GridService
- Dependencies: GridService (new)

### Phase 7: Update UI Components (3 days)
**UPDATE:** `lib/presentation/features/game/widgets/game_canvas.dart`
- Add GridService dependency injection
- Delegate coordinate operations to GridService
- Keep gesture handling local
- Dependencies: GridService (new)

**UPDATE:** `lib/presentation/features/palette/widgets/horizontal_component_palette.dart`
- Add GridService dependency injection
- Delegate placement validation to GridService
- Dependencies: GridService (new)

### Phase 8: Create Provider and Dependency Injection (1 day)
**CREATE:** `lib/core/providers/grid_service_provider.dart`
- Riverpod provider for GridService
- Dependencies: GridService, Riverpod

**UPDATE:** Main provider files to register GridService
- Update `lib/application/providers.dart`
- Update `lib/providers.dart` (if exists)
- Dependencies: GridServiceProvider

## Dependency Impact Analysis

### New Dependencies Added
1. **GridService** → All refactored files
2. **Canvas/Offset** → GridService (Flutter SDK)
3. **Grid Entity** → GridService
4. **ComponentModel** → GridService

### Dependency Chain Impact
```
GridService → Grid, ComponentModel, Canvas APIs
 ↳ CoordinateTranslator → GridService
 ↳ GameCanvasController → GridService
 ↳ GridWidget → GridService
 ↳ Painters → GridService
 ↳ Grid Entity → GridService
 ↳ MoveBehavior → GridService
 ↳ Use Cases → GridService
 ↳ UI Widgets → GridService
```

### Backward Compatibility Strategy
- **Facade Pattern**: Keep existing static methods as facades to GridService
- **Dependency Injection**: Use Riverpod providers for clean injection
- **Gradual Migration**: Update files in dependency order (leaves first)
- **API Preservation**: Maintain exact same public APIs during transition

## Risk Mitigation Strategy

### High-Risk Areas
1. **UI Components**: Canvas painting is critical path
   - **Mitigation**: Test each painter thoroughly
2. **GameCanvas**: Complex coordinate handling
   - **Mitigation**: Unit test coordinate conversions
3. **Use Cases**: Business logic dependencies
   - **Mitigation**: Add integration tests

### Testing Strategy
- **Unit Tests**: Each GridService method
- **Integration Tests**: UI component rendering
- **E2E Tests**: Complete grid operations
- **Performance Tests**: Ensure no rendering regressions

## Detailed Timeline with File Count

| Phase | Files Changed | Duration | Risk Level | Description |
|-------|---------------|----------|------------|-------------|
| 1 | 1 new | 2 days | Low | Create GridService |
| 2 | 2 | 2 days | Low | Coordinate systems |
| 3 | 4 | 3 days | Medium | Rendering logic extraction |
| 4 | 2 | 3 days | Medium | Core entities |
| 5 | 2 | 2 days | Medium | Application services |
| 6 | 3 | 2 days | Medium | Business logic |
| 7 | 2 | 3 days | High | UI components |
| 8 | 3 | 1 day | Low | Dependency injection |
**TOTAL:** ~18 days, 18 files modified + 2 new files

## Success Metrics
- ✅ Zero breaking changes (backward compatibility)
- ✅ All grid logic consolidated
- ✅ Improved test coverage (GridService methods)
- ✅ Performance maintained (Canvas operations)
- ✅ Clean dependency injection with Riverpod
- ✅ Comprehensive documentation
- ✅ Code duplication reduced by 70%

## Success Criteria

- [ ] All grid logic consolidated in GridService
- [ ] No code duplication in grid operations
- [ ] Backward compatibility maintained
- [ ] Improved test coverage (grid utilities)
- [ ] Consistent grid behavior across application
- [ ] Comprehensive documentation
- [ ] No performance regression

## Dependencies

### Internal Dependencies
- Grid entity (`lib/domain/entities/core/grid.dart`)
- Component model (`lib/domain/entities/core/component.dart`)
- Existing UI components (widgets, painters, controllers)

### External Dependencies
- Flutter Canvas API for rendering
- Riverpod for state management (GridNotifier)

This plan provides a systematic approach to centralize grid logic while minimizing risk and ensuring maintainability.