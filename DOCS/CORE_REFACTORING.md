# **Circuit STEM: Core Logic Refactoring Guide**

**Version:** 1.0
**Author:** ME
**Status:** Proposed

---

## **1. Introduction: Why Are We Doing This?**

Welcome, developer! You are about to undertake a critical and exciting task: refactoring the core architecture of the `circuit_stem` application.

#### **The Problem**

The current codebase works, but it has some significant architectural problems:
*   **Hard to Test:** The main logic file, `GameEngineNotifierV2`, is a "god class"—it does everything from handling user input to playing sounds to running the simulation. This makes it nearly impossible to test any single piece of logic in isolation.
*   **Hard to Change:** Because everything is so tightly coupled, making a small change in one place can have unexpected side effects in another. This slows down development and makes it easy to introduce bugs.
*   **Hard to Extend:** Adding new features, like a level editor or new complex components, would require massive changes to many files, which is slow and risky.

#### **The Goal**

Our goal is to refactor the application to a clean, modern architecture based on **Domain-Driven Design (DDD)**. This new architecture will have:
*   **A Pure Domain Core:** The central game logic (what a component is, how simulation works) will have **zero dependencies on Flutter**. It will be pure, testable Dart code.
*   **Clear Separation of Concerns:** The code for UI (`presentation`), business logic (`application`), and external services like audio (`infrastructure`) will be cleanly separated.
*   **A Highly Testable System:** We will be able to write fast, reliable unit tests for 100% of our core game logic.

#### **The "Strangler Fig" Approach: A Safe Path Forward**

A "big bang" refactor where we rewrite everything at once is too risky. Instead, we will use the **"Strangler Fig" pattern**. We will build the new, clean architecture *alongside* the old one. Then, piece by piece, we will replace old logic with the new system until the old code is completely "strangled" and can be safely deleted.

**This guide will walk you through this process, phase by phase.** Each phase ends with the application in a **working, testable state**.

---

## **Phase 0: Preparation & Restructuring**

**🎯 Goal:** Reorganize the project's file structure to match our target architecture *without changing any code logic*.

**🤔 Why this phase is important:** Before we start changing logic, we need to get our house in order. By creating the new directory structure and moving files first, we make the subsequent code changes much easier to manage and understand.

---

### **✅ Step-by-Step Guide**

#### **Step 1: Create the New Directory Structure**

Open your terminal in the project root and run these commands to create the new folders:

```bash
mkdir -p lib/application/dto lib/application/services lib/application/use_cases
mkdir -p lib/domain/behaviors lib/domain/commands lib/domain/entities lib/domain/events lib/domain/services lib/domain/value_objects
mkdir -p lib/infrastructure/audio lib/infrastructure/persistence lib/infrastructure/rendering
mkdir -p lib/presentation/state lib/presentation/screens lib/presentation/widgets
```

#### **Step 2: Move Existing Files**

This is the most tedious part. We need to move the existing files into their new homes. Use your file explorer or the `mv` command.

| **Move this file...** | **...to this new location** |
| :--- | :--- |
| `lib/models/*` | `lib/domain/entities/` |
| `lib/behaviors/*` | `lib/domain/behaviors/` |
| `lib/engine/*` | `lib/application/` |
| `lib/services/audio_service.dart` | `lib/infrastructure/audio/` |
| `lib/services/level_manager.dart` | `lib/infrastructure/persistence/` |
| `lib/ui/canvas_painter.dart` | `lib/presentation/` |
| `lib/ui/game_canvas.dart` | `lib/presentation/` |
| `lib/ui/game_screen.dart` | `lib/presentation/screens/` |
| `lib/ui/screens/*` | `lib/presentation/screens/` |
| `lib/ui/widgets/*` | `lib/presentation/widgets/` |
| `lib/core/providers.dart` | `lib/presentation/state/` |

**Leave `main.dart`, `app.dart`, `routes.dart`, and `theme.dart` in the `lib/` root for now.**

#### **Step 3: Fix All Import Statements**

After moving the files, the project will be full of errors because all the `import` statements are now broken.

**Best Practice:** Use your IDE's "Find and Replace in Files" feature. For example, you will need to replace all instances of:

`import 'package:circuit_stem/models/component.dart';`

with:

`import 'package:circuit_stem/domain/entities/component.dart';`

Do this for all moved files. The Dart analyzer (the red squiggly lines) is your friend here. Go through each file and fix the imports until there are no more analyzer errors.

#### **Step 4: Verify Your Work**

This is the most important step of this phase. Run the entire test suite.

```bash
flutter test
```

**Expected Outcome:** All existing tests should pass. If they do, you have successfully reorganized the project without changing its behavior. You are now ready to start the real refactoring. If any tests fail, it means an import was missed or a file was moved incorrectly. Fix the issue before proceeding.

---

## **Phase 1: Introduce the Pure Domain (Coexistence)**

**🎯 Goal:** Build and test the new, pure domain models and behaviors *in parallel* with the old system.

**🤔 Why this phase is important:** We are building the core of our new, clean architecture. By creating these pure classes and unit testing them thoroughly *before* they are used by the app, we can be 100% confident that our fundamental game logic is correct.

---

### **✅ Step-by-Step Guide**

#### **Step 1: Create the New `ComponentEntity`**

In the `lib/domain/entities/` directory, create a new file named `component_entity.dart`.

**Best Practice:** A pure domain entity contains only data and core, self-contained logic. It should **never** depend on Flutter.

