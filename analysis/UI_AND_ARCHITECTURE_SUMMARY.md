# Circuit STEM Application Summary

**Date: August 31, 2025**

---

## 1. UI Features and Functionalities Summary

### Application Overview:
The application is a Flutter-based educational game focused on circuit building. It features a main menu, level selection, an interactive game canvas for circuit construction, and various in-game UI elements like HUDs, pause menus, and win screens. It emphasizes responsive design and visual feedback.

### Screen/Widget List, UI Components, and Functionalities Present

**1. `CircuitStemApp` (Main Application Entry)**
*   **Components:** `MaterialApp.router`, `ProviderScope` (Riverpod setup).
*   **Functionalities:** Initializes the Flutter application, sets up Riverpod for global state management, configures `GoRouter` for declarative navigation, and applies the global `AppTheme`.
*   **Notes:** This is the root widget that orchestrates the entire application's UI and state.

**2. `MainMenuScreen`**
*   **Components:** `Scaffold`, `Center`, `Column`, `Text` (App Title: "SparkCircuit", Slogan: "Learn Electronics Through Play"), `ElevatedButton` ('Start Learning'), `OutlinedButton` ('Settings').
*   **Functionalities:** Serves as the primary entry point. Allows users to navigate to the `LevelSelectScreen` or `SettingsScreen`.
*   **Notes:** Basic main menu with clear navigation options.

**3. `OnboardingScreen`**
*   **Components:** `Scaffold`, `Column`, `PageView.builder` (for multiple onboarding pages), `Icon`, `Text` (Page Title, Description), `Row` (for page indicator dots), `TextButton` ('Previous'), `ElevatedButton` ('Next' / 'Get Started').
*   **Functionalities:** Guides new users through the application's core features using an interactive, multi-page carousel. Supports forward and backward navigation.
*   **Notes:** Standard onboarding flow.

**4. `LevelSelectScreen`**
*   **Components:** `Scaffold`, `AppBar`, `Padding`, `Column`, `Text` (Headers: "Choose Your Challenge", "Start with basic circuits..."), `GridView.builder` (for level cards), `Card`, `InkWell`.
*   **Functionalities:** Displays a grid of levels, allowing users to select and start a game. Levels are visually indicated as locked or unlocked. Navigates to `GameScreen` upon selecting an unlocked level.
*   **Notes:** Levels are hardcoded (15 levels, first 5 unlocked).

**5. `GameScreen`**
*   **Components:** `Scaffold`, `AppBar` (with 'Level X' title, 'Undo' and 'Refresh' `IconButton`s), `Text` (Level ID, Timer), `GameCanvas` (main interactive area), `HorizontalComponentPalette` (for component selection), `AnimatedListItem` (for HUD animations).
*   **Functionalities:** The core gameplay screen. Manages a real-time level timer. Provides actions to undo the last move and restart the current level (with success feedback). Dynamically adapts its layout (e.g., horizontal palette for landscape mobile) based on screen orientation and size.
*   **Notes:** Integrates multiple sub-widgets to form the complete game experience.

**6. `GameCanvas`**
*   **Components:** `Container`, `ClipRRect`, `Stack`, `CircuitGrid` (background grid), `CustomPaint` (for `CircuitComponentsPainter` to draw components and wires, and `WireDrawingPainter` for real-time wire drawing), `GestureDetector` (for pan, zoom, tap, long press), `CircuitComponentWidget` (for individual component interaction), `Icon`, `Text` (for placement overlay).
*   **Functionalities:** The primary interactive area for building circuits. Supports panning and zooming the canvas. Handles component drag-and-drop, placement of new components from the palette, and drawing/connecting wires between components. Visually indicates selected components and provides a placement overlay.
*   **Notes:** Complex interaction logic, central to the game's core loop.

