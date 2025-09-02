import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/game_engine_v3/providers_v3.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/domain/entities/component.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';

class HorizontalComponentPalette extends ConsumerWidget {
  final String levelId;

  const HorizontalComponentPalette({super.key, required this.levelId});

  static const double _paletteHeight = 120;
  static const double _chipPadding = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paletteState = ref.watch(paletteStateProvider(levelId));
    final paletteNotifier = ref.read(paletteStateProvider(levelId).notifier);

    return Container(
      height: _paletteHeight,
      color: Colors.grey[200],
      child: Column(
        children: [
          // Test button for drag functionality
          ElevatedButton(
            onPressed: () {
              if (paletteState.availableComponents.isEmpty) return;

              debugPrint('🎯 HorizontalComponentPalette: TEST DRAG BUTTON PRESSED');
              final testComponent = paletteState.availableComponents.first;
              final dragData = ComponentDragData.fromPaletteComponentDefinition(testComponent);

              debugPrint(
                  '🎯 HorizontalComponentPalette: Test drag data created: ${dragData.componentName} (${dragData.componentType})');

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Drag Test'),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Component: ${dragData.componentName}'),
                        Text('Type: ${dragData.componentType}'),
                        Text('Cost: ${dragData.cost}'),
                        const SizedBox(height: 16),
                        ComponentDragFeedback(dragData: dragData),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
            child: const Text('Test Drag Infrastructure'),
          ),

          // Main palette
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: paletteState.availableComponents.length,
              itemBuilder: (context, index) {
                final componentDefinition = paletteState.availableComponents[index];
                final isSelected = paletteState.selectedComponentType == componentDefinition.type;
                final dragData = ComponentDragData.fromPaletteComponentDefinition(componentDefinition);

                debugPrint(
                    '🎨 Building draggable for ${componentDefinition.name} (type: ${componentDefinition.type})');

                return Padding(
                  padding: const EdgeInsets.all(_chipPadding),
                  child: LongPressDraggable<ComponentDragData>(
                    data: dragData,
                    feedback: ComponentDragFeedback(dragData: dragData),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: _buildChip(componentDefinition.name, componentDefinition.type,
                          background: Colors.grey[300]),
                    ),
                    onDragStarted: () {
                      debugPrint('🎯 ===== DRAG STARTED =====');
                      debugPrint(
                          '🎯 Component: ${componentDefinition.name} (type: ${componentDefinition.type})');
                      debugPrint(
                          '🎯 DragData - type: ${dragData.componentType}, name: ${dragData.componentName}, cost: ${dragData.cost}');
                      debugPrint(
                          '🎯 Available in inventory: ${paletteState.canUseComponent(componentDefinition.type)}');

                      ref.read(paletteDragActiveProvider.notifier).state = true;
                      HapticFeedback.mediumImpact();
                    },
                    onDraggableCanceled: (velocity, offset) {
                      debugPrint('🎯 DRAG CANCELLED for ${componentDefinition.name} at $offset');
                      ref.read(paletteDragActiveProvider.notifier).state = false;
                    },
                    onDragEnd: (details) {
                      debugPrint('🎯 ===== DRAG ENDED =====');
                      debugPrint('🎯 Component: ${componentDefinition.name}');
                      debugPrint('🎯 Was accepted: ${details.wasAccepted}');
                      debugPrint('🎯 Velocity: ${details.velocity}');
                      if (details.wasAccepted) {
                        debugPrint('🎯 ✅ Drag completed successfully');
                      } else {
                        debugPrint('🎯 ❌ Drag was cancelled or rejected');
                      }

                      if (ref.read(paletteDragActiveProvider)) {
                        ref.read(paletteDragActiveProvider.notifier).state = false;
                      }
                    },
                    child: GestureDetector(
                      onTap: () {
                        debugPrint('🎯 TAP detected for ${componentDefinition.name}');
                        paletteNotifier.selectComponent(componentDefinition.type);
                        paletteNotifier.startPlacingComponent(componentDefinition.type);
                      },
                      child: _buildChip(
                        componentDefinition.name,
                        componentDefinition.type,
                        background: isSelected ? Colors.blue[200] : Colors.grey[300],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String name, String type, {Color? background}) {
    final icon = _getComponentIcon(type);
    return Chip(
      label: Text(name),
      backgroundColor: background,
      avatar: Icon(icon),
    );
  }

  IconData _getComponentIcon(String componentType) {
    final typeEnum = _stringToComponentType(componentType);
    return _getIconForComponentType(typeEnum);
  }

  ComponentType? _stringToComponentType(String typeString) {
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
        return null;
    }
  }

  IconData _getIconForComponentType(ComponentType? type) {
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
        return Icons.help_outline; // safer fallback
    }
  }
}