```dart
// lib/domain/entities/component_entity.dart

import 'package:collection/collection.dart';
import 'package:circuit_stem/domain/behaviors/behavior.dart';
import 'package:circuit_stem/domain/value_objects/position.dart';

class ComponentEntity {
  final String id;
  final String type;
  final Position position;
  final Map<String, dynamic> state;
  final List<Behavior> behaviors;

  ComponentEntity({
    required this.id,
    required this.type,
    required this.position,
    required this.state,
    required this.behaviors,
  });

  // Helper to get a specific behavior
  T? getBehavior<T extends Behavior>() {
    return behaviors.whereType<T>().firstOrNull;
  }

  // The core logic for executing an action
  ComponentEntity executeAction(String action, Map<String, dynamic> context) {
    ComponentEntity result = this;
    for (final behavior in behaviors) {
      if (behavior.canExecute(this, action)) {
        result = behavior.execute(result, action, context);
      }
    }
    return result;
  }

  // CopyWith for immutable updates
  ComponentEntity copyWith({
    Position? position,
    Map<String, dynamic>? state,
  }) {
    return ComponentEntity(
      id: id,
      type: type,
      position: position ?? this.position,
      state: state ?? this.state,
      behaviors: behaviors,
    );
  }
}
```
*(You will also need to create `position.dart` and the base `behavior.dart` file for this to compile).*

#### **Step 2: Create the New Behavior System**

Create a new file `lib/domain/behaviors/behavior.dart` for the base class, and another for the implementation, e.g., `interaction_behavior.dart`.

```dart
// lib/domain/behaviors/behavior.dart
import 'package:circuit_stem/domain/entities/component_entity.dart';

abstract class Behavior {
  String get type;
  bool canExecute(ComponentEntity component, String action);
  ComponentEntity execute(ComponentEntity component, String action, Map<String, dynamic> context);
}
```

```dart
// lib/domain/behaviors/interaction_behavior.dart
import 'package:circuit_stem/domain/behaviors/behavior.dart';
import 'package:circuit_stem/domain/entities/component_entity.dart';

class ToggleBehavior extends Behavior {
  @override
  String get type => 'interaction';

  @override
  bool canExecute(ComponentEntity component, String action) {
    return action == 'tap';
  }

  @override
  ComponentEntity execute(ComponentEntity component, String action, Map<String, dynamic> context) {
    if (action == 'tap') {
      final currentClosedState = component.state['closed'] as bool? ?? false;
      final newState = Map<String, dynamic>.from(component.state)
        ..['closed'] = !currentClosedState;
      return component.copyWith(state: newState);
    }
    return component;
  }
}
```

#### **Step 3: Write Unit Tests for the New Domain Logic**

**Best Practice:** Before this new code is ever used, we must test it. This is the core benefit of this architecture.

Create a new test file `test/domain/behaviors/interaction_behavior_test.dart`.

```dart
// test/domain/behaviors/interaction_behavior_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/domain/behaviors/interaction_behavior.dart';
import 'package:circuit_stem/domain/entities/component_entity.dart';
import 'package:circuit_stem/domain/value_objects/position.dart';

void main() {
  group('ToggleBehavior', () {
    test('execute with "tap" action should toggle the "closed" state from false to true', () {
      // ARRANGE
      final behavior = ToggleBehavior();
      final component = ComponentEntity(
        id: 's1',
        type: 'switch',
        position: Position(r: 1, c: 1),
        state: {'closed': false},
        behaviors: [behavior],
      );

      // ACT
      final result = behavior.execute(component, 'tap', {});

      // ASSERT
      expect(result.state['closed'], isTrue);
    });

    test('execute with "tap" action should toggle the "closed" state from true to false', () {
      // ARRANGE
      final behavior = ToggleBehavior();
      final component = ComponentEntity(
        id: 's1',
        type: 'switch',
        position: Position(r: 1, c: 1),
        state: {'closed': true},
        behaviors: [behavior],
      );

      // ACT
      final result = behavior.execute(component, 'tap', {});

      // ASSERT
      expect(result.state['closed'], isFalse);
    });
  });
}
```
Run `flutter test test/domain/behaviors/interaction_behavior_test.dart` and watch it pass.

---

## **Phase 2: In-Place Behavior Standardization (Tactical Refactoring)**

**🎯 Goal:** To standardize the way component behaviors are handled, making them functional, testable, and decoupled from direct state mutation, while leveraging the existing `ComponentModel` and `GameEngineNotifierV2` structure. This approach prioritizes immediate, low-risk improvements over a full architectural overhaul.

**🤔 Why this phase is important:** The previous "Adapter & Bridge" approach (now in "Legacy Approaches") was deemed overly complex and risky for the current scale of the application. This revised Phase 2 focuses on a tactical refactoring that delivers significant benefits (improved testability, clearer responsibilities) with minimal architectural upheaval. It addresses the "god class" problem by making behaviors inform the `Notifier` rather than directly mutate its state.

---

### **✅ Step-by-Step Guide**

This phase involves a series of focused changes to standardize the behavior interface and integrate it into the `GameEngineNotifierV2`.

#### **Step 0.1: Resolve File Conflict (Critical Pre-requisite)**

*   **Issue:** You might have duplicate `SimulationManager` (`lib/application/simulation_manager.dart`) and `SimulationService` (`lib/application/services/simulation_service.dart`) files from previous attempts. This will cause build errors.
*   **Action:** **Delete the old `lib/application/simulation_manager.dart` file.**
    *   **Command:** `rm lib/application/simulation_manager.dart`
