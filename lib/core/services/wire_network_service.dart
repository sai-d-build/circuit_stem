import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/core/migration/migration_tracker.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/presentation/features/game/controllers/canvas_interaction_controller.dart';

enum WireSegmentType {
  straight, // Single straight segment
  corner, // 90-degree corner
  junction, // Connection point for multiple wires
  bridge, // Wire crossing over another
}

class WireSegment {
  final String id;
  final GridPosition startPosition;
  final GridPosition endPosition;
  final WireSegmentType type;
  final String wireId; // Parent wire this segment belongs to
  final DateTime createdAt;
  final Set<String> connectedWires; // For junctions

  const WireSegment({
    required this.id,
    required this.startPosition,
    required this.endPosition,
    required this.type,
    required this.wireId,
    required this.createdAt,
    this.connectedWires = const {},
  });

  bool get isHorizontal => startPosition.row == endPosition.row;
  bool get isVertical => startPosition.col == endPosition.col;

  int get length {
    if (isHorizontal) {
      return (endPosition.col - startPosition.col).abs();
    } else if (isVertical) {
      return (endPosition.row - startPosition.row).abs();
    } else {
      // Diagonal segment
      return startPosition.distanceTo(endPosition).round();
    }
  }

  WireSegment copyWith({
    String? id,
    GridPosition? startPosition,
    GridPosition? endPosition,
    WireSegmentType? type,
    String? wireId,
    DateTime? createdAt,
    Set<String>? connectedWires,
  }) {
    return WireSegment(
      id: id ?? this.id,
      startPosition: startPosition ?? this.startPosition,
      endPosition: endPosition ?? this.endPosition,
      type: type ?? this.type,
      wireId: wireId ?? this.wireId,
      createdAt: createdAt ?? this.createdAt,
      connectedWires: connectedWires ?? this.connectedWires,
    );
  }
}

class WireJunction {
  final String id;
  final GridPosition position;
  final Set<String> connectedWireIds;
  final JunctionType type;
  final DateTime createdAt;

  const WireJunction({
    required this.id,
    required this.position,
    required this.connectedWireIds,
    required this.type,
    required this.createdAt,
  });

  int get connectionCount => connectedWireIds.length;

  bool get isEmpty => connectedWireIds.isEmpty;
  bool get isFull => connectionCount >= type.maxConnections;

