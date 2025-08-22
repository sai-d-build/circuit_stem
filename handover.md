session was focused on diagnosing and fixing a series of complex issues in the circuit_stem Flutter application following a major architectural refactoring. The process involved several phases of analysis, implementation, and debugging.

1. Initial Problem: Blank UI

Symptom: You reported that the main game grid and the component palette were not rendering, leaving the user with a blank screen.
Analysis: I determined that the root cause was a race condition. The recent refactoring had made the level loading process asynchronous, but the UI was not set up to handle this. It was building instantly, before any level data is available, resulting in a blank state.
2. Architectural Solution

My Proposal: I initially proposed a standard fix using a FutureProvider to manage the asynchronous loading and update the UI accordingly.
Your Fix_analysis.md: You provided a document detailing a more advanced and robust architecture using Riverpod's modern AsyncNotifierProvider and code generation.
The Hybrid Plan: I acknowledged that the architecture in your document was superior for the long term. We agreed on a two-phase approach:
Phase 1 (Immediate Fix): Implement the FutureProvider solution to get the app working quickly and resolve the blank screen.
Phase 2 (Modernization): After stabilizing the app, perform the full migration to the AsyncNotifierProvider architecture.
3. Implementation and Debugging (Phase 1)

Provider Refactoring: I executed Phase 1 by refactoring the providers in lib/core/providers.dart. This involved creating the levelDefinitionProvider and converting the gameEngineProvider and its dependencies into .family providers.
UI Updates: I updated the GameScreen and GameCanvas to correctly use these new providers, handle the async loading/error/data states, and pass the required parameters.
Analyzer Errors: This major refactoring led to a cascade of analyzer errors. We worked through them systematically, fixing issues related to:
Incorrect provider calls.
Type errors in data models and the component registry.
Mismatches in the test files.
General code quality and linting warnings.
4. The Runtime Mystery: The Infinite Loop

Symptom: After fixing all analyzer errors, running the app revealed a new, subtle bug. The application would get stuck in a loop, repeatedly trying to load a locked level, and then terminate.
Investigation: We methodically investigated the problem:
I reviewed the UI code (LevelSelectScreen, LevelGrid) and the LevelManager, but found no obvious loops.
A global search for the loadLevelByIndex method calls also revealed no incorrect programmatic calls.
The process of elimination led to the conclusion that a hidden, argument-less navigation to the /game route must be occurring.
5. The Final Diagnostic Step

The Culprit: I identified that the router in lib/routes.dart had a fallback that defaulted to levelNumber: 1 if no arguments were supplied, which was hiding the true source of the error.
The Fix: To unmask the problem, I removed this fallback and made the levelNumber argument strictly required. This is designed to force a crash at the exact point of the incorrect navigation.
Current Status: After fixing a minor compilation error in that last change, the application is now ready for you to run again. The expected outcome is no longer a loop, but a clear error message that will finally reveal the origin of the rogue navigation call, allowing us to fix it once and for all.

the Fix_analysis.md document proposes a more modern and robust long-term solution, while my initial suggestion was focused on a more immediate, less disruptive fix.

Here is a comparison and the recommended best approach, combining the insights from both analyses.

Comparison of Approaches
Aspect	My Initial Analysis (FutureProvider)	Fix_analysis.md (AsyncNotifierProvider)
Speed of Fix	Faster. Requires fewer file changes and no new dependencies. It's a targeted fix for the race condition.	Slower. Requires a larger refactoring, new dependencies (riverpod_generator), and code generation.
Modernity	Good. FutureProvider is a standard Riverpod pattern.	Excellent. AsyncNotifierProvider with code generation is the current best practice for new Riverpod development.
Code Cohesion	Good. It separates the data loading concern.	Excellent. It combines the async loading and the state management logic into a single, cohesive AsyncNotifier.
Robustness	Good. It solves the immediate problem.	Excellent. It provides a more comprehensive solution with built-in handling for loading, error, and data states, and encourages better testing and error monitoring.
Impact	Lower. Fewer files are touched, and the core GameEngineNotifier logic remains largely the same.	Higher. This is a significant architectural change that will touch the provider layer, the UI layer, and the core model classes.
The Best Approach: A Phased Migration
The optimal path forward is a phased migration that leverages the speed of the immediate fix and the robustness of the long-term architectural vision from Fix_analysis.md. A "big bang" refactor, as suggested in the document, is powerful but carries a higher risk of introducing new bugs and disrupting development.