*   **Impact:**
    *   **Files:** `lib/application/simulation_manager.dart` (deleted). `lib/application/services/simulation_service.dart` (remains as the sole simulation service).
    *   **Classes:** `GameEngineNotifierV2`'s `simulation` field and constructor initialization will need to be updated to use `SimulationService`.
    *   **Justification:** Essential for a clean build and to avoid ambiguity. This ensures a single, consistent simulation service.

#### **Step 0.2: Define `GameContext`**

*   **Purpose:** To provide behaviors with necessary read-only context (like the current grid state) without giving them direct access to the `GameEngineNotifierV2` instance. This improves decoupling and testability.
*   **File:** `lib/application/game_context.dart`
*   **Class:** `GameContext`
*   **Code Change:**
    ```dart
    // lib/application/game_context.dart
    import 'package:circuit_stem/domain/entities/grid.dart';
    import 'package:circuit_stem/application/game_engine_state.dart'; // To create from state
    // import 'package:circuit_stem/common/logger.dart'; // Example: if Logger is needed by behaviors

    class GameContext {
      final Grid grid;
      // Add other read-only services/data behaviors might need, e.g., Logger
      // final Logger logger; 

      GameContext({required this.grid /*, required this.logger */});

      // Factory constructor to create from GameEngineState
      factory GameContext.from(GameEngineState state) {
        return GameContext(
          grid: state.grid,
          // logger: Logger(), // Example: if Logger is needed
        );
      }
    }
    ```
*   **Impact:**
    *   **Files:** New `lib/application/game_context.dart`.
    *   **Classes:** `GameEngineNotifierV2` will create and pass `GameContext` to behaviors. Behaviors will receive `GameContext` in their `handle` method.
    *   **Core Logic:** Behaviors gain access to global game state (like the grid) in a controlled, read-only manner.
    *   **UI/Testing:** No direct UI impact. Improves testability of behaviors as `GameContext` can be easily mocked.

---

#### **Phase 1: Standardize Behavior Interface**

**Step 1.1: Modify `lib/domain/behaviors/behavior.dart` (New Interface Definition)**

*   **Current Role:** Abstract base for the *new* pure domain behaviors (`ToggleBehavior` was previously defined to extend this).
*   **Changes:** Adapt this file to define the `ComponentBehavior` interface. This will temporarily break `ComponentEntity` and `ToggleBehavior` (which will be fixed in subsequent steps).
*   **Code Change:**
    ```dart
    // lib/domain/behaviors/behavior.dart
    import 'package:circuit_stem/domain/entities/component.dart'; // Import ComponentModel
    import 'package:circuit_stem/application/game_context.dart'; // Import new GameContext

    /// Defines the contract for all component behaviors.
    /// Behaviors are functional: they take a component, an action, and context,
    /// and return a *new* ComponentModel if the state changes, or null otherwise.
    abstract class ComponentBehavior {
      String get behaviorType; // e.g., 'interaction', 'power_conduction', 'movement'
      
      /// Handles a specific action for a component.
      /// Returns a new ComponentModel if the component's state changes,
      /// otherwise returns null.
      ComponentModel? handle(ComponentModel component, String action, GameContext context);
    }
    ```
*   **Impact:**
    *   **Files:** `lib/domain/behaviors/behavior.dart` (modified).
    *   **Classes:** `ComponentEntity` (will have compile errors because its `executeAction` method signature no longer matches the `Behavior` interface it expects). `ToggleBehavior` (will have compile errors because it no longer correctly implements `Behavior`).
    *   **Justification:** This is the core change to standardize the behavior interface, making them functional and testable. It will cause temporary breakage in the new domain, which will be fixed by reverting `ComponentEntity` and `ToggleBehavior` to use `ComponentModel` and `GameContext`.

**Step 1.2: Refactor `lib/domain/behaviors/interaction_behavior.dart` (`ToggleBehavior`)**

*   **Current Role:** Concrete implementation of the *new* `Behavior` interface (from Phase 1 of the *original* refactoring plan).
*   **Changes:** Make `ToggleBehavior` implement the new `ComponentBehavior` interface. It will now operate directly on `ComponentModel` and return a new `ComponentModel` if the state changes.
*   **Code Change:**
    ```dart
    // lib/domain/behaviors/interaction_behavior.dart
    import 'package:circuit_stem/domain/entities/component.dart'; // Import ComponentModel
    import 'package:circuit_stem/application/game_context.dart'; // Import GameContext
    import 'package:circuit_stem/domain/behaviors/behavior.dart'; // Import ComponentBehavior (the new interface)

    /// A behavior that handles user interactions like tapping to toggle a switch.
    class ToggleBehavior implements ComponentBehavior { // Implement ComponentBehavior
      @override
      String get behaviorType => 'interaction'; // Consistent with user's example

      @override
      ComponentModel? handle(ComponentModel component, String action, GameContext context) {
        // Only handle 'tap' action for 'switch' type components
        if (action == 'tap' && component.type == 'switch') { 
          final currentState = component.state['closed'] as bool? ?? false;
          final newState = Map<String, dynamic>.from(component.state);
          newState['closed'] = !currentState;
          return component.copyWith(state: newState); // Return new ComponentModel
        }
        return null; // Return null if this behavior doesn't handle the action
      }
    }
    ```
