# 🚀 Comprehensive UI/UX Overhaul Plan: Futuristic Neon for SparkCircuit

**Date: August 31, 2025**

## 1. Introduction

This document serves as a detailed blueprint for a significant UI/UX overhaul of the SparkCircuit educational game application. It encompasses a thorough analysis of the current user interface and experience, a clear justification for the proposed changes, a visionary outline for a "Futuristic Neon" aesthetic, a holistic implementation roadmap with actionable steps, and a comprehensive checklist to guide the development effort. The aim is to transform SparkCircuit into a visually stunning, highly immersive, and engaging educational game that aligns with modern mobile game UI/UX best practices.

---

## 2. Current UI/UX State Analysis

### 2.1. Theme & Styling (Current State)

The application primarily uses a custom Material 3 theme defined in `lib/presentation/core/theme/app_theme.dart`, which extends `ThemeExtension` with `CircuitColorScheme` for circuit-specific colors.

*   **Design System:** Material 3 with a custom `CircuitColorScheme` extension.
*   **Colors:**
    *   **Light Theme:** Predominantly uses shades of blue (`primary`, `primaryContainer`), green (`secondary`), and orange (`tertiary`). Neutral colors for `surface`, `onSurface`, `outline`, and `shadow`.
    *   **Dark Theme:** Provides a darker palette with brighter accents, maintaining the core color scheme.
    *   **High Contrast Theme:** A specific theme for accessibility, using stark black and white with bright accents for active elements.
    *   **Circuit-Specific Colors:** `wireActive`, `wireInactive`, `componentBase`, `gridLine`, `glowEffect` are defined, indicating an intention for distinct visual states for circuit elements.
*   **Typography:**
    *   **Headings/Display:** `GoogleFonts.orbitron` (a futuristic, geometric sans-serif font), used for display and app bar titles.
    *   **Body/General Text:** `GoogleFonts.inter` (a modern, highly readable sans-serif font), used for most other text.
*   **Theming Elements:**
    *   **Shadows:** `BoxShadow` is used on `Card`, `ElevatedButton`, `MenuButton`, `HintChip`, and `WinScreen` for subtle depth.
    *   **Gradients:** `LinearGradient` is used for `MenuButton` backgrounds and `LevelCard` backgrounds, adding a modern, layered look.
    *   **Rounded Corners:** Consistent use of `BorderRadius.circular` (e.g., 8, 12, 16, 20) across buttons, cards, and containers.
    *   **Animations:**
        *   **Glow Effects:** `GlowEffect` (pulsing glow), `PulseEffect` (scaling pulse), `ShakeEffect` (for errors/attention), `HighlightEffect` (border highlight), `ElectricCurrentEffect` (dashed line animation for wires) are implemented as reusable widgets.
        *   **Transitions:** `AnimatedListItem` provides fade-in and slide-in animations for list items. `AnimatedComponentCard` provides scale and bounce animations for palette items.
        *   **Button Feedback:** `MenuButton` and `ComponentWidget` have custom press animations (scale down, subtle glow).
        *   **Loading Skeletons:** `ShimmerLoading` provides a shimmer effect for loading states.

*   **Overall Design Aesthetic:** The current design leans towards a **modern, clean, and somewhat enhanced** aesthetic. It's not purely flat, incorporating subtle shadows, gradients, and custom animations to add visual interest and feedback. The use of `Orbitron` font gives it a tech-game feel.

### 2.2. Screen-by-Screen UI Analysis (Current State)

#### 2.2.1. Start Menu (`MainMenuScreen`)

*   **Components:** `Scaffold`, `Center`, `Column`, `Text` (for app title and slogan), `ElevatedButton` ('Start Learning'), `OutlinedButton` ('Settings').
*   **Layout:** Simple, centered vertical stack.
*   **Buttons:** `ElevatedButton` has a default Material 3 style with a subtle shadow. `OutlinedButton` is flat with a border.
*   **Icons:** None on buttons.
*   **Animations:** No explicit animations on this screen, relies on default Material 3 button press feedback.
*   **Design:** Relatively **minimal and clean**, relying on typography and button styles. The `Orbitron` font for the title adds character.

#### 2.2.2. Onboarding (`OnboardingScreen`)

*   **Components:** `PageView.builder`, `Icon` (large, central), `Text` (title, description), `Row` with `Container` dots for page indication, `TextButton` ('Previous'), `ElevatedButton` ('Next' / 'Get Started').
*   **Layout:** Full-screen pages with content centered vertically. Bottom section for navigation and page indicators.
*   **Buttons:** Standard Material 3 `TextButton` and `ElevatedButton`.
*   **Icons:** Large, prominent icons representing the onboarding message.
*   **Animations:** `PageView` provides horizontal slide transitions between pages. No custom animations on individual elements within a page.
*   **Design:** **Clean and functional**, with clear visual hierarchy. The large icons are effective.

#### 2.2.3. Level Select (`LevelSelectScreen`)

*   **Components:** `AppBar`, `Text` (headers), `GridView.builder` with `Card` and `InkWell` for each level. Each `LevelCard` contains `Text` (level number, 'Locked'/'Play'), `Icon` (lock/play).
*   **Layout:** Standard app bar, then a column of text, followed by a scrollable grid of level cards.
*   **Buttons/Cards:** `Card` with `InkWell` for tap feedback. Locked levels have a greyed-out appearance.
*   **Icons:** Lock icon for locked levels, play icon for unlocked.
*   **Animations:** No explicit animations on this screen, relies on default `InkWell` splash.
*   **Design:** **Functional and clear**. The use of `Card` provides some depth. The locked/unlocked visual distinction is effective.

