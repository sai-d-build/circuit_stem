# **The Circuit STEM Testing Bible**

**Version:** 1.1  
**Last Updated:** 2025-08-23  

---

## **Table of Contents**

1.  [Introduction](#1-introduction)
2.  [Testing Philosophy: The Pyramid](#2-testing-philosophy-the-pyramid)
3.  [Test Suite Architecture](#3-test-suite-architecture)
4.  [Writing Tests: A Step-by-Step Guide](#4-writing-tests-a-step-by-step-guide)
5.  [Helpers: Your Testing Toolkit](#5-helpers-your-testing-toolkit)
6.  [Test Case Catalog](#6-test-case-catalog)
7.  [Running Tests](#7-running-tests)
8.  [Versioning and Maintenance](#8-versioning-and-maintenance)

---

## **1. Introduction**

Welcome to the `circuit_stem` project! A high-quality application is built on a foundation of **high-quality, well-tested code**. This document is your complete guide to understanding, contributing to, and maintaining our testing suite.

By following these guidelines, you will:

*   **Build with Confidence:** Ensure new code does not break existing functionality.
*   **Catch Bugs Early:** Detect and fix issues before they reach users.
*   **Improve Code Quality:** Write maintainable, clean, and testable code.
*   **Onboard New Developers Quickly:** Provide a consistent framework for testing.

---

## **2. Testing Philosophy: The Pyramid**

We adhere to the **Testing Pyramid**, ensuring we balance speed, reliability, and coverage:

```
      /\
     /  \   <-- Integration Tests (Few)
    /----\
   /      \  <-- Widget Tests (Many)
  /--------\
 /          \ <-- Unit Tests (Most)
/------------\
```

*   **Unit Tests (Base):** Test isolated logic. Fast and numerous.
*   **Widget Tests (Middle):** Test UI components and interactions.
*   **Integration Tests (Top):** End-to-end scenarios. Slow, but critical.

---

## **3. Test Suite Architecture**

```
test/
 ├─ unit/
 │   ├─ game_engine_notifier_test.dart
 │   └─ game_state_logic_test.dart
 ├─ widgets/
 │   ├─ switch_widget_test.dart
 │   ├─ bulb_widget_test.dart
 │   ├─ timer_widget_test.dart
 │   ├─ battery_widget_test.dart
 │   ├─ component_palette_test.dart
 │   ├─ goal_tracker_test.dart
 │   └─ game_buttons_test.dart
 ├─ levels/
 │   ├─ level_01_test.dart
 │   └─ level_02_test.dart
 ├─ integration/
 │   └─ full_game_flow_test.dart
 └─ helpers/
     ├─ test_helpers.dart
     └─ widget_helpers.dart
```

*   **`unit/`** → Core logic and state management.
*   **`widgets/`** → Individual UI component tests (gestures, animations, visuals).
*   **`levels/`** → Level-specific interactions combining multiple widgets.
*   **`integration/`** → End-to-end gameplay and flow.
*   **`helpers/`** → Reusable utilities and widget interaction helpers.

---

## **4. Writing Tests: A Step-by-Step Guide**

### **4.1 Unit Tests**

Unit tests verify **game logic** in isolation.

**File:** `test/unit/game_engine_notifier_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/game_engine_notifier_v2.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('GameEngineNotifierV2 Unit Tests', () {

    test('TC-L1-07: Partial circuit', () {
      final notifier = GameEngineNotifierV2();
      notifier.loadGrid(createPartialCircuitGrid());
      notifier.simulatePower();

      final bulb = notifier.state.findComponentById('bulb1');
      expect(bulb.isPowered, isFalse);
    });

    test('TC-L1-08: Complete circuit (no timer)', () {
      final notifier = GameEngineNotifierV2();
      notifier.loadGrid(createCompleteCircuitGrid());
      notifier.simulatePower();

      final bulb = notifier.state.findComponentById('bulb1');
      expect(bulb.isPowered, isTrue);
    });

    test('TC-L1-09: Complete circuit with timer', () {
      final notifier = GameEngineNotifierV2();
      notifier.loadGrid(createTimerCircuitGrid());
      notifier.simulatePower();

      final bulb = notifier.state.findComponentById('bulb1');
      expect(bulb.isPowered, isTrue);
      final timer = notifier.state.findComponentById('timer1');
      expect(timer.isActive, isTrue);
    });

    test('TC-L1-12: Switch break test', () {
      final notifier = GameEngineNotifierV2();
      notifier.loadGrid(createCompleteCircuitGrid());
      notifier.simulatePower();
      notifier.toggleSwitch('switch1');

      expect(notifier.checkWinState(), isFalse);
    });
  });
}
```

### **4.2 Widget Tests**

Widget tests simulate **user interactions** and **visual feedback**.

**Example:** Toggle Switch (`TC-L1-01`)

**File:** `test/widgets/switch_widget_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/game_screen.dart';
import '../helpers/widget_helpers.dart';

void main() {
  group('Switch Widget Tests', () {

    testWidgets('TC-L1-01: Toggle switch', (WidgetTester tester) async {
      await pumpGameScreenForLevel(tester, 1);

      final switchFinder = find.byKey(const Key('switch1'));
      expect(switchFinder, findsOneWidget);

      final initialState = getSwitchState(tester, 'switch1');

      await tapComponent(tester, 'switch1');

      final finalState = getSwitchState(tester, 'switch1');
      expect(finalState, !initialState);
    });
  });
}
```

**Best Practices for Widget Tests:**

*   **Use Keys:** All interactive widgets must have a unique `Key` to locate them in tests.
*   **Pump & Settle:** Always use `tester.pumpAndSettle()` after simulating a gesture to allow the UI to update and animations to complete.
*   **Test What the User Sees:** Verify both the internal state of the notifier and the visual changes in the UI.
*   **Keep Tests Independent:** Each test should set up its own state and not rely on the state of previous tests.

**Troubleshooting Widget Tests:**

*   **Widget Not Found:** Ensure the widget has been pumped into the tree and has the correct `Key`.
*   **State Not Updated:** Verify that the UI interaction correctly triggers the corresponding method on the notifier. Use `tester.pumpAndSettle()` to ensure the state change has had time to propagate.

### **4.3 Integration Tests**

Integration tests validate **full game flows**, combining logic and UI.

**File:** `test/integration/full_game_flow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:my_game/main.dart';
import '../helpers/widget_helpers.dart';

void main() {
  group('Full Game Flow', () {

    testWidgets('Complete Level 1 successfully', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      await dragComponent(tester, 'bulb1', const Offset(100, 100));
      await dragComponent(tester, 'wire1', const Offset(100, 200));
      await tapComponent(tester, 'switch1');

      expect(find.text('You Win!'), findsOneWidget);
    });
  });
}
```

---

## **5. Helpers: Your Testing Toolkit**

To keep our tests clean and reusable, we use helper files.

*   **`test/helpers/test_helpers.dart`:** Contains helpers for setting up test data (e.g., creating pre-configured grids) and verifying game state.
*   **`test/helpers/widget_helpers.dart`:** Contains helpers for interacting with widgets.

**Example:** `test/helpers/widget_helpers.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> dragComponent(WidgetTester tester, String key, Offset offset) async {
  final finder = find.byKey(Key(key));
  await tester.drag(finder, offset);
  await tester.pumpAndSettle();
}

Future<void> tapComponent(WidgetTester tester, String key) async {
  await tester.tap(find.byKey(Key(key)));
  await tester.pumpAndSettle();
}
```

---

## **6. Test Case Catalog**

| Test Case ID | Scenario                      | Layer  |
| :----------- | :---------------------------- | :----- |
| TC-L1-01     | Toggle switch                 | Widget |
| TC-L1-02     | Move bulb                     | Widget |
| TC-L1-03     | Move timer                    | Widget |
| TC-L1-04     | Try moving battery            | Widget |
| TC-L1-05     | Try moving switch             | Widget |
| TC-L1-06     | Invalid placement             | Widget |
| TC-L1-07     | Partial circuit               | Unit   |
| TC-L1-08     | Complete circuit (no timer)   | Unit   |
| TC-L1-09     | Complete circuit with timer   | Unit   |
| TC-L1-10     | All goals met                 | Widget |
| TC-L1-11     | Hint visibility               | Widget |
| TC-L1-12     | Switch break test             | Unit   |
| TC-L1-13     | Grid snap feedback            | Widget |
| TC-L1-14     | Drag cancel                   | Widget |
| TC-L1-15     | Overlap highlight             | Widget |
| TC-L1-16     | Switch visual state           | Widget |
| TC-L1-17     | Bulb lit visual               | Widget |
| TC-L1-18     | Timer running visual          | Widget |
| TC-L1-19     | Timer stopped visual          | Widget |
| TC-L1-20     | Hint ghost wire fade          | Widget |
| TC-L1-21     | Component selection highlight | Widget |
| TC-L1-22     | Placement sound               | Widget |
| TC-L1-23     | Invalid placement sound       | Widget |
| TC-L1-24     | Tap accuracy                  | Widget |
| TC-L1-25     | Mobile responsiveness         | Widget |
| TC-L1-26     | Goal tracker update           | Widget |
| TC-L1-27     | Win animation                 | Widget |
| TC-L1-28     | Restart level                 | Widget |
| TC-L1-29     | Undo last move                | Widget |
| TC-L1-30     | Switch spam prevention        | Widget |
| TC-L2-01     | Rotate wire                   | Widget |

---

## **7. Running Tests**

```bash
# Run all tests
flutter test

# Run all tests in a specific file
flutter test test/widgets/switch_widget_test.dart

# Run a specific test by name
flutter test --plain-name "TC-L1-01: Toggle switch"
```

---

## **8. Versioning and Maintenance**

*   This document should be updated whenever new tests, components, or levels are added.
*   Changes should be tagged with a version number, and the **Last Updated** field should be modified.
*   All team members are encouraged to follow this structure to ensure **consistency and scalability**.