*   **Impact:**
    *   **Files:** `lib/domain/behaviors/interaction_behavior.dart` (modified).
    *   **Classes:** `ToggleBehavior` now conforms to the new `ComponentBehavior` interface.
    *   **Testing:** `test/unit/domain/behaviors/interaction_behavior_test.dart` will need to be updated to reflect the new `handle` method signature and `ComponentModel` usage.
    *   **Justification:** Makes `ToggleBehavior` a pure function that takes a `ComponentModel` and returns a new one if a change occurs, aligning with the functional approach. This is highly testable.

**Step 1.3: Remove Unused Pure Domain Files (Cleanup)**

*   **Purpose:** The previous "Forward-Only Orchestrator" plan introduced new pure domain concepts (`ComponentEntity`, `ComponentType`, `ActionContext`) that are not part of this "In-Place Behavior Standardization" approach. Keeping them would introduce unused code and confusion.
*   **Action:** Delete the following files:
    *   `lib/domain/entities/component_entity.dart`
    *   `lib/domain/value_objects/component_type.dart`
    *   `lib/domain/value_objects/action_context.dart`
    *   `lib/domain/value_objects/position.dart` (and its generated `position.freezed.dart`) - *Note: `position.dart` was created specifically for `ComponentEntity` in the previous plan. If `Position` is used elsewhere in the legacy code, it should be preserved or re-created as needed.*
*   **Impact:**
    *   **Files:** Deletion of several files.
    *   **Classes:** Removes the `ComponentEntity` and related pure domain concepts from the active codebase for this phase.
    *   **Justification:** Reduces complexity, removes unused code, and clarifies the current refactoring strategy.

---

#### **Phase 2: Integrate Standardized Behaviors into `GameEngineNotifierV2`**

**Step 2.1: Modify `lib/application/game_engine_notifier.dart` (`_handleTap` and `simulation`)**

*   **Current Role:** Orchestrates tap handling, directly calling `onTap` on `InteractionBehavior`.
*   **Changes:**
    *   Update the `simulation` field and constructor to use `SimulationService`.
    *   Refactor `_handleTap` to iterate through `comp.behaviors` and use the new `ComponentBehavior.handle` method.
*   **Code Change:**
    ```dart
    // lib/application/game_engine_notifier.dart
    // ... existing imports ...
    import 'package:circuit_stem/application/services/simulation_service.dart'; // New import for SimulationService
    import 'package:circuit_stem/application/game_context.dart'; // New import for GameContext
    import 'package:circuit_stem/domain/behaviors/behavior.dart'; // Import ComponentBehavior (the new interface)
    // Remove: import '../../domain/behaviors/interaction_behavior.dart'; // Old import, no longer needed

    class GameEngineNotifierV2 extends StateNotifier<GameEngineState> {
      final InputManager input;
      final AudioManager audio;
      // Change type from SimulationManager to SimulationService
      final SimulationService simulation; 

      GameEngineNotifierV2({
        required AudioService audioService,
      })  : input = InputManager(),
            audio = AudioManager(audioService),
            simulation = SimulationService(), // Use new SimulationService
            super(GameEngineState.empty()) {
        _init();
      }

      // ... _init, loadLevel, _moveComponent ...

      void _handleTap(ComponentModel comp) {
        Logger.log('GameEngineNotifierV2: _handleTap called for component ${comp.id}');
        audio.playSelection(); // Keep initial audio for selection

        ComponentModel? updatedComponent;
        final gameContext = GameContext.from(state); // Create GameContext

        // Iterate through behaviors associated with the component
        // Assuming comp.behaviors now contains instances of ComponentBehavior
        for (final behavior in comp.behaviors.whereType<ComponentBehavior>()) {
          final result = behavior.handle(comp, 'tap', gameContext);
          if (result != null) {
            updatedComponent = result;
            // Trigger specific audio based on behavior type or component type
            // This can be refined later with an event bus if needed.
            if (behavior.behaviorType == 'interaction' && comp.type == 'switch') { 
                audio.playToggle(); 
            }
            break; // Assuming only one behavior handles a 'tap' action
          }
        }

        if (updatedComponent != null) {
          var newGrid = state.grid.copyWithUpdatedComponent(updatedComponent);
          newGrid = simulation.simulatePowerFlow(newGrid); // Use SimulationService
          state = state.copyWith(grid: newGrid);
        }

        // Tapping does not change the grid logic, only selection state
        // This line should probably be moved or removed if the interaction behavior handles selection
        state = state.copyWith(selectedComponentId: comp.id);
      }

      // ... updateComponent, selectPaletteComponent, togglePause, restartLevel, undo ...
    }
    ```
*   **Impact:**
    *   **Files:** `lib/application/game_engine_notifier.dart` (modified).
    *   **Core Logic:** `_handleTap` becomes more functional and delegates behavior execution. It centralizes the state update (`state = state.copyWith(...)`) after a behavior has processed an action. The `simulation` dependency is updated.
    *   **UI:** No direct UI impact, as `GameEngineNotifierV2`'s public interface remains largely the same.
    *   **Testing:** Existing tests for `GameEngineNotifierV2` will need to be updated to reflect the new `_handleTap` logic and the change in `simulation` type.
    *   **Justification:** This is the core integration step. It makes the `Notifier` responsible for state management, while behaviors become pure functions that inform the `Notifier` of changes.

---

#### **Phase 3: Verification & Cleanup**

**Step 3.1: Update Unit Tests**

