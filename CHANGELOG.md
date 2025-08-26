## [3.0.0] - 2025-08-26 - Phase 3 Refactoring Complete

### Added
- **`LoadLevelUseCase`**: A new use case to handle the logic of loading a level.
- **`AudioMiddleware`**: A new middleware to handle all audio-related logic.
- **Comprehensive Test Suite**: A new suite of tests, including integration tests, property-based tests, and performance benchmarks, to ensure the stability and correctness of the new architecture.

### Changed
- **`GameEngineNotifier`**: The `GameEngineNotifier` has been fully refactored into a "thin wrapper". All business logic has been moved to dedicated use cases and middleware.
- **`PowerSimulationService`**: The `PowerSimulationService` has been enhanced with more realistic diode logic.

### Removed
- All business logic from the `GameEngineNotifier`.
- The `_playAudioForAction` method from `GameEngineNotifier`.


25 aug: a[hse 4 progress 

ummary of what I've done:

Rotation Action:
Implemented the action, notifier logic, and UI rendering for component rotation.
Added unit tests for the rotation logic.
Power Simulation:
Used the existing SimulationService.
Refactored GameEngineNotifier to centralize the call to the simulation service.
Added a unit test for the simulation service.
Goal Checking:
Created a GoalCheckingService with a placeholder implementation.
Integrated the service with GameEngineNotifier.
Checked that the UI is already set up to listen for the win condition.
Added a unit test for the goal checking service.
Level Restart & Undo:
Checked that "Restart" is already implemented.
Implemented a basic "Undo" feature using a state history.
Added a unit test for the undo functionality.
Bug Fixes:
Fixed several compilation errors related to const constructors and incorrect syntax in behavior registration.]


## [Unreleased] - 2025-08-25 - Phase 3 Refactoring Progress & Stabilization

### Added
- **Action-Based Interaction System**: Implemented a new system where UI interactions (create, move, tap) are translated into `ComponentAction` types and dispatched via `GameEngineNotifier.executeAction()`.
  - `CreateComponentFromTemplateAction`
  - `MoveComponentAction`
  - `TapComponentAction`
- **Component Bounds Calculation**: Added `getBounds()` method to `ComponentModel` and `ComponentBounds` class for simplified UI rendering.
- **Audio Service Provider**: Created `audioServiceProvider` (`lib/infrastructure/audio/audio_providers.dart`) for centralized audio service management.

### Changed
- **`GameEngineNotifier`**: Renamed from `GameEngineNotifierV2` to `GameEngineNotifier` project-wide. Its constructor was adjusted to align with Riverpod provider instantiation.
- **`GameCanvas`**: Refactored to dispatch `ComponentAction`s for drag-and-drop and tap interactions, removing direct dependencies on `InputManager` and `DragBehavior`.
- **`ComponentPaletteManager`**: Renamed `componentTemplates` to `availableTemplates` for consistency.
- **`CORE_REFACTORING.md`**: Updated Phase 3 section with detailed analysis of implemented changes and next steps.

### Fixed
- **Analysis Errors & Warnings**: Resolved all `flutter analyze` errors and warnings, including:
  - `ambiguous_import` and `undefined_method` errors due to redundant action class definitions and missing imports.
  - Incorrect import paths (e.g., `domain/models` to `domain/entities`).
  - `const` correctness issues in various classes and test files.
  - Unused imports and local variables.

## [Unreleased]

### Refactored
- **Component Behavior System**: Completed a major architectural refactoring of the component behavior system ("Phase 2: In-Place Behavior Standardization"). This change replaced direct-call, stateful behaviors with a functional, standardized `ComponentBehavior` interface. Behaviors are now pure functions that receive state via a `GameContext` and return a new `ComponentModel` if a change occurs. This makes behaviors more testable and centralizes state management within the `GameEngineNotifierV2`.
- **Code Cleanup**: As part of the refactoring, several obsolete files from a previous architectural plan (`ComponentEntity`, `ActionContext`, `TranslationService`, etc.) were deleted. All related compilation errors and analysis warnings were fixed, and the application was verified to be stable through tests and a successful runtime on Chrome.