#### 2.2.4. Game Screen (`GameScreen`)

*   **Components:** `AppBar` (with level title, undo/refresh buttons), `GameCanvas` (main interactive area), `HorizontalComponentPalette` (bottom/side). HUD elements (timer, level title) are integrated.
*   **Layout:** Responsive layout adapting to orientation (column for portrait, row for landscape mobile).
*   **Buttons/Icons:** `IconButton`s in AppBar.
*   **Animations:**
    *   HUD elements use `AnimatedListItem` for fade-in/slide-in.
    *   `GameCanvas` handles pan/zoom animations.
    *   `CircuitComponentsPainter` draws components and wires.
    *   `ElectricCurrentEffect` is available for animated wires (though `isActive` is a TODO).
*   **Design:** **Highly interactive and functional**. The custom painters provide a distinct visual style for circuit elements. The responsive layout is a strong point.

#### 2.2.5. Pause Menu (`PauseMenu`)

*   **Components:** `Container` (as a modal dialog), `Icon` (`pause_circle`), `Text` ('Game Paused'), multiple `MenuButton`s (Resume, Restart Level, Settings, Main Menu). `AlertDialog` for confirmations.
*   **Layout:** Centered, compact modal with a vertical stack of buttons.
*   **Buttons:** Uses the custom `MenuButton` with its built-in animations (scale, glow).
*   **Icons:** Icons on `MenuButton`s.
*   **Animations:** No explicit entry/exit animation for the menu itself, relies on default `showDialog` behavior. `MenuButton`s have their animations.
*   **Design:** **Clean and functional**, consistent with the overall button style.

#### 2.2.6. Win Screen (`WinScreen`)

*   **Components:** `AnimatedBuilder`, `Transform.scale`, `Container` (as a modal dialog), `GlowEffect` (on trophy icon and stars), `Icon` (`emoji_events`, `star`), `Text` (Level Complete!, slogan, stats), `MenuButton`s (Next Level, Replay, Level Select).
*   **Layout:** Centered, celebratory modal with a clear hierarchy of elements.
*   **Buttons:** Uses custom `MenuButton`s.
*   **Icons:** Prominent trophy icon, multiple star icons for rating.
*   **Animations:**
    *   `_celebrationController` for overall scale-in of the screen (`Curves.elasticOut`).
    *   `_starsController` for staggered scale-in of stars (`Curves.bounceOut`).
    *   `GlowEffect` on trophy and earned stars.
*   **Design:** **Enhanced and celebratory**, effectively using animations and glow effects to convey success.

#### 2.2.7. Settings Screen (`SettingsScreen`)

*   **Components:** `AppBar`, `ListView`, `SwitchListTile`, `ListTile` (for dropdown and info), `DropdownButton`, `ElevatedButton` ('Reset Progress'), `AlertDialog`.
*   **Layout:** Standard list-based settings screen.
*   **Buttons:** Standard Material 3 `ElevatedButton` and `SwitchListTile`.
*   **Icons:** None on list tiles.
*   **Animations:** Relies on default Material 3 animations for switches and dropdowns.
*   **Design:** **Functional and standard Material 3**. It's clean but lacks the custom enhancements seen elsewhere.

---

## 3. Justification for Change (Why Refactor?)

The current SparkCircuit application has a solid functional foundation and a clean aesthetic. However, to truly stand out as an engaging educational game, its UI/UX needs to evolve beyond a standard Material Design application. The proposed refactoring is driven by the following justifications:

1.  **Lack of Thematic Immersion:** While the `Orbitron` font hints at a futuristic theme, the overall visual design (especially in core screens like Main Menu, Level Select, and Settings) remains largely generic Material 3. This creates a disconnect between the game's concept and its presentation, hindering immersion.
    *   **Reference:** *Game UI/UX best practices emphasize thematic consistency across all visual elements to build a cohesive world.*
2.  **Inconsistent Visual Language:** The presence of both custom `MenuButton`s (with unique animations and gradients) and standard Material 3 buttons creates visual inconsistency. Similarly, the `LevelCard` in `LevelSelectScreen` doesn't leverage the richer `LevelCard` widget available elsewhere.
    *   **Reference:** *Consistency in design elements (buttons, cards, typography) is fundamental for a predictable and intuitive user experience.*
3.  **Static and Underutilized Animation Potential:** Many key screens (Start Menu, Onboarding, Level Select, Settings) are visually static. While some custom animations exist (`GlowEffect`, `AnimatedListItem`), they are not universally applied, leading to missed opportunities for dynamic feedback and visual delight.
    *   **Reference:** *Modern mobile game UIs are highly animated, using micro-interactions and dynamic backgrounds to provide constant feedback and enhance engagement.*
4.  **Limited Visual Depth and Modernity:** The design, while clean, often appears flat. It lacks the layered depth, subtle parallax, and modern effects like glassmorphism that are prevalent in contemporary game and app design.
    *   **Reference:** *Incorporating depth cues (shadows, layering, parallax) and modern visual trends (glassmorphism, neon glows) can significantly elevate the perceived quality and sophistication of an application.*
