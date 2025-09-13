import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/models/drag_models.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart'
    as palette_state;

// Performance optimization: Cached component filtering service
class OptimizedComponentFilter {
  static final Map<String, _FilterCache> _cache = {};

  static List<palette_state.ComponentDefinition> getFilteredComponents(
    String levelId,
    List<palette_state.ComponentDefinition> availableComponents,
    Map<String, palette_state.ComponentInventory> inventory,
    String searchQuery,
    Set<String> activeFilters,
  ) {
    final cacheKey = _generateCacheKey(
        levelId, availableComponents, inventory, searchQuery, activeFilters);

    // Check cache first
    if (_cache.containsKey(cacheKey)) {
      final cached = _cache[cacheKey]!;
      if (!cached.isExpired) {
        return cached.result;
      }
    }

    // Perform filtering
    final result = _performFiltering(
        availableComponents, inventory, searchQuery, activeFilters);

    // Cache result
    _cache[cacheKey] = _FilterCache(result);

    // Clean up old cache entries (keep last 10)
    if (_cache.length > 10) {
      final keysToRemove = _cache.keys.take(_cache.length - 10).toList();
      for (final key in keysToRemove) {
        _cache.remove(key);
      }
    }

    return result;
  }

  static String _generateCacheKey(
    String levelId,
    List<palette_state.ComponentDefinition> availableComponents,
    Map<String, palette_state.ComponentInventory> inventory,
    String searchQuery,
    Set<String> activeFilters,
  ) {
    // Generate a stable cache key based on relevant data
    final componentsHash =
        availableComponents.map((c) => '${c.type}:${c.isUnlocked}').join(',');
    final inventoryHash = inventory.entries
        .map((e) => '${e.key}:${e.value.available}:${e.value.canUse}')
        .join(',');
    final filtersHash = activeFilters.join(',');
    return '$levelId|$componentsHash|$inventoryHash|$searchQuery|$filtersHash';
  }

  static List<palette_state.ComponentDefinition> _performFiltering(
    List<palette_state.ComponentDefinition> availableComponents,
    Map<String, palette_state.ComponentInventory> inventory,
    String searchQuery,
    Set<String> activeFilters,
  ) {
    return availableComponents.where((component) {
      // Unlock filter
      if (!component.isUnlocked) return false;

      // Inventory filter
      final componentInventory = inventory[component.type];
      if (componentInventory == null || !componentInventory.canUse) {
        return false;
      }

      // Search filter
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        if (!component.name.toLowerCase().contains(query) &&
            !component.type.toLowerCase().contains(query)) {
          return false;
        }
      }

      // Active filters
      if (activeFilters.isNotEmpty) {
        // Apply any active filters (basic implementation)
        for (final filter in activeFilters) {
          if (!component.type.contains(filter)) return false;
        }
      }

      return true;
    }).toList();
  }
}

class _FilterCache {
  final List<palette_state.ComponentDefinition> result;
  final DateTime _createdAt;

  _FilterCache(this.result) : _createdAt = DateTime.now();

  bool get isExpired =>
      DateTime.now().difference(_createdAt).inSeconds > 5; // 5 second cache
}

// ✅ CLEAN ARCHITECTURE: Reuse Palette Service
class PaletteService {
  final dynamic paletteNotifier;

  PaletteService(this.paletteNotifier);

  void updateSearchQuery(String query) =>
      paletteNotifier.updateSearchQuery(query);
  void clearSearch() => paletteNotifier.clearSearch();
  void addFilter(String filter) => paletteNotifier.addFilter(filter);
  void removeFilter(String filter) => paletteNotifier.removeFilter(filter);
  void clearFilters() => paletteNotifier.clearFilters();
  bool canUseComponent(String componentType) =>
      paletteNotifier.canUseComponent(componentType);
  void selectComponent(String componentType) =>
      paletteNotifier.selectComponent(componentType);
  void startPlacingComponent(String componentType) =>
      paletteNotifier.startPlacingComponent(componentType);
}

final paletteServiceProvider =
    Provider.family<PaletteService, String>((ref, levelId) {
  final paletteNotifier =
      ref.watch(palette_state.paletteStateProvider(levelId).notifier);
  return PaletteService(paletteNotifier);
});

class HorizontalComponentPalette extends ConsumerWidget {
  final String levelId;

  const HorizontalComponentPalette({super.key, required this.levelId});

