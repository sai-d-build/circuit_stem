import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';

/// Adapter to convert palette state to UI components
class ComponentPaletteAdapter {
  static List<Widget> buildComponentWidgets(
    List<ComponentDefinition> components,
    Map<String, ComponentInventory> inventory,
    Function(String) onComponentTap,
  ) {
    return components.map((component) {
      final componentInventory = inventory[component.type];
      return _buildComponentCard(component, componentInventory, onComponentTap);
    }).toList();
  }

  static Widget _buildComponentCard(
    ComponentDefinition component,
    ComponentInventory? inventory,
    Function(String) onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(_getIconForComponent(component.type)),
        title: Text(component.name),
        subtitle: Text(component.description),
        trailing: inventory != null
            ? Chip(
                label: Text('${inventory.available}'),
                backgroundColor: inventory.canUse
                    ? Colors.green.withValues(alpha: 0.2)
                    : Colors.red.withValues(alpha: 0.2),
              )
            : null,
        onTap: () => onTap(component.type),
        enabled: inventory?.canUse ?? false,
      ),
    );
  }

  static IconData _getIconForComponent(String componentType) {
    switch (componentType) {
      case 'battery':
        return Icons.battery_full;
      case 'resistor':
        return Icons.linear_scale;
      case 'led':
        return Icons.lightbulb;
      case 'wire':
        return Icons.horizontal_rule;
      case 'switch':
        return Icons.power;
      default:
        return Icons.electrical_services;
    }
  }
}