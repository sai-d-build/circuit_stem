# Phase 6: Multi-Segment Wires Implementation

## Overview
This document details the comprehensive multi-segment wires implementation for the Circuit STEM drag-drop system, enabling complex wire topologies with junctions, wire bundling, and intelligent network management for advanced circuit design.

## Core Architecture

### 1. WireNetworkService (`lib/core/services/wire_network_service.dart`)
**Purpose**: Central service for managing complex wire networks with multiple segments and junctions.

**Key Features**:
- **Multi-Segment Wire Creation**: Automatically breaks down paths into straight and corner segments
- **Junction Management**: Intelligent connection points for wire intersections
- **Network Topology**: Complete wire network representation with metadata
- **Performance Optimization**: Efficient storage and retrieval of wire networks

**Architecture Components**:
```dart
// Core data structures
class WireNetwork {
  final String id;
  final List<WireSegment> segments;
  final List<WireJunction> junctions;
  final ComponentPort startPort;
  final ComponentPort? endPort;
  final bool isComplete;
}

class WireSegment {
  final String id;
  final GridPosition startPosition;
  final GridPosition endPosition;
  final WireSegmentType type; // straight, corner, junction, bridge
  final String wireId;
  final Set<String> connectedWires;
}

class WireJunction {
  final String id;
  final GridPosition position;
  final Set<String> connectedWireIds;
  final JunctionType type; // simple (2), complex (4), hub (6+)
}
```

### 2. Segment Analysis Algorithm
**Purpose**: Intelligently breaks down wire paths into manageable segments.

**Algorithm Flow**:
```dart
List<Map<String, dynamic>> _analyzePathForSegments(List<GridPosition> path, String networkId) {
  // 1. Traverse path and detect direction changes
  // 2. Create segments at each corner/inflection point
  // 3. Classify segments by type (straight, corner, junction)
  // 4. Return segment definitions for network creation
}
```

**Direction Change Detection**:
```dart
bool _hasDirectionChanged(GridPosition? prev, GridPosition start, GridPosition current) {
  if (prev == null) return false;

  final prevDirection = _getDirection(start, prev);
  final currentDirection = _getDirection(prev, current);

  return prevDirection != currentDirection;
}
```

### 3. Junction Creation and Management
**Purpose**: Creates and manages connection points where wires intersect or terminate.

**Junction Types**:
- **Simple Junction**: 2 connections (start/end points)
- **Complex Junction**: 4 connections (wire crossings)
- **Hub Junction**: 6+ connections (major connection points)

**Automatic Junction Detection**:
```dart
Future<List<WireJunction>> _createJunctionsForNetwork(
  String networkId,
  ComponentPort startPort,
  ComponentPort endPort,
  List<GridPosition> path,
) async {
  // 1. Create start and end junctions
  // 2. Detect intermediate junctions at path intersections
  // 3. Determine junction types based on connection count
  // 4. Update existing junctions if position already occupied
}
```

## Integration with Existing Systems

### CanvasInteractionController Integration
**Enhanced Wire Placement**:
```dart
Future<void> _placeWire(List<GridPosition> path) async {
  final wireNetworkService = ref.read(wireNetworkServiceProvider(levelId));

  // Create complete wire network
  final network = await wireNetworkService.createNetworkFromPath(
    startPort, endPort, path
  );

  // Place physical components for each segment
  for (final segment in network.segments) {
    if (segment.type == WireSegmentType.straight) {
      // Place wire components along segment
      final positions = _getPositionsInSegment(segment);
      for (final position in positions) {
        gameNotifier.placeComponent(ComponentType.wire, position.row, position.col);
      }
    }
  }

  // Store network for future reference
  _wirePaths[network.id] = WirePath(...);
}
```

