## 8. Migration Status Summary

This table summarizes the current completion status of each task outlined in the UI Refactoring & Migration Plan.

| Phase | Task | Status | Notes |
|---|---|---|---|
| **Phase 1: State Management Foundation** | | | |
| | 4.1. Create New State Directory | **COMPLETED** | `lib/presentation/state` directory exists. |
| | 4.2. Implement the "State Wrapper" Pattern | **COMPLETED** | `game_state.dart` and `hud_state.dart` exist and contain expected providers. |
| | 4.3.1: Replace `providers.dart` Usage | **COMPLETED** | No imports of `lib/application/providers.dart` found. |
| | 4.3.2: Convert Widgets to `ConsumerWidget` | **COMPLETED** | Key files like `main.dart` and `game_screen.dart` are converted and use Riverpod. |
| **Phase 2: Feature-Based Restructuring** | | | |
| | 4.4. Create Feature Directories | **COMPLETED** | `lib/presentation/features` and its subdirectories exist and are populated. |
| | 4.5.1: Move Screens | **COMPLETED** | Old `lib/presentation/screens` is empty. |
| | 4.5.2: Move Widgets | **COMPLETED** | Old `lib/presentation/widgets` is empty. |
| | 4.5.3: Extract Controllers | **COMPLETED** | `lib/presentation/features/game/controllers/game_canvas_controller.dart` created and used for grid coordinate calculation. |
| **Phase 3: Polish & Finalization** | | | |
| | Delete Old Directories | **COMPLETED** | `lib/presentation/screens`, `lib/presentation/widgets`, and `lib/providers` are all empty. |
| | Code Review & Run All Tests | **N/A (Manual)** | Cannot be programmatically verified, but `CHANGELOG.md` suggests some level of verification has occurred. |

### Outstanding Items / Architectural Debt

*   **`TODO` in `game_state.dart`**: The `AnimationScheduler` is still being instantiated directly (`AnimationScheduler()`) instead of being provided by a Riverpod provider.
*   **`drag_behavior.dart`**: The file `lib/domain/behaviors/drag_behavior.dart` still directly accesses Riverpod providers, violating Clean Architecture principles. This is flagged for a future architectural refactor.

# Circuit Stem UI Refactoring & Migration Plan

## 1. Executive Summary

**Goal**: To refactor the `circuit_stem` UI layer by adopting a clean, feature-based architecture from the `sparkcircuit_REFER_MVP` reference project, while preserving 100% of `circuit_stem`’s sophisticated domain logic and game engine.

**Strategy**: This migration will be executed in a phased approach with zero downtime. We will keep the core application and domain layers of `circuit_stem` untouched and focus exclusively on restructuring the `presentation` layer. This will be achieved by wrapping existing services and notifiers in Riverpod providers and incrementally reorganizing the UI into a feature-based structure.

## 2. Overall Migration Strategy & Justification

This migration plan follows a sound, professional, and low-risk strategy for modernizing a legacy UI layer while preserving a valuable and complex core logic engine.

*   **Justification**: The core principle is to **"wrap, don't rewrite."** Instead of a risky "big bang" refactor, the plan introduces a modern state management layer (Riverpod) that acts as a bridge to the existing application logic. This allows the UI to be rebuilt incrementally using modern patterns without breaking the stable, underlying engine. The move to a feature-based UI structure is a standard best practice that will significantly improve long-term maintainability.
*   **Potential Impacts & Risks**: The primary risk is operational. The plan involves moving many files and updating their import statements, which can be tedious and error-prone. The `TODO` comment regarding the `AnimationScheduler` also highlights a small but concrete technical risk that needs to be addressed.
*   **Conclusion**: The approach is well-considered and pragmatic. It prioritizes safety and delivers value incrementally. The identified risks are manageable.

## 3. Architectural Analysis (The "What")

### 3.1. What to PRESERVE (`circuit_stem` Strengths)

The following directories contain the core business logic and are the biggest asset of this project. They should **not** be modified during this UI refactor.

```
✅ KEEP 100% UNCHANGED:
├── domain/             # Pure Dart: Entities, Behaviors, Value Objects, Goals
├── application/        # Pure Dart: Use Cases, Services, Middleware, GameEngine
├── infrastructure/     # Services: Audio, Persistence, Rendering
├── common/             # Utilities, Constants, Config
└── components/         # Game component logic (battery, bulb, wire, etc.)
```

### 3.2. What to REFACTOR (UI Improvements from `sparkcircuit`)