## [2.0.0] - 2025-08-23 5:00 PM EST - Testing Strategy Overhaul

### Added
- **`DOCS/TESTING_BIBLE.md`**: A new, comprehensive guide to the project's testing strategy, architecture, and best practices.
- A new, layered test suite architecture (`unit/`, `widgets/`, `levels/`, `integration/`).

### Changed
- The project's testing strategy has been completely refactored to follow a multi-layered approach (unit, widget, integration tests).
- The focus is now on true widget tests that simulate user interactions to prevent UI-related bugs from going undetected.

### Deprecated
- `DOCS/TESTING.md`: The old testing strategy document.
- `DOCS/TESTING_IMPLEMENTATION_ROADMAP.md`: The old testing roadmap.
- The `test/categories/` directory structure is now deprecated in favor of a more organized, level-based approach.


## [Unreleased] - 2025-08-23

### Fixed
- **Toggle Switch Interaction**: Resolved the issue where the toggle switch in the UI was not responding to taps. The `_handleTap` method in `lib/engine/game_engine_notifier.dart` was updated to correctly delegate tap events to the component's `InteractionBehavior.onTap` method. Loggers were added to `lib/engine/input_manager.dart` and `lib/engine/game_engine_notifier.dart` to trace the tap event flow.

### Changed

- **Codebase Clean-up and Refinements**:
  - **Logger Import Paths**: Corrected import paths for `logger.dart` across the `lib/` directory to reflect its consistent location in `lib/common/logger.dart`. This involved updating imports in various component files, core registries, engine files, goal files, and UI files.
  - **Test Helper `Logger` Mocking**: Introduced a local `mock_logger.dart` in `test/helpers/` to provide a decoupled `Logger` implementation for test environments, resolving persistent import resolution issues in `test/helpers/mock_animation_scheduler.dart`.
  - **Test Setup Refinements**: Adjusted `test/helpers/test_setup_helper.dart` to correctly instantiate `MockAnimationScheduler` without an undefined `logger` parameter.
  - **Unused Code Removal**: Eliminated unused imports and local variables from various files, including `lib/components/switch.dart`, `lib/engine/game_engine_core.dart`, `lib/engine/game_engine_notifier.dart`, `lib/ui/game_canvas.dart`, `test/helpers/level_test_helper.dart`, `test/level_01_revised_test.dart`, and `test/helpers/pump_game_screen.dart`.
  - **Style and Best Practices**: Applied several stylistic improvements:
    - Added missing `@override` annotations (e.g., in `lib/components/switch.dart`).
    - Removed unnecessary `.toList()` calls in spread operators (e.g., in `lib/ui/game_canvas.dart`).
    - Replaced deprecated `withOpacity` usage (e.g., in `lib/widgets/grid_widget.dart`).
    - Standardized string literals to single quotes in test files (e.g., `test/categories/02_circuit_logic_tests.dart`, `test/categories/04_audio_tests.dart`, `test/level_01_revised_test.dart`).
    - Replaced `print` statements with `Logger.log` in `test/helpers/mock_animation_scheduler.dart` for consistent logging.

## [Unreleased] - 2025-08-22

### Changed
- **Major Game Engine Refactoring (Orchestrator Pattern)**
  - The core game engine has undergone a significant architectural overhaul, transitioning from a monolithic `GameEngineNotifier` to a modular system.
  - `GameEngineNotifierV2` now acts as an orchestrator, delegating responsibilities to specialized managers:
    - `GameEngineCore`: Responsible for applying state updates and producing new `GameEngineState` objects. It assumes the `newGrid` (with pre-calculated power states) is provided, indicating a delegation of power simulation.
    - `SimulationManager`: A new dedicated component for centralizing and managing power flow simulation logic through the circuit.
    - `InputManager`: Handles user interactions and translates them into game actions.
    - `AudioManager`: Centralizes and manages audio feedback.
  - This refactoring promotes a clearer separation of concerns, improved testability, and better maintainability.

