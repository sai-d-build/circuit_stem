import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

import '../../core/persistence/storage_service.dart';

/// Standalone function to get tutorial default quantities
/// This is used by both the PaletteState class and inventory generation functions
Map<String, int> _getTutorialDefaultsMap() {
  return {
    'resistor': 2, // Essential for basic circuits
    'switch': 1, // Important control component
    'capacitor': 1, // Advanced but educational
    'inductor': 1, // Advanced component for learning
    'transistor': 1, // Semiconductor learning
  };
}

class ComponentDefinition {
  final String type;
  final String name;
  final String description;
  final String iconPath;
  final Map<String, dynamic> defaultProperties;
  final int cost;
  final bool isUnlocked;
  final List<String> requiredLevels;
  final bool isDraggable;

  const ComponentDefinition({
    required this.type,
    required this.name,
    required this.description,
    required this.iconPath,
    this.defaultProperties = const {},
    this.cost = 1,
    this.isUnlocked = true,
    this.requiredLevels = const [],
    this.isDraggable = true, // Default to draggable for backward compatibility
  });

  ComponentDefinition copyWith({
    String? type,
    String? name,
    String? description,
    String? iconPath,
    Map<String, dynamic>? defaultProperties,
    int? cost,
    bool? isUnlocked,
    List<String>? requiredLevels,
  }) {
    return ComponentDefinition(
      type: type ?? this.type,
      name: name ?? this.name,
      description: description ?? this.description,
      iconPath: iconPath ?? this.iconPath,
      defaultProperties: defaultProperties ?? this.defaultProperties,
      cost: cost ?? this.cost,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      requiredLevels: requiredLevels ?? this.requiredLevels,
    );
  }

  // JSON serialization methods
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'defaultProperties': defaultProperties,
      'cost': cost,
      'isUnlocked': isUnlocked,
      'requiredLevels': requiredLevels,
    };
  }

  factory ComponentDefinition.fromJson(Map<String, dynamic> json) {
    return ComponentDefinition(
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      iconPath: json['iconPath'] ?? '',
      defaultProperties:
          Map<String, dynamic>.from(json['defaultProperties'] ?? {}),
      cost: json['cost'] ?? 1,
      isUnlocked: json['isUnlocked'] ?? true,
      requiredLevels: List<String>.from(json['requiredLevels'] ?? []),
    );
  }
}

class ComponentInventory {
  final String componentType;
  final int available;
  final int total;
  final int used;

  const ComponentInventory({
    required this.componentType,
    required this.available,
    required this.total,
    this.used = 0,
  });

  ComponentInventory copyWith({
    String? componentType,
    int? available,
    int? total,
    int? used,
  }) {
    return ComponentInventory(
      componentType: componentType ?? this.componentType,
      available: available ?? this.available,
      total: total ?? this.total,
      used: used ?? this.used,
    );
  }

  bool get canUse => available > 0;
  bool get isExhausted => available == 0;
  double get usagePercentage => total > 0 ? used / total : 0.0;

  // JSON serialization methods
  Map<String, dynamic> toJson() {
    return {
      'componentType': componentType,
      'available': available,
      'total': total,
      'used': used,
    };
  }

  factory ComponentInventory.fromJson(Map<String, dynamic> json) {
    return ComponentInventory(
      componentType: json['componentType'] ?? '',
      available: json['available'] ?? 0,
      total: json['total'] ?? 0,
      used: json['used'] ?? 0,
    );
  }
}

class PaletteState {
  final List<ComponentDefinition> availableComponents;
  final Map<String, ComponentInventory> inventory;
  final String? selectedComponentType;
  final String searchQuery;
  final List<String> activeFilters;
  final bool isExpanded;
  final bool isAnimating;
  final List<String> recentlyUnlocked;
  final bool isPlacingComponent;
  final String? placingComponentType;