The `presentation` layer will be restructured to follow `sparkcircuit`’s more maintainable feature-based organization.

```
🔄 RESTRUCTURE THE UI:
├── presentation/       # Will be reorganized into feature folders
├── providers/          # Will be replaced by the new state directory
└── ui/                 # Will be removed and its contents merged into features
```

## 4. Detailed Migration Plan (The "How")

### Phase 1: State Management Foundation (Week 1-2)

**Goal**: Establish a unified state management layer using Riverpod without altering any underlying logic.

#### 4.1. Create New State Directory
```bash
# Create the new directory for Riverpod providers
mkdir -p lib/presentation/state
```

#### 4.2. Implement the "State Wrapper" Pattern

We will wrap existing notifiers and services in Riverpod providers. This is the key to a safe, incremental migration.

**File: `lib/presentation/state/game_state.dart`** (NEW)
```dart
// PURPOSE: Provide the core GameEngineNotifier to the UI using Riverpod.
// STRATEGY: This uses a ChangeNotifierProvider to wrap the existing GameEngineNotifier.
// NO LOGIC CHANGES ARE MADE TO THE ENGINE ITSELF.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/game_engine_notifier.dart';
import '../../infrastructure/audio/audio_service.dart';
import '../../infrastructure/persistence/level_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Provider for SharedPreferences, which is a dependency for other services
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Provider for AudioService
final audioServiceProvider = Provider<AudioService>((ref) {
  return AudioService();
});

// Provider for LevelManager
final levelManagerProvider = ChangeNotifierProvider<LevelManagerNotifier>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).asData!.value;
  return LevelManagerNotifier(prefs);
});

// The core GameEngine provider that wraps the existing notifier
final gameEngineProvider = ChangeNotifierProvider<GameEngineNotifier>((ref) {
  final audioService = ref.watch(audioServiceProvider);
  final levelManager = ref.watch(levelManagerProvider);
  // The existing GameEngineNotifier is instantiated here with its dependencies
  return GameEngineNotifier(
    audioService: audioService,
    levelManager: levelManager,
    // animationScheduler is required, let's create a dummy one for now
    // TODO: Refactor AnimationScheduler to be provided by a provider
    animationScheduler: AnimationScheduler(), 
  );
});

// Example of a new, UI-specific state provider that listens to the game engine
final isGameWonProvider = Provider<bool>((ref) {
  return ref.watch(gameEngineProvider).state.isWin;
});
```

**File: `lib/presentation/state/hud_state.dart`** (NEW)
```dart
// PURPOSE: Manage UI-specific state for the Heads-Up Display (HUD).
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This manages state that is purely for the UI, like showing a pause menu.
final hudStateProvider = StateNotifierProvider<HudStateNotifier, HudState>((ref) {
  return HudStateNotifier();
});

class HudState {
  final bool isPaused;
  final bool showWinScreen;
  
  const HudState({
    this.isPaused = false,
    this.showWinScreen = false,
  });

  HudState copyWith({bool? isPaused, bool? showWinScreen}) {
    return HudState(
      isPaused: isPaused ?? this.isPaused,
      showWinScreen: showWinScreen ?? this.showWinScreen,
    );
  }
}

class HudStateNotifier extends StateNotifier<HudState> {
  HudStateNotifier() : super(const HudState());

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  void showWinScreen() {
    state = state.copyWith(showWinScreen: true);
  }

  void hideWinScreen() {
    state = state.copyWith(showWinScreen: false);
  }
}
```

#### 4.3. Junior Developer Migration Tasks

**Task 4.3.1: Replace `providers.dart` Usage**
- Search for any imports of `lib/application/providers.dart` and remove them.
- Add imports for the new state files:
  ```dart
  import 'package:circuit_stem/presentation/state/game_state.dart';
  import 'package:circuit_stem/presentation/state/hud_state.dart';
  ```

**Task 4.3.2: Convert Widgets to `ConsumerWidget`**
- For each widget that needs access to state, change it from `StatelessWidget` or `StatefulWidget` to `ConsumerWidget` or `ConsumerStatefulWidget`.
- Replace old state access patterns with `ref.watch`.

**Example:**
```dart
// OLD (Provider)
Consumer<GameEngineNotifier>(
  builder: (context, gameEngine, child) => Text('Score: ${gameEngine.score}')
)

// NEW (Riverpod)
class ScoreDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final score = ref.watch(gameEngineProvider.select((engine) => engine.state.score));
    return Text('Score: $score');
  }
}
```

