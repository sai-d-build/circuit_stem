# Architectural Improvements for `circuit_stem`

This document outlines key architectural improvements identified in the `circuit_stem` project. These changes aim to enhance robustness, maintainability, and scalability, making the codebase easier to understand and extend for all developers, especially new contributors.

## Note on Recent Bug Fixes

As of August 27, 2025, several critical bugs preventing basic functionality (e.g., initial component loading, battery positioning) have been resolved. This document focuses on *future architectural enhancements* that will further improve the project's design, beyond these foundational fixes.

## 1. Enhance Component Type Safety (Replace String with Enum)

**Problem:** Component types (e.g., "BATTERY", "WIRE_STRAIGHT") are currently represented as simple strings in the `level.json` files and throughout the Dart code. This is prone to human error (typos) which can lead to runtime bugs that are hard to catch early.

**Proposed Solution:** Introduce a Dart `enum` (e.g., `ComponentType`) to represent all valid component types.

**Benefits:**
*   **Compile-time Safety:** Typos will be caught by the Dart analyzer *before* the code runs.
*   **Readability:** Code becomes clearer when using named enum values instead of magic strings.
*   **Refactoring Safety:** If a component type name changes, the compiler will guide you to all affected areas.

**Guidance for Jr Devs:**
1.  **Research `enum`s in Dart:** Understand how they work and their benefits. Pay attention to how they can be used with `switch` statements for exhaustive checking.
2.  **Explore `freezed` and `json_serializable`:** Learn about custom `JsonConverter`s. You'll need to tell `json_serializable` how to convert the string from JSON into your `ComponentType` enum and vice-versa. This ensures that when you load a level, the string "BATTERY" from the JSON becomes `ComponentType.battery` in your Dart code.
3.  **Identify Affected Files:**
    *   `lib/domain/component.dart`: This is where the `Component` class is defined. You'll need to change the `type` field from `String` to `ComponentType`.
    *   `lib/domain/level.dart`: If the `Level` class directly references component types, it might need updates.
    *   Any code that currently uses `String` comparisons for component types (e.g., `if (component.type == "BATTERY")`) will need to be updated to use the enum (e.g., `if (component.type == ComponentType.battery)`). This will likely affect the `GameEngineNotifier` and UI rendering logic.
    *   The `LevelManager` (or wherever JSON deserialization happens) will need the custom converter to handle the `ComponentType` enum.

## 2. Robust Error Handling for Level Loading (Introduce `Result` Type)

**Problem:** If a `level.json` file is missing, malformed, or contains invalid data, the current loading process might throw an unhandled exception, leading to a crash or an undefined state. This makes debugging difficult and provides a poor user experience.

**Proposed Solution:** Implement a `Result` type (e.g., `Result<SuccessType, FailureType>`) for operations that can succeed or fail, specifically for level loading. This pattern is common in functional programming and makes error handling explicit.

**Benefits:**
*   **Explicit Error Handling:** Forces developers to consider and handle potential errors at the call site, rather than relying on `try/catch` blocks that can be easily missed.
*   **Predictable Flow:** Code becomes easier to reason about, as the success and failure paths are clearly defined and returned as part of the function's signature.
*   **Improved User Experience:** Allows the application to gracefully display informative error messages to the user instead of crashing.

**Guidance for Jr Devs:**
1.  **Research `Result` types/sealed classes:** Understand the concept of representing success and failure explicitly. You can either use a third-party library (like `fpdart` or `dartz`) or create a simple `sealed class` in Dart to define `Success` and `Failure` states.
2.  **Identify Affected Files:**
    *   `lib/services/level_manager.dart`: The `loadLevel` method should change its return type from `Future<Level>` to `Future<Result<Level, LevelLoadingFailure>>`. You'll need to define `LevelLoadingFailure` as a custom error type (e.g., `FileNotFound`, `InvalidJsonFormat`).
    *   `lib/application/game_engine_notifier.dart`: The `loadLevel` method in the engine will need to handle the `Result` type. Instead of directly using the loaded `Level`, it will need to check if the result is a `Success` or a `Failure` and react accordingly (e.g., `result.when(success: (level) => ..., failure: (error) => ...)`).
    *   Any UI code that calls `gameEngine.loadLevel()` will also need to adapt to handle the `Result` to display appropriate messages to the user.