  const PaletteState({
    this.availableComponents = const [],
    this.inventory = const {},
    this.selectedComponentType,
    this.searchQuery = '',
    this.activeFilters = const [],
    this.isExpanded = true,
    this.isAnimating = false,
    this.recentlyUnlocked = const [],
    this.isPlacingComponent = false,
    this.placingComponentType,
  });

  PaletteState copyWith({
    List<ComponentDefinition>? availableComponents,
    Map<String, ComponentInventory>? inventory,
    String? selectedComponentType,
    String? searchQuery,
    List<String>? activeFilters,
    bool? isExpanded,
    bool? isAnimating,
    List<String>? recentlyUnlocked,
    bool? isPlacingComponent,
    String? placingComponentType,
  }) {
    return PaletteState(
      availableComponents: availableComponents ?? this.availableComponents,
      inventory: inventory ?? this.inventory,
      selectedComponentType:
          selectedComponentType ?? this.selectedComponentType,
      searchQuery: searchQuery ?? this.searchQuery,
      activeFilters: activeFilters ?? this.activeFilters,
      isExpanded: isExpanded ?? this.isExpanded,
      isAnimating: isAnimating ?? this.isAnimating,
      recentlyUnlocked: recentlyUnlocked ?? this.recentlyUnlocked,
      isPlacingComponent: isPlacingComponent ?? this.isPlacingComponent,
      placingComponentType: placingComponentType ?? this.placingComponentType,
    );
  }

