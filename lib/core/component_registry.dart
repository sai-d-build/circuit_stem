import '../models/component.dart';
import '../common/logger.dart';

// Helper function to convert direction strings to Dir enum
Dir _dirFromString(String dir) {
  final lowerDir = dir.toLowerCase();
  if (lowerDir == 'up') return Dir.north;
  if (lowerDir == 'down') return Dir.south;
  if (lowerDir == 'left') return Dir.west;
  if (lowerDir == 'right') return Dir.east;
  return Dir.values.firstWhere(
    (e) => e.name.toLowerCase() == lowerDir,
    orElse: () {
      // For backward compatibility with older level files
      if (lowerDir == 'n') return Dir.north;
      if (lowerDir == 'e') return Dir.east;
      if (lowerDir == 's') return Dir.south;
      if (lowerDir == 'w') return Dir.west;
      throw Exception('Unknown direction string: $dir');
    },
  );
}

// A map to hold factories for behaviors, keyed by their type.
// This would typically be integrated with a proper DI/service locator framework.
final Map<Type, Function> _behaviorFactories = {};

void registerBehavior<T>(T Function() factory) {
  _behaviorFactories[T] = factory;
  Logger.log('ComponentRegistry: Registered behavior factory for type: $T');
}

/// Retrieve a behavior instance by runtime [type]. This avoids relying on generic
/// type parameters at the call-site (which are erased at runtime) and lets callers
/// request an instance for a specific Type.
dynamic getBehaviorByType(Type type) {
  final factory = _behaviorFactories[type];
  if (factory == null) {
    Logger.log('ComponentRegistry: ERROR: Behavior factory for type $type not registered.');
    return null;
  }
  Logger.log('ComponentRegistry: Retrieved behavior factory for type: $type');
  return factory();
}

class ComponentRegistry {
  static final Map<String, List<Type>> _behaviors = {};
  static final Map<String, bool> _draggable = {};
  static final Map<String, String> _displayNames = {};

  static void register({
    required String type,
    required List<Type> behaviors,
    required String displayName,
    bool isDraggable = false,
  }) {
    _behaviors[type] = behaviors;
    _draggable[type] = isDraggable;
    _displayNames[type] = displayName;
    Logger.log('ComponentRegistry: Registered component type: $type with ${behaviors.length} behaviors');
  }

  static String getDisplayName(String type) {
    return _displayNames[type] ?? 'Unknown';
  }

  static ComponentModel create({
    required String type,
    required String id,
    required int r,
    required int c,
    int rotation = 0,
    bool isPowered = false,
  }) {
    return _createWithBehaviors(
      type: type,
      id: id,
      r: r,
      c: c,
      rotation: rotation,
      isPowered: isPowered,
    );
  }

  /// Create a component from JSON data while ensuring behaviors are attached
  static ComponentModel createFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    Logger.log('ComponentRegistry: Creating component from JSON - type: $type');
    
    // Parse position data
    final r = (json['position']?['r'] ?? json['r']) as int;
    final c = (json['position']?['c'] ?? json['c']) as int;
    final id = json['id'] as String;
    final rotation = json['rotation'] as int? ?? 0;
    final isPowered = json['isPowered'] as bool? ?? false;
    
    // Parse shape offsets
    final shapeOffsetsJson = json['shapeOffsets'] as List<dynamic>?;
    final shapeOffsets = shapeOffsetsJson != null
        ? shapeOffsetsJson.map((e) {
            final offsetJson = e as Map<String, dynamic>;
            return CellOffset(
              offsetJson['r'] as int,
              offsetJson['c'] as int,
            );
          }).toList()
        : [const CellOffset(0, 0)];

