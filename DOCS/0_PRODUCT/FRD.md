# Functional Requirements Document (FRD)

**Project:** Circuit STEM

---

This document outlines the functional requirements for the application, detailing what the system must do from a user's perspective.

### 1. Core Gameplay Mechanics

*   **FR-1.1 (Grid-based Play):** The game shall be presented on a grid. All components must snap to this grid.
*   **FR-1.2 (Component Interaction):**
    *   Users must be able to drag and drop movable components from a dedicated `ComponentPalette` or within the grid.
    *   Users must be able to rotate components in 90-degree increments.
    *   Users must be able to tap on interactive components (like switches) to toggle their state.
*   **FR-1.3 (Component Placement):** The system shall prevent the placement of a component in a grid cell that is already occupied by another component.

### 2. Circuit Logic & Evaluation

*   **FR-2.1 (Power Flow):** The system must simulate the flow of electricity from a power source (battery).
*   **FR-2.2 (Complete Circuit):** A circuit is considered complete if there is a continuous, unbroken path of conductive components from the positive terminal of a battery to the negative terminal.
*   **FR-2.3 (Powered Components):** Any component that is part of a complete circuit shall enter a "powered" state.
*   **FR-2.4 (Short Circuit):** The system must detect a short circuit, defined as a continuous path from a battery's positive to negative terminal without passing through a load-bearing component (e.g., a bulb).
*   **FR-2.5 (Switches):** A switch component shall either allow or block the flow of power based on its state (open/closed).

### 3. User Feedback

*   **FR-3.1 (Visual Feedback):**
    *   Powered wires and components must be visually distinct from unpowered ones through programmatic drawing (e.g., color change, glowing effects, or animation).
    *   The system shall display a clear success animation or indicator when a level's goal is met.
    *   The system shall provide a distinct visual warning when a short circuit is detected.
*   **FR-3.2 (Audio Feedback):** The system shall provide sound effects for key actions, such as placing a component, toggling a switch, and completing a level.

### 4. Level Progression

*   **FR-4.1 (Level Loading):** The game shall load level layouts, component positions, and goals from external data files (JSON).
*   **FR-4.2 (Win Condition):** Each level must have a clear win condition (e.g., "power all bulbs"). The system will automatically detect when this condition is met.
*   **FR-4.3 (Progression):** Upon completing a level, the system shall unlock the next level.
*   **FR-4.4 (Persistence):** The user's progress (i.e., which levels have been unlocked) must be saved locally on their device and persist between game sessions.

### 5. UI/UX

*   **FR-5.1 (Game Controls):** The UI must provide clear, intuitive controls for resetting the current level and pausing the game.
*   **FR-5.2 (Navigation):** Users must be able to navigate from the game screen back to a main menu or level selection screen.