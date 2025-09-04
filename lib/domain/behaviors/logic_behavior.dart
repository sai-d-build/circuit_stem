// Logic behavior interface for circuit components
// Defines the behavior for components that have logical operations

import '../entities/core/component.dart';

abstract class LogicBehavior {
  void execute(ComponentModel component);
  bool canExecute(ComponentModel component);
  String get behaviorType;
}

// Base implementation of logic behavior
class BaseLogicBehavior implements LogicBehavior {
  @override
  void execute(ComponentModel component) {
    // Base implementation - override in subclasses
  }

  @override
  bool canExecute(ComponentModel component) {
    return true;
  }

  @override
  String get behaviorType => 'base';
}

// Wire logic behavior for connecting components
class WireLogicBehavior extends BaseLogicBehavior {
  @override
  void execute(ComponentModel component) {
    // Wire logic - propagate power through connections
    // Implementation would handle power flow through wire connections
  }

  @override
  String get behaviorType => 'wire';
}

// Switch logic behavior for controlling power flow
class SwitchLogicBehavior extends BaseLogicBehavior {
  @override
  void execute(ComponentModel component) {
    // Switch logic - control power flow based on switch state
        // final isOn = component.properties['isOn'] ?? false;
    // Implementation would handle switch on/off logic
  }

  @override
  String get behaviorType => 'switch';
}

// Battery logic behavior for power source
class BatteryLogicBehavior extends BaseLogicBehavior {
  @override
  void execute(ComponentModel component) {
    // Battery logic - provide constant power source
        // final voltage = component.properties['voltage'] ?? 9.0;
    // Implementation would handle battery power output
  }

  @override
  String get behaviorType => 'battery';
}

// Bulb logic behavior for power consumption
class BulbLogicBehavior extends BaseLogicBehavior {
  @override
  void execute(ComponentModel component) {
    // Bulb logic - consume power and light up
        // final resistance = component.properties['resistance'] ?? 100.0;
    // Implementation would handle bulb illumination logic
  }

  @override
  String get behaviorType => 'bulb';
}