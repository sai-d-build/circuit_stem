# **Legacy Refactoring Plan Archive**

**Status:** Superseded
**Date Archived:** 2025-08-25

---

## 1. Introduction

This document is an archive of a previously proposed refactoring plan that has since been **superseded** by the "In-Place Behavior Standardization" strategy. It is preserved here for historical context and to document the project's architectural evolution.

This plan involved creating a pure domain model, free of Flutter dependencies, and bridging it to the existing application using an adapter pattern.

---

## **Legacy Phase 1: Introduce the Pure Domain (Coexistence)**

**🎯 Goal:** Build and test the new, pure domain models and behaviors *in parallel* with the old system.

### **✅ Step-by-Step Guide**

#### **Step 1: Create the New `ComponentEntity`**

In the `lib/domain/entities/` directory, create a new file named `component_entity.dart`.

```dart
// lib/domain/entities/component_entity.dart

import 'package:collection/collection.dart';
import 'package:circuit_stem/domain/behaviors/behavior.dart';
import 'package:circuit_stem/domain/value_objects/position.dart';

class ComponentEntity {
  final String id;
  final String type;
  final Position position;
  final Map<String, dynamic> state;
  final List<Behavior> behaviors;

  ComponentEntity({
    required this.id,
    required this.type,
    required this.position,
    required this.state,
    required this.behaviors,
  });

  T? getBehavior<T extends Behavior>() {
    return behaviors.whereType<T>().firstOrNull;
  }

  ComponentEntity executeAction(String action, Map<String, dynamic> context) {
    ComponentEntity result = this;
    for (final behavior in behaviors) {
      if (behavior.canExecute(this, action)) {
        result = behavior.execute(result, action, context);
      }
    }
    return result;
  }

  ComponentEntity copyWith({
    Position? position,
    Map<String, dynamic>? state,
  }) {
    return ComponentEntity(
      id: id,
      type: type,
      position: position ?? this.position,
      state: state ?? this.state,
      behaviors: behaviors,
    );
  }
}
```

#### **Step 2: Create the New Behavior System**

Create a new file `lib/domain/behaviors/behavior.dart` for the base class, and another for the implementation, e.g., `interaction_behavior.dart`.

```dart
// lib/domain/behaviors/behavior.dart
import 'package:circuit_stem/domain/entities/component_entity.dart';

abstract class Behavior {
  String get type;
  bool canExecute(ComponentEntity component, String action);
  ComponentEntity execute(ComponentEntity component, String action, Map<String, dynamic> context);
}
```

```dart
// lib/domain/behaviors/interaction_behavior.dart
import 'package:circuit_stem/domain/behaviors/behavior.dart';
import 'package:circuit_stem/domain/entities/component_entity.dart';

class ToggleBehavior extends Behavior {
  @override
  String get type => 'interaction';

  @override
  bool canExecute(ComponentEntity component, String action) {
    return action == 'tap';
  }

  @override
  ComponentEntity execute(ComponentEntity component, String action, Map<String, dynamic> context) {
    if (action == 'tap') {
      final currentClosedState = component.state['closed'] as bool? ?? false;
      final newState = Map<String, dynamic>.from(component.state)
        ..['closed'] = !currentClosedState;
      return component.copyWith(state: newState);
    }
    return component;
  }
}
```

#### **Step 3: Write Unit Tests for the New Domain Logic**

Create a new test file `test/domain/behaviors/interaction_behavior_test.dart`.

```dart
// test/domain/behaviors/interaction_behavior_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/domain/behaviors/interaction_behavior.dart';
import 'package:circuit_stem/domain/entities/component_entity.dart';
import 'package:circuit_stem/domain/value_objects/position.dart';

void main() {
  group('ToggleBehavior', () {
    test('execute with "tap" action should toggle the "closed" state from false to true', () {
      // ARRANGE
      final behavior = ToggleBehavior();
      final component = ComponentEntity(
        id: 's1',
        type: 'switch',
        position: Position(r: 1, c: 1),
        state: {'closed': false},
        behaviors: [behavior],
      );

      // ACT
      final result = behavior.execute(component, 'tap', {});

      // ASSERT
      expect(result.state['closed'], isTrue);
    });
  });
}
```

---

## **Legacy Phase 2: The Adapter & Bridge (First Integration)**

**🎯 Goal:** To connect a single piece of the old engine to our new, tested domain logic. This proves the integration works while keeping the risk contained to one small feature.

### **✅ Step-by-Step Guide**

#### **Step 1: Create the "Adapter" File**

Create a new file: `lib/application/domain_adapter.dart`.

```dart
// lib/application/domain_adapter.dart

import 'package:circuit_stem/domain/entities/component_entity.dart';
import 'package:circuit_stem/domain/value_objects/position.dart';
import 'package:circuit_stem/domain/behaviors/interaction_behavior.dart';
import 'package:circuit_stem/domain/entities/component.dart' as old;

ComponentEntity toComponentEntity(old.ComponentModel model) {
  final behaviors = [
    if (model.type == 'Component.Switch') ToggleBehavior(),
  ];

  return ComponentEntity(
    id: model.id,
    type: model.type,
    position: Position(r: model.r, c: model.c),
    state: model.state,
    behaviors: behaviors,
  );
}

old.ComponentModel toComponentModel(ComponentEntity entity) {
  return old.ComponentModel(
    id: entity.id,
    type: entity.type,
    r: entity.position.r,
    c: entity.position.c,
    rotation: 0,
    state: entity.state,
    behaviors: [],
  );
}
```

#### **Step 2: Modify the Old Engine to Use the Adapter**

Modify `lib/application/game_engine_notifier.dart` to use the new logic for a specific case.

```dart
// lib/application/game_engine_notifier.dart (New code)
import 'package:circuit_stem/application/domain_adapter.dart';

void _handleTap(ComponentModel component) {
  if (component.type == 'Component.Switch') {
    final entity = toComponentEntity(component);
    final resultEntity = entity.executeAction('tap', {});
    final newModel = toComponentModel(resultEntity);
    updateComponent(newModel);
    audio.playToggle();
  } else {
    // ... old logic here ...
  }
}
```