### Phase 2: Feature-Based Restructuring (Week 3-4)

**Goal**: Reorganize the UI files into a feature-based directory structure.

#### 4.4. Create Feature Directories
```bash
mkdir -p lib/presentation/features/{game,hud,menus,palette,onboarding,core}
mkdir -p lib/presentation/features/game/{screens,widgets,controllers}
mkdir -p lib/presentation/features/hud/{screens,widgets}
mkdir -p lib/presentation/features/menus/{screens,widgets}
mkdir -p lib/presentation/features/palette/{widgets}
mkdir -p lib/presentation/core/{widgets,theme,utils}
```

#### 4.5. File Migration Instructions

**Task 4.5.1: Move Screens**
- Move `lib/presentation/screens/game_screen.dart` -> `lib/presentation/features/game/screens/game_screen.dart`
- Move `lib/presentation/screens/main_menu.dart` -> `lib/presentation/features/menus/screens/main_menu.dart`
- Move `lib/presentation/widgets/pause_menu.dart` -> `lib/presentation/features/hud/screens/pause_menu.dart`
- **Update all imports** after moving the files.

**Task 4.5.2: Move Widgets**
- Move `lib/presentation/widgets/game_canvas.dart` -> `lib/presentation/features/game/widgets/game_canvas.dart`
- Move `lib/presentation/widgets/component_palette.dart` -> `lib/presentation/features/palette/widgets/component_palette.dart`
- Move shared widgets like `menu_button.dart` -> `lib/presentation/core/widgets/menu_button.dart`

**Task 4.5.3: Extract Controllers (Example)**
- Create a new file: `lib/presentation/features/game/controllers/game_canvas_controller.dart`
- Identify any UI-specific logic in `game_canvas.dart` (like pan/zoom state) and move it into the new `GameCanvasController`. The `GameEngineNotifier` should still handle the core game interactions.

### Phase 3: Polish & Finalization (Week 5)

**Goal**: Clean up the old structure and ensure the new architecture is stable.

- **Delete Old Directories**: Once all files have been migrated and tested, delete the now-empty `lib/presentation/screens`, `lib/presentation/widgets`, and `lib/providers` directories.
- **Code Review**: Perform a full code review of the new `presentation` layer to ensure consistency.
- **Run All Tests**: Execute the entire test suite to confirm no regressions were introduced.

## 5. Component-by-Component Analysis & Risk Assessment

This section provides a detailed analysis of the migration plan, reviewing the approach, justification, and potential impacts for each component.

### 5.1. Preserved Core Logic
*   **Directories**: `domain/`, `application/`, `infrastructure/`, `components/`
*   **Classes Referenced**: `GameEngineNotifier`, `AudioService`, `LevelManagerNotifier`, `AnimationScheduler`.
*   **Approach**: These components, containing the essential business logic, will be kept **100% unchanged**. They will be "wrapped" by the new Riverpod state layer.
*   **Justification**: This is the most critical decision in the plan. The core logic is the project's biggest asset. Preserving it avoids introducing bugs into the complex game simulation and significantly de-risks the entire refactoring effort.
*   **Review and Potential Issues**:
    *   **Positive**: This is the best practice for this scenario. It isolates the refactoring to the UI layer, where changes are less likely to have catastrophic side effects.
    *   **Minor Risk**: The plan mentions a `TODO` to properly provide the `AnimationScheduler`. In the new `gameEngineProvider`, it's being created with a dummy instance (`AnimationScheduler()`). If the *real* `AnimationScheduler` holds important state, using a dummy instance could lead to animations not working or other subtle UI bugs. **This `TODO` should be addressed early in Phase 1.**

### 5.2. New State Management Layer
*   **Directory**: `lib/presentation/state/`
*   **Classes Referenced**: `sharedPreferencesProvider`, `audioServiceProvider`, `levelManagerProvider`, `gameEngineProvider`, `isGameWonProvider`, `hudStateProvider`, `HudStateNotifier`, `HudState`.
*   **Approach**: Create a new, centralized set of Riverpod providers. This includes wrapping existing notifiers (like `GameEngineNotifier`) and creating new, UI-specific state notifiers (like `HudStateNotifier`).
*   **Justification**: This unifies state management under a single, modern library (Riverpod). It decouples the UI from the logic, improves testability, and makes state flow predictable. Creating specific providers like `isGameWonProvider` allows widgets to listen to only the state they need, preventing unnecessary rebuilds.
*   **Review and Potential Issues**:
    *   **Positive**: This is a textbook-perfect way to introduce Riverpod into an existing application. The use of `ChangeNotifierProvider` for `gameEngineProvider` is a pragmatic choice that acts as a perfect bridge from the old `ChangeNotifier` pattern to the new Riverpod world.
    *   **No Major Issues**: The implementation code provided for the new providers is standard and correct. The separation of game state (`gameEngineProvider`) from pure UI state (`hudStateProvider`) is a clean design.

