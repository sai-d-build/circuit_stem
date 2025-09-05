import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/core/services/drag_service.dart';

class HorizontalComponentPalette extends ConsumerWidget {
  final String levelId;

  const HorizontalComponentPalette({super.key, required this.levelId});

  static const double _paletteHeight = 120;
  static const double _chipPadding = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paletteState = ref.watch(paletteStateProvider(levelId));
    final paletteNotifier = ref.read(paletteStateProvider(levelId).notifier);

    // Add comprehensive debug logging for palette state
    debugPrint('🎨 ===== HORIZONTAL PALETTE BUILD =====');
    debugPrint('🎨 Level ID: $levelId');
    debugPrint('🎨 Available components count: ${paletteState.availableComponents.length}');
    debugPrint('🎨 Filtered components count: ${paletteState.filteredComponents.length}');
    debugPrint('🎨 Inventory count: ${paletteState.inventory.length}');
    debugPrint('🎨 Inventory items: ${paletteState.inventory.keys.toList()}');
    debugPrint('🎨 Selected component: ${paletteState.selectedComponentType}');
    debugPrint('🎨 Is placing component: ${paletteState.isPlacingComponent}');
    debugPrint('🎨 Placing component type: ${paletteState.placingComponentType}');

    if (paletteState.filteredComponents.isEmpty) {
      debugPrint('🎨 ❌ WARNING - No filtered components!');
    } else {
      debugPrint('🎨 📋 Filtered components:');
      for (final component in paletteState.filteredComponents) {
        final inventory = paletteState.inventory[component.type];
        final canUse = inventory?.canUse ?? false;
        debugPrint('🎨   - ${component.name} (${component.type}) - cost: ${component.cost}, unlocked: ${component.isUnlocked}, canUse: $canUse, available: ${inventory?.available ?? 0}');
      }
    }
    debugPrint('🎨 ===== END PALETTE BUILD =====');

