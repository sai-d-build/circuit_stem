import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart';

import 'package:sparkcircuit/domain/entities/entities.dart';
import 'dart:convert';
import '../../core/persistence/storage_service.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

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
      defaultProperties: Map<String, dynamic>.from(json['defaultProperties'] ?? {}),
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
      selectedComponentType: selectedComponentType ?? this.selectedComponentType,
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
    StructuredLogger.debug('Component filtering analysis', context: {
      'totalAvailableComponents': availableComponents.length,
      'unlockedComponents': availableComponents.where((c) => c.isUnlocked).length,
      'inventoryItems': inventory.length,
      'inventoryKeys': inventory.keys.toList(),
      'searchQuery': searchQuery,
      'activeFilters': activeFilters,
    });

    var filtered = availableComponents.where((component) => component.isUnlocked);

    StructuredLogger.trace('After unlock filter', context: {
      'count': filtered.length,
      'components': filtered.map((c) => '${c.type}:${c.isUnlocked}').toList(),
    });

    // Filter by inventory availability - only show components that exist in inventory
    filtered = filtered.where((component) => inventory.containsKey(component.type));

    StructuredLogger.trace('After inventory filter', context: {
      'count': filtered.length,
      'components': filtered.map((c) => c.type).toList(),
      'missingFromInventory': availableComponents
          .where((c) => c.isUnlocked && !inventory.containsKey(c.type))
          .map((c) => c.type)
          .toList(),
    });

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      final beforeSearch = filtered.length;
      filtered = filtered.where((component) =>
        component.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        component.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
        component.type.toLowerCase().contains(searchQuery.toLowerCase())
      );
      StructuredLogger.trace('After search filter', context: {
        'before': beforeSearch,
        'after': filtered.length,
        'query': searchQuery,
      });
    }

    // Apply category filters
    if (activeFilters.isNotEmpty) {
      final beforeCategory = filtered.length;
      filtered = filtered.where((component) =>
        activeFilters.any((filter) => _componentMatchesFilter(component, filter))
      );
      StructuredLogger.trace('After category filter', context: {
        'before': beforeCategory,
        'after': filtered.length,
        'filters': activeFilters,
      });
    }

    final result = filtered.toList();
    StructuredLogger.info('Component filtering complete', context: {
      'finalCount': result.length,
      'filteredComponents': result.map((c) => '${c.type}:${inventory[c.type]?.available ?? 0}').toList(),
    });

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
    return availableComponents.where((c) => c.type == componentType).firstOrNull;
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
        return ['led', 'switch', 'transistor'].contains(component.type);
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
}

// Providers
final paletteStateProvider = StateNotifierProvider.family<PaletteStateNotifier, PaletteState, String>((ref, levelId) {
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
    'availableComponentsList': levelConfig?.components.available.map((c) => c.type).toList() ?? [],
  });

  debugPrint('🎨 PaletteStateProvider: Initializing for level $levelId');
  debugPrint('🎨 PaletteStateProvider: Game state level: ${gameState.currentLevel}');
  debugPrint('🎨 PaletteStateProvider: Level config: ${levelConfig?.levelId ?? "NULL"}');
  debugPrint('🎨 PaletteStateProvider: Available components: ${levelConfig?.components.available.length ?? 0}');

  return PaletteStateNotifier(levelId, storageService, levelConfig);
});

class PaletteStateNotifier extends StateNotifier<PaletteState> {
  final String levelId;
  final StorageService _storageService;
  final LevelDefinition? levelConfig;

  PaletteStateNotifier(this.levelId, this._storageService, [this.levelConfig]) : super(PaletteState(
    availableComponents: _getAvailableComponents(),
    inventory: _getInventoryForLevel(levelId, levelConfig),
  )) {
    StructuredLogger.info('Palette state notifier initialized', context: {
      'levelId': levelId,
      'levelConfigId': levelConfig?.levelId,
      'availableComponentsCount': levelConfig?.components.available.length ?? 0,
    });
    _loadPaletteState();
  }

  Future<void> _loadPaletteState() async {
    try {
      // Load inventory for this level
      final savedInventory = _storageService.readData<String>('inventory_$levelId');
      if (savedInventory != null) {
        final inventoryJson = jsonDecode(savedInventory) as Map<String, dynamic>;
        final inventory = <String, ComponentInventory>{};
        inventoryJson.forEach((key, value) {
          inventory[key] = ComponentInventory.fromJson(value as Map<String, dynamic>);
        });
        state = state.copyWith(inventory: inventory);
      }

      // Load unlocked components (global, not per level)
      final unlockedTypes = _storageService.readData<List<String>>('unlocked_components') ?? [];
      if (unlockedTypes.isNotEmpty) {
        final updatedComponents = state.availableComponents.map((component) {
          return component.copyWith(isUnlocked: unlockedTypes.contains(component.type));
        }).toList();
        state = state.copyWith(availableComponents: updatedComponents);
      }
    } catch (e) {
      StructuredLogger.error('Failed to load palette state', context: {
        'levelId': levelId,
        'error': e.toString(),
      }, error: e);
    }
  }