Here is the recommended, phase-by-phase solution:

Phase 1: Stabilize the Application (Immediate Fix)
The primary goal of this phase is to get the application out of its broken state and make the UI functional again. This provides immediate value and a stable base for further refactoring.

Introduce levelDefinitionProvider: I will add a FutureProvider.autoDispose.family to lib/core/providers.dart. Its only job will be to fetch the LevelDefinition asynchronously.
Refactor gameEngineProvider: I will convert the gameEngineProvider to a .family provider that accepts a LevelDefinition. This decouples the game engine from the data loading process.
Update the UI (GameScreen): I will modify the GameScreen to watch the new levelDefinitionProvider. It will use the AsyncValue.when() method to:
Show a CircularProgressIndicator while loading.
Display a user-friendly error message if loading fails.
Build the main game UI (GameCanvas, ComponentPalette) only when the data is successfully loaded and passed to the gameEngineProvider.
This phase will completely resolve the user's reported issue with a minimal, targeted set of changes.

Phase 2: Modernize the Architecture (The Fix_analysis.md Vision)
With the application stable, we can now execute the more advanced architectural refactoring proposed in Fix_analysis.md. This will pay long-term dividends in maintainability and developer experience.

Add Dependencies: Add riverpod_annotation, riverpod_generator, and build_runner to pubspec.yaml.
Implement AsyncNotifierProvider: Replace the FutureProvider and StateNotifierProvider from Phase 1 with the new GameEngine AsyncNotifierProvider using the @riverpod annotation. This new provider will handle its own data loading within its build method.
Create Derived State Providers: Implement the efficient, derived providers for grid, renderState, paletteComponents, etc., as detailed in the analysis document.
Refactor UI to Use New Providers: The UI will still use AsyncValue.when(), but it will now watch the single gameEngineProvider and the new derived providers. This will simplify the widget code.
Update Models and Tests: Refactor the GameState and RenderState models and update the tests to align with the new architecture, following the comprehensive examples in Fix_analysis.md.
Conclusion
I will proceed with Phase 1 now to provide the quickest and safest path to a working application. This directly addresses your problem while preparing the codebase for the more advanced and robust architecture you've designed.


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

*   **Drawing Logic Refinement**
    *   Refined `lib/ui/canvas_painter.dart` to make grid and dragged component colors theme-aware, improving dark mode support.
    *   Updated `lib/ui/game_canvas.dart` to pass these theme-aware colors to the painter.
    *   Fixed analyzer warnings by removing unused imports and replacing a deprecated `withOpacity` call.
*   **New Component Implementation (Cross Wire & Buzzer)**
    *   Added `crossWire` and `buzzer` to the `ComponentType` enum in `lib/models/component.dart`.
    *   Updated the `isDraggable` property for the new components.
    *   Regenerated the `freezed` and `g` files using `build_runner`.
    *   Implemented the drawing logic for `crossWire` and `buzzer` in `lib/ui/painters/circuit_component_painter.dart`.
    *   Integrated a sound effect for the buzzer, playing it when the buzzer becomes powered, by modifying `lib/engine/game_engine_notifier.dart` and `lib/engine/game_engine_state.dart`.
*   **Component Placement in Levels**
    *   Reverted the `level_01.json` palette to its original state.
    *   Created a new `level_02.json` file, incorporating the new `crossWire` and `buzzer` components into its initial setup and palette.
*   **Rotatable Wire Feature**
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

### **Debugging & Architectural Refactoring Summary**

This summary outlines the process of diagnosing and fixing critical issues following a major architectural refactoring.

**1. The Problem: Blank UI & Infinite Loop**

