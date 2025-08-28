import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/state/game_state.dart';

class CircuitComponentWidget extends StatelessWidget {
  final CircuitComponent component;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const CircuitComponentWidget({
    super.key,
    required this.component,
    this.isSelected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: component.isActive
              ? circuitColors.primary.withOpacity(0.2)
              : circuitColors.surfaceContainer.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? circuitColors.primary
                : circuitColors.outline.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: circuitColors.shadow.withOpacity(0.1),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _getComponentIcon(component.type),
                color: component.isActive
                    ? circuitColors.primary
                    : circuitColors.onSurface,
                size: 24,
              ),
              const SizedBox(height: 2),
              Text(
                _getComponentLabel(component.type),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: circuitColors.onSurface,
                  fontSize: 8,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getComponentIcon(String componentType) {
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
      case 'capacitor':
        return Icons.battery_charging_full;
      case 'inductor':
        return Icons.settings_ethernet;
      default:
        return Icons.electrical_services;
    }
  }

  String _getComponentLabel(String componentType) {
    switch (componentType) {
      case 'battery':
        return 'BAT';
      case 'resistor':
        return 'R';
      case 'led':
        return 'LED';
      case 'wire':
        return 'W';
      case 'switch':
        return 'SW';
      case 'capacitor':
        return 'C';
      case 'inductor':
        return 'L';
      default:
        return componentType.toUpperCase().substring(0, 3);
    }
  }
}