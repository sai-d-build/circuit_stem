
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