3.  **Define Failure Types:** Think about different types of loading failures (e.g., `FileNotFound`, `InvalidJsonFormat`, `SchemaMismatch`). Each specific failure can be its own class extending a common `LevelLoadingFailure` base class.

## 3. Decouple Asset Paths (Centralized Asset Mapping)

**Problem:** The current approach likely infers asset file paths directly from component types (e.g., "BATTERY" -> `assets/images/battery.svg`). This creates a hidden dependency: if an asset file is renamed, moved, or replaced with a different format, the code won't know, leading to broken images or assets not loading correctly.

**Proposed Solution:** Create a dedicated `AssetMappingService` that explicitly maps component types (preferably the new `ComponentType` enum) to their corresponding asset paths.

**Benefits:**
*   **Decoupling:** Changes to asset file names or locations only require updating one central service (`AssetMappingService`), not multiple UI widgets or rendering logic scattered throughout the codebase.
*   **Maintainability:** Easier to manage and audit all asset paths in one place, making it clear which asset belongs to which component.
*   **Flexibility:** Allows for more complex asset logic in the future (e.g., different assets for different themes, or dynamically loading assets based on game state) without impacting core game logic.

**Guidance for Jr Devs:**
1.  **Create a new service:** `lib/services/asset_mapping_service.dart`. This service would be a simple class, possibly a singleton or provided via Riverpod.
2.  **Define the mapping:** This service would expose a method like `String getAssetPath(ComponentType type)` that returns the correct string path for a given component type. Internally, it could use a `Map<ComponentType, String>`.
3.  **Integrate with Riverpod:** Make this service available via a Riverpod provider so that any part of the UI or game engine can easily access it.
4.  **Update UI:** Any UI code that currently constructs asset paths based on component type strings should instead use this new service (e.g., `Image.asset(ref.read(assetMappingServiceProvider).getAssetPath(component.type))`).

## 4. Enhance Interaction Logic Scalability (Behavioral Pattern)

**Problem:** The `isStatic` flag is simple but limited. As the game grows, you might need more nuanced interaction rules (e.g., "can rotate but not move," "can only be placed on specific cells," "activates when another component is powered"). Adding these rules directly to the `GameEngine` or UI can lead to complex, hard-to-manage conditional logic (`if/else if` chains) that becomes difficult to extend.

**Proposed Solution:** Introduce a "Behavioral Pattern" where each component can have a set of defined behaviors (e.g., `Movable`, `Rotatable`, `Toggleable`). This allows you to compose complex interactions from simpler, reusable building blocks.

**Benefits:**
*   **Modularity:** Each behavior encapsulates its own logic, making it easier to understand, test, and debug in isolation.
*   **Flexibility:** Easily combine different behaviors to create new component types with unique and complex interactions without writing redundant code.
*   **Extensibility:** Adding new interaction types (e.g., "Explodable," "Connectable") doesn't require modifying existing core logic; you just create a new behavior.

**Guidance for Jr Devs:**
1.  **Research `Design Patterns`:** Look into "Strategy Pattern" or "Composition over Inheritance." These patterns are fundamental to this approach.
2.  **Define Interfaces/Abstract Classes:** Create interfaces or abstract classes for common behaviors (e.g., `abstract class MovableBehavior { bool canMove(Grid grid, Position newPos); }`, `abstract class RotatableBehavior { void rotate(Component component); }`).
3.  **Implement Concrete Behaviors:** Create classes that implement these interfaces for specific component types (e.g., `DefaultMovableBehavior`, `FixedRotatableBehavior`, `SwitchToggleBehavior`). A static component would have a `NonMovableBehavior` and `NonRotatableBehavior`.
4.  **Update Component Model:** The `Component` class in `lib/domain/component.dart` could hold instances of these behaviors. For example, instead of `bool isStatic`, it might have `MovableBehavior movableBehavior` and `RotatableBehavior rotatableBehavior`.
5.  **Update Game Engine:** The `GameEngineNotifier` would then delegate interaction requests to the component's behaviors (e.g., `component.movableBehavior.tryMove(newPosition)`). This keeps the engine clean and focused on orchestration, not specific interaction logic.
6.  **Data-Driven Behaviors:** Consider how behaviors could be specified in the `level.json` (e.g., a `behaviors` array for each component) to make them configurable per level. This would be an advanced step.