- **Behavior System Adaptation**
  - `lib/behaviors/drag_behavior.dart`, `lib/behaviors/interaction_behavior.dart`, `lib/behaviors/movable_behavior.dart`: All behavior classes have been updated to use `GameEngineNotifierV2`, ensuring interaction with the new engine API.
  - `drag_behavior.dart` now directly interacts with `GridWidgetState` for UI operations, improving type safety and encapsulation.

- **Component-Level Updates**
  - `lib/components/switch.dart`: Updated to use `GameEngineNotifierV2`. The `onTap` method's `updateComponent` call changed from `updatedComponent` to `component`, requiring verification. Audio handling shifted to `notifier.audio.playToggle()`.

- **Test Suite Adaptation**
  - `test/helpers/game_test_helper.dart`: Test utilities updated to correctly access `gameEngineProvider`'s state, use string literals for component types, and reflect new state property names (e.g., `isClosed`, `isActive`).
  - `test/helpers/test_setup_helper.dart`: Test setup now instantiates `GameEngineNotifierV2` and removes the `animationScheduler` dependency, aligning the test environment.
  - `test/level_01_revised_test.dart`: Updated to use `GameEngineNotifierV2` and the renamed `audioManager` parameter.
- **Refactored GameEngineNotifier into a modular architecture.**
  - The monolithic `GameEngineNotifier` has been broken down into specialized managers to improve separation of concerns, testability, and extensibility.
  - Introduced `GameEngineCore` for core state management and logic application.
  - Introduced `SimulationManager` for handling power propagation and circuit simulation.
  - Introduced `InputManager` for translating UI gestures into game actions.
  - Introduced `AudioManager` for centralizing audio feedback.
  - `GameEngineNotifier` now acts as a thin orchestrator, wiring up these new managers.
  - Updated `lib/core/providers.dart` to use the new `GameEngineNotifier` (formerly `GameEngineNotifierV2`).
  - Updated UI consumers (`lib/ui/game_canvas.dart`, `lib/ui/game_screen.dart`) to interact with the new `InputManager` and the refined `GameEngineNotifier` API.

## [1.2.1] - 2025-08-21 - State Management and Data Consistency Fixes

This release addresses critical bugs related to state management, component registration, and data consistency, leading to a more stable and robust application.

### Fixed

-   **State Management Race Conditions:** Refactored the `GameEngineNotifier` to use a "single commit pipeline" architecture. This eliminates race conditions that were causing unpredictable behavior and failing tests. All state updates now go through a single, centralized `_commitGrid` method, ensuring that state changes are atomic and predictable.
-   **Component Behavior Registration:** Fixed a bug in the `ComponentRegistry` that was preventing behaviors from being attached to components created from JSON. This was a primary cause of the switch interaction test failure.
-   **Data Inconsistencies in `level_01.json`:**
    *   Corrected the switch component's state to use `closed` instead of `switchOpen`.
    *   Un-nested the `position` field to be top-level `r` and `c` properties.
-   **Coordinate Naming Convention:** Standardized on `r` and `c` for rows and columns throughout the codebase, including in the `CellOffset` class, the `GameEngineNotifier`, and the `Grid` model.

### Changed

-   **`lib/engine/game_engine_notifier.dart`:** Completely refactored to use a "single commit pipeline" architecture.
-   **`lib/core/component_registry.dart`:** Updated the `createFromJson` method to correctly attach behaviors to components.
-   **`lib/models/component.dart`:** Refactored the `CellOffset` class to use `r` and `c` instead of `x` and `y`.
-   **`lib/models/grid.dart`:** Updated the `componentAt` method to use `r` and `c`.
-   **`assets/levels/level_01.json`:** Updated to be consistent with the new data model.

---

 ## [1.2.0] - 2025-08-21 - Comprehensive Testing Overhaul

This release introduces a robust, scalable testing architecture and implements a significant portion of the test suite, ensuring higher application quality and stability.

### Added

