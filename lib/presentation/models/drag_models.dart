import 'package:flutter/material.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

/// Data structure for component drag operations
class ComponentDragData {
  final ComponentType componentType;
  final String componentName;
  final String description;
  final Map<String, dynamic> defaultProperties;
  final int cost;
  final IconData icon;

  const ComponentDragData({
    required this.componentType,
    required this.componentName,
    required this.description,
    required this.defaultProperties,
    required this.cost,
    required this.icon,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ComponentDragData) return false;
    return componentType == other.componentType &&
        componentName == other.componentName &&
        description == other.description &&
        _mapEquals(defaultProperties, other.defaultProperties) &&
        cost == other.cost &&
        icon == other.icon;
  }

  @override
  int get hashCode {
    return Object.hash(
      componentType,
      componentName,
      description,
      _mapHash(defaultProperties),
      cost,
      icon,
    );
  }

  bool _mapEquals(Map<String, dynamic>? a, Map<String, dynamic>? b) {
    if (a == null && b == null) return true;
    if (a == null || b == null) return false;
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }

  int _mapHash(Map<String, dynamic>? map) {
    if (map == null) return 0;
    var hash = 0;
    for (final entry in map.entries) {
      hash ^= entry.key.hashCode;
      hash ^= entry.value.hashCode;
    }
    return hash;
  }

  /// Create drag data from ComponentDefinition (palette state version)
  factory ComponentDragData.fromPaletteComponentDefinition(dynamic definition) {
    // Handle both domain ComponentDefinition and palette ComponentDefinition
    final type = definition.type;
    final componentType =
        type is ComponentType ? type : _stringToComponentType(type);

    return ComponentDragData(
      componentType: componentType,
      componentName: definition.name,
      description: definition.description,
      defaultProperties: definition.defaultProperties ?? {},
      cost: definition.cost ?? 1,
      icon: _getComponentIcon(componentType),
    );
  }

  static ComponentType _stringToComponentType(String typeString) {
    switch (typeString) {
      case 'battery':
        return ComponentType.battery;
      case 'resistor':
        return ComponentType.resistor;
      case 'bulb':
      case 'led':
        return ComponentType.bulb;
      case 'wire':
        return ComponentType.wire;
      case 'switch':
        return ComponentType.switch_;
      case 'capacitor':
        return ComponentType.capacitor;
      case 'inductor':
        return ComponentType.inductor;
      case 'buzzer':
        return ComponentType.buzzer;
      default:
        return ComponentType.wire; // Default fallback
    }
  }

  static IconData _getComponentIcon(ComponentType type) {
    switch (type) {
      case ComponentType.battery:
        return Icons.battery_full;
      case ComponentType.resistor:
        return Icons.linear_scale;
      case ComponentType.bulb:
        return Icons.lightbulb;
      case ComponentType.wire:
        return Icons.horizontal_rule;
      case ComponentType.switch_:
        return Icons.power;
      case ComponentType.capacitor:
        return Icons.battery_charging_full;
      case ComponentType.inductor:
        return Icons.settings_ethernet;
      case ComponentType.buzzer:
        return Icons.volume_up;
      default:
        return Icons.electrical_services;
    }
  }
}

/// Drag feedback widget for component being dragged
class ComponentDragFeedback extends StatelessWidget {
  final ComponentDragData dragData;

  const ComponentDragFeedback({
    super.key,
    required this.dragData,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      // Prevent interaction with drag feedback to eliminate ghost behavior
      child: Transform.scale(
        scale: 0.9, // Slightly smaller to reduce ghost confusion
        child: Opacity(
          opacity:
              0.6, // Semi-transparent to distinguish from placed components
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    dragData.icon,
                    size: 32,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dragData.componentName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
