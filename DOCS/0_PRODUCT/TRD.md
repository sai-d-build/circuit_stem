# Technical Requirements Document (TRD)

**Project:** Circuit STEM
**Version:** 3.0 (Post-Riverpod Refactor)
**Last Updated:** 2025-08-12 EST

---

## 1. Introduction

This document provides a deep dive into the technical architecture, components, and design principles for the Circuit STEM application. It is intended for developers to understand the project structure, data flow, and the role of each component, enabling them to contribute effectively.

## 2. High-Level Design Principles

- **Modularity & Separation of Concerns:** The architecture strictly separates core logic (`LogicEngine`), game state management (`GameEngineNotifier`), level/asset management (`LevelManager`, `AssetManager`), and UI rendering (`GameScreen`, `CanvasPainter`). This ensures components are independently testable and maintainable.
- **Reactive State Management (Riverpod):** The `flutter_riverpod` package is the backbone of the state management system. It provides a robust, compile-safe, and scalable way to manage state and inject dependencies throughout the application.
- **Data-Driven Design:** Levels, components, and game goals are defined in external JSON files (`assets/levels/`), allowing for content updates without requiring a new application build.
- **Performance:** The core logic is pure Dart for maximum performance. UI rendering is optimized using `CustomPainter` and minimizing widget rebuilds through the granular and efficient nature of Riverpod providers.

## 3. Architecture & Data Flow

The application follows a reactive, service-oriented architecture. For visual diagrams and a high-level overview, please see the **[Architecture & UI Design Document](./Architecture.md)**.

**Typical Data Flow (User Taps a Switch):**

1.  **Input:** `GameCanvas` captures the tap via a `GestureDetector`.
2.  **Action:** It calls a method on the notifier, e.g., `ref.read(gameEngineProvider.notifier).toggleSwitch(componentId)`.
3.  **State Change:** `GameEngineNotifier` computes a new, immutable `GameEngineState` based on the action.
4.  **Evaluation:** As part of computing the new state, it calls `logicEngine.evaluate(grid)`.
5.  **Result:** `LogicEngine` returns a new `EvaluationResult`.
6.  **State Emission:** `GameEngineNotifier` finalizes the new `GameEngineState` and updates its state via `state = newState;`.
7.  **Re-render:** Riverpod detects the state change and automatically rebuilds any widget that was `watch`ing the `gameEngineProvider`. The `CanvasPainter` receives the new state and redraws the frame.

## 4. Project Structure (`lib` directory)

```
lib/
├── app.dart
├── main.dart
├── routes.dart
├── common/             # Shared constants, themes, utils
├── core/
│   ├── providers.dart  # Centralized Riverpod provider definitions
│   └── state/          # State definitions (not yet used)
├── engine/             # Core stateful game logic (StateNotifiers)
├── models/             # Immutable data models (using Freezed)
├── services/           # App-wide singleton services (logic, levels)
└── ui/                 # All UI-related code
    ├── screens/        # Top-level screen widgets
    └── widgets/        # Reusable UI components
```

## 5. File-by-File Breakdown

(A detailed file-by-file breakdown is included in the previous version of this document.)

---

## 6. Core Logic & Algorithms

_(This section remains accurate as the pure logic of the circuit evaluation has not changed.)_

This section details the fundamental algorithms used by the `LogicEngine`.

### 6.1. Terminal Generation

-   For each `ComponentModel` in the `Grid`, the engine calculates the absolute position and orientation of its `TerminalSpec` definitions.
-   It accounts for the component's anchor position (`r`, `c`) and its `rotation` to produce a flat list of `Terminal` objects, each with a unique ID, absolute grid coordinates, and final direction.

### 6.2. Graph Building (Adjacency Mapping)

The engine builds a graph where terminals are nodes and connections are edges. An adjacency map (`Map<String, Set<String>>`) is built in two phases:

1.  **External Adjacency:** The engine iterates through all terminals. For each terminal, it checks the neighboring grid cell in its path of direction. If a terminal exists in that cell with the *opposite* direction, an edge is created between them.
2.  **Internal Adjacency:** The engine connects terminals that belong to the same component.
    *   If `internalConnections` are explicitly defined in the `ComponentModel`, those connections are used exclusively.
    *   If not, the engine falls back to a heuristic where all terminals on the same component are considered interconnected.

### 6.3. Power Evaluation (Breadth-First Search)

-   The BFS starts from all positive battery terminals (`role: 'pos').
-   It traverses the graph, respecting any blocked terminals (e.g., an open switch), and adds every component it visits to a `poweredComponentIds` set.
-   This provides an efficient way to determine the power state of the entire circuit in a single pass.

### 6.4. Short Circuit Detection

-   A separate BFS is performed to detect shorts.
-   This search also starts at the positive battery terminals but keeps track of whether it has passed through a "load" component (like a bulb).
-   If the search reaches a negative battery terminal (`role: 'neg'`) **without** having seen a load, a short circuit is flagged.

## 7. Technical & Implementation Considerations

### 7.1. Performance

-   **`CustomPainter` Optimization:** The `CanvasPainter` is highly optimized. `Paint` objects are reused where possible, and allocations within the `paint()` method are avoided to prevent jank.
-   **`RepaintBoundary`:** The `GameCanvas` should be wrapped in a `RepaintBoundary` to isolate its frequent repaints from the rest of the UI tree.
-   **Asset Preloading:** All critical image and audio assets are preloaded at startup via the `AssetManager` to prevent loading-related hitches during gameplay.

### 7.2. State Management (Riverpod & StateNotifier)

-   **Rationale for Migration:** The project was migrated from a `ChangeNotifier` and `provider` based approach to `flutter_riverpod` with `StateNotifier`. This was a deliberate architectural decision to improve the robustness and maintainability of the application.
-   **Benefits of the New Architecture:**
    1.  **Compile-Time Safety:** Riverpod providers are type-safe, eliminating a class of runtime errors that can occur with traditional dependency injection.
    2.  **Immutable State:** `StateNotifier` works with immutable state objects (e.g., `GameEngineState`, managed with `freezed`). This prevents state from being modified accidentally and makes state changes predictable and easy to trace.
    3.  **Declarative and Efficient UI:** Widgets `watch` providers and are rebuilt automatically and efficiently by Riverpod when the state they depend on changes. This removes the need for manual `notifyListeners()` calls and complex `Consumer` nesting.
    4.  **Testability:** Riverpod's architecture makes testing significantly easier. Providers can be easily overridden with mock implementations in a test environment, allowing for true unit testing of widgets and services.
-   **Provider Structure:** All core application providers are defined in `lib/core/providers.dart`. Services that need to be initialized at startup (like `AssetManager`) have their providers overridden in the `ProviderScope` in `main.dart`.

### 7.3. Testing Strategy

-   **Unit Tests:** The `LogicEngine` is the primary target for unit tests due to its pure and stateless nature. Tests should cover all edge cases for series, parallel, short circuits, and complex component interactions.
-   **Widget Tests:** The UI widgets, especially the `GameCanvas`, should have widget tests to verify that user interactions (taps, drags) correctly trigger methods on the `GameEngineNotifier`.
-   **Integration Tests:** An integration test can be used to play through a simple level automatically to ensure all the services (`LevelManager`, `GameEngineNotifier`, `LogicEngine`) work together correctly.