    // Parse terminals
    final terminalsJson = json['terminals'] as List<dynamic>?;
    final terminals = terminalsJson != null
        ? terminalsJson.map((e) {
            final termJson = e as Map<String, dynamic>;
            
            // Parse offset
            final offsetJson = termJson['offset'] as Map<String, dynamic>;
            final offset = CellOffset(
              offsetJson['r'] as int,
              offsetJson['c'] as int,
            );
            
            // Parse direction string
            final dirString = termJson['dir'] as String;
            final dir = _dirFromString(dirString);
            
            // Parse type string with null-check and default
            final typeString = termJson['type'] as String? ?? 'power';
            final terminalType = typeString.toTerminalType();
            
            return TerminalSpec(
              offset: offset,
              direction: dir,
              type: terminalType,
            );
          }).toList()
        : const [
            TerminalSpec(offset: CellOffset(0, 0), direction: Dir.north, type: TerminalType.power),
            TerminalSpec(offset: CellOffset(0, 0), direction: Dir.south, type: TerminalType.power)
          ];

    // Parse internal connections
    final internalConnectionsJson = json['internalConnections'] as List<dynamic>?;
    final internalConnections = internalConnectionsJson?.map<List<int>>((e) {
            final connectionJson = e as List<dynamic>;
            return connectionJson.map<int>((i) => i as int).toList();
          }).toList() ??
          const [];

    // Parse state
    final stateJson = json['state'] as Map<String, dynamic>?;
    final state = stateJson ?? const {};

    // Create component with behaviors using the centralized method
    return _createWithBehaviors(
      type: type,
      id: id,
      r: r,
      c: c,
      rotation: rotation,
      isPowered: isPowered,
      shapeOffsets: shapeOffsets,
      terminals: terminals,
      internalConnections: internalConnections,
      state: state,
    );
  }

  /// Centralized component creation that always attaches behaviors properly
  static ComponentModel _createWithBehaviors({
    required String type,
    required String id,
    required int r,
    required int c,
    int rotation = 0,
    bool isPowered = false,
    List<CellOffset>? shapeOffsets,
    List<TerminalSpec>? terminals,
    List<List<int>>? internalConnections,
    Map<String, dynamic>? state,
  }) {
    final behaviorTypes = _behaviors[type];
    
    if (behaviorTypes == null) {
      Logger.log('ComponentRegistry: WARNING - Unknown component type: $type, creating component without behaviors');
      return ComponentModel(
        id: id,
        r: r,
        c: c,
        type: type,
        behaviors: const [],
        isDraggable: false,
        rotation: rotation,
        isPowered: isPowered,
        shapeOffsets: shapeOffsets ?? const [CellOffset(0, 0)],
        terminals: terminals ?? const [
          TerminalSpec(offset: CellOffset(0, 0), direction: Dir.north, type: TerminalType.power),
          TerminalSpec(offset: CellOffset(0, 0), direction: Dir.south, type: TerminalType.power)
        ],
        internalConnections: internalConnections ?? const [],
        state: state ?? const {},
      );
    }

    // CRITICAL FIX: Always instantiate behaviors using the factory registry
    final behaviorInstances = <dynamic>[];
    for (final behaviorType in behaviorTypes) {
      final instance = getBehaviorByType(behaviorType);
      if (instance != null) {
        behaviorInstances.add(instance);
        Logger.log('ComponentRegistry: Successfully attached behavior: $behaviorType to component $type');
      } else {
        Logger.log('ComponentRegistry: ERROR - Failed to create behavior: $behaviorType for component $type');
      }
    }

    Logger.log('ComponentRegistry: Created component $type with ${behaviorInstances.length}/${behaviorTypes.length} behaviors');

    return ComponentModel(
      id: id,
      r: r,
      c: c,
      type: type,
      behaviors: behaviorInstances,
      isDraggable: _draggable[type] ?? false,
      rotation: rotation,
      isPowered: isPowered,
      shapeOffsets: shapeOffsets ?? const [CellOffset(0, 0)],
      terminals: terminals ?? const [
        TerminalSpec(offset: CellOffset(0, 0), direction: Dir.north, type: TerminalType.power),
        TerminalSpec(offset: CellOffset(0, 0), direction: Dir.south, type: TerminalType.power)
      ],
      internalConnections: internalConnections ?? const [],
      state: state ?? const {},
    );
  }
}