    return Container(
      height: _paletteHeight,
      color: Colors.green.shade200,
      child: Column(
        children: [
          // Instruction text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.blue[50],
            child: Row(
              children: [
                Icon(Icons.touch_app, size: 16, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tap to select a component, then drag it onto the grid',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main palette
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: paletteState.filteredComponents.length,
              itemBuilder: (context, index) {
                final componentDefinition = paletteState.filteredComponents[index];
                final isSelected = paletteState.selectedComponentType == componentDefinition.type;
                final dragData = ComponentDragData.fromPaletteComponentDefinition(componentDefinition);

                debugPrint(
                    '🎨 Building draggable for ${componentDefinition.name} (type: ${componentDefinition.type})');

                // Enhanced logging for component building
                final inventory = paletteState.inventory[componentDefinition.type];
                final canUse = inventory?.canUse ?? false;
                final isExhausted = inventory?.isExhausted ?? false;

                debugPrint('🎨 Building component: ${componentDefinition.name} (${componentDefinition.type})');
                debugPrint('🎨   - Is selected: $isSelected');
                debugPrint('🎨   - Can use: $canUse');
                debugPrint('🎨   - Is exhausted: $isExhausted');
                debugPrint('🎨   - Available count: ${inventory?.available ?? 0}');
                debugPrint('🎨   - Will be draggable: ${isSelected && canUse && !isExhausted}');

                return Padding(
                  padding: const EdgeInsets.all(_chipPadding),
                  child: isSelected && canUse && !isExhausted
                      ? Draggable<ComponentDragData>(
                          data: dragData,
                          feedback: ComponentDragFeedback(dragData: dragData),
                          childWhenDragging: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: Colors.green,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Opacity(
                              opacity: 0.7,
                              child: _buildChip(componentDefinition.name, componentDefinition.type,
                                  background: Colors.green[100]),
                            ),
                          ),
                          onDragStarted: () {
                            debugPrint('🎯 ===== DRAG STARTED =====');
                            debugPrint('🎯 Component: ${componentDefinition.name} (type: ${componentDefinition.type})');
                            debugPrint('🎯 DragData - type: ${dragData.componentType}, name: ${dragData.componentName}, cost: ${dragData.cost}');
                            debugPrint('🎯 Available in inventory: ${paletteState.canUseComponent(componentDefinition.type)}');
                            debugPrint('🎯 Inventory state: available=${inventory?.available}, total=${inventory?.total}, used=${inventory?.used}');

                            // Auto-select component when dragging starts
                            if (!isSelected) {
                              debugPrint('🎯 Auto-selecting component for drag: ${componentDefinition.name}');
                              paletteNotifier.selectComponent(componentDefinition.type);
                            }

                            // Use centralized DragService
                            DragService().controller.startDrag(dragData, DragType.component, Offset.zero); // Position will be updated by canvas
                            ref.read(paletteDragActiveProvider.notifier).state = true;
                            HapticFeedback.mediumImpact();

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Dragging ${componentDefinition.name}...'),
                                duration: const Duration(milliseconds: 500),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          onDraggableCanceled: (velocity, offset) {
                            debugPrint('🎯 ❌ DRAG CANCELLED for ${componentDefinition.name} at $offset');
                            debugPrint('🎯 Cancellation reason: velocity=$velocity');

                            // Use centralized DragService
                            DragService().cancelDrag(position: offset);
                            ref.read(paletteDragActiveProvider.notifier).state = false;
                          },
                          onDragEnd: (details) {
                            debugPrint('🎯 ===== DRAG ENDED =====');
                            debugPrint('🎯 Component: ${componentDefinition.name}');
                            debugPrint('🎯 Was accepted: ${details.wasAccepted}');
                            debugPrint('🎯 Velocity: ${details.velocity}');
                            debugPrint('🎯 Offset: ${details.offset}');
                            if (details.wasAccepted) {
                              debugPrint('🎯 ✅ Drag completed successfully - component should be placed');
                            } else {
                              debugPrint('🎯 ❌ Drag was cancelled or rejected - checking canvas acceptance');
                            }

                            // For now, keep the palette notifier update - will be handled by canvas
                            if (ref.read(paletteDragActiveProvider)) {
                              ref.read(paletteDragActiveProvider.notifier).state = false;
                            }
                          },
                          child: GestureDetector(
                            onTap: () {
                              debugPrint('🎯 👆 TAP detected for ${componentDefinition.name} (selected: $isSelected)');
                              // If already selected, start placement mode
                              if (isSelected) {
                                debugPrint('🎯 🔄 Starting placement mode for ${componentDefinition.name}');
                                paletteNotifier.startPlacingComponent(componentDefinition.type);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Tap on grid to place ${componentDefinition.name}'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              } else {
                                debugPrint('🎯 🎯 Selecting ${componentDefinition.name} for dragging');
                                paletteNotifier.selectComponent(componentDefinition.type);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${componentDefinition.name} selected - drag onto grid or tap again for placement mode'),
                                    duration: const Duration(seconds: 2),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              }
                            },
                            child: _buildChip(
                              componentDefinition.name,
                              componentDefinition.type,
                              background: isSelected ? Colors.blue[200] : Colors.green.shade300,
                              isSelected: isSelected,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            debugPrint('🎯 👆 TAP detected for ${componentDefinition.name} (not draggable)');
                            debugPrint('🎯 Reason not draggable: selected=$isSelected, canUse=$canUse, exhausted=$isExhausted');
                            paletteNotifier.selectComponent(componentDefinition.type);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${componentDefinition.name} selected - now drag it onto the grid!'),
                                duration: const Duration(seconds: 2),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: _buildChip(
                            componentDefinition.name,
                            componentDefinition.type,
                            background: isSelected ? Colors.blue[200] : Colors.green.shade300,
                            isSelected: isSelected,
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

  Widget _buildChip(String name, String type, {Color? background, bool isSelected = false}) {
    final icon = _getComponentIcon(type);
    final tooltipMessage = isSelected
        ? 'Drag $name onto the circuit grid, or tap again to enter placement mode'
        : 'Tap to select $name for dragging or placement';

    return Tooltip(
      message: tooltipMessage,
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(name),
            const SizedBox(width: 4),
            Icon(
              isSelected ? Icons.drag_handle : Icons.touch_app,
              size: 12,
              color: isSelected ? Colors.blue[700] : Colors.green.shade600,
            ),
          ],
        ),
        backgroundColor: background,
        avatar: Icon(icon),
        side: isSelected ? const BorderSide(color: Colors.blue, width: 1) : null,
      ),
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