### 5.3. Feature-Based UI Restructuring
*   **Directories**: `lib/presentation/features/...`, `lib/presentation/core/`
*   **Approach**: Physically reorganize all UI files (screens, widgets) from generic folders (`screens/`, `widgets/`) into feature-specific folders (`features/game/`, `features/hud/`, `features/menus/`).
*   **Justification**: This is a massive improvement for code organization. When working on the "HUD," a developer can go to the `features/hud/` folder and find all relevant files. This is much more scalable and intuitive than hunting through a giant, flat list of widgets.
*   **Review and Potential Issues**:
    *   **Positive**: This is the current industry best practice for structuring large Flutter applications.
    *   **Operational Risk**: The primary risk is human error. This phase involves a lot of manual file moving and fixing of `import` statements. This can be mitigated with careful, incremental work and by using IDEs with good refactoring tools.

### 5.4. Deprecated and Deleted Directories
*   **Directories**: `lib/presentation/screens/`, `lib/presentation/widgets/`, `lib/providers/`
*   **Approach**: These directories will be completely deleted after their contents have been migrated to the new feature-based structure.
*   **Justification**: These directories will be obsolete. Deleting them removes dead code and confusion, ensuring the new structure is the single source of truth.
*   **Review and Potential Issues**:
    *   **Positive**: This is the necessary final step to complete the migration.
    *   **Minor Risk**: Deleting code is irreversible. The plan wisely puts this in the final phase and includes a full regression test run before doing so, which is the correct way to mitigate this risk.

## 6. Risk Mitigation & Testing

### 6.1. Error Prevention
1.  **Do Not Modify Core Logic**: The `domain/`, `application/`, and `infrastructure/` directories are off-limits for this refactoring.
2.  **Migrate Incrementally**: Move and refactor one widget or screen at a time. Test immediately after each change.
3.  **Use Git**: Create a dedicated branch for the refactoring. Commit after each successful step.

### 6.2. Testing Strategy
- **After Each Phase**: Run `flutter test` to ensure all existing unit and widget tests pass.
- **Manual Regression Testing**:
  - [ ] Can the game be started?
  - [ ] Can levels be loaded?
  - [ ] Do all components drag, drop, and rotate correctly?
  - [ ] Does the power simulation work as expected?
  - [ ] Do the win/lose conditions trigger correctly?
  - [ ] Do the pause menu and other UI overlays work?

## 7. Success Criteria

- **Technical**: The `presentation` layer is fully organized by feature. State management is consistently handled by Riverpod. All domain and application logic is preserved.
- **Business**: No user-facing functionality is lost or broken. The codebase is easier for new developers to understand and for future features to be added.

---

## Appendix A: Legacy Analysis & Reference Material

*This section contains the initial analysis of the `sparkcircuit_REFER_MVP` project and the original, more abstract refactoring plan. This information was used to generate the detailed, phased plan above.*

### 1. Analysis of `sparkcircuit_REFER_MVP`

*   **Project Overview**:
    *   **Name**: sparkcircuit
    *   **Description**: An educational app for building and testing electronic circuits.
    *   **Key Technologies**: `flutter_riverpod` for state management and `go_router` for navigation.
    *   **Architecture**: A clean, feature-based architecture within the `presentation` layer.
*   **Comparison to `circuit_stem`**:
    *   **State Management**: `sparkcircuit` uses a single, consistent state management solution (`flutter_riverpod`), whereas `circuit_stem` has a mix of `provider`, `hooks`, and `riverpod`.
    *   **Organization**: `sparkcircuit` is organized by feature, which is easier to maintain.
    *   **Navigation**: `sparkcircuit` uses `go_router`, a more powerful routing solution.
*   **Conclusion**: The `sparkcircuit_REFER_MVP` project is a good reference for a modern Flutter application with a clean, feature-driven architecture.

### 2. Initial High-Level Refactoring Plan