*   **Files:** `test/unit/domain/behaviors/interaction_behavior_test.dart` (and any other behavior tests that will be refactored later).
*   **Changes:** Update tests to use the new `ComponentBehavior` interface and `handle` method signature, passing `GameContext`.
*   **Justification:** Ensure the new behavior implementations are correctly tested in isolation.

**Step 3.2: Run All Tests & Analysis**

*   **Action:** `flutter test && flutter analyze`.
*   **Justification:** Verify that all changes are correct, no regressions are introduced, and the codebase remains clean. This is a critical step after any code modification.

**Step 3.3: Clean Up Old `InteractionBehavior` (Later)**

*   **Action:** Once all components are migrated to the new `ComponentBehavior` interface, the old `lib/domain/behaviors/interaction_behavior.dart` (the one with `onTap(this, comp)`) and its usages can be safely removed. This will be a gradual process as more behaviors are refactored.
*   **Justification:** Remove dead code and simplify the codebase.

---

**Legacy Approaches & Discarded Plans**

This section documents previous architectural proposals that were considered but ultimately discarded in favor of the current strategy. This serves as a historical record and provides context for future developers.

---

## **Phase 2: The Adapter & Bridge (First Integration)**

**🎯 Goal:** To connect a single piece of the old engine to our new, tested domain logic. This proves the integration works while keeping the risk contained to one small feature.

**🤔 Why this phase is important:** This is our first step in "strangling" the old system. We're building a "bridge" from the old world to the new. By doing this for one small feature (toggling a switch), we can prove the pattern works before applying it to more complex logic like the power simulation.

---

### **✅ Step-by-Step Guide**

#### **Step 1: Create the "Adapter" File**

This file will contain helper functions to translate between the old models and our new, pure entities.

Create a new file: `lib/application/domain_adapter.dart`.

```dart
// lib/application/domain_adapter.dart

import 'package:circuit_stem/domain/entities/component_entity.dart';
import 'package:circuit_stem/domain/value_objects/position.dart';
import 'package:circuit_stem/domain/behaviors/interaction_behavior.dart'; // Import new behaviors
// ... import other new behaviors as they are created

// Import the OLD model
import 'package:circuit_stem/domain/entities/component.dart';

// Note: For this to work, you might need to use an alias on one of the imports
// if both files define a class with the same name, e.g.:
// import 'package:circuit_stem/domain/entities/component.dart' as old;

// This function converts an old ComponentModel to a new ComponentEntity
ComponentEntity toComponentEntity(ComponentModel model) {
  // This is a simplified example. We would need a factory or switch
  // statement to assign the correct new behaviors based on the model's type.
  final behaviors = [
    if (model.type == 'Component.Switch') ToggleBehavior(),
    // Add other behaviors here...
  ];

  return ComponentEntity(
    id: model.id,
    type: model.type,
    position: Position(r: model.r, c: model.c),
    state: model.state,
    behaviors: behaviors,
  );
}

// This function converts a new ComponentEntity back to an old ComponentModel
ComponentModel toComponentModel(ComponentEntity entity) {
  return ComponentModel(
    id: entity.id,
    type: entity.type,
    r: entity.position.r,
    c: entity.position.c,
    rotation: 0, // Assuming default, would need to be mapped
    state: entity.state,
    // The old model's behaviors list can be ignored as we are phasing it out.
    behaviors: [],
  );
}
```

#### **Step 2: Modify the Old Engine to Use the Adapter**

Now we will modify the original `GameEngineNotifierV2` to use our new logic for just one specific case.

**File to Modify:** `lib/application/game_engine_notifier.dart`

Find the method responsible for handling taps (it might be named `_handleTap` or be inside the `InteractionBehavior`). We are going to change it.

**FROM (The Old Way):**
```dart
// lib/application/game_engine_notifier.dart (Old code)

// This logic was likely inside the old SwitchInteractionBehavior
void onTap(GameEngineNotifierV2 notifier, ComponentModel component) {
  final currentState = component.state['closed'] as bool? ?? false;
  final newComponentState = Map<String, dynamic>.from(component.state)
    ..['closed'] = !currentState;

  final updatedComponent = component.copyWith(state: newComponentState);

  notifier.updateComponent(updatedComponent); // Directly updates state
  notifier.audio.playToggle();
}
```

**TO (The New Way, Using the Bridge):**
```dart
// lib/application/game_engine_notifier.dart (New code)
import 'package:circuit_stem/application/domain_adapter.dart';

// This logic is now inside the GameEngineNotifierV2 itself, replacing the old behavior call.
void _handleTap(ComponentModel component) {
  // We only handle the switch this new way for now.
  if (component.type == 'Component.Switch') {
    print("Using NEW domain logic for switch toggle!");

    // 1. Convert to the new, pure entity
    final entity = toComponentEntity(component);

    // 2. Execute the pure, tested domain logic
    final resultEntity = entity.executeAction('tap', {});

    // 3. Convert back to the old model
    final newModel = toComponentModel(resultEntity);

    // 4. Update the state using the old mechanism
    updateComponent(newModel);
    audio.playToggle();

  } else {
    // For all other components, do whatever you were doing before.
    print("Using OLD logic for other components.");
    // ... old logic here ...
  }
}
```

#### **Step 3: Verify Your Work**

Run the application. Play Level 1. When you tap the switch, you should see the message "Using NEW domain logic for switch toggle!" in your console. The switch should toggle exactly as it did before. All other functionality (dragging, power simulation) should also work as before.