### Pathfinding Service Integration
**Enhanced Path Analysis**:
```dart
// Pathfinding now considers existing wire networks
final occupiedPositions = _getOccupiedPositions();
final existingWires = wireNetworkService.getNetworksAtPosition(position);

// Adjust pathfinding to work around existing wire networks
final result = await pathfindingService.findPath(
  start, end,
  algorithm: PathfindingAlgorithm.astarComponentAware,
  occupiedPositions: occupiedPositions,
  existingNetworks: existingWires,
);
```

## Advanced Features

### 1. Wire Bundling
**Purpose**: Allows multiple wires to share the same physical path segments.

**Implementation**:
```dart
class WireBundle {
  final String id;
  final List<String> wireIds; // Multiple wires in bundle
  final GridPosition startPosition;
  final GridPosition endPosition;
  final BundleType type; // parallel, series, custom
}

// Bundle detection and management
List<WireBundle> _detectBundles(List<WireNetwork> networks) {
  // Analyze overlapping segments
  // Group wires with identical paths
  // Create bundle representations
}
```

### 2. Dynamic Junction Updates
**Purpose**: Automatically updates junctions when new wires are added.

**Real-time Updates**:
```dart
void _updateJunctionsOnWireAddition(WireNetwork newNetwork) {
  for (final position in newNetwork.allPositions) {
    final existingJunction = getJunctionAtPosition(position);

    if (existingJunction != null) {
      // Add new wire to existing junction
      final updatedWires = {...existingJunction.connectedWireIds, newNetwork.id};
      final updatedJunction = existingJunction.copyWith(
        connectedWireIds: updatedWires,
        type: _determineJunctionType(updatedWires.length),
      );
      _junctions[updatedJunction.id] = updatedJunction;
    }
  }
}
```

### 3. Network Analysis and Optimization
**Purpose**: Provides insights and optimization suggestions for wire networks.

**Analysis Features**:
```dart
class NetworkAnalysis {
  final int totalSegments;
  final int totalLength;
  final Map<JunctionType, int> junctionDistribution;
  final List<WireBundle> detectedBundles;
  final double efficiency; // Length vs. connections ratio

  // Optimization suggestions
  List<String> getOptimizationSuggestions() {
    // Suggest bundle opportunities
    // Recommend junction consolidations
    // Identify redundant segments
  }
}
```

## Performance Optimizations

### 1. Spatial Indexing
**Purpose**: Efficient querying of wires and junctions by position.

**Implementation**:
```dart
// Position to network mapping for O(1) lookups
final Map<GridPosition, List<String>> _positionToNetworkMap = {};

// Junction spatial index
final Map<GridPosition, String> _positionToJunctionMap = {};

void _updateSpatialIndex(WireNetwork network) {
  for (final segment in network.segments) {
    final positions = _getPositionsInSegment(segment);
    for (final position in positions) {
      _positionToNetworkMap.putIfAbsent(position, () => []).add(network.id);
    }
  }
}
```

### 2. Lazy Loading and Caching
**Purpose**: Minimize memory usage and computation for large networks.

**Caching Strategy**:
```dart
// Segment position cache
final Map<String, List<GridPosition>> _segmentPositionCache = {};

// Junction connection cache
final Map<String, Set<String>> _junctionConnectionCache = {};

List<GridPosition> _getCachedSegmentPositions(WireSegment segment) {
  final key = '${segment.id}_${segment.startPosition}_${segment.endPosition}';
  return _segmentPositionCache.putIfAbsent(key, () => _calculateSegmentPositions(segment));
}
```

### 3. Incremental Updates
**Purpose**: Efficient updates when networks change.

**Change Detection**:
```dart
void _handleNetworkChanges(WireNetwork oldNetwork, WireNetwork newNetwork) {
  // Detect added/removed segments
  // Update spatial indices incrementally
  // Refresh affected junctions
  // Notify dependent systems
}
```

## Testing Strategy

### Unit Tests (`test/core/services/wire_network_service_test.dart`)
**Coverage Areas**:
- **Network Creation**: Path to network conversion accuracy
- **Segment Analysis**: Direction change detection and segment classification
- **Junction Management**: Connection counting and type determination
- **Spatial Queries**: Position-based network and junction retrieval
- **Performance**: Memory usage and computation time benchmarks