*   **Initial Symptom**: The main game grid and component palette were not rendering, resulting in a blank screen.
    *   **Root Cause**: A race condition. The UI was building before the asynchronous level-loading process had completed.
*   **Secondary Symptom**: After initial fixes, the app entered an infinite loop, repeatedly trying to load a locked level.
    *   **Root Cause**: A fallback in the router (`lib/routes.dart`) was hiding the true error by defaulting to `levelNumber: 1` when navigation arguments were missing.

**2. The Architectural Decision: A Phased Approach**

A key decision was how to manage the asynchronous data loading. Two approaches were considered:

*   **Immediate Fix (`FutureProvider`)**: A quick, targeted solution to resolve the race condition and stabilize the app.
*   **Modernization (`AsyncNotifierProvider`)**: A more robust, long-term solution based on modern Riverpod best practices, as detailed in `Fix_analysis.md`.

**The agreed-upon plan was a two-phase migration:**

*   **Phase 1 (Completed):** Implement the `FutureProvider` to immediately fix the blank screen and create a stable base. This involved:
    *   Refactoring providers in `lib/core/providers.dart`.
    *   Updating the UI to handle async states (`loading`, `error`, `data`).
    *   Systematically fixing a cascade of resulting analyzer errors.
*   **Phase 2 (Planned):** After stabilization, migrate to the superior `AsyncNotifierProvider` architecture for long-term maintainability.

**3. The Resolution & Current Status**

*   **The Fix**: The router's fallback was removed, and the `levelNumber` argument was made mandatory. This will force a crash at the precise location of the incorrect, argument-less navigation call.
*   **Current Status**: The application is ready to be run. The expected outcome is no longer an infinite loop but a clear error message that will pinpoint the origin of the rogue navigation, enabling a final fix.

## Recent Debugging Session: Level Loading Errors (2025-08-20)

This session focused on resolving critical `TypeError` issues that prevented `level_01.json` from loading correctly, despite previous compilation fixes.

### Problem Statement

After addressing compilation errors, the application would launch but crash with `TypeError` messages when attempting to load `level_01.json`. The errors indicated that `null` values were being encountered where `int` or `String` types were expected during the parsing of level data.

### Diagnosis and Root Cause Analysis

Through systematic debugging and the strategic addition of `Logger.log` statements, the root causes were identified as mismatches between the JSON structure in `level_01.json` and the parsing logic in `lib/core/component_registry.dart`:

1.  **`shapeOffsets` Parsing Error (`TypeError: null: type 'Null' is not a subtype of type 'int'`):**
    *   **Symptom**: The application crashed when parsing the `shapeOffsets` for components.
    *   **Root Cause**: `level_01.json` uses `"r"` (row) and `"c"` (column) keys within `shapeOffsets` objects (e.g., `{"r": 0, "c": 0}`), but the `ComponentRegistry.createFromJson` method was incorrectly attempting to read `"x"` and `"y"` keys.

2.  **`terminals` Parsing Errors (`TypeError: null: type 'Null' is not a subtype of type 'String'`):**
    *   **Symptom**: The application crashed when parsing the `terminals` for components.
    *   **Root Cause 1 (Direction)**: `level_01.json` uses `"dir"` (direction) key (e.g., `"dir": "up"`), but the `ComponentRegistry.createFromJson` method was incorrectly attempting to read `"direction"`.
    *   **Root Cause 2 (Type)**: The `"type"` field within `terminals` objects was often missing in `level_01.json`. The parsing logic expected a non-nullable `String` for this field, leading to a crash when `null` was encountered.

### Actions Taken and Fixes Implemented

To resolve these issues, the following modifications were made to `lib/core/component_registry.dart`:

1.  **Corrected `shapeOffsets` Parsing:**
    *   The code responsible for parsing `shapeOffsets` was updated to read `offsetJson['r']` and `offsetJson['c']` instead of `offsetJson['x']` and `offsetJson['y']`.

2.  **Corrected `terminals` Parsing:**
    *   The code was updated to read `termJson['dir']` for the terminal direction.
    *   A null-aware operator (`??`) was added to the `"type"` field parsing (`termJson['type'] as String? ?? 'power'`). This ensures that if the `"type"` field is missing or `null` in the JSON, it defaults to `'power'`, preventing a crash.
    *   The `TerminalSpec` constructor call was updated to use named arguments for clarity and correctness.