Run the test suite again with `flutter test`. All tests should still pass.

**You have successfully replaced a piece of the engine's core logic with your new, pure domain code, without breaking the application!**

---

## **Phase 3: Gradual Strangulation (Feature by Feature)**

**🎯 Goal:** To repeat the "Adapter" pattern for all other features, systematically replacing the old logic until the `GameEngineNotifierV2` is just an empty shell.

**🤔 Why this phase is important:** This is the main part of the refactoring. We are methodically and safely migrating the entire application's logic, one piece at a time, reducing risk at every step.

---

### **✅ Step-by-Step Guide**

This phase involves repeating the pattern from Phase 2 for every feature.

#### **Example 1: Refactoring Component Movement**

1.  **Create the Domain Logic:** Create a `MoveBehavior` in `lib/domain/behaviors/`. Write unit tests for it.
2.  **Create a Use Case:** Create a `MoveComponentUseCase` in `lib/application/use_cases/`. This will orchestrate the validation and execution of the move.
3.  **Update the Adapter:** Add logic to `domain_adapter.dart` to handle the new `MoveBehavior`.
4.  **Modify the Engine:** In `GameEngineNotifierV2`, find the `onDragEnd` or `handleMove` logic. Replace its body with a call to your new `MoveComponentUseCase` (via the adapter).
5.  **Test:** Run the app and the test suite to ensure dragging still works.

#### **Example 2: Refactoring the Power Simulation**

1.  **Create the Domain Logic:** Create a `SimulationService` in `lib/domain/services/`. Port all the complex power flow logic into this pure Dart class.
2.  **Write Unit Tests:** Write extensive unit tests for the `SimulationService`, covering all edge cases (short circuits, parallel circuits, etc.).
3.  **Modify the Engine:** In `GameEngineNotifierV2`, find the place where it calls the old `SimulationManager`. Replace this call. The new logic will:
    a. Convert the entire grid of old `ComponentModel`s to a grid of new `ComponentEntity`s.
    b. Call the new, pure `SimulationService.simulate(gridEntity)`.
    c. Convert the entire resulting grid back to the old models.
    d. Update the state.
4.  **Test:** This is a major change. Test thoroughly by playing through all levels.

**Continue this process for every feature: rotation, goal checking, etc.** With each step, the old `GameEngineNotifierV2` becomes simpler, and your new, clean `domain` and `application` layers become more powerful.

---

## **Phase 4: The Final Cutover**

**🎯 Goal:** To completely remove the old system and have the UI communicate directly with the new, clean application layer.

**🤔 Why this phase is important:** This is the final step that removes all the old code, adapters, and technical debt, leaving us with our beautiful new architecture.

---

### **✅ Step-by-Step Guide**

By now, your `GameEngineNotifierV2` should be almost empty. All its work is delegated. Now we can finally remove it.

#### **Step 1: Create the New `GameStateNotifier`**

Create the new, thin notifier as you designed in your proposal. This class will be part of the `presentation` layer.

```dart
// lib/presentation/state/game_state_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/application/use_cases/game_use_cases.dart'; // Your new use cases
import 'package:circuit_stem/domain/entities/game_state.dart'; // Your new game state entity

class GameStateNotifier extends StateNotifier<GameState> {
  final GameUseCases _gameUseCases;

  GameStateNotifier(this._gameUseCases) : super(GameState.empty());

  Future<void> moveComponent(String componentId, Position position) async {
    final result = await _gameUseCases.moveComponent(state, componentId, position);
    
    if (result.isSuccess) {
      state = result.data;
    } else {
      // Handle error (show snackbar, etc.)
    }
  }

  // ... other methods for each use case ...
}
```

#### **Step 2: Update Riverpod Providers**

Modify `lib/presentation/state/providers.dart`. Change the main `gameEngineProvider` to provide an instance of your new `GameStateNotifier`. You will also need to provide your new `GameUseCases` and other services.

#### **Step 3: Update the UI**

Go through all the UI files in `lib/presentation/screens/` and `lib/presentation/widgets/`. Change any widget that was using the old `GameEngineNotifierV2` to now use the new `GameStateNotifier`. The calls should be much cleaner now.

**FROM (Old Way):**
`ref.read(gameEngineProvider.notifier).inputManager.handleMove(...)`

**TO (New Way):**
`ref.read(gameEngineProvider.notifier).moveComponent(...)`

#### **Step 4: The Great Deletion**

This is the satisfying part. You can now safely delete:
*   The old `GameEngineNotifierV2` file.
*   The old `ComponentModel` and other old model files.
*   The old `behaviors` directory.
*   The `domain_adapter.dart` file, as it is no longer needed.
*   Any other leftover parts of the old system.

#### **Step 5: Final Verification**

Run the entire test suite one last time. Play through every level of the game. Congratulations, you have successfully refactored the entire core of the application!

---

## **Phase 5: Post-Refactoring Enhancements**

Now that you have a clean, testable, and extensible architecture, you can easily implement the advanced features from your proposal:
*   **Command Pattern for Undo/Redo:** Implement the `CommandService` and `Command` classes.
*   **Event-Driven Audio:** Implement the `EventBus` and decouple the audio system.
*   **Advanced Testing:** Begin implementing the Golden, Performance, and Accessibility tests on your new, highly testable codebase.

Design Plan PHASE 2: Option A - In-Place Behavior Standardization
Goal: To refactor component behaviors to be functional and testable, centralizing state updates within GameEngineNotifierV2, while leveraging the existing ComponentModel and comp.behaviors structure.