**7. `ComponentPalette` (Vertical)**
*   **Components:** `Container`, `TextField` (Search bar), `FilterChip` (for component categories), `ListView.builder`, `ComponentWidget` (for individual component items).
*   **Functionalities:** Displays a comprehensive, searchable, and filterable list of available circuit components. Allows users to select components, which then activates placement mode on the `GameCanvas`. Manages component inventory (available count, usage).
*   **Notes:** Provides detailed information and interaction for component selection.

**8. `HorizontalComponentPalette`**
*   **Components:** `Container`, `ListView.builder` (horizontal), `Chip`, `Icon`, `Text`.
*   **Functionalities:** A simplified, horizontal version of the component palette, primarily used in landscape layouts. Allows selection of components as chips to initiate placement.
*   **Notes:** Optimized for space-constrained horizontal layouts.

**9. `PauseMenu` (Overlay)**
*   **Components:** `Container`, `Icon` (`pause_circle`), `Text` ('Game Paused'), `MenuButton` (Resume, Restart Level, Settings, Main Menu), `AlertDialog` (for restart/exit confirmations).
*   **Functionalities:** Appears as an overlay when the game is paused. Offers options to resume gameplay, restart the current level (with confirmation), navigate to settings, or return to the main menu (with confirmation).
*   **Notes:** Standard in-game pause functionality.

**10. `WinScreen` (Overlay)**
*   **Components:** `AnimatedBuilder`, `Transform.scale`, `GlowEffect`, `Icon` (`emoji_events`, `star`), `Text` ('Level Complete!', score, time, hints used, best score), `MenuButton` (Next Level, Replay, Level Select).
*   **Functionalities:** Displays a celebratory screen upon level completion. Shows stars earned and detailed game statistics. Provides navigation options to the next level, replay the current level, or go to the level selection screen. Includes visual celebration animations.
*   **Notes:** Visually engaging end-of-level feedback.

**11. `SettingsScreen`**
*   **Components:** `Scaffold`, `AppBar`, `ListView`, `SwitchListTile` (Sound Effects, Background Music, Show Hints), `ListTile` (Difficulty, Version, Educational Platform), `DropdownButton`, `ElevatedButton` ('Reset Progress'), `AlertDialog` (for reset confirmation).
*   **Functionalities:** Allows users to configure various game settings, including audio preferences, hint display, and game difficulty. Displays app version information. Includes a button to reset all game progress.
*   **Notes:** Standard settings screen.

### Reusable UI Widgets

*   **`GlowEffect`, `PulseEffect`, `ShakeEffect`, `HighlightEffect`, `ElectricCurrentEffect`:** General-purpose animation wrappers for adding visual flair to any widget.
*   **`AnimatedComponentCard`, `AnimatedListItem`:** Pre-built animated widgets for displaying items in lists or grids with entry/selection animations.
*   **`HintChip`:** A small, interactive chip used to display hints, featuring pulsing and scaling animations.
*   **`MenuButton`:** A customizable, animated button used consistently across menus.
*   **`ResponsiveScaffold`, `ResponsiveLayoutBuilder`, `ResponsiveGridView`:** Core layout widgets that adapt their structure and padding based on screen size (mobile, tablet, desktop) and orientation.
*   **`AccessibleFocusLayer`:** A wrapper widget to enhance keyboard navigation and screen reader compatibility.
*   **`DebugOverlay`:** A utility overlay for displaying real-time debug information about the game state and canvas.
*   **`LevelCard`:** A card widget used in the level selection screen to display level details, completion status, and stars.
*   **`ProgressHud`:** A Head-Up Display widget that shows in-game progress (stars, score, time, hints remaining).
*   **`ComponentWidget`:** A detailed widget representing an individual component within the palette, showing its icon, name, description, and inventory count with visual feedback.
*   **`ShareDialog`:** A dialog for sharing level achievements, offering options to share to social media, copy text, or share an image of the circuit.
*   **`CoachMark`:** An overlay widget designed for in-app tutorials, highlighting specific UI elements and providing instructional text.
*   **`SparkProgressIndicator`, `LoadingOverlay`, `GameSkeletonScreen`, `ShimmerLoading`:** A suite of widgets for displaying various loading states, including custom progress indicators, full-screen overlays, and skeleton loading effects.