  WireJunction copyWith({
    String? id,
    GridPosition? position,
    Set<String>? connectedWireIds,
    JunctionType? type,
    DateTime? createdAt,
  }) {
    return WireJunction(
      id: id ?? this.id,
      position: position ?? this.position,
      connectedWireIds: connectedWireIds ?? this.connectedWireIds,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

enum JunctionType {
  simple(2, 'Simple'), // 2 connections
  complex(4, 'Complex'), // 4 connections
  hub(6, 'Hub'); // 6+ connections

  const JunctionType(this.maxConnections, this.displayName);
  final int maxConnections;
  final String displayName;
}

class WireNetwork {
  final String id;
  final List<WireSegment> segments;
  final List<WireJunction> junctions;
  final ComponentPort startPort;
  final ComponentPort? endPort;
  final bool isComplete;
  final DateTime createdAt;

  const WireNetwork({
    required this.id,
    required this.segments,
    required this.junctions,
    required this.startPort,
    this.endPort,
    required this.isComplete,
    required this.createdAt,
  });

  int get totalLength =>
      segments.fold(0, (sum, segment) => sum + segment.length);
  int get segmentCount => segments.length;
  int get junctionCount => junctions.length;

  WireNetwork copyWith({
    String? id,
    List<WireSegment>? segments,
    List<WireJunction>? junctions,
    ComponentPort? startPort,
    ComponentPort? endPort,
    bool? isComplete,
    DateTime? createdAt,
  }) {
    return WireNetwork(
      id: id ?? this.id,
      segments: segments ?? this.segments,
      junctions: junctions ?? this.junctions,
      startPort: startPort ?? this.startPort,
      endPort: endPort ?? this.endPort,
      isComplete: isComplete ?? this.isComplete,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

final wireNetworkServiceProvider = Provider.family<WireNetworkService, String>(
  (ref, levelId) {
    MigrationTracker.markFileMigrated(
        'wire_network_service.dart', DateTime.now().toIso8601String());
    return WireNetworkService(levelId: levelId);
  },
);

class WireNetworkService {
  final String levelId;

  // In-memory storage for wire networks
  final Map<String, WireNetwork> _networks = {};
  final Map<String, WireJunction> _junctions = {};
  final Map<GridPosition, List<String>> _positionToNetworkMap = {};

  WireNetworkService({required this.levelId});

  /// Create a new wire network from a path
  Future<WireNetwork> createNetworkFromPath(
    ComponentPort startPort,
    ComponentPort endPort,
    List<GridPosition> path,
  ) async {
    final networkId = 'network_${DateTime.now().millisecondsSinceEpoch}';
    final segments = <WireSegment>[];
    final junctions = <WireJunction>[];

    // Analyze path for corners and create segments
    final pathSegments = _analyzePathForSegments(path, networkId);

    for (final segmentData in pathSegments) {
      final segment = WireSegment(
        id: 'segment_${DateTime.now().millisecondsSinceEpoch}_${segments.length}',
        startPosition: segmentData['start'] as GridPosition,
        endPosition: segmentData['end'] as GridPosition,
        type: segmentData['type'] as WireSegmentType,
        wireId: networkId,
        createdAt: DateTime.now(),
      );
      segments.add(segment);
    }

    // Create junctions at connection points
    final networkJunctions =
        await _createJunctionsForNetwork(networkId, startPort, endPort, path);
    junctions.addAll(networkJunctions);

    final network = WireNetwork(
      id: networkId,
      segments: segments,
      junctions: junctions,
      startPort: startPort,
      endPort: endPort,
      isComplete: true,
      createdAt: DateTime.now(),
    );

    _networks[networkId] = network;

    // Update position mapping
    _updatePositionMapping(network);

    return network;
  }

  /// Analyze path to create individual segments
  List<Map<String, dynamic>> _analyzePathForSegments(
    List<GridPosition> path,
    String networkId,
  ) {
    final segments = <Map<String, dynamic>>[];

    if (path.length < 2) return segments;

    var currentStart = path[0];
    GridPosition? previous;

    for (var i = 1; i < path.length; i++) {
      final current = path[i];
      final directionChanged =
          _hasDirectionChanged(previous, currentStart, current);

      if (directionChanged && previous != null) {
        // Create segment for previous direction
        segments.add({
          'start': currentStart,
          'end': previous,
          'type': _determineSegmentType(currentStart, previous),
        });
        currentStart = previous;
      }

      previous = current;
    }

    // Add final segment
    if (previous != null) {
      segments.add({
        'start': currentStart,
        'end': previous,
        'type': _determineSegmentType(currentStart, previous),
      });
    }

    return segments;
  }

  /// Check if direction changed (indicates corner/junction)
  bool _hasDirectionChanged(
      GridPosition? prev, GridPosition start, GridPosition current) {
    if (prev == null) return false;

    final prevDirection = _getDirection(start, prev);
    final currentDirection = _getDirection(prev, current);

    return prevDirection != currentDirection;
  }

  /// Get direction between two points
  String _getDirection(GridPosition from, GridPosition to) {
    final rowDiff = to.row - from.row;
    final colDiff = to.col - from.col;

    if (rowDiff > 0) return 'down';
    if (rowDiff < 0) return 'up';
    if (colDiff > 0) return 'right';
    if (colDiff < 0) return 'left';
    return 'none';
  }

  /// Determine segment type based on start/end positions
  WireSegmentType _determineSegmentType(GridPosition start, GridPosition end) {
    if (start.row == end.row || start.col == end.col) {
      return WireSegmentType.straight;
    } else {
      return WireSegmentType.corner;
    }
  }

  /// Create junctions for network connection points
  Future<List<WireJunction>> _createJunctionsForNetwork(
    String networkId,
    ComponentPort startPort,
    ComponentPort endPort,
    List<GridPosition> path,
  ) async {
    final junctions = <WireJunction>[];

    // Create junction at start port
    final startJunction = WireJunction(
      id: 'junction_${networkId}_start',
      position: startPort.position,
      connectedWireIds: {networkId},
      type: JunctionType.simple,
      createdAt: DateTime.now(),
    );
    junctions.add(startJunction);
    _junctions[startJunction.id] = startJunction;

    // Create junction at end port
    final endJunction = WireJunction(
      id: 'junction_${networkId}_end',
      position: endPort.position,
      connectedWireIds: {networkId},
      type: JunctionType.simple,
      createdAt: DateTime.now(),
    );
    junctions.add(endJunction);
    _junctions[endJunction.id] = endJunction;

    // Check for intermediate junctions (where wires might cross)
    final intermediateJunctions =
        await _findIntermediateJunctions(path, networkId);
    junctions.addAll(intermediateJunctions);

    return junctions;
  }

  /// Find intermediate junction points
  Future<List<WireJunction>> _findIntermediateJunctions(
    List<GridPosition> path,
    String networkId,
  ) async {
    final junctions = <WireJunction>[];

    for (final position in path) {
      // Check if position already has a junction
      final existingJunction = _junctions.values.firstWhere(
        (j) => j.position == position,
        orElse: () => WireJunction(
          id: '',
          position: position,
          connectedWireIds: {},
          type: JunctionType.simple,
          createdAt: DateTime.now(),
        ),
      );

      if (existingJunction.id.isNotEmpty) {
        // Add this network to existing junction
        final updatedWires = {...existingJunction.connectedWireIds, networkId};
        final updatedJunction = existingJunction.copyWith(
          connectedWireIds: updatedWires,
          type: _determineJunctionType(updatedWires.length),
        );
        junctions.add(updatedJunction);
        _junctions[updatedJunction.id] = updatedJunction;
      } else if (_hasMultipleWiresAtPosition(position)) {
        // Create new junction for wire crossing
        final junction = WireJunction(
          id: 'junction_${DateTime.now().millisecondsSinceEpoch}',
          position: position,
          connectedWireIds: {networkId, ..._getWiresAtPosition(position)},
          type: JunctionType.complex,
          createdAt: DateTime.now(),
        );
        junctions.add(junction);
        _junctions[junction.id] = junction;
      }
    }

    return junctions;
  }

  /// Check if position has multiple wires
  bool _hasMultipleWiresAtPosition(GridPosition position) {
    final networksAtPosition = _positionToNetworkMap[position] ?? [];
    return networksAtPosition.length > 1;
  }

  /// Get wire IDs at a position
  Set<String> _getWiresAtPosition(GridPosition position) {
    final networksAtPosition = _positionToNetworkMap[position] ?? [];
    return networksAtPosition.toSet();
  }

  /// Determine junction type based on connection count
  JunctionType _determineJunctionType(int connectionCount) {
    if (connectionCount <= 2) return JunctionType.simple;
    if (connectionCount <= 4) return JunctionType.complex;
    return JunctionType.hub;
  }

  /// Update position to network mapping
  void _updatePositionMapping(WireNetwork network) {
    for (final segment in network.segments) {
      final positions = _getPositionsInSegment(segment);
      for (final position in positions) {
        _positionToNetworkMap.putIfAbsent(position, () => []).add(network.id);
      }
    }
  }

  /// Get all positions covered by a segment
  List<GridPosition> _getPositionsInSegment(WireSegment segment) {
    final positions = <GridPosition>[];

    if (segment.isHorizontal) {
      final startCol = segment.startPosition.col < segment.endPosition.col
          ? segment.startPosition.col
          : segment.endPosition.col;
      final endCol = segment.startPosition.col < segment.endPosition.col
          ? segment.endPosition.col
          : segment.startPosition.col;

      for (var col = startCol; col <= endCol; col++) {
        positions.add(GridPosition(row: segment.startPosition.row, col: col));
      }
    } else if (segment.isVertical) {
      final startRow = segment.startPosition.row < segment.endPosition.row
          ? segment.startPosition.row
          : segment.endPosition.row;
      final endRow = segment.startPosition.row < segment.endPosition.row
          ? segment.endPosition.row
          : segment.startPosition.row;

      for (var row = startRow; row <= endRow; row++) {
        positions.add(GridPosition(row: row, col: segment.startPosition.col));
      }
    } else {
      // For diagonal segments, add start and end points
      positions.add(segment.startPosition); // ignore: cascade_invocations
      positions.add(segment.endPosition); // ignore: cascade_invocations
    }

    return positions;
  }

  /// Get all networks
  List<WireNetwork> getAllNetworks() {
    return _networks.values.toList();
  }

  /// Get network by ID
  WireNetwork? getNetwork(String networkId) {
    return _networks[networkId];
  }

  /// Get networks at position
  List<WireNetwork> getNetworksAtPosition(GridPosition position) {
    final networkIds = _positionToNetworkMap[position] ?? [];
    return networkIds
        .map((id) => _networks[id])
        .whereType<WireNetwork>()
        .toList();
  }

  /// Get junction at position
  WireJunction? getJunctionAtPosition(GridPosition position) {
    return _junctions.values.firstWhere(
      (junction) => junction.position == position,
      orElse: () => WireJunction(
        id: '',
        position: position,
        connectedWireIds: {},
        type: JunctionType.simple,
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Remove network
  void removeNetwork(String networkId) {
    final network = _networks[networkId];
    if (network != null) {
      // Remove from position mapping
      for (final segment in network.segments) {
        final positions = _getPositionsInSegment(segment);
        for (final position in positions) {
          _positionToNetworkMap[position]?.remove(networkId);
          if (_positionToNetworkMap[position]?.isEmpty ?? false) {
            _positionToNetworkMap.remove(position);
          }
        }
      }

      // Remove junctions
      for (final junction in network.junctions) {
        _junctions.remove(junction.id);
      }

      _networks.remove(networkId);
    }
  }

  /// Get network statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalNetworks': _networks.length,
      'totalSegments':
          _networks.values.fold(0, (sum, net) => sum + net.segmentCount),
      'totalJunctions': _junctions.length,
      'totalLength':
          _networks.values.fold(0, (sum, net) => sum + net.totalLength),
      'junctionsByType': {
        'simple': _junctions.values
            .where((j) => j.type == JunctionType.simple)
            .length,
        'complex': _junctions.values
            .where((j) => j.type == JunctionType.complex)
            .length,
        'hub':
            _junctions.values.where((j) => j.type == JunctionType.hub).length,
      },
    };
  }

  /// Clear all networks and junctions
  void clear() {
    _networks.clear();
    _junctions.clear();
    _positionToNetworkMap.clear();
  }
}