5.  **Suboptimal User Feedback:** While basic error/success feedback exists, it's not always consistent or as visually impactful as it could be. Crucial gameplay elements like active wires lack dynamic visual feedback.
    *   **Reference:** *Immediate and clear visual feedback for every user action is paramount in game design to reinforce interactions and guide the player.*
6.  **Architectural Inconsistencies:** The presence of redundant routing files (`lib/routes.dart`) indicates a need for architectural cleanup to improve maintainability and prevent future conflicts.
    *   **Reference:** *Clean Architecture principles advocate for clear separation of concerns and a single source of truth for core functionalities.*

By addressing these points, the UI/UX overhaul will not only make SparkCircuit more aesthetically pleasing but also more intuitive, engaging, and aligned with the high standards of modern educational games.

---

## 4. Futuristic Neon UI/UX Vision

The core vision for SparkCircuit's UI/UX is to create a **futuristic, neon-infused, and highly immersive educational game experience**. This will be achieved through:

*   **Electric Neon Hues:** A vibrant color palette of cyan, magenta, neon green, and electric blues, set against dark, high-contrast backgrounds.
*   **Dynamic Gradients & Glows:** Animated, multi-layered gradients and pervasive neon glow effects that respond to user interaction and game state, creating a sense of energy and dynamism.
*   **Glassmorphism & Layered Depth:** Translucent "glass" panels with glowing neon outlines for dialogs, HUDs, and overlays, creating a sense of depth and sophistication.
*   **Animated Backgrounds & Parallax:** Dynamic, multi-layered backgrounds featuring glowing circuit patterns and particle effects that subtly shift with user input, enhancing immersion.
*   **Micro-interactions & Fluid Animations:** Every user interaction will be met with immediate, delightful, and thematic visual feedback, making the UI feel alive and responsive.
*   **Consistent Thematic Elements:** All UI components, from buttons to switches, will be custom-designed to fit the futuristic neon aesthetic, ensuring a cohesive and branded experience.

---

## 5. Implementation Plan: Holistic Roadmap

This section details the phased implementation plan, combining the "Futuristic Neon UI/UX Implementation Plan" with specific refactoring actions and best practices.

### 5.0. Foundational Backend & Data Layers (Pre-UI Phases)

**Goal:** Establish robust data management and core system functionalities that UI enhancements will depend on.

*   **Action 0.1: Core Data Persistence Layer.**
    *   **Problem:** No save/load for onboarding status, game progress (scores, stars, elapsed time), and unlocked components/inventory. This impacts user retention and game state continuity.
    *   **Files Involved:**
        *   `lib/app.dart`: For the `_showOnboarding` flag.
        *   `lib/presentation/state/hud_state.dart`: Manages `ProgressData`.
        *   `lib/presentation/state/palette_state.dart`: Manages `ComponentInventory` and `isUnlocked` status.
        *   `lib/core/persistence/storage_service.dart`: The central interface for persistence.
    *   **Solution:** Implement a robust local persistence layer. Use `shared_preferences` for simple key-value pairs (like onboarding status). For complex data (game progress, inventory, unlocked components), integrate a structured local database solution like `hive` or `sqflite`. The `storage_service.dart` should abstract these implementations.
    *   **Best Practice:** Data integrity and user experience. Persistent data is crucial for a game's core loop and user satisfaction. Abstract persistence behind a service layer for testability and future flexibility (e.g., cloud sync).

*   **Action 0.2: Core Audio System Integration.**
    *   **Problem:** Sound effects and background music system is incomplete, hindering game immersion.
    *   **Files Involved:**
        *   `lib/application/audio_manager.dart`: The central audio management class.
        *   `lib/presentation/core/utils/feedback_utils.dart`: Contains `provideSoundFeedback` with a `TODO`.
        *   `lib/presentation/features/menus/screens/settings_screen.dart`: Has audio toggles.
    *   **Solution:** Implement the `audio_manager.dart` using a Flutter audio plugin (e.g., `audioplayers` for sound effects, `just_audio` for background music). Connect `provideSoundFeedback` to this manager. Integrate sound effects for key UI events (button taps, component placement, win/lose states, errors) and background music. Ensure audio settings from `SettingsScreen` control the manager.
    *   **Best Practice:** Multi-sensory immersion. Audio cues significantly enhance game feel and provide critical feedback. Decouple audio logic from UI components.

*   **Action 0.3: Dynamic Content Management.**
    *   **Problem:** Levels are static and hardcoded (only 15 levels), limiting scalability and replayability; no procedural/dynamic level generation.
    *   **Files Involved:**
        *   `lib/presentation/features/menus/screens/level_select.dart`: Hardcoded level count.
        *   `lib/domain/entities/level_definition.dart`: Defines level structure.
        *   New files for level data loading/generation.
    *   **Solution:** Implement a system to load level definitions from external files (e.g., JSON assets bundled with the app or fetched remotely). This allows for easy addition of new levels without code changes. For long-term replayability, explore a basic procedural generation system for certain level types.
    *   **Best Practice:** Scalability and content pipeline. Externalizing content makes updates easier and allows for community contributions or future expansions. Procedural generation enhances replayability.

*   **Action 0.4: User Account & Cloud Sync (Post-MVP).**
    *   **Problem:** No user authentication or cloud progress storage, limiting cross-device play and user retention.
    *   **Files Involved:** New infrastructure and application-layer files.
    *   **Solution:** Integrate a backend service (e.g., Firebase, Supabase, or a custom API) for user authentication and cloud storage of game progress. This would involve new `infrastructure` and `application` layer components.
    *   **Best Practice:** User retention and platform independence. Cloud sync is a standard feature for modern games. **Note: This is a significant effort and should be considered a post-MVP feature.**

