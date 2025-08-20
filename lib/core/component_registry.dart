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
    final behaviorTypes = _behaviors[type];
    if (behaviorTypes == null) throw Exception('Unknown component type: $type');

    // Instantiate behavior instances using the runtime type -> factory map.
    final behaviorInstances = behaviorTypes.map((t) {
      final instance = getBehaviorByType(t);
      if (instance == null) {
        Logger.log('ComponentRegistry: No factory for behavior type: \$t');
      }
      return instance;
    }).toList();

    return ComponentModel(
      id: id,
      r: r,
      c: c,
      type: type,
      behaviors: behaviorInstances,
      isDraggable: _draggable[type] ?? false,
      rotation: rotation,
      isPowered: isPowered,
    );
  }

  /// Create a component from JSON data while ensuring behaviors are attached
  static ComponentModel createFromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    final behaviorTypes = _behaviors[type];
    
    if (behaviorTypes == null) {
      Logger.log('ComponentRegistry: Unknown component type: $type, creating component without behaviors');
      // Create a basic component without behaviors rather than calling fromJson
      return ComponentModel(
        id: json['id'] as String,
        r: (json['position']?['r'] ?? json['r']) as int,
        c: (json['position']?['c'] ?? json['c']) as int,
        type: type,
        behaviors: const [],
        isDraggable: false,
        rotation: json['rotation'] as int? ?? 0,
        isPowered: json['isPowered'] as bool? ?? false,
        shapeOffsets: const [const CellOffset(0, 0)],
        terminals: const [],
        internalConnections: const [],
        state: const {},
      );
    }

    // Instantiate behavior instances using the runtime type -> factory map.
    final behaviorInstances = behaviorTypes.map((t) {
      final instance = getBehaviorByType(t);
      if (instance == null) {
        Logger.log('ComponentRegistry: No factory for behavior type: \$t');
      }
      return instance;
    }).toList();

    Logger.log('ComponentRegistry: Attached ${behaviorInstances.length} behaviors to component $type');

    // Parse shapeOffsets manually
    final shapeOffsetsJson = json['shapeOffsets'] as List<dynamic>?;
    final shapeOffsets = shapeOffsetsJson != null
        ? shapeOffsetsJson.map((e) {
            final offsetJson = e as Map<String, dynamic>;
            return CellOffset(
              offsetJson['x'] as int,
              offsetJson['y'] as int,
            );
          }).toList()
        : [CellOffset(0, 0)];

    // Parse terminals manually - NEVER call TerminalSpec.fromJson
    final terminalsJson = json['terminals'] as List<dynamic>?;
    final terminals = terminalsJson != null
        ? terminalsJson.map((e) {
            final termJson = e as Map<String, dynamic>;
            
            // Parse offset
            final offsetJson = termJson['offset'] as Map<String, dynamic>;
            final offset = CellOffset(
              offsetJson['x'] as int,
              offsetJson['y'] as int,
            );
            
            // Parse direction string
            final dirString = termJson['direction'] as String;
            final dir = _dirFromString(dirString);
            
            return TerminalSpec(
              offset: offset,
              direction: dir,
              type: (termJson['type'] as String).toTerminalType(),
            );
          }).toList()
        : const [
            TerminalSpec(offset: CellOffset(0, 0), direction: Dir.north, type: TerminalType.power),
            TerminalSpec(offset: CellOffset(0, 0), direction: Dir.south, type: TerminalType.power)
          ];

    // Parse internalConnections manually
    final internalConnectionsJson = json['internalConnections'] as List<dynamic>?;
    final internalConnections = internalConnectionsJson?.map<List<int>>((e) {
            final connectionJson = e as List<dynamic>;
            return connectionJson.map<int>((i) => i as int).toList();
          }).toList() ??
          const [];

    // Parse state manually
    final stateJson = json['state'] as Map<String, dynamic>?;
    final state = stateJson ?? const {};

    // Create component with behaviors attached, preserving all JSON properties
    return ComponentModel(
      id: json['id'] as String,
      r: (json['position']?['r'] ?? json['r']) as int,
      c: (json['position']?['c'] ?? json['c']) as int,
      type: type,
      behaviors: behaviorInstances,
      isDraggable: json['isDraggable'] as bool? ?? (_draggable[type] ?? false),
      rotation: json['rotation'] as int? ?? 0,
      isPowered: json['isPowered'] as bool? ?? false,
      shapeOffsets: shapeOffsets,
      terminals: terminals,
      internalConnections: internalConnections,
      state: state,
    );
  }
}
