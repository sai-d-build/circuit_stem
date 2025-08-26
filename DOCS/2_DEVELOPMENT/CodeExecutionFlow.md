# Code Execution Flow

**Project:** Circuit STEM
**Last Updated:** 2025-08-22

---

This document provides a step-by-step narrative of how the application executes, from the initial launch to a complete gameplay loop. It is designed to help developers trace the flow of logic and data through the architecture.

## 1. Application Startup

1.  **`main.dart`**: Execution begins here.
    -   `WidgetsFlutterBinding.ensureInitialized()` prepares the Flutter framework.
    -   Core services (`AssetManager`, `SharedPreferences`) are initialized.
    -   The root `App` widget is wrapped in a `ProviderScope`. This is where the application's entire provider state is held.
    -   The providers for the core services are **overridden** with the initialized instances. For example:
        ```dart
        ProviderScope(
          overrides: [
            assetManagerProvider.overrideWithValue(assetManager),
            // ... other providers
          ],
          child: const App(),
        )
        ```
    -   `runApp()` inflates the root widget.

2.  **`app.dart`**: The `App` widget builds the `MaterialApp`.
    -   It sets the global theme, title, and initial route (`/`).
    -   It assigns `AppRoutes.onGenerateRoute` to handle all named navigation.

## 2. Navigating to the Game

_(This flow remains largely the same.)_

1.  **`routes.dart`**: The initial route `/` is mapped to `MainMenuScreen`.

2.  **`ui/screens/main_menu.dart`**: The user sees the main menu. When they tap "Start Playing", the app navigates to the level selection screen.

3.  **`ui/screens/level_select.dart`**: When this screen is first loaded, it now explicitly calls an initialization method on the `levelManagerProvider` to ensure all level data is loaded from the asset manifest *before* the user can interact with the screen. This was a critical bug fix. When the user taps on an unlocked level, the app then navigates to the `GameScreen`.

## 3. Initializing the Game Screen

This flow is now much simpler and more robust due to the centralized Riverpod architecture.

1.  **`routes.dart`**: The `/game` route maps to the `GameScreen` widget.

2.  **`ui/game_screen.dart`**: The `GameScreen` is a `ConsumerWidget` (or `ConsumerStatefulWidget`).
    -   Its `build` method uses a `WidgetRef` (`ref`) to access the application's providers.
    -   It **watches** the providers it needs. This single line both retrieves the state and subscribes to future updates.
        ```dart
        final gameEngineState = ref.watch(gameEngineProvider(level)).state; // Accessing state property
        final levelManager = ref.watch(levelManagerProvider);
        ```
    -   There is no need to manually create providers here. Riverpod handles the entire lifecycle automatically. If `gameEngineProvider` needs the `levelManager`, it will read it internally, as defined in `lib/core/providers.dart`.
    -   The UI is built directly based on the state received from the providers (e.g., `gameEngineState.isPaused`).

## 4. The Gameplay Loop (Orchestrator Pattern)

Once the `GameScreen` is built, the gameplay loop is driven by state changes.

1.  **User Input (`ui/game_canvas.dart`)**:
    -   The user interacts with the `GameCanvas` (e.g., taps a component, drags a component, taps a rotate button).
    -   The UI widget calls a method on the `InputManager` via the `GameEngineNotifierV2`.
        ```dart
        ref.read(gameEngineProvider(level).notifier).input.handleTap(component); // Delegated to InputManager
        ```
    -   If a component is tapped, the `handleTap` method in `InputManager` is called. This manager then translates the raw input into a game action and calls the appropriate method on `GameEngineNotifierV2`.
    -   If a rotate button is tapped, the `rotateComponent` method in `GameEngineNotifierV2` is called.

2.  **State Update (`engine/game_engine_notifier.dart`)**:
    -   `GameEngineNotifierV2` receives the action (e.g., from `InputManager` or a direct call).
    -   It delegates the core logic to `GameEngineCore`.
    -   `GameEngineCore` processes the action, potentially interacting with `SimulationManager` for logic evaluation (e.g., power flow), and creates a **new, immutable `GameEngineState` object**.
    -   `GameEngineCore` updates the `GameEngineState`. `GameEngineNotifierV2` then updates its internal state by assigning the new state object to its internal `state` property:
        ```dart
        state = core.commit(state, newGrid, ...); // Delegation to GameEngineCore
        ```

3.  **Re-render (Riverpod -> UI)**:
    -   Riverpod automatically detects that the `gameEngineProvider` has emitted a new state.
    -   It efficiently rebuilds **only the widgets that were watching the provider**.
    -   In `GameScreen`, the `build` method runs again. The `ref.watch(gameEngineProvider(level)).state` call now returns the *new* `GameEngineState`.
    -   The new state is passed down to the `CanvasPainter`, which redraws the screen to reflect the changes.

This entire loop is a declarative, unidirectional data flow, which is more robust and easier to reason about than the previous imperative `notifyListeners()` approach.

## 5. Winning a Level

1.  In the `GameEngineNotifierV2`, after a state update (delegated to `GameEngineCore`), the win condition is checked.
2.  If the win condition is met, the `isWin` flag in the `GameEngineState` is set to `true`.
3.  The `onWin` callback (which was injected into the notifier by its provider) is executed, which calls `levelManager.markCurrentLevelComplete()`.
4.  The `LevelManager` updates its own state (e.g., the list of completed levels).
5.  Back in `game_screen.dart`, the UI rebuilds in response to the new state, and because `gameEngineState.isWin` is true, it can now show a `WinScreen` overlay.

## Legacy Code Execution Flow (Historical Reference)

The previous architecture featured a monolithic `GameEngineNotifier` that directly handled state management, UI input, and logic evaluation using a `LogicEngine` service. This section is retained for historical context.

### Old Gameplay Loop (StateNotifier Pattern)

1.  **User Input (`ui/game_canvas.dart`)**:
    -   The UI widget called a method directly on the `GameEngineNotifier` (e.g., `ref.read(gameEngineProvider.notifier).handleTap(x, y);`).
    -   The `handleTap` method in `GameEngineNotifier` contained the business logic and used the `LogicEngine` to compute a new `GameEngineState`.

2.  **State Update (`engine/game_engine_notifier.dart`)**:
    -   The `GameEngineNotifier` directly updated its `state` property (e.g., `state = state.copyWith(grid: newGrid, ...);`).

3.  **Re-render (Riverpod -> UI)**:
    -   Riverpod detected the new state and rebuilt watching widgets.

### Old Winning a Level

1.  In the `GameEngineNotifier`, after a state update, a `_checkWinCondition` method was called.
2.  If the win condition was met, the `onWin` callback was executed, calling `levelManager.markCurrentLevelComplete()`.

This legacy approach has been superseded by the modular `GameEngineNotifierV2` orchestrator pattern for improved maintainability, testability, and scalability.