### 5.1. Core Architectural & Theming Foundations (Phase 1)

**Goal:** Establish a robust and consistent foundation for the new UI/UX.

*   **Action 1.1: Consolidate `AppTheme` Definitions.**
    *   **Details:**
        *   **Problem:** Redundant `AppTheme` files (`lib/presentation/core/theme/app_theme.dart` and `lib/presentation/theme/app_theme.dart`).
        *   **Solution:** Delete `lib/presentation/theme/app_theme.dart`. Ensure all theme-related logic, including `CircuitColorScheme` and its extensions, is centralized and correctly defined in `lib/presentation/core/theme/app_theme.dart`.
        *   **Best Practice:** Single Source of Truth (SSOT) for theming. Reduces maintenance overhead and prevents inconsistencies.
    *   **Reference:** `lib/presentation/core/theme/app_theme.dart`
*   **Action 1.2: Expand `CircuitColorScheme` for Neon Palette.**
    *   **Details:**
        *   **Problem:** Current color scheme lacks specific neon hues and state-based glow colors.
        *   **Solution:** Add new color properties to `CircuitColorScheme` (e.g., `neonPrimary`, `neonAccent`, `errorGlow`, `energyPulse`, `highlightAccent`). Define these colors using vibrant, electric hues.
        *   **Best Practice:** Use `ThemeExtension` for custom theme properties, allowing easy access via `Theme.of(context).extension<CircuitColorScheme>()!`.
    *   **Reference:** `lib/presentation/core/theme/app_theme.dart`
*   **Action 1.3: Create `lib/presentation/ui_components/` Directory.**
    *   **Details:**
        *   **Problem:** Custom UI widgets are scattered or not explicitly organized.
        *   **Solution:** Create a new top-level directory `lib/presentation/ui_components/`. All reusable custom UI widgets (e.g., `NeonButton`, `GlassPanel`, `NeonSwitch`, `NeonLevelCard`, `NeonHUD`) will reside here.
        *   **Best Practice:** Modular design. Centralizes reusable components, improves discoverability, and enforces consistency.
*   **Action 1.4: Build Core Reusable Neon Widgets.**
    *   **Details:**
        *   **Problem:** Standard Material widgets are used, lacking the desired futuristic aesthetic.
        *   **Solution:** Develop custom `Neon*` widgets within `lib/presentation/ui_components/`.
            *   **`NeonButton`:** Enhance `MenuButton` to incorporate scaling, pulsing neon glow, and animated gradient backgrounds on interaction.
            *   **`GlassPanel`:** Implement a reusable widget using `BackdropFilter` (for blur) and a semi-transparent, often gradient-filled background. This will be the foundation for glassmorphism.
            *   **`NeonSwitch`, `NeonSlider`, `NeonDropdown`:** Create custom versions of these controls with glowing toggles, animated states, and thematic styling.
        *   **Best Practice:** Component-driven development. Build small, reusable, and testable UI components.
    *   **Reference:** `lib/presentation/ui_components/`
*   **Action 1.5: Establish Global Effects Registry (`lib/presentation/effects/`).**
    *   **Details:**
        *   **Problem:** Animation effects are not centrally managed or easily reusable across the app.
        *   **Solution:** Create `lib/presentation/effects/` directory. Refactor existing effects (`GlowEffect`, `PulseEffect`, `ShakeEffect`, `HighlightEffect`, `ElectricCurrentEffect`) into this directory. Implement new effects like `ParticleEffect` and `ParallaxBackground`. Provide a consistent API for applying these effects.
        *   **Best Practice:** Centralized effect management. Promotes reusability, simplifies application of visual effects, and aids performance optimization.
    *   **Reference:** `lib/presentation/effects/`

### 5.2. Core Screens Overhaul (Phase 2)

**Goal:** Apply the new design system to the main navigation and settings screens.

*   **Action 2.1: Upgrade `MainMenuScreen`.**
    *   **Details:** Replace standard Material buttons with `NeonMenuButton`s. Implement a `ParallaxBackground` featuring a slow-moving circuit board pattern with glowing nodes and a `ParticleEffect` (sparks flowing through wires). Animate the "SparkCircuit" title with a pulsing neon glow and subtle 3D tilt. Add an idle attract mode that intensifies background animations if the app is inactive.
    *   **Best Practice:** Strong first impression. The main menu sets the tone for the entire game.
    *   **Reference:** `lib/presentation/features/menus/screens/main_menu.dart`
*   **Action 2.2: Upgrade `LevelSelectScreen`.**
    *   **Details:** Replace current level cards with `NeonLevelCard`s (from `ui_components/`). Implement glow borders (blue=unlocked, grey=locked, gold=completed) and subtle rotation/tilt hover animations. Apply staggered fade-in/scale-up animations for cards on screen load (using `AnimatedListItem`). Implement an animated circuitry map as the background.
    *   **Best Practice:** Clear visual progression. Make level selection feel like a futuristic control panel.
    *   **Reference:** `lib/presentation/features/menus/screens/level_select.dart`