Phase 0: Preparation & Foundation
Step 0.1: Resolve File Conflict (Critical Blocker)

Issue: Duplicate SimulationManager (lib/application/simulation_manager.dart) and SimulationService (lib/application/services/simulation_service.dart) files. This will cause build errors and ambiguity.
Action: Delete the old lib/application/simulation_manager.dart file.
Impact:
Files: lib/application/simulation_manager.dart (deleted). lib/application/services/simulation_service.dart (remains as the sole simulation service).
Classes: GameEngineNotifierV2's simulation field and constructor initialization will need to be updated to use SimulationService.
Justification: This is a non-negotiable first step to ensure a clean build environment and prevent runtime errors. It establishes a single source of truth for simulation logic.
Step 0.2: Define GameContext

Purpose: To provide behaviors with necessary read-only context (like the current grid state) without giving them direct access to the GameEngineNotifierV2 instance. This improves decoupling and testability.
File: lib/application/game_context.dart
Class: GameContext
Code Change:
// lib/application/game_context.dart
import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/application/game_engine_state.dart'; // To create from state

class GameContext {
  final Grid grid;
  // Add other read-only services/data behaviors might need, e.g., Logger
  // final Logger logger; 

  GameContext({required this.grid /*, required this.logger */});

  // Factory constructor to create from GameEngineState
  factory GameContext.from(GameEngineState state) {
    return GameContext(
      grid: state.grid,
      // logger: Logger(), // Example: if Logger is needed
    );
  }
}
Impact:
Files: New lib/application/game_context.dart.
Classes: GameEngineNotifierV2 will instantiate GameContext and pass it to behaviors. Behaviors will receive GameContext in their handle method.
Core Logic: Behaviors gain access to global game state (like the grid) in a controlled, read-only manner.
UI/Testing: No direct UI impact. Improves testability of behaviors as GameContext can be easily mocked.
Phase 1: Standardize Behavior Interface
Step 1.1: Modify lib/domain/behaviors/behavior.dart (New Interface Definition)

Current Role: Abstract base for the new pure domain behaviors (ToggleBehavior was previously defined to extend this).
Changes: Adapt this file to define the ComponentBehavior interface proposed by you. This will temporarily break ComponentEntity and ToggleBehavior (which will be fixed in subsequent steps).
Code Change:
// lib/domain/behaviors/behavior.dart
import 'package:circuit_stem/domain/entities/component.dart'; // Import ComponentModel
import 'package:circuit_stem/application/game_context.dart'; // Import new GameContext

abstract class ComponentBehavior {
  String get behaviorType; // e.g., 'interaction', 'power_conduction', 'movement'

  // handle method returns a new ComponentModel if state changes, null otherwise
  // This makes behaviors functional: input (component, action, context) -> output (new component or null)
  ComponentModel? handle(ComponentModel component, String action, GameContext context);
}
Impact:
Files: lib/domain/behaviors/behavior.dart (modified).
Classes: ComponentEntity (will have compile errors because its executeAction method signature no longer matches the Behavior interface it expects). ToggleBehavior (will have compile errors because it no longer correctly implements Behavior).
Justification: This is the foundational change for the "In-Place Behavior Standardization." It defines the new contract for all behaviors, making them functional and decoupled from the notifier's direct mutation methods.
Step 1.2: Refactor lib/domain/behaviors/interaction_behavior.dart (ToggleBehavior)

Current Role: Concrete implementation of the new Behavior interface (from Phase 1 of the original refactoring plan).
Changes: Make ToggleBehavior implement the new ComponentBehavior interface. It will now operate directly on ComponentModel and return a new ComponentModel if the state changes.
Code Change:
// lib/domain/behaviors/interaction_behavior.dart
import 'package:circuit_stem/domain/entities/component.dart'; // Import ComponentModel
import 'package:circuit_stem/application/game_context.dart'; // Import GameContext
import 'package:circuit_stem/domain/behaviors/behavior.dart'; // Import ComponentBehavior (the new interface)

class ToggleBehavior implements ComponentBehavior { // Implement ComponentBehavior
    String get behaviorType => 'interaction'; // Consistent with user's example

  
  ComponentModel? handle(ComponentModel component, String action, GameContext context) {
    // Only handle 'tap' action for 'switch' type components
    if (action == 'tap' && component.type == 'switch') { 
      final currentState = component.state['closed'] as bool? ?? false;
      final newState = Map<String, dynamic>.from(component.state);
      newState['closed'] = !currentState;
      return component.copyWith(state: newState); // Return new ComponentModel
    }
    return null; // Return null if this behavior doesn't handle the action
  }
}
Impact:
Files: lib/domain/behaviors/interaction_behavior.dart (modified).
Classes: ToggleBehavior now conforms to the new ComponentBehavior interface.
Testing: test/unit/domain/behaviors/interaction_behavior_test.dart will need to be updated to reflect the new handle method signature and ComponentModel usage.
Justification: This makes ToggleBehavior a pure function. It receives a component and context, processes the action, and returns a new component if its state changes, or null otherwise. This is highly testable and avoids direct state mutation.
Step 1.3: Revert/Adjust lib/domain/entities/component_entity.dart (Temporary Adjustment)