*   **Recommendation**: Adopting `sparkcircuit`'s patterns would be a significant but beneficial refactoring for `circuit_stem`. It would unify state management and improve the organization of the UI code. The core domain logic of `circuit_stem` is strong and should be preserved.

*   **Architectural Deep Dive**:
| Aspect | `circuit_stem` (Current) | `sparkcircuit_REFER_MVP` (Target) |
| :--- | :--- | :--- |
| **Architecture** | Layered, use-case driven, with a central `GameEngineNotifier`. | Feature-based UI architecture. Logic is distributed among Riverpod state notifiers. |
| **State Management** | Fragmented: `provider`, `hooks_riverpod`, `flutter_riverpod`. | Unified: `flutter_riverpod` is used consistently. |
| **Navigation** | Basic `Navigator`. | `go_router` for declarative, URL-based navigation. |
| **Core Logic** | Centralized in `GameEngineNotifier`. | Decoupled from UI. Game logic is managed in Riverpod notifiers. |

*   **Proposed Incremental Plan**:
    1.  **Phase 1: Unify State Management**: Add `flutter_riverpod` and create a new set of Riverpod providers. Gradually migrate widgets, then remove old state management packages.
    2.  **Phase 2: Implement `go_router`**: Add `go_router` and define a new routing table. Replace all `Navigator` calls.
    3.  **Phase 3: Decompose the `GameEngine`**: Break down the monolithic `GameEngineNotifier` into smaller, more focused Riverpod `StateNotifier`s.
    4.  **Phase 4: Reorganize into a Feature-Based Structure**: Create a new `lib/presentation/features` directory and group all UI code by feature.

### 3. Project Structure Reference

