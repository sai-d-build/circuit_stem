# Architectural Refactor Plan: The Component-Behavior Model

**Author:** Gemini Agent
**Date:** 2025-08-19
**Status:** Proposed

---

## 1. Introduction: The "Why"

This document outlines a plan to refactor the core architecture of the Circuit STEM project. Our current architecture, while functional, has a key limitation: adding new types of components or goals requires modifying multiple core files (`GameEngineNotifier`, `CanvasPainter`, etc.), often within large `switch` statements. This violates the **Open/Closed Principle**, making the system rigid and harder to maintain as it grows.

The goal of this refactoring is to evolve our architecture into a **"plug-in" model**. This new design, called the **Component-Behavior model**, will allow developers to add new functionality by simply adding new files, without modifying existing core engine code. This approach is heavily inspired by industry-standard patterns like **Entity-Component-System (ECS)** and aligns with best practices found in modern game engines like Unity, Godot, and Flame.

## 2. Core Concepts of the New Architecture

### 2.1. From `enum` to Data-Driven Types

We are moving away from hard-coded `enum` types for components and goals. Instead, the level JSON files will use simple, human-readable string identifiers.

**Before:**
```json
{ "type": 1, "id": "sw1" } // `1` refers to ComponentType.switch
```

**After:**
```json
{ "type": "Component.Switch", "id": "sw1" }
```

### 2.2. Behaviors (The Strategy Pattern)

Instead of having monolithic services that know how to handle every component type, we will break down those responsibilities into small, interchangeable classes called **Behaviors**. A component will be a simple container that *has* a collection of behaviors.

We will define a set of `abstract class`es (interfaces) for these behaviors:

*   `DrawingBehavior`: Defines how a component is rendered on the canvas.
*   `LogicBehavior`: Defines how a component interacts with the circuit's power evaluation.
*   `InteractionBehavior`: Defines how a component responds to user input like taps or drags.
*   `GoalCheckingBehavior`: Defines the logic for determining if a specific goal has been met.

### 2.3. The Central Registry

To make the system truly plug-and-play, we will introduce a central registry. On app startup, each component and goal type will "register" itself and its associated behaviors.

**Example Registration:**
```dart
// In a new file, e.g., lib/components/bulb.dart
void registerBulb() {
  ComponentRegistry.register(
    type: "Component.Bulb",
    behaviors: [BulbDrawingBehavior, BulbLogicBehavior],
    isDraggable: true,
  );
}
```

When the `LevelManager` loads a level, it will use this registry to look up the string identifier from the JSON (e.g., `"Component.Bulb"`) and automatically construct a `ComponentModel` with the correct behavior instances attached.

### 2.4. Behavior-Driven Engines

The core game engines (`GameEngineNotifier`, `CanvasPainter`) will become much simpler. Their job is no longer to *know* about every component, but simply to *delegate* tasks to the behaviors attached to each component.

**Before:**
```dart
// In CanvasPainter
switch (component.type) {
  case ComponentType.bulb:
    // draw bulb
    break;
  case ComponentType.wire:
    // draw wire
    break;
}
```

**After:**
```dart
// In CanvasPainter
// Simply find the component's drawing behavior and execute it.
component.getBehavior<DrawingBehavior>()?.draw(canvas, component);
```

## 3. Pros vs. Cons of This Approach

### Pros
*   **Maximum Extensibility:** New components or goals can be added just by creating new files and registering them. No core engine code needs to be touched.
*   **Improved Maintainability:** All code related to a single component (its drawing, logic, interaction) is located in one place, making it easier to find and debug.
*   **High Testability:** Each behavior is a small, focused class that can be unit-tested in complete isolation.
*   **Industry Alignment:** This architecture brings our project in line with modern, professional game development standards.

### Cons
*   **Increased Initial Complexity:** The new system involves more files and classes, and the concepts of a registry and behaviors are more abstract than a simple `switch` statement. This is the primary trade-off for achieving extreme flexibility.

## 4. The Comprehensive Refactoring Plan

This plan is broken into sequential phases. The core strategy is **"Additive-First, Subtractive-Last"**: we build the new system alongside the old and only remove the old code once the new system is fully verified.

---

### **Phase 0: Foundation - Setting Up the New Architecture**

*Goal: Create the foundational files. No existing code will be broken.*

1.  **Create New Directories:**
    *   `lib/behaviors/`
    *   `lib/components/`
    *   `lib/goals/`

2.  **Create Behavior Interfaces:**
    *   **File:** `lib/behaviors/drawing_behavior.dart`
        ```dart
        import 'package:flutter/painting.dart';
        import '../models/component.dart';
        import '../services/asset_manager.dart';

        abstract class DrawingBehavior {
          void draw(Canvas canvas, Size size, ComponentModel component, AssetManagerNotifier assets);
        }
        ```
    *   Create similar abstract classes for `LogicBehavior`, `InteractionBehavior`, and `GoalCheckingBehavior`.

3.  **Create Registries:**
    *   **File:** `lib/core/component_registry.dart`
        ```dart
        // Basic structure
        class ComponentRegistry {
          static final Map<String, List<Type>> _behaviors = {};
          // ... registration and creation logic ...
        }
        ```
    *   Create a similar `GoalRegistry` in `lib/core/goal_registry.dart`.

4.  **Update `main.dart`:**
    *   Add a new function `registerAllGameEntities()` and call it before `runApp()`. This function will eventually contain calls to `registerBulb()`, `registerSwitch()`, etc.

---

### **Phase 1: The First Migration - The "Bulb" Component**

*Goal: Prove the new architecture works by migrating a single component end-to-end.*