  Future<void> _savePaletteState() async {
    try {
      // Save inventory for this level
      final inventoryJson = state.inventory.map((key, value) => MapEntry(key, value.toJson()));
      final inventoryString = jsonEncode(inventoryJson);
      await _storageService.saveData<String>('inventory_$levelId', inventoryString);
    } catch (e) {
      StructuredLogger.error('Failed to save palette state', context: {
        'levelId': levelId,
        'inventoryItems': state.inventory.length,
        'error': e.toString(),
      }, error: e);
    }
  }

  Future<void> _saveUnlockedComponents(String newUnlockedType) async {
    try {
      final currentUnlocked = _storageService.readData<List<String>>('unlocked_components') ?? [];
      if (!currentUnlocked.contains(newUnlockedType)) {
        currentUnlocked.add(newUnlockedType);
        await _storageService.saveData<List<String>>('unlocked_components', currentUnlocked);
      }
    } catch (e) {
      StructuredLogger.error('Failed to save unlocked components', context: {
        'levelId': levelId,
        'error': e.toString(),
      }, error: e);
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

  void reset() {
    state = PaletteState(
      availableComponents: _getAvailableComponents(),
      inventory: _getInventoryForLevel(levelId),
    );
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
      type: 'led',
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

Map<String, ComponentInventory> _getInventoryForLevel(String levelId, [LevelDefinition? levelConfig]) {
  StructuredLogger.info('Generating component inventory for level', context: {
    'levelId': levelId,
    'levelConfigProvided': levelConfig != null,
    'configComponentsCount': levelConfig?.components.preplaced.length ?? 0,
  });

  // If we have a level config, use it as the source of truth
  if (levelConfig != null && levelConfig.components.available.isNotEmpty) {
    StructuredLogger.debug('Using level configuration for inventory', context: {
      'levelId': levelConfig.levelId,
      'components': levelConfig.components.available.map((c) => '${c.type}:${c.quantity}').toList(),
    });

    final inventory = <String, ComponentInventory>{};
    // Create inventory based on available components with their specified quantities
    for (final componentAvailability in levelConfig.components.available) {
      final componentType = componentAvailability.type;
      final quantity = componentAvailability.quantity;
      inventory[componentType] = ComponentInventory(
        componentType: componentType,
        available: quantity,
        total: quantity,
      );

      StructuredLogger.trace('Component inventory populated', context: {
        'componentType': componentType,
        'available': quantity,
        'total': quantity,
      });
    }

    StructuredLogger.info('Inventory generation complete from config', context: {
      'levelId': levelId,
      'inventoryItems': inventory.length,
      'totalComponents': inventory.values.fold(0, (sum, item) => sum + item.total),
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
      'battery': const ComponentInventory(componentType: 'battery', available: 1, total: 1),
      'resistor': const ComponentInventory(componentType: 'resistor', available: 2, total: 2),
      'led': const ComponentInventory(componentType: 'led', available: 1, total: 1),
      'wire': const ComponentInventory(componentType: 'wire', available: 5, total: 5),
      'switch': const ComponentInventory(componentType: 'switch', available: 1, total: 1),
    },
    '2': {
      'battery': const ComponentInventory(componentType: 'battery', available: 1, total: 1),
      'resistor': const ComponentInventory(componentType: 'resistor', available: 3, total: 3),
      'led': const ComponentInventory(componentType: 'led', available: 2, total: 2),
      'wire': const ComponentInventory(componentType: 'wire', available: 8, total: 8),
      'switch': const ComponentInventory(componentType: 'switch', available: 1, total: 1),
    },
    '3': {
      'battery': const ComponentInventory(componentType: 'battery', available: 1, total: 1),
      'resistor': const ComponentInventory(componentType: 'resistor', available: 2, total: 2),
      'led': const ComponentInventory(componentType: 'led', available: 2, total: 2),
      'wire': const ComponentInventory(componentType: 'wire', available: 10, total: 10),
      'switch': const ComponentInventory(componentType: 'switch', available: 1, total: 1),
    },
  };

  return levelInventories[levelId] ?? levelInventories['1']!;
}