-   **New Testing Roadmap:** Created `DOCS/TESTING_IMPLEMENTATION_ROADMAP.md`, a detailed technical guide for implementing the full test suite.
-   **Foundational Test Helpers:**
    -   `test/helpers/game_test_helper.dart`: A universal helper class for querying game state and simulating user interactions in a readable way.
    -   `test/helpers/mock_services.dart`: Provides verifiable mocks, including a `MockAudioService` that records played sounds.
    -   `test/helpers/test_setup_helper.dart`: A standardized, reusable setup function (`pumpGameScreenForLevel`) that creates a fully mocked and stable environment for any level test.
-   **Comprehensive Test Suite:**
    -   Established a new category-based test structure in `test/categories/`.
    -   **Interaction Tests (`01_interaction_tests.dart`):** Added tests for immovable components and invalid placements (`TC-L1-04`, `TC-L1-05`, `TC-L1-06`).
    -   **Circuit Logic Tests (`02_circuit_logic_tests.dart`):** Implemented a full suite of logic tests covering partial circuits, complete circuits (with and without a timer), win conditions, and breaking the win state (`TC-L1-07` to `TC-L1-12`).
    -   **Audio Tests (`04_audio_tests.dart`):** Added tests to verify correct audio feedback for valid and invalid component placements (`TC-L1-22`, `TC-L1-23`).
    -   **Game Flow Tests (`03_game_flow_tests.dart`):** Implemented tests for the Restart and Undo buttons, and for switch spam prevention (`TC-L1-28`, `TC-L1-29`, `TC-L1-30`).
-   **New UI Features:**
    -   Added "Restart" and "Undo" `IconButton`s to the `GameScreen` to provide core gameplay functionality.

### Changed

-   **`lib/ui/game_screen.dart`:** Modified to include the new Restart and Undo buttons in the component palette area.
-   **`DOCS/TESTING.md`:** Updated to reflect the resolution of previous test-hanging bugs and to document the new testing architecture as the current standard.

### Fixed

-   **Testability of UI:** The `GameScreen` is now more testable due to the addition of `Key`s (`restart_button`, `undo_button`) on interactive elements.

---

## [Unreleased] - 2025-08-20 - Level Loading Fixes & Enhanced Debugging

### Fixed

- **Level Data Parsing Errors (TypeError: null: type 'Null' is not a subtype of type 'int' / String)**:
  - **Problem for the New Developer**: You might have noticed the app crashing with confusing "TypeError" messages when trying to load Level 1 (or any level). This happened because the game was trying to read information from the level's JSON file, but some pieces of data were either missing or named differently than expected. Imagine trying to find a "red" apple, but the basket only has "crimson" apples or no apples at all! The game didn't know what to do with the unexpected "null" (nothing) value.
  - **Technical Details & Root Cause**:
    - **`shapeOffsets` Issue**: The `level_01.json` file defined component shapes using `r` (row) and `c` (column) for coordinates (e.g., `{"r": 0, "c": 0}`). However, the code responsible for reading this (`ComponentRegistry.createFromJson` in `lib/core/component_registry.dart`) was mistakenly looking for `x` and `y` coordinates. When it couldn't find `x` or `y`, it got `null` and crashed when trying to treat `null` as a number (`int`).
    - **`terminals` Issue (Direction)**: Similarly, the `level_01.json` used `dir` (e.g., `"dir": "up"`) for terminal directions, but the parsing code was looking for a key named `direction`. Again, it found `null` and crashed when expecting a text (`String`) value.
    - **`terminals` Issue (Type)**: Some terminal definitions in `level_01.json` didn't specify a `type` (like "power" or "signal"). The code expected a `String` for this, and when it found `null`, it crashed.
  - **Solution**:
    - We updated `lib/core/component_registry.dart` to be smarter about reading the JSON.
    - For `shapeOffsets`, it now correctly looks for `r` and `c`.
    - For `terminals`, it now correctly looks for `dir` for directions.
    - For the `type` of terminals, we added a "fallback" mechanism: if `type` is missing in the JSON, it will now automatically assume it's a "power" terminal. This prevents crashes and makes the level files more flexible.
  - **Impact**: The game can now successfully load all level data from `level_01.json` without crashing, allowing you to play the first level!

### Added