### Navigation Flow

The application uses `GoRouter` for declarative navigation, configured in `lib/presentation/app.dart`.

*   **`/` (home):** `MainMenuScreen`
    *   `ElevatedButton('Start Learning')` → `/level-select`
    *   `OutlinedButton('Settings')` → `/settings`
*   **`/onboarding`:** `OnboardingScreen` (initial route if onboarding is active)
    *   `ElevatedButton('Get Started')` (after last page) → `/` (replaces current route)
*   **`/level-select`:** `LevelSelectScreen`
    *   `InkWell` on `LevelCard` (if unlocked) → `/game/:levelId` (e.g., `/game/1`)
*   **`/game/:levelId`:** `GameScreen`
    *   **From Pause Menu (Overlay):**
        *   `MenuButton('Settings')` → `/settings`
        *   `MenuButton('Main Menu')` → `/` (with confirmation)
    *   **From Win Screen (Overlay):**
        *   `MenuButton('Next Level')` → `/game/:nextLevelId`
        *   `MenuButton('Level Select')` → `/level-select`
*   **`/settings`:** `SettingsScreen`
    *   No direct navigation *from* this screen to other main routes, but it's accessible from `MainMenuScreen` and `PauseMenu`.

---

## 2. Current Project Architecture

The Circuit STEM application appears to follow a layered architectural pattern, strongly resembling principles found in Clean Architecture or Domain-Driven Design. This is evident from the clear separation of concerns into distinct directories, each representing a specific layer or module.

### Key Architectural Patterns/Principles

*   **Layered Architecture:** The codebase is organized into distinct layers, promoting separation of concerns, maintainability, and testability.
*   **Domain-Driven Design (DDD) Elements:** The explicit `domain` layer suggests a focus on the core business logic and entities, independent of external concerns.
*   **State Management:** Riverpod is used for reactive state management, providing a robust and testable way to manage application state across different layers.
*   **Dependency Inversion Principle:** Higher-level modules (e.g., `application`) depend on abstractions (interfaces/abstract classes) defined in lower-level modules (e.g., `domain`), with concrete implementations provided by `infrastructure`.
*   **Modular Design:** Features and functionalities are grouped into logical modules (e.g., `game`, `palette`, `menus`).

### Technology Stack

*   **Framework:** Flutter
*   **Language:** Dart
*   **State Management:** Riverpod
*   **Navigation:** GoRouter
*   **Styling/Theming:** Custom `AppTheme` and `ThemeExtension` for circuit-specific colors.
*   **Fonts:** Google Fonts (`Orbitron`, `Inter`)

### Module Breakdown

The project structure clearly delineates responsibilities:

*   **`lib/` (Root)**
    *   **`app.dart` / `main.dart`:** Application entry points, root widget, and global setup (Riverpod, GoRouter).
    *   **`routes.dart`:** (Note: Appears to be an older routing system, superseded by GoRouter in `presentation/app.dart`. This should be consolidated.)
    *   **`common/`:** Contains cross-cutting concerns and shared utilities that don't belong to a specific layer.
        *   `asset_manager.dart`: Manages application assets.
        *   `config.dart`, `constants.dart`: Application-wide configurations and constants.
        *   `logger.dart`: Logging utility.
        *   `utils.dart`: General utility functions.
    *   **`core/`:** Foundational elements and shared components that might be used across multiple layers, often containing abstractions or core logic.
        *   `commands/`: Command pattern implementation (e.g., `GameCommand`, `CommandStack`).
        *   `persistence/`: Abstractions for data storage.
        *   `services/`: Core services (e.g., `component_factory`, `power_simulation_service`).
        *   `simulation/`: Core simulation logic.
        *   `validation/`: Core validation rules.