3.  **Enhanced Logging:**
    *   Extensive `Logger.log` statements were added to `lib/core/component_registry.dart`, `lib/models/level_definition.dart`, and `lib/services/level_manager.dart`. These loggers provide visibility into the raw JSON data being parsed and the intermediate results, which was invaluable for diagnosing the subtle data mismatches.

### Current Status

The application now successfully launches, loads `level_01.json`, and displays the game grid and components correctly. All previously identified `TypeError` issues related to level data parsing have been resolved. The added loggers provide a robust mechanism for future debugging of data-related issues.

### Key Files Involved

*   `lib/core/component_registry.dart`: Contains the core parsing logic for components from JSON.
*   `lib/models/level_definition.dart`: Responsible for deserializing the overall level structure.
*   `lib/services/level_manager.dart`: Manages the loading and state of levels.
*   `assets/levels/level_01.json`: The level data file that was causing the parsing issues.

This concludes the debugging session for the level loading errors. The application is now in a stable state regarding level data parsing.



2025-80-20 9PMEST

worked on testing suite, Hanging seems to be resolved dbut other issue persistis, phase 0 of proect road map is completed. 
### **Summary of Issues, Fixes, and Next Steps for `circuit_stem` Test Suite**

---

## **1. Root Causes of Test Failures**

### **A. Test Setup Hangs**
- **SharedPreferences Hang**: The test setup was hanging due to incorrect mocking of `SharedPreferences`. The `setMockInitialValues()` method can only be called once, and calling it multiple times or in the wrong order causes a deadlock.
- **File I/O Hang**: `File().readAsString()` hangs in `testWidgets()` but works in regular `test()`. This is a known Flutter bug.

### **B. Component and Behavior Registration**
- **Missing Component Registration**: The `ComponentRegistry` was not populated in the test environment, leading to "Unknown component type" errors.
- **Missing Behavior Factories**: Even if components were registered, their behaviors (e.g., `LogicBehavior`, `GoalCheckingBehavior`) were not properly linked, causing "No LogicBehavior found" and "No GoalCheckingBehavior found" errors.

---

## **2. Fixes Implemented**

### **A. Resolved Test Setup Hangs**
- **SharedPreferences Fix**:
  - Moved `SharedPreferences.setMockInitialValues({})` to `setUpAll()` to ensure it runs only once.
  - Used `TestWidgetsFlutterBinding.ensureInitialized()` to ensure proper Flutter test framework initialization.
- **File I/O Fix**:
  - Moved all `File().readAsString()` calls to `setUpAll()` to avoid the Flutter bug with file reading in `testWidgets()`.

### **B. Resolved Component/Behavior Registration**
- **Component Registry Initialization**:
  - Added a call to `registerAllGameEntities()` in `setUpAll()` to ensure all components and behaviors are registered before tests run.

---

## **3. Remaining Issues (From Latest Test Output)**

### **A. Component Behaviors Not Found**
- The logs show:
  ```
  ComponentRegistry: Unknown component type: Component.Battery, creating component without behaviors
  GameEngineNotifier: No LogicBehavior found for component: ${component.id}
  _SimpleLogicSimulator: Battery has no positive terminals.
  GameEngineNotifier: No GoalCheckingBehavior found for goal: ${goal.type}
  ```
- **Root Cause**:
  The `ComponentRegistry` is now populated, but the components are still being created without their expected behaviors. This suggests a mismatch between the component types in the JSON (`Component.Battery`) and the registered types in the code.

### **B. Test Assertions Failing**
- The tests expect the switch state to toggle (`true` → `false`), but the final state remains `false`.
- The timer component drag test also fails because the component is not recognized as draggable.

---

## **4. Next Steps**

### **A. Verify Component Type Matching**
- Ensure the component types in `assets/levels/level_01.json` (e.g., `Component.Battery`) match the types registered in the code (e.g., `Battery`).
- Check if the `ComponentRegistry` is correctly mapping JSON types to Dart classes.