*   **Action 2.3: Upgrade `SettingsScreen`.**
    *   **Details:** Replace standard Material switches, sliders, and dropdowns with custom `NeonSwitch`, `NeonSlider`, and `NeonDropdown` widgets. Use futuristic neon lines for section dividers. Implement a static dark gradient background with subtle neon circuit nodes. Add micro-interactions like hover glow and press bounce.
    *   **Best Practice:** Thematic consistency. Even utility screens should feel part of the game world.
    *   **Reference:** `lib/presentation/features/menus/screens/settings_screen.dart`
*   **Action 2.4: Implement Custom Screen Transitions.**
    *   **Details:** Utilize `GoRouter`'s `pageBuilder` or `customTransitionPage` property for all major routes. Implement custom transitions (e.g., fade-through, scale-up, or slide effects) using effects from `lib/presentation/effects/screen_transitions.dart`.
    *   **Best Practice:** Fluid user journey. Custom transitions enhance the game's polish and thematic feel.
    *   **Reference:** `lib/presentation/app.dart` (GoRouter configuration)

### 5.3. Gameplay Enhancements (Phase 3)

**Goal:** Make the core gameplay visually immersive and responsive to circuit states.

*   **Action 3.1: Fully Implement Animated Wires.**
    *   **Details:** Connect the `isActive` property of `CircuitWire` (in `lib/presentation/models/circuit_drawing_models.dart`) to the actual circuit simulation results. Ensure `ElectricCurrentEffect` (from `lib/presentation/effects/`) is correctly applied to wires that are part of an active circuit, showing a moving glow along paths.
    *   **Best Practice:** Direct visual feedback. Crucial for an educational game about circuits.
    *   **Reference:** `lib/presentation/features/game/painters/wire_painter.dart`, `lib/presentation/models/circuit_drawing_models.dart`
*   **Action 3.2: Implement Dynamic Component States Visual Feedback.**
    *   **Details:**
        *   **LEDs:** Make LEDs glow intensely when active.
        *   **Motors/Actuators:** Implement subtle vibration effects when powered.
        *   **Overload:** Components experiencing overload should flash with a distinct red neon glow (using `GlowEffect` with `errorGlow` color).
    *   **Best Practice:** Clear state indication. Helps players understand circuit behavior at a glance.
*   **Action 3.3: Refine Placement Feedback.**
    *   **Details:** When placing a component from the palette, display a ghost image of the component. This ghost image should change color (e.g., green for valid, red for invalid) and be accompanied by a neon grid highlight (using `GlowEffect` or custom painter) indicating valid/invalid placement zones.
    *   **Best Practice:** Intuitive interaction. Guides the user during drag-and-drop operations.
*   **Action 3.4: Modernize HUD.**
    *   **Details:** Redesign HUD elements (score, timer, hints) using `GlassPanel`s (from `ui_components/`) with glowing neon borders. Add subtle micro-animations (e.g., score counter animation, timer pulse).
    *   **Best Practice:** Immersive overlay. HUD should feel integrated into the game world.
    *   **Reference:** `lib/presentation/features/hud/widgets/progress_hud.dart`
*   **Action 3.5: Implement Game Screen Background.**
    *   **Details:** Use a `ParallaxBackground` (from `lib/presentation/effects/`) for the `GameCanvas`. This background should feature a layered, subtle neon grid that shifts smoothly with canvas panning.
    *   **Best Practice:** Adds depth and dynamism to the core gameplay area.
    *   **Reference:** `lib/presentation/features/game/screens/game_screen.dart`
*   **Action 3.6: Add Connection Particles.**
    *   **Details:** Integrate a `ParticleEffect` (from `lib/presentation/effects/`) to generate tiny energy sparks or light trails when connections are successfully made between components.
    *   **Best Practice:** Micro-interaction. Provides satisfying visual feedback for a key action.
*   **Action 3.7: Implement Component Manipulation (Rotation, Deletion, Advanced Wire Editing).**
    *   **Problem:** Core circuit manipulation features like component rotation, deletion, and advanced wire editing are missing.
    *   **Files Involved:**
        *   `lib/application/enhanced_game_state_notifier.dart`: Needs new methods (e.g., `rotateComponent`, `deleteComponent`, `editWire`).
        *   `lib/core/commands/`: New commands (e.g., `RotateComponentCommand`, `DeleteComponentCommand`, `EditWireCommand`).
        *   `lib/application/use_cases/`: Corresponding use cases (e.g., `rotate_component_use_case_v2.dart`, `delete_component_use_case_v2.dart`).
        *   `lib/presentation/features/game/widgets/game_canvas.dart`: Needs UI for these actions (e.g., context menus on components, drag handles for wires).
    *   **Solution:** Implement the necessary commands, use cases, and notifier methods to support these interactions. Design intuitive UI/UX for triggering these actions (e.g., long-press for context menu on components, dedicated buttons in a toolbar, or advanced drag-and-drop gestures for wire editing).
    *   **Best Practice:** Comprehensive interaction. Essential for a fully functional circuit builder. Ensure undo/redo support for these new actions.

### 5.4. Celebrations & Extras (Phase 4)

**Goal:** Enhance celebratory moments and secondary UI elements.

*   **Action 4.1: Enhance `WinScreen`.**
    *   **Details:** Add `ParticleEffect` (sparkles, light rays) around the trophy. Implement a neon-themed confetti burst or subtle fireworks animation upon screen entry. Make the background dynamically brighter and more intensely neon-lit based on stars earned.
    *   **Best Practice:** Rewarding experience. Celebrations should be visually impactful.
    *   **Reference:** `lib/presentation/features/hud/screens/win_screen.dart`
