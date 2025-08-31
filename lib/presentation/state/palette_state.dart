import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/enhanced_game_state.dart';
import 'package:sparkcircuit/application/providers.dart';
import 'package:sparkcircuit/domain/entities/component.dart';
import 'package:sparkcircuit/domain/entities/level_definition.dart';

class ComponentDefinition {
  final String type;
  final String name;
  final String description;
  final String iconPath;
  final Map<String, dynamic> defaultProperties;
  final int cost;
  final bool isUnlocked;
  final List<String> requiredLevels;

  const ComponentDefinition({
    required this.type,
    required this.name,
    required this.description,
    required this.iconPath,
    this.defaultProperties = const {},
    this.cost = 1,
    this.isUnlocked = true,
    this.requiredLevels = const [],
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
    var filtered = availableComponents.where((component) => component.isUnlocked);

    // Apply search filter
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((component) => 
        component.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
        component.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
        component.type.toLowerCase().contains(searchQuery.toLowerCase())
      );
    }

    // Apply category filters
    if (activeFilters.isNotEmpty) {
      filtered = filtered.where((component) => 
        activeFilters.any((filter) => _componentMatchesFilter(component, filter))
      );
    }

    return filtered.toList();
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

  print('🎨 PaletteStateProvider: Initializing for level $levelId');
  print('🎨 PaletteStateProvider: Level config: $levelConfig');
  print('🎨 PaletteStateProvider: Available components: ${levelConfig?.initialComponentsList}');

  return PaletteStateNotifier(levelId, levelConfig);
});

class PaletteStateNotifier extends StateNotifier<PaletteState> {
  final String levelId;
  final LevelDefinition? levelConfig;

  PaletteStateNotifier(this.levelId, [this.levelConfig]) : super(PaletteState(
    availableComponents: _getAvailableComponents(),
    inventory: _getInventoryForLevel(levelId, levelConfig),
  )) {
    print('🎨 PaletteStateNotifier: Initialized for level $levelId');
    print('🎨 PaletteStateNotifier: Level config: $levelConfig');
    print('🎨 PaletteStateNotifier: Available components from config: ${levelConfig?.initialComponentsList}');
  }

  void selectComponent(String? componentType) {
    state = state.copyWith(selectedComponentType: componentType);
  }

  bool canUseComponent(String componentType) {
    final inventory = state.inventory[componentType];
    final canUse = inventory?.canUse ?? false;
    print('🎨 PaletteState: Checking if can use $componentType - inventory: $inventory, canUse: $canUse');
    return canUse;
  }

  void useComponent(String componentType) {
    print('🎨 PaletteState: Using component $componentType');
    final currentInventory = state.inventory[componentType];
    print('🎨 PaletteState: Current inventory for $componentType: $currentInventory');

    if (currentInventory != null && currentInventory.canUse) {
      final updatedInventory = currentInventory.copyWith(
        available: currentInventory.available - 1,
        used: currentInventory.used + 1,
      );

      print('🎨 PaletteState: Updated inventory for $componentType: $updatedInventory');

      state = state.copyWith(
        inventory: {...state.inventory, componentType: updatedInventory},
      );

      print('🎨 PaletteState: Component $componentType used successfully');
    } else {
      print('🎨 PaletteState: Cannot use component $componentType - no inventory or not available');
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
    print('🎨 PaletteState: Starting placement mode for $componentType');
    print('🎨 PaletteState: Previous state - isPlacingComponent: ${state.isPlacingComponent}, placingComponentType: ${state.placingComponentType}');

    state = state.copyWith(
      isPlacingComponent: true,
      placingComponentType: componentType,
    );

    print('🎨 PaletteState: New state - isPlacingComponent: ${state.isPlacingComponent}, placingComponentType: ${state.placingComponentType}');
    print('🎨 PaletteState: Placement mode started for $componentType');
  }

  void stopPlacingComponent() {
    print('🎨 PaletteState: Stopping placement mode');
    print('🎨 PaletteState: Previous state - isPlacingComponent: ${state.isPlacingComponent}, placingComponentType: ${state.placingComponentType}');

    state = state.copyWith(
      isPlacingComponent: false,
      placingComponentType: null,
    );

    print('🎨 PaletteState: New state - isPlacingComponent: ${state.isPlacingComponent}, placingComponentType: ${state.placingComponentType}');
    print('🎨 PaletteState: Placement mode stopped');
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
      isUnlocked: false,
      requiredLevels: ['5'],
    ),
  ];
}

Map<String, ComponentInventory> _getInventoryForLevel(String levelId, [LevelDefinition? levelConfig]) {
  print('🎨 _getInventoryForLevel: Generating inventory for level $levelId');
  print('🎨 _getInventoryForLevel: Level config provided: ${levelConfig != null}');

  // If we have a level config, use it as the source of truth
  if (levelConfig != null && levelConfig.initialComponentsList.isNotEmpty) {
    print('🎨 _getInventoryForLevel: Using level config components: ${levelConfig.initialComponentsList}');

    final inventory = <String, ComponentInventory>{};
    for (final componentModel in levelConfig.initialComponentsList) {
      final componentType = componentModel.type.toString().split('.').last; // Convert enum to string
      inventory[componentType] = ComponentInventory(
        componentType: componentType,
        available: (inventory[componentType]?.available ?? 0) + 1,
        total: (inventory[componentType]?.total ?? 0) + 1,
      );
      print('🎨 _getInventoryForLevel: Added $componentType');
    }

    print('🎨 _getInventoryForLevel: Generated inventory from config: $inventory');
    return inventory;
  }

  // Fallback to hardcoded values (for backward compatibility)
  print('🎨 _getInventoryForLevel: Using fallback hardcoded inventory');
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