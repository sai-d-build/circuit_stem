import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart' as providers_v3;
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart';

class HorizontalComponentPalette extends ConsumerWidget {
  final String levelId;

  const HorizontalComponentPalette({super.key, required this.levelId});

  static const double _paletteHeight = 120;
  static const double _chipPadding = 8.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('🎨 HORIZONTAL PALETTE BUILD CALLED for level: $levelId');
    final paletteState = ref.watch(paletteStateProvider(levelId));
    final paletteNotifier = ref.read(paletteStateProvider(levelId).notifier);

    // Add comprehensive debug logging for palette state
    StructuredLogger.info('🎨 ===== PALETTE STATE ANALYSIS =====', context: {
      'levelId': levelId,
      'availableComponentsCount': paletteState.availableComponents.length,
      'filteredComponentsCount': paletteState.filteredComponents.length,
      'inventoryCount': paletteState.inventory.length,
      'inventoryItems': paletteState.inventory.keys.toList(),
      'selectedComponentType': paletteState.selectedComponentType,
      'isPlacingComponent': paletteState.isPlacingComponent,
      'placingComponentType': paletteState.placingComponentType,
    });

    // Add simple debug prints for immediate visibility
    print('🎨 PALETTE DEBUG: Available components: ${paletteState.availableComponents.length}');
    print('🎨 PALETTE DEBUG: Filtered components: ${paletteState.filteredComponents.length}');
    print('🎨 PALETTE DEBUG: Inventory items: ${paletteState.inventory.keys.toList()}');
    print('🎨 PALETTE DEBUG: Available component types: ${paletteState.availableComponents.map((c) => c.type).toList()}');
    print('🎨 PALETTE DEBUG: Filtered component types: ${paletteState.filteredComponents.map((c) => c.type).toList()}');

    // Log detailed component availability
    StructuredLogger.info('🎨 ===== COMPONENT AVAILABILITY =====', context: {
      'levelId': levelId,
      'totalComponentsInLevel': paletteState.inventory.values.fold(0, (sum, inv) => sum + inv.total),
      'availableComponentsInLevel': paletteState.inventory.values.fold(0, (sum, inv) => sum + inv.available),
      'usedComponentsInLevel': paletteState.inventory.values.fold(0, (sum, inv) => sum + inv.used),
      'componentDetails': paletteState.inventory.entries.map((entry) {
        final type = entry.key;
        final inv = entry.value;
        return {
          'type': type,
          'available': inv.available,
          'total': inv.total,
          'used': inv.used,
          'canUse': inv.canUse,
          'isExhausted': inv.isExhausted,
          'usagePercentage': inv.usagePercentage,
        };
      }).toList(),
    });

    if (paletteState.filteredComponents.isEmpty) {
      StructuredLogger.warning('No filtered components available', context: {
        'levelId': levelId,
        'availableComponentsCount': paletteState.availableComponents.length,
        'inventoryCount': paletteState.inventory.length,
      });
    } else {
      StructuredLogger.trace('Filtered components details', context: {
        'levelId': levelId,
        'filteredComponents': paletteState.filteredComponents.map((c) {
          final inventory = paletteState.inventory[c.type];
          final canUse = inventory?.canUse ?? false;
          return {
            'name': c.name,
            'type': c.type,
            'cost': c.cost,
            'unlocked': c.isUnlocked,
            'canUse': canUse,
            'available': inventory?.available ?? 0,
          };
        }).toList(),
      });
    }