  List<ComponentDefinition> get filteredComponents {
    // Only log main filtering info if debugFiltering flag is enabled
    if (StructuredLogger.debugFiltering) {
      StructuredLogger.filtering('🎨 ===== COMPONENT FILTERING START =====',
          context: {
            'totalAvailableComponents': availableComponents.length,
            'availableComponentTypes':
                availableComponents.map((c) => c.type).toList(),
            'availableComponentDetails': availableComponents
                .map((c) => '${c.type}:${c.isUnlocked}')
                .toList(),
            'inventoryItems': inventory.length,
            'inventoryKeys': inventory.keys.toList(),
            'inventoryDetails': inventory.entries
                .map((e) => '${e.key}:${e.value.available}/${e.value.total}')
                .toList(),
            'searchQuery': searchQuery,
            'activeFilters': activeFilters,
          });
    }

    // Add detailed step-by-step debug logs only if debugFilterDetails flag is enabled
    if (StructuredLogger.debugFilterDetails) {
      StructuredLogger.filtering('🎨 FILTER DETAILS: Total available',
          context: {
            'availableComponents': availableComponents.length,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });

      StructuredLogger.filtering('🎨 FILTER DETAILS: Available types',
          context: {
            'availableTypes': availableComponents.map((c) => c.type).toList(),
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });

      StructuredLogger.filtering('🎨 FILTER DETAILS: Inventory keys', context: {
        'inventoryKeys': inventory.keys.toList(),
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      StructuredLogger.filtering('🎨 FILTER DETAILS: Unlocked components',
          context: {
            'unlockedComponents':
                availableComponents.where((c) => c.isUnlocked).length,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
    }

    var filtered =
        availableComponents.where((component) => component.isUnlocked);

    if (StructuredLogger.debugFiltering) {
      StructuredLogger.filtering('🎨 After unlock filter', context: {
        'count': filtered.length,
        'components': filtered.map((c) => '${c.type}:${c.isUnlocked}').toList(),
        'filteredOut': availableComponents
            .where((c) => !c.isUnlocked)
            .map((c) => c.type)
            .toList(),
      });
    }

    // ENHANCED FILTERING: Show components that are either in inventory OR have tutorial defaults
    final beforeInventoryFilter = filtered.length;
    filtered = filtered.where((component) {
      final inInventory = inventory.containsKey(component.type);
      final hasTutorialDefault =
          _getTutorialDefaultQuantity(component.type) > 0;
      return inInventory || hasTutorialDefault;
    });

    if (StructuredLogger.debugFiltering) {
      StructuredLogger.filtering('🎨 After enhanced inventory filter',
          context: {
            'before': beforeInventoryFilter,
            'after': filtered.length,
            'components': filtered.map((c) => c.type).toList(),
            'componentsWithInventory': filtered
                .where((c) => inventory.containsKey(c.type))
                .map((c) => c.type)
                .toList(),
            'componentsWithTutorialDefaults': filtered
                .where((c) =>
                    !inventory.containsKey(c.type) &&
                    _getTutorialDefaultQuantity(c.type) > 0)
                .map((c) => c.type)
                .toList(),
            'missingFromInventory': availableComponents
                .where((c) =>
                    c.isUnlocked &&
                    !inventory.containsKey(c.type) &&
                    _getTutorialDefaultQuantity(c.type) == 0)
                .map((c) => '${c.type}:${c.isUnlocked}')
                .toList(),
            'inventoryLookupResults': availableComponents
                .where((c) => c.isUnlocked)
                .map((c) =>
                    '${c.type}:inventory=${inventory.containsKey(c.type)}:tutorial=${_getTutorialDefaultQuantity(c.type) > 0}')
                .toList(),
          });
    }

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final beforeSearch = filtered.length;
      filtered = filtered.where((component) =>
          component.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          component.description
              .toLowerCase()
              .contains(searchQuery.toLowerCase()) ||
          component.type.toLowerCase().contains(searchQuery.toLowerCase()));
      if (StructuredLogger.debugFilterDetails) {
        StructuredLogger.filtering('After search filter', context: {
          'before': beforeSearch,
          'after': filtered.length,
          'query': searchQuery,
        });
      }
    }

    // Apply category filters
    if (activeFilters.isNotEmpty) {
      final beforeCategory = filtered.length;
      filtered = filtered.where((component) => activeFilters
          .any((filter) => _componentMatchesFilter(component, filter)));
      if (StructuredLogger.debugFilterDetails) {
        StructuredLogger.filtering('After category filter', context: {
          'before': beforeCategory,
          'after': filtered.length,
          'filters': activeFilters,
        });
      }
    }

    final result = filtered.toList();

    if (StructuredLogger.debugFiltering) {
      StructuredLogger.filtering('Component filtering complete', context: {
        'finalCount': result.length,
        'filteredComponents': result
            .map((c) => '${c.type}:${inventory[c.type]?.available ?? 0}')
            .toList(),
      });
    }

    return result;
  }

  bool get hasSelection => selectedComponentType != null;
  bool get hasSearch => searchQuery.isNotEmpty;
  bool get hasFilters => activeFilters.isNotEmpty;
  bool get hasNewlyUnlocked => recentlyUnlocked.isNotEmpty;

  ComponentInventory? getInventory(String componentType) {
    return inventory[componentType];
  }

  ComponentDefinition? getComponent(String componentType) {
    return availableComponents
        .where((c) => c.type == componentType)
        .firstOrNull;
  }

  bool canUseComponent(String componentType) {
    final inventory = getInventory(componentType);
    return inventory?.canUse ?? false;
  }

  bool _componentMatchesFilter(ComponentDefinition component, String filter) {
    switch (filter.toLowerCase()) {
      case 'basic':
        return ['resistor', 'wire', 'battery'].contains(component.type);
      case 'active':
        return ['bulb', 'switch', 'transistor'].contains(component.type);
      case 'measurement':
        return ['voltmeter', 'ammeter', 'multimeter'].contains(component.type);
      case 'power':
        return ['battery', 'dc_source', 'ac_source'].contains(component.type);
      case 'passive':
        return ['resistor', 'capacitor', 'inductor'].contains(component.type);
      default:
        return false;
    }
  }

  /// Get tutorial default quantity for components that should be available for learning
  /// even if not explicitly defined in the level configuration
  int _getTutorialDefaultQuantity(String componentType) {
    // Tutorial defaults for components that should be available for educational purposes
    // These provide minimal quantities for learning without overwhelming beginners
    const tutorialDefaults = {
      'resistor': 2, // Essential for basic circuits
      'switch': 1, // Important control component
      'capacitor': 1, // Advanced but educational
      'inductor': 1, // Advanced component for learning
      'transistor': 1, // Semiconductor learning
    };

    return tutorialDefaults[componentType] ?? 0;
  }
}

// Providers
final paletteStateProvider =
    StateNotifierProvider.family<PaletteStateNotifier, PaletteState, String>(
        (ref, levelId) {
  // Get the level configuration from GameState
  final gameState = ref.watch(enhancedGameStateNotifierProvider);
  final levelConfig = gameState.currentLevel;
  final storageService = ref.watch(storageServiceProvider);

  StructuredLogger.info('Palette state provider initialized', context: {
    'levelId': levelId,
    'levelConfig': levelConfig?.levelId ?? 'null',
    'levelConfigNull': levelConfig == null,
    'gameStateLevel': gameState.currentLevel,
    'availableComponents': levelConfig?.components.available.length ?? 0,
    'availableComponentsList':
        levelConfig?.components.available.map((c) => c.type).toList() ?? [],
  });

  debugPrint('🎨 PaletteStateProvider: Initializing for level $levelId');
  debugPrint(
      '🎨 PaletteStateProvider: Game state level: ${gameState.currentLevel}');
  debugPrint(
      '🎨 PaletteStateProvider: Level config: ${levelConfig?.levelId ?? "NULL"}');
  debugPrint(
      '🎨 PaletteStateProvider: Available components: ${levelConfig?.components.available.length ?? 0}');

  return PaletteStateNotifier(levelId, storageService, levelConfig);
});

class PaletteStateNotifier extends StateNotifier<PaletteState> {
  final String levelId;
  final StorageService _storageService;
  final LevelDefinition? levelConfig;

  PaletteStateNotifier(this.levelId, this._storageService, [this.levelConfig])
      : super(PaletteState(
          availableComponents: _getAvailableComponentsForLevel(levelConfig),
          inventory: _getInventoryForLevel(levelId, levelConfig),
        )) {
    StructuredLogger.info('🎨 ===== PALETTE STATE NOTIFIER INITIALIZED =====',
        context: {
          'levelId': levelId,
          'levelConfigId': levelConfig?.levelId,
          'levelConfigNull': levelConfig == null,
          'availableComponentsCount':
              levelConfig?.components.available.length ?? 0,
          'availableComponentsList':
              levelConfig?.components.available.map((c) => c.type).toList() ??
                  [],
          'inventoryFromConfig':
              _getInventoryForLevel(levelId, levelConfig).keys.toList(),
          'componentsFromConfig': _getAvailableComponentsForLevel(levelConfig)
              .map((c) => c.type)
              .toList(),
        });
    _loadPaletteState();
  }

  Future<void> _loadPaletteState() async {
    try {
      // Load inventory for this level
      final savedInventory =
          _storageService.readData<String>('inventory_$levelId');
      if (savedInventory != null) {
        final inventoryJson =
            jsonDecode(savedInventory) as Map<String, dynamic>;
        final inventory = <String, ComponentInventory>{};
        inventoryJson.forEach((key, value) {
          inventory[key] =
              ComponentInventory.fromJson(value as Map<String, dynamic>);
        });
        state = state.copyWith(inventory: inventory);
      }

      // Load unlocked components (global, not per level)
      final unlockedTypes =
          _storageService.readData<List<String>>('unlocked_components') ?? [];
      if (unlockedTypes.isNotEmpty) {
        final updatedComponents = state.availableComponents.map((component) {
          return component.copyWith(
              isUnlocked: unlockedTypes.contains(component.type));
        }).toList();
        state = state.copyWith(availableComponents: updatedComponents);
      }
    } catch (e) {
      StructuredLogger.error('Failed to load palette state',
          context: {
            'levelId': levelId,
            'error': e.toString(),
          },
          error: e);
    }
  }

  Future<void> _savePaletteState() async {
    try {
      // Save inventory for this level
      final inventoryJson =
          state.inventory.map((key, value) => MapEntry(key, value.toJson()));
      final inventoryString = jsonEncode(inventoryJson);
      await _storageService.saveData<String>(
          'inventory_$levelId', inventoryString);
    } catch (e) {
      StructuredLogger.error('Failed to save palette state',
          context: {
            'levelId': levelId,
            'inventoryItems': state.inventory.length,
            'error': e.toString(),
          },
          error: e);
    }
  }

  Future<void> _saveUnlockedComponents(String newUnlockedType) async {
    try {
      final currentUnlocked =
          _storageService.readData<List<String>>('unlocked_components') ?? [];
      if (!currentUnlocked.contains(newUnlockedType)) {
        currentUnlocked.add(newUnlockedType);
        await _storageService.saveData<List<String>>(
            'unlocked_components', currentUnlocked);
      }
    } catch (e) {
      StructuredLogger.error('Failed to save unlocked components',
          context: {
            'levelId': levelId,
            'error': e.toString(),
          },
          error: e);
    }
  }

  void selectComponent(String? componentType) {
    state = state.copyWith(selectedComponentType: componentType);
  }

  bool canUseComponent(String componentType) {
    final inventory = state.inventory[componentType];
    final canUse = inventory?.canUse ?? false;
    StructuredLogger.debug('Component usefulness check', context: {
      'componentType': componentType,
      'available': inventory?.available ?? 0,
      'total': inventory?.total ?? 0,
      'canUse': canUse,
    });
    return canUse;
  }

  // ✅ EXPOSED PUBLIC API: Get actual inventory state for inventory service
  Map<String, ComponentInventory> getInventoryState() {
    return Map.unmodifiable(state.inventory);
  }

  void useComponent(String componentType) {
    final currentInventory = state.inventory[componentType];

    StructuredLogger.info('Component usage initiated', context: {
      'componentType': componentType,
      'currentAvailable': currentInventory?.available ?? 0,
      'currentUsed': currentInventory?.used ?? 0,
      'total': currentInventory?.total ?? 0,
    });

    if (currentInventory != null && currentInventory.canUse) {
      final updatedInventory = currentInventory.copyWith(
        available: currentInventory.available - 1,
        used: currentInventory.used + 1,
      );

      state = state.copyWith(
        inventory: {...state.inventory, componentType: updatedInventory},
      );

      StructuredLogger.debug('Component inventory decremented', context: {
        'componentType': componentType,
        'newAvailable': updatedInventory.available,
        'newUsed': updatedInventory.used,
      });

      _savePaletteState();

      StructuredLogger.info('Component usage successful', context: {
        'componentType': componentType,
        'remainingAvailable': updatedInventory.available,
      });
    } else {
      StructuredLogger.warning('Component usage denied', context: {
        'componentType': componentType,
        'reason': 'insufficient_inventory',
        'available': currentInventory?.available ?? 0,
        'canUse': currentInventory?.canUse ?? false,
      });
    }
  }

  void returnComponent(String componentType) {
    final currentInventory = state.inventory[componentType];
    if (currentInventory != null && currentInventory.used > 0) {
      final updatedInventory = currentInventory.copyWith(
        available: currentInventory.available + 1,
        used: currentInventory.used - 1,
      );

      state = state.copyWith(
        inventory: {...state.inventory, componentType: updatedInventory},
      );

      _savePaletteState();
    }
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }

  void addFilter(String filter) {
    if (!state.activeFilters.contains(filter)) {
      state = state.copyWith(
        activeFilters: [...state.activeFilters, filter],
      );
    }
  }

  void removeFilter(String filter) {
    state = state.copyWith(
      activeFilters: state.activeFilters.where((f) => f != filter).toList(),
    );
  }

  void clearFilters() {
    state = state.copyWith(activeFilters: []);
  }

  void toggleExpanded() {
    state = state.copyWith(
      isExpanded: !state.isExpanded,
      isAnimating: true,
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        state = state.copyWith(isAnimating: false);
      }
    });
  }

  void unlockComponent(String componentType) {
    final updatedComponents = state.availableComponents.map((component) {
      if (component.type == componentType) {
        return component.copyWith(isUnlocked: true);
      }
      return component;
    }).toList();

    state = state.copyWith(
      availableComponents: updatedComponents,
      recentlyUnlocked: [...state.recentlyUnlocked, componentType],
    );

    _savePaletteState();
    _saveUnlockedComponents(componentType);

    // Clear the newly unlocked notification after some time
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        state = state.copyWith(
          recentlyUnlocked: state.recentlyUnlocked
              .where((type) => type != componentType)
              .toList(),
        );
      }
    });
  }

  void clearNewlyUnlocked() {
    state = state.copyWith(recentlyUnlocked: []);
  }

  void startPlacingComponent(String componentType) {
    StructuredLogger.info('Component placement mode activated', context: {
      'componentType': componentType,
      'previousState': {
        'wasPlacing': state.isPlacingComponent,
        'previousComponentType': state.placingComponentType,
      },
    });

    state = state.copyWith(
      isPlacingComponent: true,
      placingComponentType: componentType,
    );

    StructuredLogger.debug('Placement mode state updated', context: {
      'componentType': componentType,
      'isNowActive': state.isPlacingComponent,
    });
  }

  void stopPlacingComponent() {
    StructuredLogger.info('Component placement mode deactivated', context: {
      'previousState': {
        'wasPlacing': state.isPlacingComponent,
        'componentType': state.placingComponentType,
      },
    });

    state = state.copyWith(
      isPlacingComponent: false,
      placingComponentType: null,
    );

    StructuredLogger.debug('Placement mode cleared', context: {
      'isNowInactive': !state.isPlacingComponent,
      'componentTypeCleared': state.placingComponentType == null,
    });
  }

  Future<void> reset() async {
    // Clear saved inventory first to prevent _loadPaletteState override
    // Delete the key entirely by saving an empty collection instead of null
    final emptyInventoryJson = jsonEncode(<String, dynamic>{});
    await _storageService.saveData<String>(
        'inventory_$levelId', emptyInventoryJson);

    // Then recreate fresh state with full inventory
    state = PaletteState(
      availableComponents: _getAvailableComponentsForLevel(levelConfig),
      inventory: _getInventoryForLevel(levelId, levelConfig),
    );

    StructuredLogger.info('🎨 ===== INVENTORY RESET COMPLETED =====', context: {
      'levelId': levelId,
      'freshInventoryItems': state.inventory.length,
      'totalComponentsRestored':
          state.inventory.values.fold(0, (sum, item) => sum + item.total),
      'availableComponentsRestored':
          state.inventory.values.fold(0, (sum, item) => sum + item.available),
      'inventoryDetails': state.inventory.entries
          .map((e) => '${e.key}: ${e.value.available}/${e.value.total}')
          .toList(),
    });
  }
}