#### `circuit_stem` (Current Structure)
```
lib/
├── app.dart
├── application/
│   ├── animation_scheduler.dart
│   ├── animation_state.dart
│   ├── audio_manager.dart
│   ├── core/
│   │   └── result.dart
│   ├── game_context.dart
│   ├── game_engine_core.dart
│   ├── game_engine_notifier.dart
│   ├── game_engine_state.dart
│   ├── input_manager.dart
│   ├── middleware/
│   │   ├── audio_middleware.dart
│   │   ├── logging_middleware.dart
│   │   ├── middleware.dart
│   │   ├── performance_middleware.dart
│   │   └── validation_middleware.dart
│   ├── providers.dart
│   ├── render_state.dart
│   ├── services/
│   │   ├── component_factory.dart
│   │   ├── component_palette_manager.dart
│   │   ├── component_registry.dart
│   │   ├── goal_checking_service.dart
│   │   ├── goal_registry.dart
│   │   ├── power_simulation_service.dart
│   │   └── state/
│   └── use_cases/
│       ├── base_use_case.dart
│       ├── check_win_condition_use_case.dart
│       ├── component_action.dart
│       ├── create_component_use_case.dart
│       ├── load_level_use_case.dart
│       ├── move_component_use_case.dart
│       ├── restart_level_use_case.dart
│       ├── rotate_component_use_case.dart
│       ├── select_palette_component_use_case.dart
│       ├── simulate_power_flow_action.dart
│       ├── simulate_power_flow_use_case.dart
│       ├── tap_component_use_case.dart
│       ├── toggle_pause_use_case.dart
│       ├── undo_use_case.dart
│       └── update_component_use_case.dart
├── common/
│   ├── asset_manager.dart
│   ├── assets.dart
│   ├── config.dart
│   ├── constants.dart
│   ├── debug_utils.dart
│   ├── logger.dart
│   ├── theme.dart
│   └── utils.dart
├── components/
│   ├── battery.dart
│   ├── bulb.dart
│   ├── buzzer.dart
│   ├── switch.dart
│   ├── timer.dart
│   └── wire.dart
├── domain/
│   ├── behaviors/
│   │   ├── behavior.dart
│   │   ├── drag_behavior.dart
│   │   ├── drawing_behavior.dart
│   │   ├── goal_checking_behavior.dart
│   │   ├── interaction_behavior.dart
│   │   ├── logic_behavior.dart
│   │   ├── movable_behavior.dart
│   │   └── move_behavior.dart
│   ├── entities/
│   │   ├── component.dart
│   │   ├── evaluation_result.dart
│   │   ├── goal.dart
│   │   ├── grid.dart
│   │   ├── grid_cell.dart
│   │   ├── hint.dart
│   │   ├── index.dart
│   │   ├── level_definition.dart
│   │   ├── level_metadata.dart
│   │   └── position.dart
│   ├── goals/
│   │   └── power_bulb_goal.dart
│   └── value_objects/
│       └── position.dart
├── flame_components_optional/
├── game/
│   └── components/
├── infrastructure/
│   ├── audio/
│   │   ├── audio_providers.dart
│   │   └── audio_service.dart
│   ├── persistence/
│   │   ├── level_manager.dart
│   │   └── level_manager_state.dart
│   └── rendering/
│       ├── asset_manager.dart
│       ├── asset_manager_state.dart
│       ├── svg_processor.dart
│       └── svg_processor_base.dart
├── main.dart
├── presentation/
│   ├── game_screen.dart.new
│   ├── screens/
│   │   ├── game_screen.dart
│   │   ├── level_select.dart
│   │   ├── main_menu.dart
│   │   ├── settings_screen.dart
│   │   └── win_screen.dart
│   ├── svg_capture.dart
│   ├── theme/
│   │   └── app_theme.dart
│   ├── utils/
│   │   └── coordinate_translator.dart
│   └── widgets/
│       ├── canvas_painter.dart
│       ├── circuit_component_display.dart
│       ├── component_painter.dart
│       ├── component_palette.dart
│       ├── component_palette_adapter.dart
│       ├── component_widget.dart
│       ├── debug_overlay.dart
│       ├── game_canvas.dart
│       ├── grid_widget.dart
│       ├── hint_chip.dart
│       ├── level_card.dart
│       ├── level_grid.dart
│       ├── menu_button.dart
│       └── pause_menu.dart
├── providers/
├── routes.dart
├── theme.dart
└── ui/
sparkcircuit_REFER_MVP Project Structure (with files)

#### `sparkcircuit_REFER_MVP` 
```
lib/
├── main.dart
├── presentation/
│   ├── app.dart
│   ├── core/
│   │   ├── animations/
│   │   │   └── glow_effect.dart
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   ├── utils/
│   │   │   └── coordinate_translator.dart
│   │   └── widgets/
│   │       ├── hint_chip.dart
│   │       ├── menu_button.dart
│   │       └── responsive_scaffold.dart
│   ├── features/
│   │   ├── accessibility/
│   │   │   └── widgets/
│   │   ├── game/
│   │   │   ├── controllers/
│   │   │   │   └── game_canvas_controller.dart
│   │   │   ├── painters/
│   │   │   │   ├── canvas_painter.dart
│   │   │   │   ├── component_painter.dart
│   │   │   │   └── wire_painter.dart
│   │   │   ├── screens/
│   │   │   │   └── game_screen.dart
│   │   │   └── widgets/
│   │   │       ├── circuit_component_display.dart
│   │   │       ├── circuit_component_widget.dart
│   │   │       ├── circuit_grid.dart
│   │   │       ├── debug_overlay.dart
│   │   │       ├── game_canvas.dart
│   │   │       └── grid_widget.dart
│   │   ├── hud/
│   │   │   ├── screens/
│   │   │   │   ├── pause_menu.dart
│   │   │   │   └── win_screen.dart
│   │   │   └── widgets/
│   │   │       ├── level_card.dart
│   │   │       ├── level_grid.dart
│   │   │       └── progress_hud.dart
│   │   ├── menus/
│   │   │   ├── screens/
│   │   │   │   ├── level_select.dart
│   │   │   │   ├── main_menu.dart
│   │   │   │   └── settings_screen.dart
│   │   │   └── widgets/
│   │   │       └── menu_button.dart
│   │   ├── onboarding/
│   │   │   ├── screens/
│   │   │   │   └── onboarding_screen.dart
│   │   │   └── widgets/
│   │   │       └── coach_mark.dart
│   │   ├── palette/
│   │   │   ├── controllers/
│   │   │   └── widgets/
│   │   │       ├── component_palette.dart
│   │   │       ├── component_palette_adapter.dart
│   │   │       └── component_widget.dart
│   │   └── sharing/
│   │       ├── services/
│   │       └── widgets/
│   │           └── share_dialog.dart
│   └── state/
│       ├── game_state.dart
│       ├── hud_state.dart
│       └── palette_state.dart
└── theme.dart
```
A Note on drag_behavior.dart: The file lib/domain/behaviors/drag_behavior.dart is part of the domain layer. According to Clean Architecture, it should not have any knowledge of the application or presentation layers (including providers). This is an architectural issue. While the full fix is outside the scope of this UI migration, I will proceed with the migration as planned, but this file should be flagged for a future architectural refactor.


