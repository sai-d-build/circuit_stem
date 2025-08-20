## [v2.0.0] - 2025-08-19 - Architectural Refactor: Component-Behavior Model

This is a major architectural overhaul to improve extensibility and align with modern best practices.

### Added
- **Component-Behavior Architecture**: Introduced a new, highly extensible architecture inspired by Entity-Component-System (ECS) patterns.
- **Behavior Interfaces**: Created abstract classes for behaviors in `lib/behaviors/`:
  - `DrawingBehavior`: For component rendering.
  - `LogicBehavior`: For component game logic.
  - `InteractionBehavior`: For user input handling.
  - `GoalCheckingBehavior`: For win condition logic.
- **Central Registries**:
  - `ComponentRegistry` (`lib/core/component_registry.dart`): For registering all component types and their associated behaviors and display names.
  - `GoalRegistry` (`lib/core/goal_registry.dart`): For registering all goal types and their checking behaviors.
- **Component-Specific Behavior Files**: Created dedicated files in `lib/components/` for each component (`bulb.dart`, `wire.dart`, `switch.dart`, etc.) to encapsulate their specific logic.
- **Goal-Specific Behavior Files**: Created `lib/goals/power_bulb_goal.dart` to encapsulate the logic for that goal type.
- **New Documentation**:
  - `DOCS/REFACTOR_PLAN.md`: A comprehensive document detailing the entire refactoring process.

### Changed
- **Data Models**:
  - `lib/models/component.dart`: `ComponentModel` now uses a `String` for its `type` and contains a `List<dynamic> behaviors`.
  - `lib/models/goal.dart`: `Goal` now uses a `String` for its `type` and contains a `List<dynamic> behaviors`.
- **Core Engine**:
  - `lib/engine/game_engine_notifier.dart`: Refactored to be behavior-driven. `handleTap` and `_checkWinCondition` now delegate logic to behaviors instead of using `switch` statements.
  - `lib/ui/canvas_painter.dart`: Now uses `DrawingBehavior` exclusively for rendering, removing all component-specific drawing logic.
- **UI Widgets**:
  - `lib/ui/widgets/component_palette.dart`: Refactored to use the `ComponentRegistry` for display names and string-based types.
- **Level Files**: All `.json` files in `assets/levels/` have been updated to use new string-based identifiers for components and goals (e.g., `"type": "Component.Bulb"`).
- **`main.dart`**: Updated to call `registerAllGameEntities()` on startup, which registers all the new component and goal behaviors.

### Removed
- **`ComponentType` Enum**: The old enum in `lib/models/component.dart` has been removed.
- **Obsolete Files**:
  - `lib/ui/painters/circuit_component_painter.dart`: The monolithic painter has been deleted.
  - `lib/services/logic_engine.dart`: The old logic engine has been deleted, with its responsibilities distributed to `LogicBehavior` classes.
  - `test/logic_engine_rich_test.dart`: The obsolete test file for the old logic engine has been deleted.


## [Unreleased] - 2025-08-18

### Changed

- **Drawing Logic Refinement**:
    - Refined `lib/ui/canvas_painter.dart` to make grid and dragged component colors theme-aware.
    - Updated `lib/ui/game_canvas.dart` to pass these theme-aware colors to the painter.
    - Fixed analyzer warnings by removing unused imports and replacing a deprecated `withOpacity` call.
- **New Component Implementation (Cross Wire & Buzzer)**:
    - Added `crossWire` and `buzzer` to the `ComponentType` enum in `lib/models/component.dart`.
    - Updated the `isDraggable` property for the new components.
    - Regenerated the `freezed` and `g` files using `build_runner`.
    - Implemented the drawing logic for `crossWire` and `buzzer` in `lib/ui/painters/circuit_component_painter.dart`.
    - Integrated a sound effect for the buzzer, playing it when the buzzer becomes powered, by modifying `lib/engine/game_engine_notifier.dart` and `lib/engine/game_engine_state.dart`.
- **Component Placement in Levels**:
    - Reverted the `level_01.json` palette to its original state.
    - Created a new `level_02.json` file, incorporating the new `crossWire` and `buzzer` components into its initial setup and palette.
- **Rotatable Wire Feature**:
    - Implemented a `rotateComponent` method in `lib/engine/game_engine_notifier.dart` to allow rotation of draggable components.
    - Modified the `handleTap` method in `GameEngineNotifier` to select components.
    - Updated the UI in `lib/ui/game_canvas.dart` to show a rotate button when a draggable component is selected.
    - Added a rotatable `wire_straight` component to `level_02.json` to demonstrate the new feature.

## [Unreleased] - 2025-08-19 - Debugging Session & Compiler Error Fixes

### Added
- **Extensive Logging**: Added `Logger.log` statements across critical files (`main.dart`, `component_registry.dart`, `game_engine_notifier.dart`, `asset_manager.dart`, `canvas_painter.dart`, `game_canvas.dart`, `circuit_component_display.dart`, and individual component/goal registration files) to trace execution flow and pinpoint issues related to missing grid and component images.

### Fixed
- **Compilation Errors**:
    - `Method not found: 'MyApp'` in `main.dart`: Corrected `runApp` call to use `Initializer`.
    - Syntax errors in `lib/ui/game_canvas.dart`: Fixed incorrect string interpolation in logger statements.
    - `Undefined class/name` errors in `lib/ui/widgets/circuit_component_display.dart`: Added missing imports for `ComponentModel`, `assetManagerProvider`, `AssetManagerNotifier`, and `DrawingBehavior`.
    - `Duplicate import` and `unnecessary_import` warnings: Cleaned up imports in `lib/services/asset_manager.dart` and `lib/ui/canvas_painter.dart`.
    - `Error: Type 'Grid' not found.` in component files (`wire.dart`, `switch.dart`, `battery.dart`, `timer.dart`, `buzzer.dart`): Added missing `import '../models/grid.dart';` statements.
    - `Error: The value 'null' can't be returned from a function with return type 'T' because 'T' is not nullable.` in `lib/core/component_registry.dart`: Reverted `getBehavior<T>()` to throw an exception for unregistered behaviors, as this is the correct behavior for non-nullable types.

### Current Status
- All known compilation errors have been addressed. The application should now compile and run.
- The next step is to run the application and analyze the new runtime logs to understand why behaviors are not being found and why the grid is not rendering.