# Tutorial: Adding a New Component

This guide walks you through the process of adding a new component to the Circuit STEM application. Thanks to the **Component-Behavior model**, this process is simple and does not require modifying any core engine code.

As an example, we will add a **Diode**, a component that only allows power to flow in one direction.

---

### Step 1: Create a New Component File

First, create a new file for your component inside the `lib/components/` directory.

*   **File:** `lib/components/diode.dart`

---

### Step 2: Implement the Component's Behaviors

Inside your new file, you will define the classes that represent your component's unique behaviors. A typical component will have at least a `DrawingBehavior` and a `LogicBehavior`.

```dart
import 'package:flutter/material.dart';
import '../behaviors/drawing_behavior.dart';
import '../behaviors/logic_behavior.dart';
import '../core/component_registry.dart';
import '../models/component.dart';
import '../services/asset_manager.dart';

// --- Drawing Behavior ---
// Defines how the diode looks on the canvas.
class DiodeDrawingBehavior implements DrawingBehavior {
  @override
  void draw(Canvas canvas, Size size, ComponentModel component, AssetManagerNotifier assets) {
    // Here, you would get the SVG image for the diode from the asset manager
    // and draw it onto the canvas, applying the component's rotation.
    // Example:
    // final diodeImage = assets.getSvgAsImage('assets/images/diode.svg');
    // if (diodeImage != null) {
    //   // ... logic to draw the image on the canvas ...
    // }
  }
}

// --- Logic Behavior ---
// Defines how the diode functions in the circuit.
class DiodeLogicBehavior implements LogicBehavior {
  // This is where you would implement the one-way power flow.
  // The actual implementation would involve checking the direction
  // of incoming power against the diode's orientation.
}
```

---

### Step 3: Create a Registration Function

Now, in the same file, create a function that "registers" your new component with the game's `ComponentRegistry`. This makes the game engine aware of your component and its behaviors.

```dart
void registerDiode() {
  ComponentRegistry.register(
    type: "Component.Diode", // A unique string identifier for your component
    displayName: "Diode",     // The name that appears in the UI
    behaviors: [
      DiodeDrawingBehavior, // The behaviors to attach to this component
      DiodeLogicBehavior
    ],
    isDraggable: true, // Can the user drag this component from the palette?
  );
}
```

---

### Step 4: Register the Component on App Startup

Finally, you need to call your new registration function when the app starts.

1.  Open `lib/main.dart`.
2.  Find the `registerAllGameEntities()` function.
3.  Add your `registerDiode()` function call to the list.

```dart
// lib/main.dart

// ... imports
import '../components/diode.dart';

void registerAllGameEntities() {
  registerBulb();
  registerSwitch();
  registerWire();
  registerBattery();
  registerGround();
  registerTimer();
  registerBuzzer();

  // Add your new component here
  registerDiode();

  // Register Goals
  registerPowerBulbGoal();
}
```

---

### Step 5: Use Your New Component

**That's it!** Your new component is fully integrated into the game engine.

You can now add it to any level by using its string identifier in the level's JSON file.

**Example: `assets/levels/level_xx.json`**
```json
{
  "paletteComponents": [
    {
      "id": "diode_palette",
      "type": "Component.Diode",
      "position": {"r": 0, "c": 0}
    }
  ]
}
```