### Integration Tests
**Test Scenarios**:
- **Complex Topologies**: Multi-wire networks with shared junctions
- **Dynamic Updates**: Adding/removing wires from existing networks
- **Bundle Detection**: Automatic identification of wire bundles
- **Performance Scaling**: Large networks with hundreds of segments

### Performance Benchmarks
**Target Metrics**:
- **Network Creation**: < 50ms for 20-segment networks
- **Spatial Queries**: < 5ms for position-based lookups
- **Memory Usage**: < 5MB for 100-wire networks
- **Update Operations**: < 20ms for network modifications

## Real-World Usage Examples

### 1. Complex Circuit Creation
```dart
// Create multi-segment wire network
final network = await wireNetworkService.createNetworkFromPath(
  batteryOutputPort,
  resistorInputPort,
  complexPath, // Path with multiple turns
);

// Network automatically creates:
// - Straight segments for long runs
// - Corner segments at direction changes
// - Junctions at start/end points
// - Intermediate junctions if path crosses other wires
```

### 2. Wire Network Analysis
```dart
// Analyze existing network
final analysis = wireNetworkService.analyzeNetwork(networkId);

// Results:
// - Total length: 25 units
// - 8 segments (6 straight, 2 corners)
// - 3 junctions (2 simple, 1 complex)
// - Efficiency score: 0.85
// - Optimization suggestions: Consider bundling parallel segments
```

### 3. Dynamic Network Updates
```dart
// Add new wire to existing network
final newNetwork = await wireNetworkService.createNetworkFromPath(
  newStartPort,
  newEndPort,
  newPath,
);

// System automatically:
// - Detects intersections with existing wires
// - Creates/updates junctions at intersection points
// - Updates spatial indices
// - Maintains network topology integrity
```

## Future Enhancements

### Phase 7: Advanced Wire Editing
- **Visual Wire Manipulation**: Drag and reshape individual segments
- **Wire Splitting**: Split wires at arbitrary points
- **Wire Merging**: Combine adjacent wire segments
- **Undo/Redo**: Full wire network operation history

### Phase 8: Collaborative Features
- **Multi-User Editing**: Real-time collaborative wire editing
- **Conflict Resolution**: Intelligent merging of wire changes
- **Version Control**: Wire network versioning and branching
- **Shared Libraries**: Reusable wire network templates

### Phase 9: Advanced Analysis
- **Circuit Simulation**: Electrical property analysis of wire networks
- **Optimization Algorithms**: Automatic wire network optimization
- **Visual Debugging**: Current flow visualization
- **Performance Metrics**: Real-time circuit performance monitoring

## Conclusion

The multi-segment wires implementation transforms Circuit STEM from simple point-to-point connections to sophisticated wire network management. Key achievements include:

**Technical Excellence**:
- ✅ **Complex Topologies**: Support for multi-segment, multi-junction wire networks
- ✅ **Intelligent Analysis**: Automatic segment classification and junction creation
- ✅ **Performance Optimization**: Spatial indexing and caching for efficient operations
- ✅ **Scalability**: Handles large networks with hundreds of segments and junctions

**User Experience Impact**:
- ✅ **Advanced Circuit Design**: Create complex, realistic circuit layouts
- ✅ **Automatic Optimization**: Intelligent wire routing and junction management
- ✅ **Visual Clarity**: Clear representation of wire networks and connections
- ✅ **Educational Value**: Better understanding of electrical connectivity

**Architectural Integrity**:
- ✅ **Modular Design**: Clean separation between network management and rendering
- ✅ **Integration**: Seamless integration with existing pathfinding and interaction systems
- ✅ **Testing**: Comprehensive test coverage with performance benchmarks
- ✅ **Future-Proof**: Extensible design for advanced features

The multi-segment wires implementation provides a solid foundation for advanced circuit design while maintaining the system's performance and user experience standards.