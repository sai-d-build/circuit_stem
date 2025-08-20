## 2. The New Component-Behavior Architecture

**Date:** 2025-08-19

The project has undergone a major architectural refactoring to a **Component-Behavior model**. This was done to dramatically improve extensibility, maintainability, and testability, aligning the codebase with modern game development best practices (inspired by Entity-Component-System).

### 2.1. Core Concepts

- **Everything is a "Behavior"**: Instead of large services with `switch` statements that know how to handle every component, the logic is now inverted. Each component is a simple data container that has a list of "Behaviors" attached to it. These behaviors define how it looks, how it interacts, and how it functions in the game logic.
- **Central Registries**: All components and goals are registered at startup in a central registry (`ComponentRegistry` and `GoalRegistry`). This registry maps a simple string ID (e.g., `"Component.Bulb"`) to a set of behaviors and other metadata like a display name.
- **Data-Driven Levels**: The level `.json` files now define which components to create using these string IDs. The engine uses the registry to construct the correct components with the correct behaviors at runtime.

### 2.2. How to Add a New Component (e.g., a "Diode")

Adding a new component is now a simple, self-contained process that does **not** require modifying any core engine files.

1.  **Create a New File**: Create `lib/components/diode.dart`.
2.  **Implement Behaviors**: Inside this file, create classes that implement the necessary `Behavior` interfaces:
    - `class DiodeDrawingBehavior implements DrawingBehavior { ... }`
    - `class DiodeLogicBehavior implements LogicBehavior { ... }` (e.g., to enforce one-way power flow)
3.  **Create a Registration Function**: In the same file, create a function to register the component and its behaviors:
    ```dart
    void registerDiode() {
      // First, register the behavior classes themselves so the factory can create them.
      registerBehavior<DiodeDrawingBehavior>(() => DiodeDrawingBehavior());
      registerBehavior<DiodeLogicBehavior>(() => DiodeLogicBehavior());

      // Now, register the component type with its associated behaviors.
      ComponentRegistry.register(
        type: "Component.Diode",
        displayName: "Diode",
        behaviors: [DiodeDrawingBehavior, DiodeLogicBehavior],
        isDraggable: true,
      );
    }
    ```
4.  **Register on Startup**: In `lib/main.dart`, add a call to `registerDiode()` inside the `registerAllGameEntities()` function.
5.  **Use in JSON**: You can now use `"type": "Component.Diode"` in any level file.

### 2.3. Key Files & Directories

-   `lib/behaviors/`: Contains the abstract `Behavior` interfaces.
-   `lib/core/`: Contains the `ComponentRegistry` and `GoalRegistry`.
-   `lib/components/`: Contains the specific `Behavior` implementations and registration functions for each component.
-   `lib/goals/`: Contains the `Behavior` implementations for goals.
-   `DOCS/REFACTOR_PLAN.md`: For the full history and detailed steps of this refactoring.

This new architecture makes the project significantly easier to extend and maintain.

---

### 1.3 New Features & Enhancements (2025-08-18)

This section details the new features and enhancements implemented during the latest development cycle.

*   **Drawing Logic Refinement**:
    *   Refined `lib/ui/canvas_painter.dart` to make grid and dragged component colors theme-aware, improving dark mode support.
    *   Updated `lib/ui/game_canvas.dart` to pass these theme-aware colors to the painter.
    *   Fixed analyzer warnings by removing unused imports and replacing a deprecated `withOpacity` call.
*   **New Component Implementation (Cross Wire & Buzzer)**:
    *   Added `crossWire` and `buzzer` to the `ComponentType` enum in `lib/models/component.dart`.
    *   Updated the `isDraggable` property for the new components.
    *   Regenerated the `freezed` and `g` files using `build_runner`.
    *   Implemented the drawing logic for `crossWire` and `buzzer` in `lib/ui/painters/circuit_component_painter.dart`.
    *   Integrated a sound effect for the buzzer, playing it when the buzzer becomes powered, by modifying `lib/engine/game_engine_notifier.dart` and `lib/engine/game_engine_state.dart`.
*   **Component Placement in Levels**:
    *   Reverted the `level_01.json` palette to its original state.
    *   Created a new `level_02.json` file, incorporating the new `crossWire` and `buzzer` components into its initial setup and palette.
*   **Rotatable Wire Feature**:
    *   Implemented a `rotateComponent` method in `lib/engine/game_engine_notifier.dart` to allow rotation of draggable components.
    *   Modified the `handleTap` method in `GameEngineNotifier` to select components.
    *   Updated the UI in `lib/ui/game_canvas.dart` to show a rotate button when a draggable component is selected.
    *   Added a rotatable `wire_straight` component to `level_02.json` to demonstrate the new feature.