  static const double _paletteHeight = 120;
  static const double _chipPadding = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    StructuredLogger.debug(
        '🎨 HORIZONTAL PALETTE BUILD CALLED for level: $levelId',
        context: {
          'levelId': levelId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
    final paletteState = ref.watch(palette_state.paletteStateProvider(levelId));
    final paletteService = ref.watch(paletteServiceProvider(levelId));
    // Note: paletteNotifier variable removed - using helper methods instead

    // Performance optimization: Minimize logging in hot paths
    // Only log essential information and reduce frequency
    if (paletteState.filteredComponents.isEmpty &&
        paletteState.availableComponents.isNotEmpty) {
      StructuredLogger.warning('🎨 No filtered components available', context: {
        'levelId': levelId,
        'availableComponentsCount': paletteState.availableComponents.length,
        'inventoryCount': paletteState.inventory.length,
      });
    }

    // Performance optimization: Remove redundant filtering operations
    // The filteredComponents getter already handles all filtering logic

    return Container(
      height: _paletteHeight,
      color: Colors.green.shade200,
      child: Column(
        children: [
          // Instruction text with component counts
          Consumer(
            builder: (context, ref, child) {
              final paletteState =
                  ref.watch(palette_state.paletteStateProvider(levelId));
              final totalComponents = paletteState.inventory.values.fold<int>(
                0,
                (sum, inventory) => sum + inventory.total,
              );
              final usedComponents = paletteState.inventory.values.fold<int>(
                0,
                (sum, inventory) =>
                    sum + (inventory.total - inventory.available),
              );

              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.blue[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.touch_app,
                            size: 16, color: Colors.blue[700]),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
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
                final componentDefinition =
                    paletteState.filteredComponents[index];
                final isSelected = paletteState.selectedComponentType ==
                    componentDefinition.type;
                final dragData =
                    ComponentDragData.fromPaletteComponentDefinition(
                        componentDefinition);

                // Performance optimization: Minimize logging in hot paths
                final inventory =
                    paletteState.inventory[componentDefinition.type];
                final canUse = inventory?.canUse ?? false;
                final isExhausted = inventory?.isExhausted ?? false;
                final shouldBeDraggable = isSelected && canUse && !isExhausted;

                // Only log warnings for problematic states, not every component
                if (!canUse && inventory != null && inventory.available > 0) {
                  StructuredLogger.debug(
                      'Component not draggable - inventory issue',
                      context: {
                        'componentName': componentDefinition.name,
                        'componentType': componentDefinition.type,
                        'available': inventory.available,
                        'levelId': levelId,
                      });
                }

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
                            // Performance optimization: Consolidate drag start logging
                            StructuredLogger.info('🎯 DRAG STARTED', context: {
                              'component': componentDefinition.name,
                              'type': componentDefinition.type.toString(),
                              'available': inventory?.available ?? 0,
                              'levelId': levelId,
                            });

                            // Auto-select component when dragging starts
                            if (!isSelected) {
                              paletteService
                                  .selectComponent(componentDefinition.type);
                            }

                            ref.read(paletteDragActiveProvider.notifier).state =
                                true;
                            HapticFeedback.mediumImpact();

                            // Show success message
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'Dragging ${componentDefinition.name}...'),
                                duration: const Duration(milliseconds: 500),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          onDraggableCanceled: (velocity, offset) {
                            // Performance optimization: Minimal logging for cancelled drags
                            StructuredLogger.debug('Component drag cancelled',
                                context: {
                                  'component': componentDefinition.name,
                                  'levelId': levelId,
                                });
                            ref.read(paletteDragActiveProvider.notifier).state =
                                false;
                          },
                          onDragEnd: (details) {
                            // Performance optimization: Only log important drag outcomes
                            if (details.wasAccepted) {
                              StructuredLogger.info('Component drag accepted',
                                  context: {
                                    'component': componentDefinition.name,
                                    'levelId': levelId,
                                  });
                            } else {
                              StructuredLogger.debug('Component drag rejected',
                                  context: {
                                    'component': componentDefinition.name,
                                    'levelId': levelId,
                                  });
                            }
                            ref.read(paletteDragActiveProvider.notifier).state =
                                false;
                          },
                          child: GestureDetector(
                            onTap: () {
                              // Performance optimization: Minimal logging for tap events
                              if (isSelected) {
                                paletteService.startPlacingComponent(
                                    componentDefinition.type);
                              } else {
                                paletteService
                                    .selectComponent(componentDefinition.type);
                              }
                            },
                            child: _buildChip(
                              componentDefinition.name,
                              componentDefinition.type,
                              background: isSelected
                                  ? Colors.blue[200]
                                  : Colors.green.shade300,
                              isSelected: isSelected,
                              canUse: canUse,
                              available: inventory?.available ?? 0,
                              total: inventory?.total ?? 0,
                            ),
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            // Performance optimization: Minimal logging for non-draggable taps
                            paletteService
                                .selectComponent(componentDefinition.type);
                          },
                          child: _buildChip(
                            componentDefinition.name,
                            componentDefinition.type,
                            background: isSelected
                                ? Colors.blue[200]
                                : Colors.green.shade300,
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

  Widget _buildChip(String name, String type,
      {Color? background,
      bool isSelected = false,
      bool canUse = true,
      int available = 0,
      int total = 0}) {
    final icon = _getComponentIcon(type);
    final isDraggable = isSelected && canUse && available > 0;

    // Enhanced tooltip with inventory info
    final tooltipMessage = isDraggable
        ? 'DRAGGABLE: $name ($available/$total available) - Drag onto grid'
        : !isSelected
            ? 'Tap to select $name ($available/$total available)'
            : !canUse
                ? 'NOT AVAILABLE: $name ($available/$total available)'
                : available == 0
                    ? 'EXHAUSTED: $name (0/$total available)'
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
                  '$available/$total',
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
          backgroundColor:
              Colors.transparent, // Use container background instead
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