*   **`lib/application/` (Application Layer)**
    *   This layer orchestrates the use cases and interacts with the domain and infrastructure layers. It contains the application's business logic that is specific to how the application operates, rather than the core domain rules.
    *   `enhanced_game_state_notifier.dart`: Manages the overall game state.
    *   `game_engine_core.dart`: Core game engine logic.
    *   `providers.dart`: Riverpod providers for various services and notifiers.
    *   `use_cases/`: Defines the application's use cases (e.g., `load_level_use_case`, `create_component_use_case`). These typically interact with domain entities and services.
    *   `services/`: Application-specific services that coordinate domain logic.
    *   `middleware/`: Intercepts actions/events (e.g., `logging_middleware`, `performance_middleware`).

*   **`lib/domain/` (Domain Layer)**
    *   This is the heart of the application, containing the core business logic, entities, value objects, and rules, independent of any UI, database, or external service.
    *   `behaviors/`: Defines behaviors of domain entities.
    *   `content/`: Educational content definitions.
    *   `entities/`: Core domain entities (e.g., `component.dart`, `level_definition.dart`).
    *   `goals/`: Defines game goals/objectives.
    *   `value_objects/`: Immutable value objects.

*   **`lib/infrastructure/` (Infrastructure Layer)**
    *   This layer provides concrete implementations for interfaces defined in the domain or application layers. It handles external concerns like data persistence, network communication, and device-specific functionalities.
    *   `audio/`: Audio playback implementation.
    *   `persistence/`: Concrete implementations for data storage (e.g., `storage_service`).
    *   `rendering/`: Low-level rendering details (if any, beyond Flutter's built-in capabilities).

*   **`lib/presentation/` (Presentation Layer - UI)**
    *   This layer is responsible for all user interface logic and rendering. It depends on the application layer to retrieve data and trigger actions.
    *   `app.dart`: Main UI entry point with GoRouter setup.
    *   `core/`: Shared UI components, utilities, and theming.
        *   `animations/`: Reusable animation widgets.
        *   `theme/`: Application theme definitions (`AppTheme`, `CircuitColorScheme`).
        *   `utils/`: UI-specific utilities (e.g., `responsive_utils`, `error_utils`, `animation_utils`).
        *   `widgets/`: Generic, reusable UI widgets (e.g., `menu_button`, `responsive_scaffold`).
    *   `features/`: Contains UI code organized by feature (e.g., `game`, `menus`, `palette`, `onboarding`, `hud`, `sharing`, `accessibility`). Each feature typically has its own screens, widgets, and controllers/notifiers.
    *   `models/`: UI-specific data models (e.g., `circuit_drawing_models.dart` for painters).
    *   `state/`: UI-specific state management (e.g., `hud_state.dart`, `palette_state.dart`).

### High-Level Data Flow

1.  **User Interaction (Presentation Layer):** User interacts with UI elements (e.g., taps a button, drags a component on `GameCanvas`).
2.  **Event/Action Dispatch (Presentation to Application Layer):** The UI dispatches an event or calls a method on a Riverpod `StateNotifier` (e.g., `enhancedGameStateNotifierProvider.notifier.placeComponent()`).
3.  **Use Case Execution (Application Layer):** The `StateNotifier` or a dedicated use case (from `lib/application/use_cases/`) processes the request. This involves:
    *   Retrieving necessary data from the `domain` layer (entities, rules).
    *   Applying application-specific logic.
    *   Interacting with `infrastructure` services if external resources are needed (e.g., saving data via `persistence`).
    *   Updating the `domain` state.
4.  **Domain State Update (Domain Layer):** Core entities and aggregates within the `domain` layer are updated according to the business rules.
5.  **State Notification (Application to Presentation Layer):** The `StateNotifier` (or other state management mechanism) notifies its listeners (UI widgets) about changes in the application state.
6.  **UI Re-rendering (Presentation Layer):** UI widgets, being consumers of the state, rebuild themselves to reflect the updated data, providing visual feedback to the user.

This layered approach ensures that the core game logic (`domain`) remains independent and testable, while the UI (`presentation`) is decoupled and can evolve separately.