### 1.4 Bug Fixes (2025-08-18)

This section details the bug fixes implemented during the latest development cycle.

*   **Initial Component Rendering**:
    *   **Bug**: Initial level components were not rendering due to a race condition where the `GameCanvas` was built before the `AssetManager` had finished loading SVGs.
    *   **Fix**: Modified `lib/ui/screens/game_screen.dart` to use a `FutureBuilder` that waits for the `assetManagerProvider` to complete its initialization (`loadSvgs` method) before building the `GameCanvas`. This ensures that all necessary `ui.Image` assets are available before any rendering is attempted.
*   **Logic Engine Power Evaluation**:
    *   **Bug**: The `LogicEngine` was failing to correctly evaluate power flow through complex or rotated components, causing several unit tests to fail.
    *   **Fix**: Corrected the logic in `lib/services/logic_engine.dart` to properly handle component terminals, shapes, and rotations during power evaluation. This resolved the failing tests in `test/logic_engine_rich_test.dart`.
*   **Component Selection and Rotation**:
    *   **Bug**: The component selection and rotation feature was not working as intended.
    *   **Fix**: Implemented the `handleTap` method in `GameEngineNotifier` to correctly select components and updated the UI in `GameCanvas` to display the rotate button when a draggable component is selected.

### 1.5 Known Issues & Next Steps

This section lists the known issues that still need to be addressed and the next steps for the project.

*   **Test Compilation Error**:
    *   **Issue**: Tests are failing to compile with the error `Error: Type 'Component' not found` in `test/helpers/level_01_test_helper.dart`.
    *   **Next Step**: This is a critical issue that needs to be investigated and resolved. It is likely a problem with how the test environment resolves package imports.
*   **macOS Build Environment Issue**:
    *   **Issue**: The macOS application build and test execution are blocked by a missing `xcodebuild` utility.
    *   **Next Step**: The developer needs to run `xcode-select --install` to install the Xcode command-line tools.
*   **Outdated Package Dependencies**:
    *   **Issue**: The project has 26 packages with newer versions that are incompatible with the current dependency constraints.
    *   **Next Step**: Run `flutter pub outdated` and update `pubspec.yaml` to address the outdated dependencies.
*   **Comprehensive Testing**:
    *   **Next Step**: Implement the comprehensive testing strategy outlined in `DOCS/TESTING.md` to achieve full test coverage for the application.
*   **New Feature Development**:
    *   **Next Step**: Continue to add new components, levels, and features to the game.

## Debugging Session & Compiler Error Fixes (2025-08-19)

This section summarizes the debugging session and the compiler error fixes implemented.

### Problem Statement
- The game grid was not appearing for Level 01.
- Component palette images/icons were not displaying.

### Actions Taken
1.  **Initial Analysis & Logging**: Reviewed project architecture and recent git changes (Component-Behavior model refactoring). Added extensive `Logger.log` statements across critical files (`main.dart`, `component_registry.dart`, `game_engine_notifier.dart`, `asset_manager.dart`, `canvas_painter.dart`, `game_canvas.dart`, `circuit_component_display.dart`, and individual component/goal registration files) to trace execution flow.
2.  **Compilation Error Resolution (Round 1)**:
    -   **`Method not found: 'MyApp'` in `main.dart`**: Fixed by correcting the `runApp` call to use `Initializer`.
    -   **Syntax errors in `lib/ui/game_canvas.dart`**: Fixed incorrect string interpolation in logger statements.
    -   **`Undefined class/name` errors in `lib/ui/widgets/circuit_component_display.dart`**: Added missing imports for `ComponentModel`, `assetManagerProvider`, `AssetManagerNotifier`, and `DrawingBehavior`.
    -   **Warnings (`Duplicate import`, `unnecessary_import`)**: Cleaned up imports in `lib/services/asset_manager.dart` and `lib/ui/canvas_painter.dart`.
3.  **Compilation Error Resolution (Round 2)**:
    -   **`Error: Type 'Grid' not found.` in component files (`wire.dart`, `switch.dart`, `battery.dart`, `timer.dart`, `buzzer.dart`)**: Added missing `import '../models/grid.dart';` statements to these files.
    -   **`Error: The value 'null' can't be returned from a function with return type 'T' because 'T' is not nullable.` in `lib/core/component_registry.dart`**: Reverted `getBehavior<T>()` to throw an `Exception` for unregistered behaviors, as this is the correct behavior for non-nullable types.

### Current Status
- All known compilation errors have been addressed. The application should now compile and run.
- The next step is to run the application and analyze the new runtime logs to understand why behaviors are not being found and why the grid is not rendering.