*   **Action 4.2: Integrate Sound for Win Screen.**
    *   **Details:** Play a futuristic "power-up" or "level complete" sound effect when the win screen appears. This requires implementing the TODO in `FeedbackUtils.provideSoundFeedback` (in `lib/presentation/core/utils/feedback_utils.dart`).
    *   **Best Practice:** Multi-sensory feedback. Audio cues enhance the impact of visual events.
*   **Action 4.3: Enhance PauseMenu.**
    *   **Details:** Implement a custom entry animation (scale + neon pulse). Apply a frosted glass effect (using `GlassPanel`) to the background `GameScreen` when the pause menu is active, with a neon outline around the modal.
    *   **Best Practice:** Seamless interruption. Pause menu should feel integrated and visually appealing.
    *   **Reference:** `lib/presentation/features/hud/screens/pause_menu.dart`
*   **Action 4.4: Implement Idle Attract Mode for MainMenuScreen.**
    *   **Details:** If the app is idle for a set period, intensify background animations, make circuits pulse more strongly, or trigger a short, captivating visual sequence.
    *   **Best Practice:** Passive engagement. Keeps the user visually entertained even when not actively playing.

### 5.5. Optimization & Polish (Phase 5)

**Goal:** Ensure performance, accessibility, and overall quality.

*   **Action 5.1: Accessibility Pass.**
    *   **Details:** Conduct a comprehensive accessibility audit. Implement proper `SemanticsService` announcements for important UI state changes or interactive elements. Ensure all custom `Neon*` widgets provide appropriate `Semantics` labels and hints. Verify full keyboard navigation. **Specifically, ensure the high-contrast theme (`AppTheme.highContrastTheme`) is fully supported and can be toggled via settings.**
    *   **Best Practice:** Inclusive design. Makes the app usable by a wider audience.
    *   **Reference:** `lib/presentation/features/accessibility/widgets/accessible_focus_layer.dart`
*   **Action 5.2: Performance Optimizations.**
    *   **Details:**
        *   **GPU-Friendly Animations:** For complex animations (e.g., parallax backgrounds, particle systems), consider using tools like Rive or Flare to create GPU-accelerated animations.
        *   **Effect Optimization:** Implement techniques like culling (only rendering visible particles/elements) and efficient use of `RepaintBoundary` for custom painters. Profile CPU/GPU usage to identify bottlenecks.
        *   **Glassmorphism:** Be mindful of `BackdropFilter` performance. Apply it judiciously and optimize where possible (e.g., by limiting the area of effect).
    *   **Best Practice:** Smooth user experience. High frame rates are crucial for a game.
*   **Action 5.3: Consistency Audit.**
    *   **Details:** Conduct a final audit to ensure all Material 3 default widgets are replaced with their custom `Neon*` variants. Verify that the neon aesthetic is uniformly applied across the entire application.
    *   **Best Practice:** Unified brand identity. Every element should contribute to the game's theme.
