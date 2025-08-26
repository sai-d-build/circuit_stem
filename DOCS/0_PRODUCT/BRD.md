
# Business Requirements Document (BRD)

**Project:** Circuit STEM

---

### 1. Purpose & Vision

The primary purpose of *Circuit STEM* is to teach the fundamental concepts of electrical circuits to young learners (ages 6-12) through a series of engaging, hands-on puzzles. The vision is to create a delightful and educational experience that sparks curiosity in STEM fields by making complex topics accessible and fun.

### 2. Key Business Goals

*   **Engagement:** Launch an MVP with at least 10 levels that effectively teach concepts of series, parallel circuits, switches, and shorts.
*   **Educational Efficacy:** Ensure the gameplay mechanics accurately represent real-world circuit logic, providing genuine "light bulb" moments for players.
*   **Technical Foundation:** Build the application on a solid, testable, and modular pure-Dart architecture that enables rapid future expansion with new levels, components, and features.

### 3. Target Audience

*   **Primary:** Children aged 6–12.
*   **Secondary:** Educators (teachers, tutors) looking for simple and effective STEM mini-games for classroom or remote learning.
*   **Tertiary:** Parents seeking educational and engaging activities for their children.

### 4. Scope

#### In Scope for MVP:

*   A sequence of 10+ puzzle levels.
*   Core gameplay mechanics: dragging, dropping, and rotating circuit components.
*   Interactive components: switches that can be toggled by the user.
*   Logic engine capable of detecting complete circuits, powered components, and short circuits.
*   Clear visual and audio feedback for game states (e.g., bulb glow, wire power flow, success sounds).
*   Level definitions loaded from external JSON files.
*   Player progress saved locally on the device.
*   Optimized for iOS and Android, with a focus on tablet-first layouts.

#### Out of Scope for MVP:

*   In-app purchases or monetization.
*   A user-facing level editor.
*   Multiplayer or competitive features.
*   Advanced components like timers, logic gates, or sequencers.
*   User accounts or cloud-based progress saving.

### 5. Success Criteria

*   **User Adoption:** Achieve a target number of downloads within the first three months of launch.
*   **Player Retention:** >60% of new players complete the first 5 levels.
*   **Technical Stability:** The application maintains a crash-free user rate of >99%.
*   **Performance:** All user interactions and animations feel responsive (<150ms reaction time) on mid-range devices from the last 3-5 years.