- **Enhanced Debugging Loggers**:
  - **Why we added them**: When the app was crashing, the error messages were a bit vague. To understand exactly *what* data was being read and *where* the problem was, we added special "Logger" messages throughout the code. Think of these as little notes the program writes to tell us what it's doing at critical moments.
  - **Where to find them**: We added these loggers in key files involved in level loading and component parsing:
    - `lib/core/component_registry.dart`
    - `lib/models/level_definition.dart`
    - `lib/services/level_manager.dart`
  - **How they help you**: If you encounter similar data-related crashes in the future, you can run the app and look at the console output. These log messages will show you the exact JSON data being processed, helping you quickly pinpoint if a field is missing, misspelled, or has an unexpected value. This is a powerful tool for debugging!

### Changed

- **Improved Level Data Robustness**: The parsing logic for `shapeOffsets` and `terminals` in `lib/core/component_registry.dart` is now more resilient to variations and missing optional fields in the level JSON files.

### Current Status

- All known level loading and data parsing `TypeError` issues have been resolved. The application should now compile, run, and allow you to play Level 1.
- The added loggers provide a valuable tool for diagnosing future data-related issues.


## [Unreleased] - 2025-08-20 - Debugging Session

### Fixed
- **Faulty Navigation Logic**: Fixed a bug where the app would try to load a locked level. The navigation logic in `lib/ui/widgets/level_grid.dart` was corrected to use the centralized logic from `lib/ui/screens/level_select.dart`.
- **Level Loading Error**: Fixed an "off-by-one" error where the UI would show "Level not found!" when a level was selected. The `levelDefinitionProvider` was corrected to pass the proper 0-based index to the `LevelManager`.

### Known Issues
- The fix for the "Level not found!" error has not yet been successfully applied due to a mistake during the file update process. The `lib/core/providers.dart` file was accidentally truncated and has been restored, but the final fix is still pending.


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

---

## [Unreleased] - 2025-08-20 - Architectural Stabilization

This release focuses on fixing critical bugs related to level loading and state management, and implementing a more robust, architecturally sound solution using Riverpod best practices.

### Fixed

- **Riverpod Initialization Crash:** Fixed a critical crash where the application would terminate upon selecting a level.
    - **For the New Developer:** The crash was caused by a Riverpod anti-pattern. The `levelDefinitionProvider` (a `FutureProvider`) was trying to modify the state of the `levelManagerProvider` during its own initialization. This is not allowed in Riverpod as it can lead to unpredictable behavior. We fixed this by making the `levelDefinitionProvider` "pure" - it now only fetches data and does not modify any other provider. The state update is now handled as a side effect in the `GameScreen` using `ref.listen`.
- **"Off-by-one" Level Loading Error:** Fixed a bug where selecting a level would load the next level instead of the selected one.
    - **For the New Developer:** The error was caused by the level index being incremented in two different places. We removed the incorrect increment in `lib/ui/screens/level_select.dart` to ensure that the correct, 0-based index is passed to the `GameScreen`.

### Added

- **Automatic Level Advancement:** Upon completing a level, the application now automatically unlocks and navigates to the next level.
    - **For the New Developer:** This logic is implemented in the `GameScreen`. It listens to the `isWinProvider` and, when the level is won, it calls the `markCurrentLevelComplete` method in the `LevelManagerNotifier` and then navigates to the next level if one is available.

### Changed

- **`LevelManagerNotifier` (`lib/services/level_manager.dart`):**
    - The `loadLevelByIndex` method is now a "pure" function that only fetches level data and does not modify the provider's state.
    - A new `setCurrentLevel` method was added to explicitly set the current level in the provider's state. This method is called from the `GameScreen` as a side effect after the level data has been loaded.
- **`GameScreen` (`lib/ui/game_screen.dart`):**
    - Now uses `ref.listen` to safely update the `levelManagerProvider`'s state after the `levelDefinitionProvider` has finished loading.
    - Contains the logic for automatic level advancement.
- **`levelDefinitionProvider` (`lib/core/providers.dart`):**
    - Is now a pure `FutureProvider` that only fetches data.