Current Role: The new pure domain ComponentEntity (from the previous, now discarded, "Forward-Only Orchestrator" plan).
Changes: Since we are no longer pursuing the full "pure domain" separation in this phase, ComponentEntity and its related files (component_type.dart, action_context.dart) are not directly part of "In-Place Behavior Standardization." For now, we will either:
Option A (Simpler): Delete component_entity.dart, component_type.dart, action_context.dart and their related freezed files. This removes the unused code.
Option B (Preserve for Future): Keep them, but they will not be used in this phase. The behavior.dart file will be the one used by ComponentModel.
Decision: Given the "in-place" nature and focus on immediate benefits, Option A (deletion) is cleaner to avoid confusion and unused code.
Action: Delete lib/domain/entities/component_entity.dart, lib/domain/value_objects/component_type.dart, lib/domain/value_objects/action_context.dart, and lib/domain/value_objects/position.freezed.dart (as position.dart was created for ComponentEntity).
Impact:
Files: Deletion of several files.
Classes: Removes the ComponentEntity and related pure domain concepts from the active codebase for this phase.
Justification: Reduces complexity and removes code that is not part of the current refactoring strategy. The Position value object can be re-introduced if needed by other parts of the system later.
Phase 2: Integrate Standardized Behaviors into GameEngineNotifierV2
Step 2.1: Modify lib/application/game_engine_notifier.dart (_handleTap and simulation)

Current Role: Orchestrates tap handling, directly calling onTap on InteractionBehavior.
Changes:
Update the simulation field and constructor to use SimulationService.
Refactor _handleTap to iterate through comp.behaviors and use the new ComponentBehavior.handle method.
Code Change:
// lib/application/game_engine_notifier.dart
// ... existing imports ...
import 'package:circuit_stem/application/services/simulation_service.dart'; // New import for SimulationService
import 'package:circuit_stem/application/game_context.dart'; // New import for GameContext
import 'package:circuit_stem/domain/behaviors/behavior.dart'; // Import ComponentBehavior (the new interface)
// Remove: import '../../domain/behaviors/interaction_behavior.dart'; // Old import

class GameEngineNotifierV2 extends StateNotifier<GameEngineState> {
  final InputManager input;
  final AudioManager audio;
  // Change type from SimulationManager to SimulationService
  final SimulationService simulation; 

  GameEngineNotifierV2({
    required AudioService audioService,
  })  : input = InputManager(),
        audio = AudioManager(audioService),
        simulation = SimulationService(), // Use new SimulationService
        super(GameEngineState.empty()) {
    _init();
  }

  // ... _init, loadLevel, _moveComponent ...

  void _handleTap(ComponentModel comp) {
    Logger.log('GameEngineNotifierV2: _handleTap called for component ${comp.id}');
    audio.playSelection(); // Keep initial audio for selection

    ComponentModel? updatedComponent;
    final gameContext = GameContext.from(state); // Create GameContext

    // Iterate through behaviors associated with the component
    // Assuming comp.behaviors now contains instances of ComponentBehavior
    for (final behavior in comp.behaviors.whereType<ComponentBehavior>()) {
      final result = behavior.handle(comp, 'tap', gameContext);
      if (result != null) {
        updatedComponent = result;
        // Trigger specific audio based on behavior type or component type
        if (behavior.behaviorType == 'interaction' && comp.type == 'switch') { 
            audio.playToggle(); 
        }
        break; // Assuming only one behavior handles a 'tap' action
      }
    }

    if (updatedComponent != null) {
      var newGrid = state.grid.copyWithUpdatedComponent(updatedComponent);
      newGrid = simulation.simulatePowerFlow(newGrid); // Use SimulationService
      state = state.copyWith(grid: newGrid);
    }

    // Tapping does not change the grid logic, only selection state
    // This line should probably be moved or removed if the interaction behavior handles selection
    state = state.copyWith(selectedComponentId: comp.id);
  }

  // ... updateComponent, selectPaletteComponent, togglePause, restartLevel, undo ...
}
Impact:
Files: lib/application/game_engine_notifier.dart (modified).
Core Logic: _handleTap becomes more functional and delegates behavior execution. It centralizes the state update (state = state.copyWith(...)) after a behavior has processed an action.
UI: No direct UI impact, as GameEngineNotifierV2's public interface remains largely the same.
Testing: Existing tests for GameEngineNotifierV2 will need to be updated to reflect the new _handleTap logic and the change in simulation type.
Justification: This is the core integration step. It makes the Notifier responsible for state management, while behaviors become pure functions that inform the Notifier of changes.
Phase 3: Verification & Cleanup
Step 3.1: Update Unit Tests

Files: test/unit/domain/behaviors/interaction_behavior_test.dart (and any other behavior tests that will be refactored later).
Changes: Update tests to use the new ComponentBehavior interface and handle method signature, passing GameContext.
Justification: Ensure the new behavior implementations are correctly tested in isolation.
Step 3.2: Run All Tests & Analysis

Action: flutter test && flutter analyze.
Justification: Verify that all changes are correct, no regressions are introduced, and the codebase remains clean. This is a critical step after any code modification.
Step 3.3: Clean Up Old InteractionBehavior (Later)

Action: Once all components are migrated to the new ComponentBehavior interface, the old lib/domain/behaviors/interaction_behavior.dart (the one with onTap(this, comp)) and its usages can be safely removed. This will be a gradual process as more behaviors are refactored.
Justification: Remove dead code and simplify the codebase.
This detailed plan for "Option A: In-Place Behavior Standardization" provides a clear, step-by-step guide for implementation, focusing on a low-risk, incremental approach that aligns with your recommendations.

Context Sources (1)
