# Logic Reference — Circuit STEM

**Project:** Circuit STEM
**Last Updated:** 2025-08-22

This document describes the core pure-Dart logic used by the game engine for circuit simulation and component-specific logic. It reflects the current architecture where logic is distributed between the `SimulationManager` and `LogicBehavior` implementations.

## 1. Overview of Logic Architecture

The game's logic is now primarily handled by two main components:

*   **`SimulationManager`**: Responsible for the overall power flow simulation across the entire grid. It determines which components are powered based on the circuit's connectivity and power sources.
*   **`LogicBehavior`**: An abstract interface implemented by individual components. Each component's `LogicBehavior` defines how that specific component evaluates its own state based on the grid (e.g., a switch toggling, a timer counting down).

This separation ensures a clear distinction between global circuit simulation and component-specific logic.

## 2. `SimulationManager` - Power Flow Simulation

The `SimulationManager` is responsible for simulating the flow of power through the circuit. It uses a graph traversal algorithm to identify powered components.

### 2.1. Public API

*   **`void simulatePowerFlow()`**: This is the main method that orchestrates the power simulation. It retrieves the current grid state from the `GameEngineNotifierV2`, resets all component power states, identifies power sources, and initiates power propagation. Finally, it updates the grid in the `GameEngineNotifierV2` with the newly calculated power states.

### 2.2. Power Propagation Algorithm (`_propagatePower`)

The `SimulationManager` uses a recursive graph traversal (Depth-First Search or Breadth-First Search, depending on implementation details) to propagate power from sources.

**Steps:**

1.  **Initialization**: All components' `isPowered` state is reset to `false`. A `visited` list is maintained to prevent infinite loops in cyclic circuits.
2.  **Identify Power Sources**: Components of type `battery` are identified as power sources.
3.  **Propagation**: Starting from each power source, the `_propagatePower` method recursively traverses connected components:
    *   Marks the current component as `isPowered = true`.
    *   Adds the current component's ID to the `visited` list.
    *   Iterates through the component's `terminals` (connection points).
    *   For each terminal, it finds the connected component on the grid using its coordinates.
    *   Recursively calls `_propagatePower` for unvisited connected components.

### 2.3. Short Circuit Detection

Short circuit detection is integrated into the power propagation. If a path from a positive battery terminal reaches a negative battery terminal without passing through a load (e.g., a bulb), a short circuit is detected. This is handled implicitly within the `_propagatePower` logic by checking component types during traversal.

## 3. `LogicBehavior` - Component-Specific Logic

The `LogicBehavior` interface defines how individual components evaluate their own state. Each component type (e.g., `Bulb`, `Switch`, `Timer`) implements its own `LogicBehavior`.

### 3.1. Public API

*   **`void evaluate(Grid grid, ComponentModel component)`**: This method is called by the `GameEngineCore` for each component on the grid. It allows the component to update its internal state based on the current grid configuration and its own properties.

### 3.2. Examples of `LogicBehavior` Implementations

*   **Bulb**: Its `evaluate` method might check if it is `isPowered` and update its internal state to reflect being "on" or "off".
*   **Timer**: Its `evaluate` method might check if it is `isPowered` and, if so, increment its internal timer count.
*   **Switch**: Its `evaluate` method might not directly change its state (as it's typically user-controlled), but it might influence power flow for connected components.

## 4. Integration with `GameEngineCore`

The `GameEngineCore` orchestrates the logic evaluation:

1.  It calls `component.getBehavior<LogicBehavior>()?.evaluate(newGrid, c);` for each component to allow them to update their internal states.
2.  It then relies on the `SimulationManager` to update the `isPowered` state of components based on the circuit.

## 5. Key Files Involved

*   `lib/engine/simulation_manager.dart`: Implements the core power flow simulation.
*   `lib/behaviors/logic_behavior.dart`: Defines the `LogicBehavior` interface.
*   `lib/components/*.dart`: Contains concrete implementations of `LogicBehavior` for each component type.
*   `lib/engine/game_engine_core.dart`: Orchestrates the evaluation of `LogicBehavior` and integrates with `SimulationManager`.
*   `lib/models/grid.dart`, `lib/models/component.dart`, `lib/models/port.dart`: Core data models used by the logic.

## Legacy Logic Engine (Historical Reference)

The previous architecture utilized a monolithic `LogicEngine` service. This section is retained for historical context but is no longer relevant to the current implementation.

### Old Public API

*   `EvaluationResult evaluateGrid(Grid grid)`
*   `Map<String, List<String>> buildGraph(Grid grid)`
*   `bool detectShort(Map<String,List<String>> graph, Grid grid)`

### Old Evaluation Steps (Simplified)

1.  `graph = buildGraph(grid)`
2.  `pos = findBatteryPositiveNodes(grid)`
3.  `visited = bfs(graph, pos)`
4.  `powered = components at visited nodes`
5.  `short = detectShort(graph, grid)`
6.  `openEndpoints = findOpenEndpoints(grid, graph)`
7.  return `EvaluationResult(powered, short, openEndpoints, debugMessages)`

This legacy approach has been superseded by the modular `SimulationManager` and `LogicBehavior` architecture for improved maintainability and testability.