    return Container(
      height: _paletteHeight,
      color: Colors.green.shade200,
      child: Column(
        children: [
          // Instruction text with component counts
          Consumer(
            builder: (context, ref, child) {
              final paletteState = ref.watch(paletteStateProvider(levelId));
              final totalComponents = paletteState.inventory.values.fold<int>(
                0,
                (sum, inventory) => sum + inventory.total,
              );
              final usedComponents = paletteState.inventory.values.fold<int>(
                0,
                (sum, inventory) => sum + (inventory.total - inventory.available),
              );

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
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
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!, width: 1),
                      ),
                      child: Text(
                        'Components Used: $usedComponents / $totalComponents',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue[800],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          // Main palette
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: paletteState.filteredComponents.length,
              itemBuilder: (context, index) {
                final componentDefinition = paletteState.filteredComponents[index];
                print('🎨 BUILDING COMPONENT CHIP at index $index for ${componentDefinition.name} (${componentDefinition.type})');
                final isSelected = paletteState.selectedComponentType == componentDefinition.type;
                final dragData = ComponentDragData.fromPaletteComponentDefinition(componentDefinition);

                StructuredLogger.trace('Building draggable component', context: {
                  'componentName': componentDefinition.name,
                  'componentType': componentDefinition.type,
                  'levelId': levelId,
                });

                // Enhanced logging for component building
                final inventory = paletteState.inventory[componentDefinition.type];
                final canUse = inventory?.canUse ?? false;
                final isExhausted = inventory?.isExhausted ?? false;

                StructuredLogger.debug('Component draggability analysis', context: {
                  'componentName': componentDefinition.name,
                  'componentType': componentDefinition.type,
                  'isSelected': isSelected,
                  'canUse': canUse,
                  'isExhausted': isExhausted,
                  'availableCount': inventory?.available ?? 0,
                  'willBeDraggable': isSelected && canUse && !isExhausted,
                  'levelId': levelId,
                });

                 // 🔧 RCA: Add detailed debugging for draggability logic
                 if (!isSelected) {
                   StructuredLogger.debug('Component not draggable - not selected', context: {
                     'componentName': componentDefinition.name,
                     'componentType': componentDefinition.type,
                     'levelId': levelId,
                   });
                 } else if (!canUse) {
                   StructuredLogger.warning('Component not draggable - inventory issue', context: {
                     'componentName': componentDefinition.name,
                     'componentType': componentDefinition.type,
                     'available': inventory?.available ?? 0,
                     'levelId': levelId,
                   });
                 } else if (isExhausted) {
                   StructuredLogger.debug('Component not draggable - exhausted', context: {
                     'componentName': componentDefinition.name,
                     'componentType': componentDefinition.type,
                     'levelId': levelId,
                   });
                 } else {
                   StructuredLogger.debug('Component should be draggable - all conditions met', context: {
                     'componentName': componentDefinition.name,
                     'componentType': componentDefinition.type,
                     'levelId': levelId,
                   });
                 }

                // 🔧 DEBUG: Detailed draggability analysis
                final shouldBeDraggable = isSelected && canUse && !isExhausted;
                print('🎨 DRAGGABILITY CHECK for ${componentDefinition.name}:');
                print('🎨   - isSelected: $isSelected');
                print('🎨   - canUse: $canUse');
                print('🎨   - isExhausted: $isExhausted');
                print('🎨   - available: ${inventory?.available ?? 0}');
                print('🎨   - total: ${inventory?.total ?? 0}');
                print('🎨   - shouldBeDraggable: $shouldBeDraggable');

                return Padding(
                  padding: const EdgeInsets.all(_chipPadding),
                  child: shouldBeDraggable
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
                              child: _buildChip(
                                componentDefinition.name,
                                componentDefinition.type,
                                background: Colors.green[100],
                                canUse: canUse,
                                available: inventory?.available ?? 0,
                                total: inventory?.total ?? 0,
                              ),
                            ),
                          ),
                          onDragStarted: () {
                            print('🎯 ===== DRAG STARTED ===== for ${componentDefinition.name}');
                            // Simple, clear inventory logging that user expects
                            StructuredLogger.info('🎯 ===== DRAG STARTED =====', context: {
                              'component': componentDefinition.name,
                              'type': componentDefinition.type.toString(),
                              'levelId': levelId,
                            });

                            // Explicit inventory state logging
                            StructuredLogger.info('🎯 DRAG START - INVENTORY STATE', context: {
                              'componentType': componentDefinition.type,
                              'availableBeforeDrag': inventory?.available ?? 0,
                              'total': inventory?.total ?? 0,
                              'usedBeforeDrag': inventory?.used ?? 0,
                              'canUse': inventory?.canUse ?? false,
                              'levelId': levelId,
                            });

                            // Log overall level inventory
                            final totalAvailable = paletteState.inventory.values.fold<int>(
                              0, (sum, inv) => sum + inv.available);
                            final totalUsed = paletteState.inventory.values.fold<int>(
                              0, (sum, inv) => sum + inv.used);

                            StructuredLogger.info('🎯 DRAG START - LEVEL INVENTORY SUMMARY', context: {
                              'totalAvailable': totalAvailable,
                              'totalUsed': totalUsed,
                              'totalCapacity': paletteState.inventory.values.fold(0, (sum, inv) => sum + inv.total),
                              'componentBreakdown': paletteState.inventory.entries.map((e) =>
                                '${e.key}: ${e.value.available}/${e.value.total} (${e.value.used} used)').toList(),
                              'levelId': levelId,
                            });

                            // More detailed logging
                            StructuredLogger.info('🎯 DRAG START DETAILS', context: {
                              'component': componentDefinition.name,
                              'type': componentDefinition.type.toString(),
                              'dragDataType': dragData.componentType.toString(),
                              'dragDataName': dragData.componentName,
                              'cost': dragData.cost,
                              'availableInInventory': paletteState.canUseComponent(componentDefinition.type),
                              'inventoryAvailable': inventory?.available,
                              'inventoryTotal': inventory?.total,
                              'inventoryUsed': inventory?.used,
                              'totalComponentsInPalette': paletteState.filteredComponents.length,
                              'levelId': levelId,
                              'timestamp': DateTime.now().millisecondsSinceEpoch,
                            });

                            // Log current game state
                            final gameState = ref.read(providers_v3.enhancedGameStateNotifierProvider);
                            StructuredLogger.info('🎯 DRAG START - GAME STATE', context: {
                              'gridComponentsCount': gameState.grid.components.length,
                              'gridWidth': gameState.grid.cols,
                              'gridHeight': gameState.grid.rows,
                              'placedComponents': gameState.grid.components.values.map((c) => {
                                'id': c.id,
                                'type': c.type.toString(),
                                'position': '${c.row},${c.col}',
                              }).toList(),
                              'levelId': levelId,
                            });

                            // Auto-select component when dragging starts
                            if (!isSelected) {
                              StructuredLogger.info('🎯 AUTO-SELECTING COMPONENT', context: {
                                'component': componentDefinition.name,
                                'wasSelected': isSelected,
                                'levelId': levelId,
                              });
                              paletteNotifier.selectComponent(componentDefinition.type);
                            }

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

                            StructuredLogger.info('🎯 DRAG START COMPLETED', context: {
                              'component': componentDefinition.name,
                              'dragActive': true,
                              'levelId': levelId,
                            });
                          },
                          onDraggableCanceled: (velocity, offset) {
                            StructuredLogger.warning('Component drag cancelled', context: {
                              'componentName': componentDefinition.name,
                              'componentType': componentDefinition.type,
                              'velocity': velocity.toString(),
                              'offset': offset.toString(),
                              'levelId': levelId,
                            });

                            ref.read(paletteDragActiveProvider.notifier).state = false;
                          },
                          onDragEnd: (details) {
                            StructuredLogger.info('Component drag completed', context: {
                              'componentName': componentDefinition.name,
                              'componentType': componentDefinition.type,
                              'wasAccepted': details.wasAccepted,
                              'velocity': details.velocity.toString(),
                              'offset': details.offset.toString(),
                              'levelId': levelId,
                            });

                            if (details.wasAccepted) {
                              StructuredLogger.info('Component drag accepted by canvas', context: {
                                'componentName': componentDefinition.name,
                                'componentType': componentDefinition.type,
                                'levelId': levelId,
                              });
                            } else {
                              StructuredLogger.warning('Component drag rejected by canvas', context: {
                                'componentName': componentDefinition.name,
                                'componentType': componentDefinition.type,
                                'levelId': levelId,
                              });
                            }

                            // Reset drag state
                            ref.read(paletteDragActiveProvider.notifier).state = false;
                          },
                          child: GestureDetector(
                            onTap: () {
                              print('🎨 COMPONENT TAPPED: ${componentDefinition.name} (was selected: $isSelected)');
                              StructuredLogger.info('Component tap detected', context: {
                                'componentName': componentDefinition.name,
                                'componentType': componentDefinition.type,
                                'wasSelected': isSelected,
                                'levelId': levelId,
                              });

                              // If already selected, start placement mode
                              if (isSelected) {
                                StructuredLogger.info('Starting placement mode for component', context: {
                                  'componentName': componentDefinition.name,
                                  'componentType': componentDefinition.type,
                                  'levelId': levelId,
                                });
                                paletteNotifier.startPlacingComponent(componentDefinition.type);
                              } else {
                                StructuredLogger.info('Selecting component for dragging', context: {
                                  'componentName': componentDefinition.name,
                                  'componentType': componentDefinition.type,
                                  'levelId': levelId,
                                });
                                paletteNotifier.selectComponent(componentDefinition.type);
                              }
                            },
                            child: _buildChip(
                              componentDefinition.name,
                              componentDefinition.type,
                              background: isSelected ? Colors.blue[200] : Colors.green.shade300,
                              isSelected: isSelected,
                              canUse: canUse,
                              available: inventory?.available ?? 0,
                              total: inventory?.total ?? 0,
                            ),
                          ),
                        )
                      : GestureDetector(
                        onTap: () {
                          print('🎨 NON-DRAGGABLE COMPONENT TAPPED: ${componentDefinition.name} (reason: selected=$isSelected, canUse=$canUse, exhausted=$isExhausted)');
                          StructuredLogger.info('Non-draggable component tap detected', context: {
                            'componentName': componentDefinition.name,
                            'componentType': componentDefinition.type,
                            'isSelected': isSelected,
                            'canUse': canUse,
                            'isExhausted': isExhausted,
                            'levelId': levelId,
                          });
                          paletteNotifier.selectComponent(componentDefinition.type);
                        },
                          child: _buildChip(
                            componentDefinition.name,
                            componentDefinition.type,
                            background: isSelected ? Colors.blue[200] : Colors.green.shade300,
                            isSelected: isSelected,
                            canUse: canUse,
                            available: inventory?.available ?? 0,
                            total: inventory?.total ?? 0,
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

  Widget _buildChip(String name, String type, {Color? background, bool isSelected = false, bool canUse = true, int available = 0, int total = 0}) {
    final icon = _getComponentIcon(type);
    final isDraggable = isSelected && canUse && available > 0;

    // Enhanced tooltip with inventory info
    final tooltipMessage = isDraggable
        ? 'DRAGGABLE: $name (${available}/${total} available) - Drag onto grid'
        : !isSelected
            ? 'Tap to select $name (${available}/${total} available)'
            : !canUse
                ? 'NOT AVAILABLE: $name (${available}/${total} available)'
                : available == 0
                    ? 'EXHAUSTED: $name (0/${total} available)'
                    : 'Tap again to enter placement mode for $name';

    return Tooltip(
      message: tooltipMessage,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isDraggable
                ? Colors.green
                : isSelected
                    ? Colors.blue
                    : available == 0
                        ? Colors.red
                        : Colors.grey,
            width: isDraggable ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16),
          color: isDraggable
              ? Colors.green[100]
              : isSelected
                  ? Colors.blue[100]
                  : available == 0
                      ? Colors.red[50]
                      : background ?? Colors.grey[100],
        ),
        child: Chip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                name,
                style: TextStyle(
                  color: isDraggable
                      ? Colors.green[800]
                      : available == 0
                          ? Colors.red[800]
                          : Colors.black,
                  fontWeight: isDraggable ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(width: 4),
              // Inventory count display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: available == 0 ? Colors.red[200] : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: available == 0 ? Colors.red : Colors.grey[400]!,
                    width: 1,
                  ),
                ),
                child: Text(
                  '${available}/${total}',
                  style: TextStyle(
                    fontSize: 10,
                    color: available == 0 ? Colors.red[800] : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isDraggable
                    ? Icons.drag_indicator
                    : isSelected
                        ? Icons.touch_app
                        : available == 0
                            ? Icons.block
                            : Icons.radio_button_unchecked,
                size: 12,
                color: isDraggable
                    ? Colors.green[700]
                    : isSelected
                        ? Colors.blue[700]
                        : available == 0
                            ? Colors.red[700]
                            : Colors.grey[600],
              ),
            ],
          ),
          backgroundColor: Colors.transparent, // Use container background instead
          avatar: Icon(
            icon,
            color: isDraggable
                ? Colors.green[700]
                : available == 0
                    ? Colors.red[700]
                    : Colors.grey[700],
          ),
          side: BorderSide.none, // Remove default chip border
        ),
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