### **B. Debug Component Behaviors**
- Add logging in `ComponentRegistry` to confirm:
  - Which components are registered.
  - Which behaviors are linked to each component.
- Verify that `registerBehavior<T>()` is called for all required behaviors (e.g., `BatteryBehavior`, `SwitchBehavior`).

### **C. Fix Test Assertions**
- Update the test expectations to match the actual behavior of the components.
- If the switch state is not toggling, debug the `SwitchBehavior` logic.

### **D. Final Test Run**
- After fixing the above, re-run the tests to confirm:
  - No more hangs.
  - Components are created with the correct behaviors.
  - Test assertions should pass.

---

## **5. Key Files to Review**
| File | Purpose |
|------|---------|
| `lib/core/component_registry.dart` | Component and behavior registration logic. |
| `lib/main.dart` | Calls `registerAllGameEntities()` to populate the registry. |
| `test/level_01_revised_test.dart` | Test setup and assertions. |
| `assets/levels/level_01.json` | Level definition (component types must match code). |
| `lib/components/battery.dart`, `lib/components/switch.dart`, etc. | Component and behavior implementations. |

---

## **6. Expected Outcome**
- **Tests should no longer hang**.
- **Components should be created with the correct behaviors**.
- **Test assertions should pass** (switch toggles, timer is draggable).

---

## **7. Current Test Issue: Premature `GameEngineNotifier` Disposal**

**Date:** 2025-08-21

### Problem Description

The tests "TC-L1-01: Toggle switch interaction" and "TC-L1-02: Move timer component" in `test/level_01_revised_test.dart` are failing with a `StateError: Bad state: Tried to use GameEngineNotifier after `dispose` was called.` This error occurs when the test attempts to access `gameEngineNotifier.state` within the test body.

### Root Cause Analysis

`GameEngineNotifier` is managed by an `autoDispose` Riverpod provider (`gameEngineProvider`). When a `ProviderContainer` is disposed, all `autoDispose` providers within it are also disposed. While `addTearDown(() => container.dispose())` is used to ensure the `ProviderContainer` is disposed at the end of the test, the error occurs *within* the test body, implying that `gameEngineNotifier` is being disposed prematurely.

This suggests a subtle lifecycle management issue. It's highly unusual for `addTearDown` to execute before the test body completes. Possible, though less common, scenarios for this premature disposal include:

1.  **Asynchronous Cleanup Conflict**: An asynchronous operation or microtask might be completing after `pumpAndSettle()` but before the test's final assertions, implicitly triggering the disposal of the `ProviderContainer` or the `GameEngineNotifier`.
2.  **Implicit Framework Disposal**: The Flutter test framework might have an internal cleanup mechanism that disposes of certain resources (including `StateNotifier` instances managed by `autoDispose` providers) at an unexpected point in the test lifecycle, conflicting with the explicit `addTearDown` setup.

### Summary

The tests are failing because `GameEngineNotifier` is being disposed prematurely, leading to a `StateError` when its state is accessed. This points to a complex lifecycle management issue within the Flutter test environment, where the `GameEngineNotifier` is becoming unmounted earlier than anticipated during the test's execution, despite explicit disposal handling via `addTearDown`.


---

## Recent Debugging Session: State Management and Data Consistency (2025-08-21)

This section summarizes the recent debugging session that resolved critical issues related to state management and data consistency.

### Problem Statement

The test suite was failing with two critical errors: one for toggling a switch and another for moving a timer component. These errors were caused by a combination of issues, including race conditions in the state management pipeline, incorrect component registration, and data inconsistencies in the level files.

### The "Single Commit Pipeline" Architecture

The `GameEngineNotifier` has been refactored to use a "single commit pipeline" architecture. This is a critical concept for new developers to understand.

*   **The Problem:** The old `GameEngineNotifier` had multiple methods that could independently modify the game state, leading to race conditions and unpredictable behavior.
*   **The Solution:** All state updates now go through a single, centralized `_commitGrid` method. This ensures that state changes are atomic and predictable. Any method that needs to update the game state must now call `_commitGrid`.