*   **Action 5.4: Responsive Design Review.**
    *   **Details:** Thoroughly test across various devices and orientations (using Flutter's device preview or actual devices/emulators) to confirm responsive layouts. Ensure all neon effects, glassmorphism, and animated backgrounds scale beautifully and maintain their visual impact.
    *   **Best Practice:** Cross-platform compatibility. Ensures a great experience on any device.
    *   **Reference:** `lib/presentation/core/utils/responsive_utils.dart`
*   **Action 5.5: Final QA.**
    *   **Details:** Comprehensive testing for bugs, visual glitches, and overall user experience. Gather feedback from a diverse group of testers.
    *   **Best Practice:** Quality assurance. Ensures a polished and bug-free release.

---

## 6. Implementation Checklist

This checklist provides a detailed breakdown of tasks for each phase.

### Phase 0.0 – Foundational Backend & Data Layers (Pre-UI Phases)

*   **Phase 0.1: Core Data Persistence Layer**
    *   [ ] Choose persistence solution (`shared_preferences` for flags, `hive`/`sqflite` for structured data).
    *   [ ] Implement `storage_service.dart` as the persistence interface.
    *   [ ] Persist `_showOnboarding` flag in `lib/app.dart`.
    *   [ ] Implement persistence for `ProgressData` in `hud_state.dart`.
    *   [ ] Implement persistence for `ComponentInventory` and `isUnlocked` status in `palette_state.dart`.
*   **Phase 0.2: Core Audio System Integration**
    *   [ ] Choose Flutter audio plugin (`audioplayers`, `just_audio`).
    *   [ ] Implement `audio_manager.dart` for sound effects and background music.
    *   [ ] Connect `FeedbackUtils.provideSoundFeedback` to `audio_manager.dart`.
    *   [ ] Integrate audio settings from `SettingsScreen` with `audio_manager.dart`.
    *   [ ] Add sound effects for key UI events (button taps, component placement, win/lose, errors).
*   **Phase 0.3: Dynamic Content Management**
    *   [ ] Implement system to load level definitions from external JSON assets.
    *   [ ] Update `level_select.dart` to load levels dynamically.
    *   [ ] (Optional) Explore basic procedural generation for levels.
*   **Phase 0.4: User Account & Cloud Sync (Post-MVP)**
    *   [ ] Research backend services (Firebase, Supabase, custom API).
    *   [ ] Define API for user authentication and cloud progress storage.
    *   [ ] (Post-MVP) Implement user authentication flow.
    *   [ ] (Post-MVP) Implement cloud save/load functionality.

### Phase 1 – Foundations (Global Theme & Reusable Components)

*   [ ] Delete `lib/presentation/theme/app_theme.dart`.
*   [ ] Verify `lib/presentation/core/theme/app_theme.dart` is the sole theme source.
*   [ ] Expand `CircuitColorScheme` with `neonPrimary`, `neonAccent`, `errorGlow`, `energyPulse`, `highlightAccent`.
*   [ ] Create `lib/presentation/ui_components/` directory.
*   [ ] Implement `NeonButton` (enhance `MenuButton`).
*   [ ] Implement `GlassPanel` widget.
*   [ ] Implement `NeonSwitch`.
*   [ ] Implement `NeonSlider`.
*   [ ] Implement `NeonDropdown`.
*   [ ] Create `lib/presentation/effects/` directory.
*   [ ] Refactor existing effects (`GlowEffect`, `PulseEffect`, etc.) into `lib/presentation/effects/`.
*   [ ] Implement `ParticleEffect` (basic version).
*   [ ] Implement `ParallaxBackground` (basic version).
*   [ ] Implement `ScreenTransition` effects (basic versions).

### Phase 2 – Core Screens Overhaul (Initial Visual Overhaul)

*   **`MainMenuScreen`:**
    *   [ ] Replace Material buttons with `NeonMenuButton`s.
    *   [ ] Implement `ParallaxBackground` with circuit pattern and `ParticleEffect`.
    *   [ ] Animate "SparkCircuit" title (pulsing neon glow, subtle 3D tilt).
*   **`LevelSelectScreen`:**
    *   [ ] Replace current level cards with `NeonLevelCard`s.
    *   [ ] Implement glow borders and hover animations for `NeonLevelCard`s.
    *   [ ] Apply staggered fade-in/scale-up animations for cards.
    *   [ ] Implement animated circuitry map background.
*   **`SettingsScreen`:**
    *   [ ] Replace standard switches with `NeonSwitch`.
    *   [ ] Replace standard sliders with `NeonSlider`.
    *   [ ] Replace standard dropdowns with `NeonDropdown`.
    *   [ ] Implement futuristic neon lines for section dividers.
    *   [ ] Implement static dark gradient background with neon circuit nodes.
    *   [ ] Add micro-interactions (hover glow and press bounce).
*   **Global:**
    *   [ ] Apply custom screen transitions using `GoRouter` for all major routes.

### Phase 3 – Gameplay Enhancements (Immersion & Feedback)

*   [ ] Fully implement `ElectricCurrentEffect` for wires (connect `isActive` to simulation).
*   [ ] Implement LED glowing when active.
*   [ ] Implement subtle vibration for motors/actuators when powered.
*   [ ] Implement red neon glow for overloaded components.
*   [ ] Implement ghost image for component placement.
*   [ ] Implement neon grid highlight for valid/invalid placement zones.
*   [ ] Redesign HUD elements (`ProgressHud`) using `GlassPanel`s with neon borders.
*   [ ] Add micro-animations to HUD elements (score counter, timer pulse).
*   [ ] Implement `ParallaxBackground` for `GameCanvas`.
*   [ ] Add `ParticleEffect` for connection sparks.
*   [ ] Implement Component Manipulation (Rotation, Deletion, Advanced Wire Editing).
    *   [ ] Implement `rotateComponent` method in `enhanced_game_state_notifier.dart`.
    *   [ ] Implement `deleteComponent` method in `enhanced_game_state_notifier.dart`.
    *   [ ] Implement `editWire` method in `enhanced_game_state_notifier.dart`.
    *   [ ] Create corresponding commands in `lib/core/commands/`.
    *   [ ] Create corresponding use cases in `lib/application/use_cases/`.
    *   [ ] Design and implement UI for component rotation (e.g., context menu, dedicated button).
    *   [ ] Design and implement UI for component deletion (e.g., context menu, drag to trash).
    *   [ ] Design and implement UI for advanced wire editing (e.g., re-routing, segment deletion).

### Phase 4 – Celebrations & Extras (Polish & Delight)

*   **`WinScreen`:**
    *   [ ] Add `ParticleEffect` (sparkles, light rays) around trophy.
    *   [ ] Implement neon-themed confetti burst/fireworks.
    *   [ ] Implement dynamic background based on stars earned.
    *   [ ] Integrate futuristic sound effect.
    *   [ ] Redesign stats using `GlassPanel` cards with neon borders.
*   **`PauseMenu`:**
    *   [ ] Implement custom entry animation (scale + neon pulse).
    *   [ ] Apply frosted glass effect (`GlassPanel`) to background `GameScreen`.
    *   [ ] Ensure `NeonMenuButton`s are used with enhanced hover effects.
*   [ ] Implement Idle Attract Mode for `MainMenuScreen`.

### Phase 5 – Optimization & Polish (Performance, Accessibility, Final QA)

*   [ ] Conduct full accessibility audit.
*   [ ] Implement `SemanticsService` announcements for all custom widgets.
*   [ ] Verify full keyboard navigation.
*   [ ] Profile and optimize animations (consider Rive/Flare).
*   [ ] Optimize particle systems and `BackdropFilter` usage.
*   [ ] Conduct final consistency audit (all Material 3 defaults replaced).
*   [ ] Thoroughly test responsive design across devices/orientations.
*   [ ] Perform comprehensive final QA.
V+---------------------------------------------------+
|                 NeonTheme (Global)                |
|---------------------------------------------------|
|  - CircuitColorScheme (Neon Palette)              |
|  - Typography (Orbitron / Inter)                  |
|  - Neon Gradients / Glassmorphism / Glow Effects   |
|  - Global Animations (Pulse, Glow, Parallax, etc)  |
+---------------------------------------------------+

                     │
     ┌───────────────┴────────────────┐
     │                                │
+------------+                  +-----------------+
| UI Widgets |                  | Background FX   |
+------------+                  +-----------------+
| - NeonButton                  | - ParallaxBG    |
| - NeonCard                    | - ParticleFX    |
| - NeonSwitch                  | - CircuitLines  |
| - NeonSlider                  | - EnergyFlowFX  |
| - NeonDialog                  +-----------------+
| - NeonProgressBar             
| - NeonLevelCard               
+------------+  

                     │
     ┌───────────────┼──────────────────────────────┐
     │               │                              │
     ▼               ▼                              ▼

+------------------+      +------------------+      +------------------+
| Main Menu Screen |      | Onboarding       |      | Level Select     |
+------------------+      +------------------+      +------------------+
| - NeonTitle      |      | - PageView Neon  |      | - Grid NeonCards |
| - NeonMenuButton |      | - Animated Icons |      | - Unlock Anim FX |
| - ParallaxBG     |      | - ParallaxBG     |      | - Progress Path  |
+------------------+      +------------------+      +------------------+

     │                          │                          │
     ▼                          ▼                          ▼

+------------------+      +------------------+      +------------------+
| Game Screen      |      | Pause Menu       |      | Win Screen       |
+------------------+      +------------------+      +------------------+
| - NeonHUD (glass)|      | - NeonDialog FX  |      | - NeonDialog FX  |
| - EnergyFlowFX   |      | - NeonButtons    |      | - NeonStatsCard  |
| - Circuit Glow   |      | - Blur BG        |      | - ParticleFX     |
| - Placement Glow |      +------------------+      | - Fireworks FX   |
+------------------+                                 +------------------+
     │
     ▼
+------------------+
| Settings Screen  |
+------------------+
| - NeonSwitches   |
| - NeonSliders    |
| - Section Glow   |
| - Gradient BG    |
+------------------+

lib/
│
├── main.dart                  # Entry point, applies NeonTheme & routes
├── routes.dart                # Centralized routing with GoRouter
│
├── presentation/
│   ├── app.dart               # Root app widget
│   │
│   ├── core/
│   │   ├── theme/
│   │   │   ├── neon_theme.dart          # Neon color scheme, typography
│   │   │   ├── neon_gradients.dart      # Central gradient definitions
│   │   │   ├── neon_effects.dart        # Glow, pulse, shimmer effects
│   │   │   ├── glassmorphism.dart       # Glassmorphism styles
│   │   │   └── animation_tokens.dart    # Animation durations/curves
│   │   │
│   │   ├── utils/
│   │   │   ├── accessibility.dart       # Screen reader + a11y helpers
│   │   │   ├── haptic_feedback.dart     # Custom vibrations/tactile feedback
│   │   │   └── responsive.dart          # Breakpoints for mobile/tablet/desktop
│   │   │
│   │   └── constants.dart               # Global constants
│   │
│   ├── ui_components/
│   │   ├── neon_button.dart             # Custom neon glowing button
│   │   ├── neon_card.dart               # Neon card w/ glow & gradient
│   │   ├── neon_switch.dart             # Futuristic toggle switch
│   │   ├── neon_slider.dart             # Volume/brightness/game sliders
│   │   ├── neon_dialog.dart             # Pause/Win dialogs
│   │   ├── neon_progress_bar.dart       # Energy bar / level progress
│   │   ├── neon_level_card.dart         # Level select card (locked/unlocked)
│   │   └── neon_hud.dart                # Game HUD (glassmorphism overlay)
│   │
│   ├── effects/
│   │   ├── parallax_bg.dart             # Animated parallax backgrounds
│   │   ├── particle_fx.dart             # Particles / sparks / fireworks
│   │   ├── energy_flow_fx.dart          # Flowing neon wires animation
│   │   ├── placement_glow.dart          # Glow around placed components
│   │   └── screen_transitions.dart      # Fade/scale/slide transitions
│   │
│   ├── features/
│   │   ├── main_menu/
│   │   │   └── main_menu_screen.dart
│   │   ├── onboarding/
│   │   │   └── onboarding_screen.dart
│   │   ├── level_select/
│   │   │   └── level_select_screen.dart
│   │   ├── game/
│   │   │   ├── game_screen.dart
│   │   │   ├── hud/                     # HUD sub-widgets
│   │   │   └── canvas/                  # Circuit drawing & interaction
│   │   ├── pause_menu/
│   │   │   └── pause_menu.dart
│   │   ├── win_screen/
│   │   │   └── win_screen.dart
│   │   └── settings/
│   │       └── settings_screen.dart
│   │
│   └── accessibility/
│       └── accessible_focus_layer.dart  # Ensures all neon widgets are screen reader ready
│
└── data/
    ├── repositories/        # Game data storage
    ├── models/              # Game models (levels, progress, etc.)
    └── services/            # API/local storage services