1.  **Create Bulb Behaviors:**
    *   **File:** `lib/components/bulb.dart`
    *   **Contents:**
        ```dart
        import 'package:flutter/material.dart';
        import '../behaviors/drawing_behavior.dart';
        import '../behaviors/logic_behavior.dart';
        import '../core/component_registry.dart';
        // ... other imports

        class BulbDrawingBehavior implements DrawingBehavior {
          @override
          void draw(Canvas canvas, Size size, ComponentModel component, AssetManagerNotifier assets) {
            // Move drawing logic from CircuitComponentPainter here
          }
        }

        class BulbLogicBehavior implements LogicBehavior {
          // ... Move logic evaluation for the bulb here
        }

        void registerBulb() {
          ComponentRegistry.register(
            type: "Component.Bulb",
            behaviors: [BulbDrawingBehavior, BulbLogicBehavior],
            isDraggable: true,
          );
        }
        ```

2.  **Update Data Models:**
    *   **File:** `lib/models/component.dart`
    *   **Change:** Add `List<dynamic> behaviors = const []` to the `ComponentModel`. Change `type` from `ComponentType` to `String`. Make the old `ComponentType` enum optional for now to avoid breaking everything at once.

3.  **Update JSON:**
    *   **File:** `assets/levels/level_01.json`
    *   **Change:** Find the "bulb" component and change its `type` to `"Component.Bulb"`.

4.  **Update `LevelManager`:**
    *   **File:** `lib/services/level_manager.dart`
    *   **Change:** In `loadLevelByIndex`, when parsing the level JSON, use `ComponentRegistry.create()` for any component that has a string `type`.

5.  **Temporary Engine Change (for verification):**
    *   **File:** `lib/ui/canvas_painter.dart`
    *   **Change:** In the `paint` method, add a temporary `if` statement to use the new drawing behavior if it exists, otherwise fall back to the old `switch` statement.

---

### **Phase 2: Full Migration - All Components & Goals**

*Goal: Migrate all remaining components and goals to the new architecture.*

1.  **Create Behavior & Registration Files:** For each component (switch, wire, battery, etc.), create a file in `lib/components/` containing its behavior classes and registration function.
2.  **Create Goal Behavior Files:** For each goal type, create a file in `lib/goals/` with its `GoalCheckingBehavior` and registration function.
3.  **Update All JSON Files:** Go through every file in `assets/levels/` and convert all component and goal types to their new string-based identifiers.

---

### **Phase 3: Engine Refactoring**

*Goal: Remove the core engine's dependency on the old system.*

1.  **Refactor `GameEngineNotifier`:** Replace all `switch` statements related to goals and interactions with behavior-driven loops.
2.  **Refactor `CanvasPainter`:** Remove the temporary `if/else` block and the old `switch` statement entirely. The painter should now *only* use `DrawingBehavior` to render all components.

---

### **Phase 4: Cleanup & Deprecation**

*Goal: Remove all legacy code related to the old architecture.*

1.  **Delete Old Files:**
    *   `lib/ui/painters/circuit_component_painter.dart`
    *   `lib/services/logic_engine.dart`
2.  **Modify Models:**
    *   Delete the `ComponentType` enum from `lib/models/component.dart`.
    *   Delete the `GoalType` enum from `lib/models/goal.dart`.
3.  **Run Build Runner:** Execute `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate the `freezed` and `g` files.
4.  **Code Cleanup:** Search the project for any remaining references to the old types and remove them.

---

### **Phase 5: Documentation**

*Goal: Update project documentation to reflect the new architecture.*

1.  **Update `DOCS/Architecture.md`:** Add a section summarizing the Component-Behavior model and link to this `REFACTOR_PLAN.md` document.
2.  **Create `DOCS/AddingNewComponents.md`:** Create a new tutorial file that walks a developer through adding a new component using the new, extensible system.

## 5. Tutorial: How to Add a New "Diode" Component

This tutorial shows how simple it is to add a new component once this refactor is complete.

1.  **Create the file `lib/components/diode.dart`**.
2.  **Implement its behaviors**:
    ```dart
    class DiodeDrawingBehavior implements DrawingBehavior { ... }
    class DiodeLogicBehavior implements LogicBehavior {
      // Implement one-way power flow logic here
    }
    ```
3.  **Create its registration function in the same file**:
    ```dart
    void registerDiode() {
      ComponentRegistry.register(
        type: "Component.Diode",
        behaviors: [DiodeDrawingBehavior, DiodeLogicBehavior],
      );
    }
    ```
4.  **Register it at startup**:
    *   In `main.dart`, add `registerDiode();` to the `registerAllGameEntities()` function.
5.  **Use it in a level JSON file**:
    ```json
    { "type": "Component.Diode", "id": "d1", "position": ... }
    ```
**That's it.** No changes are needed to the core engine.

## 6. Future Improvements

*   **Scriptable Behaviors:** For ultimate extensibility (e.g., for modding), we could investigate loading behavior logic from an external source, like a script file or directly from the JSON, rather than from compiled Dart code.
*   **Event Bus:** For more complex interactions between components that don't involve direct power flow, we could implement a global event bus. A component's `InteractionBehavior` could fire an event (e.g., `ButtonPressedEvent`), and other components could have `ListeningBehavior`s that react to it.

This refactoring will result in a highly professional, maintainable, and extensible architecture that will serve the project well into the future.

Pending: lib/ui/widgets/component_palette.dart. This widget is heavily reliant on the old ComponentType enum for its logic. I will read the file to understand its implementation and then refactor it to work with our new string-based, behavior-driven component model.