### The `ComponentRegistry`

The `ComponentRegistry` is responsible for creating components and attaching behaviors to them.

*   **The Problem:** The `createFromJson` method was not correctly attaching behaviors to components created from the level's JSON data.
*   **The Solution:** The `createFromJson` method has been fixed to ensure that all components have the correct behaviors at runtime.

### The `r` and `c` Naming Convention

The codebase has been standardized to use `r` for rows and `c` for columns. This convention is used in the `Grid` model, the `ComponentModel`, the `CellOffset` class, and the level files.

### How to Add a New Component

To add a new component, you need to:

1.  **Create a new component file** in `lib/components/`.
2.  **Implement the necessary behaviors** for the component.
3.  **Create a registration function** that registers the component and its behaviors with the `ComponentRegistry`.
4.  **Call the registration function** in `lib/main.dart`.
5.  **Use the new component** in your level files.

This new architecture makes the project significantly easier to extend and maintain.
## Recent Architectural Refactoring: Game Engine Orchestration (2025-08-22)

This section details a significant architectural refactoring of the game engine, moving towards a more modular and orchestrated design.

### Overview of Changes

The core game engine has undergone a substantial overhaul, transitioning from a monolithic `GameEngineNotifier` to a system where `GameEngineNotifierV2` acts as a central orchestrator, delegating responsibilities to specialized managers. This refactoring aims to improve modularity, testability, and maintainability.

### Key Components and Their Roles

*   **`GameEngineNotifierV2` (Orchestrator):**
    *   Replaces the original `GameEngineNotifier`.
    *   Delegates core responsibilities to dedicated managers.
    *   Coordinates interactions between different parts of the game engine.

*   **`GameEngineCore` (New File: `lib/engine/game_engine_core.dart`):**
    *   Responsible for applying state updates and producing new `GameEngineState` objects.
    *   Assumes the `newGrid` (with pre-calculated power states) is provided, indicating a delegation of power simulation logic.

*   **`SimulationManager` (New File: `lib/engine/simulation_manager.dart`):**
    *   Centralizes and manages the power flow simulation logic through the circuit.
    *   Explicitly handles power propagation, improving clarity and testability of this complex logic.

*   **`InputManager`:**
    *   Handles user interactions and translates them into game actions.

*   **`AudioManager`:**
    *   Centralizes and manages audio feedback within the game.

### Impact on Existing Codebase

*   **Behavior System Adaptation:**
    *   `lib/behaviors/drag_behavior.dart`, `lib/behaviors/interaction_behavior.dart`, `lib/behaviors/movable_behavior.dart`: All behavior classes have been updated to interact with `GameEngineNotifierV2`.
    *   `drag_behavior.dart` now directly interacts with `GridWidgetState` for UI operations, enhancing type safety and encapsulation.

*   **Component-Level Updates:**
    *   `lib/components/switch.dart`: Updated to use `GameEngineNotifierV2`. The `onTap` method's `updateComponent` call changed from `updatedComponent` to `component`, which requires careful verification in `GameEngineNotifierV2` to ensure correct state updates. Audio handling shifted to `notifier.audio.playToggle()`.

*   **Test Suite Adaptation:**
    *   `test/helpers/game_test_helper.dart`: Test utilities updated to correctly access `gameEngineProvider`'s state, use string literals for component types, and reflect new state property names (e.g., `isClosed`, `isActive`).
    *   `test/helpers/test_setup_helper.dart`: Test setup now instantiates `GameEngineNotifierV2` and removes the `animationScheduler` dependency, aligning the test environment.
    *   `test/level_01_revised_test.dart`: Updated to use `GameEngineNotifierV2` and the renamed `audioManager` parameter.

### Rationale and Benefits

This refactoring promotes a clearer separation of concerns, making the codebase more modular, easier to understand, and more maintainable. Each new component has a well-defined responsibility, which significantly improves testability and scalability for future feature development. While this introduces significant changes across the codebase, it lays a robust foundation for the game's long-term architectural health.