// Sample data functions
List<ComponentDefinition> _getAvailableComponents() {
  return [
    const ComponentDefinition(
      type: 'battery',
      name: 'Battery',
      description: 'DC power source (1.5V)',
      iconPath: 'assets/components/battery.svg',
      defaultProperties: {'voltage': 1.5, 'internal_resistance': 0.1},
      cost: 1,
    ),
    const ComponentDefinition(
      type: 'resistor',
      name: 'Resistor',
      description: 'Limits current flow',
      iconPath: 'assets/components/resistor.svg',
      defaultProperties: {'resistance': 1000, 'tolerance': 0.05},
      cost: 1,
    ),
    const ComponentDefinition(
      type: 'bulb',
      name: 'LED',
      description: 'Light Emitting Diode',
      iconPath: 'assets/components/led.svg',
      defaultProperties: {'forward_voltage': 2.0, 'color': 'red'},
      cost: 2,
    ),
    const ComponentDefinition(
      type: 'wire',
      name: 'Wire',
      description: 'Conducts electricity',
      iconPath: 'assets/components/wire.svg',
      defaultProperties: {'resistance': 0.0},
      cost: 1,
    ),
    const ComponentDefinition(
      type: 'switch',
      name: 'Switch',
      description: 'Controls circuit flow',
      iconPath: 'assets/components/switch.svg',
      defaultProperties: {'state': 'open'},
      cost: 2,
    ),
    const ComponentDefinition(
      type: 'capacitor',
      name: 'Capacitor',
      description: 'Stores electrical energy',
      iconPath: 'assets/components/capacitor.svg',
      defaultProperties: {'capacitance': 0.001, 'voltage_rating': 25},
      cost: 3,
      isUnlocked: false,
      requiredLevels: ['3'],
    ),
    const ComponentDefinition(
      type: 'inductor',
      name: 'Inductor',
      description: 'Stores magnetic energy',
      iconPath: 'assets/components/inductor.svg',
      defaultProperties: {'inductance': 0.1},
      cost: 3,
      isUnlocked: true,
      requiredLevels: [],
    ),
  ];
}

