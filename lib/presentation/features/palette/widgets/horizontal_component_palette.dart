
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/domain/entities/component.dart';

class HorizontalComponentPalette extends ConsumerWidget {
  final String levelId;

  const HorizontalComponentPalette({super.key, required this.levelId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paletteState = ref.watch(paletteStateProvider(levelId));
    final paletteNotifier = ref.read(paletteStateProvider(levelId).notifier);

    return Container(
      height: 100, // Adjust height as needed
      color: Colors.grey[200],
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: paletteState.availableComponents.length,
        itemBuilder: (context, index) {
          final componentDefinition = paletteState.availableComponents[index];
          final isSelected = paletteState.selectedComponentType == componentDefinition.type;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                paletteNotifier.selectComponent(componentDefinition.type);
                // Start placing component mode
                paletteNotifier.startPlacingComponent(componentDefinition.type);
              },
              child: Chip(
                label: Text(componentDefinition.name),
                backgroundColor: isSelected ? Colors.blue[200] : Colors.grey[300],
                avatar: Icon(_getComponentIcon(componentDefinition.type)),
              ),
            ),
          );
        },
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
        return Icons.power_settings_new;
      case 'capacitor':
        return Icons.battery_charging_full;
      case 'inductor':
        return Icons.settings_ethernet;
      default:
        return Icons.electrical_services;
    }
  }
}