List<ComponentDefinition> _getAvailableComponentsForLevel(
    LevelDefinition? levelConfig) {
  StructuredLogger.info('Getting available components for level', context: {
    'levelId': levelConfig?.levelId ?? 'null',
    'hasLevelConfig': levelConfig != null,
    'availableComponentsCount': levelConfig?.components.available.length ?? 0,
  });

  // If we have a level config, use it as the source of truth
  if (levelConfig != null && levelConfig.components.available.isNotEmpty) {
    StructuredLogger.debug('Using level config for available components',
        context: {
          'levelId': levelConfig.levelId,
          'components': levelConfig.components.available
              .map((c) => '${c.type}:${c.quantity}')
              .toList(),
        });

    final componentDefinitions = <ComponentDefinition>[];

    // Get the base component definitions
    final allComponents = _getAvailableComponents();

    // Create component definitions based on what's available in the level
    for (final componentAvailability in levelConfig.components.available) {
      final componentType = componentAvailability.type;

      // Find the base definition for this component type
      final baseDefinition = allComponents.firstWhere(
        (c) => c.type == componentType,
        orElse: () => ComponentDefinition(
          type: componentType,
          name: componentType.toUpperCase(),
          description: 'Component: $componentType',
          iconPath: 'assets/components/$componentType.svg',
          defaultProperties: componentAvailability.properties ?? {},
          cost: componentAvailability.properties?['cost'] ?? 1,
        ),
      );

      componentDefinitions.add(baseDefinition);

      StructuredLogger.trace('Component definition added', context: {
        'componentType': componentType,
        'name': baseDefinition.name,
        'cost': baseDefinition.cost,
        'isUnlocked': baseDefinition.isUnlocked,
      });
    }

    StructuredLogger.info('Component definitions generated from level config',
        context: {
          'levelId': levelConfig.levelId,
          'definitionsCount': componentDefinitions.length,
          'componentTypes': componentDefinitions.map((c) => c.type).toList(),
        });

    // Add simple debug logs for immediate visibility
    StructuredLogger.debug(
        '🎨 COMPONENT CREATION: Generated ${componentDefinitions.length} definitions',
        context: {
          'componentDefinitionsLength': componentDefinitions.length,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
    StructuredLogger.debug('🎨 COMPONENT CREATION: Types', context: {
      'componentTypes': componentDefinitions.map((c) => c.type).toList(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    StructuredLogger.debug(
        '🎨 COMPONENT CREATION: ${componentDefinitions.where((c) => c.isUnlocked).length} unlocked components',
        context: {
          'unlockedComponentsCount':
              componentDefinitions.where((c) => c.isUnlocked).length,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

    return componentDefinitions;
  }

  // Fallback to all available components if no level config
  StructuredLogger.info('Using fallback component definitions', context: {
    'reason': 'no_level_config_provided',
  });

  return _getAvailableComponents();
}

Map<String, ComponentInventory> _getInventoryForLevel(String levelId,
    [LevelDefinition? levelConfig]) {
  StructuredLogger.info('Generating component inventory for level', context: {
    'levelId': levelId,
    'levelConfigProvided': levelConfig != null,
    'configComponentsCount': levelConfig?.components.preplaced.length ?? 0,
  });

  final inventory = <String, ComponentInventory>{};

  // If we have a level config, use it as the source of truth
  if (levelConfig != null && levelConfig.components.available.isNotEmpty) {
    StructuredLogger.debug('Using level configuration for inventory', context: {
      'levelId': levelConfig.levelId,
      'components': levelConfig.components.available
          .map((c) => '${c.type}:${c.quantity}')
          .toList(),
    });

    // Create inventory based on available components with their specified quantities
    for (final componentAvailability in levelConfig.components.available) {
      final componentType = componentAvailability.type;
      final quantity = componentAvailability.quantity;
      inventory[componentType] = ComponentInventory(
        componentType: componentType,
        available: quantity,
        total: quantity,
      );

      StructuredLogger.trace('Component inventory populated from config',
          context: {
            'componentType': componentType,
            'available': quantity,
            'total': quantity,
          });
    }

    // ENHANCED: Add tutorial default quantities for components not in level config
    // This ensures educational components are available even if not explicitly configured
    final tutorialDefaults = _getTutorialDefaultsMap();
    for (final entry in tutorialDefaults.entries) {
      final componentType = entry.key;
      final defaultQuantity = entry.value;

      // Only add if not already in inventory from level config
      if (!inventory.containsKey(componentType)) {
        inventory[componentType] = ComponentInventory(
          componentType: componentType,
          available: defaultQuantity,
          total: defaultQuantity,
        );

        StructuredLogger.trace(
            'Component inventory populated from tutorial defaults',
            context: {
              'componentType': componentType,
              'available': defaultQuantity,
              'total': defaultQuantity,
              'source': 'tutorial_default',
            });
      }
    }

    StructuredLogger.info(
        'Inventory generation complete from config + tutorial defaults',
        context: {
          'levelId': levelId,
          'inventoryItems': inventory.length,
          'configComponents': levelConfig.components.available.length,
          'tutorialDefaultsAdded':
              tutorialDefaults.length - levelConfig.components.available.length,
          'totalComponents':
              inventory.values.fold(0, (sum, item) => sum + item.total),
        });
    return inventory;
  }

  // Fallback to hardcoded values (for backward compatibility)
  StructuredLogger.info('Using fallback inventory for level', context: {
    'levelId': levelId,
    'reason': 'no_level_config_provided',
  });
  final levelInventories = {
    '1': {
      'battery': const ComponentInventory(
          componentType: 'battery', available: 1, total: 1),
      'resistor': const ComponentInventory(
          componentType: 'resistor', available: 2, total: 2),
      'bulb': const ComponentInventory(
          componentType: 'bulb', available: 1, total: 1),
      'wire': const ComponentInventory(
          componentType: 'wire', available: 5, total: 5),
      'switch': const ComponentInventory(
          componentType: 'switch', available: 1, total: 1),
    },
    '2': {
      'battery': const ComponentInventory(
          componentType: 'battery', available: 1, total: 1),
      'resistor': const ComponentInventory(
          componentType: 'resistor', available: 3, total: 3),
      'bulb': const ComponentInventory(
          componentType: 'bulb', available: 2, total: 2),
      'wire': const ComponentInventory(
          componentType: 'wire', available: 8, total: 8),
      'switch': const ComponentInventory(
          componentType: 'switch', available: 1, total: 1),
    },
    '3': {
      'battery': const ComponentInventory(
          componentType: 'battery', available: 1, total: 1),
      'resistor': const ComponentInventory(
          componentType: 'resistor', available: 2, total: 2),
      'bulb': const ComponentInventory(
          componentType: 'bulb', available: 2, total: 2),
      'wire': const ComponentInventory(
          componentType: 'wire', available: 10, total: 10),
      'switch': const ComponentInventory(
          componentType: 'switch', available: 1, total: 1),
    },
  };

  return levelInventories[levelId] ?? levelInventories['1']!;
}
