import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers/unified_providers.dart';
import 'package:sparkcircuit/core/migration/migration_tracker.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/domain/entities/core/component.dart';

enum PathfindingAlgorithm {
  manhattan, // Current implementation
  astar, // New A* implementation
  astarOptimized, // A* with precomputed heuristics
  astarDiagonal, // A* with diagonal movement
  astarComponentAware, // A* with component-aware routing
}

class PathNode {
  final GridPosition position;
  final double gCost; // Cost from start
  final double hCost; // Heuristic cost to end
  final double fCost; // Total cost (g + h)
  final PathNode? parent;

  const PathNode({
    required this.position,
    required this.gCost,
    required this.hCost,
    this.parent,
  }) : fCost = gCost + hCost;

  PathNode copyWith({
    GridPosition? position,
    double? gCost,
    double? hCost,
    PathNode? parent,
  }) {
    return PathNode(
      position: position ?? this.position,
      gCost: gCost ?? this.gCost,
      hCost: hCost ?? this.hCost,
      parent: parent ?? this.parent,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PathNode && position == other.position;

  @override
  int get hashCode => position.hashCode;
}

class PathfindingResult {
  final List<GridPosition> path;
  final bool success;
  final int nodesExplored;
  final double pathCost;
  final Duration computationTime;

  const PathfindingResult({
    required this.path,
    required this.success,
    required this.nodesExplored,
    required this.pathCost,
    required this.computationTime,
  });

  factory PathfindingResult.success(
    List<GridPosition> path,
    int nodesExplored,
    double pathCost,
    Duration computationTime,
  ) {
    return PathfindingResult(
      path: path,
      success: true,
      nodesExplored: nodesExplored,
      pathCost: pathCost,
      computationTime: computationTime,
    );
  }

  factory PathfindingResult.failure(
      int nodesExplored, Duration computationTime) {
    return PathfindingResult(
      path: [],
      success: false,
      nodesExplored: nodesExplored,
      pathCost: 0,
      computationTime: computationTime,
    );
  }
}

final pathfindingServiceProvider = Provider.family<PathfindingService, String>(
  (ref, levelId) {
    MigrationTracker.markFileMigrated(
        'pathfinding_service.dart', DateTime.now().toIso8601String());
    return PathfindingService(
      gameState: ref.read(unifiedGameStateProvider),
      levelId: levelId,
    );
  },
);

class PathfindingService {
  final dynamic gameState;
  final String levelId;

  // Precomputed heuristic cache for optimization
  final Map<String, double> _heuristicCache = {};
  final Map<String, List<GridPosition>> _neighborCache = {};

  PathfindingService({
    required this.gameState,
    required this.levelId,
  });

  /// Main pathfinding method with algorithm selection
  Future<PathfindingResult> findPath(
    GridPosition start,
    GridPosition end, {
    PathfindingAlgorithm algorithm = PathfindingAlgorithm.astar,
    Set<GridPosition>? occupiedPositions,
    int maxNodes = 1000,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      switch (algorithm) {
        case PathfindingAlgorithm.manhattan:
          return _findPathManhattan(start, end, occupiedPositions, stopwatch);
        case PathfindingAlgorithm.astar:
          return _findPathAStar(
              start, end, occupiedPositions, maxNodes, stopwatch,
              allowDiagonal: false);
        case PathfindingAlgorithm.astarOptimized:
          return _findPathAStarOptimized(
              start, end, occupiedPositions, maxNodes, stopwatch);
        case PathfindingAlgorithm.astarDiagonal:
          return _findPathAStar(
              start, end, occupiedPositions, maxNodes, stopwatch,
              allowDiagonal: true);
        case PathfindingAlgorithm.astarComponentAware:
          return _findPathAStarComponentAware(
              start, end, occupiedPositions, maxNodes, stopwatch);
      }
    } finally {
      stopwatch.stop();
    }
  }

  /// Current Manhattan distance implementation (for compatibility)
  PathfindingResult _findPathManhattan(
    GridPosition start,
    GridPosition end,
    Set<GridPosition>? occupiedPositions,
    Stopwatch stopwatch,
  ) {
    final path = <GridPosition>[];
    final current = start;
    path.add(current);

    // Horizontal move
    final hTarget = GridPosition(row: current.row, col: end.col);
    if (hTarget.col > current.col) {
      for (var col = current.col + 1; col <= hTarget.col; col++) {
        path.add(GridPosition(row: current.row, col: col));
      }
    } else {
      for (var col = current.col - 1; col >= hTarget.col; col--) {
        path.add(GridPosition(row: current.row, col: col));
      }
    }

    // Vertical move
    final vTarget = GridPosition(row: end.row, col: end.col);
    if (vTarget.row > hTarget.row) {
      for (var row = hTarget.row + 1; row <= vTarget.row; row++) {
        path.add(GridPosition(row: row, col: hTarget.col));
      }
    } else {
      for (var row = hTarget.row - 1; row >= vTarget.row; row--) {
        path.add(GridPosition(row: row, col: hTarget.col));
      }
    }

    return PathfindingResult.success(
      path,
      path.length,
      _calculatePathCost(path),
      stopwatch.elapsed,
    );
  }

  /// A* pathfinding implementation
  PathfindingResult _findPathAStar(
    GridPosition start,
    GridPosition end,
    Set<GridPosition>? occupiedPositions,
    int maxNodes,
    Stopwatch stopwatch, {
    bool allowDiagonal = false,
  }) {
    final openSet = <PathNode>[];
    final closedSet = <GridPosition>{};
    final cameFrom = <GridPosition, PathNode>{};
    final gScore = <GridPosition, double>{};
    final fScore = <GridPosition, double>{};

    // Initialize
    final startNode = PathNode(
      position: start,
      gCost: 0,
      hCost: _heuristic(start, end),
    );

    openSet.add(startNode);
    gScore[start] = 0;
    fScore[start] = startNode.fCost;

    var nodesExplored = 0;

    while (openSet.isNotEmpty && nodesExplored < maxNodes) {
      // Find node with lowest fCost
      openSet.sort((a, b) => a.fCost.compareTo(b.fCost));
      final current = openSet.removeAt(0);
      nodesExplored++;

      if (current.position == end) {
        // Reconstruct path
        final path = _reconstructPath(cameFrom, current);
        return PathfindingResult.success(
          path,
          nodesExplored,
          current.gCost,
          stopwatch.elapsed,
        );
      }

      closedSet.add(current.position);

      for (final neighbor in _getNeighbors(current.position, occupiedPositions,
          allowDiagonal: allowDiagonal)) {
        if (closedSet.contains(neighbor)) continue;

        final tentativeGScore =
            current.gCost + _movementCost(current.position, neighbor);

        if (!gScore.containsKey(neighbor) ||
            tentativeGScore < gScore[neighbor]!) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentativeGScore;

          final hCost = _heuristic(neighbor, end);
          fScore[neighbor] = tentativeGScore + hCost;

          final neighborNode = PathNode(
            position: neighbor,
            gCost: tentativeGScore,
            hCost: hCost,
            parent: current,
          );

          // Remove old entry if exists and add new one
          openSet.removeWhere((node) => node.position == neighbor);
          openSet.add(neighborNode);
        }
      }
    }

    return PathfindingResult.failure(nodesExplored, stopwatch.elapsed);
  }

  /// Optimized A* with precomputed heuristics and neighbor caching
  PathfindingResult _findPathAStarOptimized(
    GridPosition start,
    GridPosition end,
    Set<GridPosition>? occupiedPositions,
    int maxNodes,
    Stopwatch stopwatch,
  ) {
    // Precompute heuristics for all positions in grid bounds
    _precomputeHeuristics(end);

    // Use cached neighbors
    _precomputeNeighbors(occupiedPositions);

    // Use optimized A* implementation
    return _findPathAStar(start, end, occupiedPositions, maxNodes, stopwatch);
  }

  /// Calculate Manhattan distance heuristic
  double _heuristic(GridPosition a, GridPosition b) {
    final key = '${a.row},${a.col}-${b.row},${b.col}';
    if (_heuristicCache.containsKey(key)) {
      return _heuristicCache[key]!;
    }

    final distance = (a.row - b.row).abs() + (a.col - b.col).abs().toDouble();
    _heuristicCache[key] = distance;
    return distance;
  }

  /// Get valid neighboring positions
  List<GridPosition> _getNeighbors(
    GridPosition position,
    Set<GridPosition>? occupiedPositions, {
    bool allowDiagonal = false,
  }) {
    final key = '${position.row},${position.col}';
    if (_neighborCache.containsKey(key)) {
      return _neighborCache[key]!;
    }

    final neighbors = <GridPosition>[];
    final directions = [
      const GridPosition(row: 0, col: 1), // Right
      const GridPosition(row: 1, col: 0), // Down
      const GridPosition(row: 0, col: -1), // Left
      const GridPosition(row: -1, col: 0), // Up
    ];

    // Add diagonal directions if enabled
    if (allowDiagonal) {
      directions.addAll([
        const GridPosition(row: 1, col: 1), // Down-Right
        const GridPosition(row: 1, col: -1), // Down-Left
        const GridPosition(row: -1, col: 1), // Up-Right
        const GridPosition(row: -1, col: -1), // Up-Left
      ]);
    }

    for (final dir in directions) {
      final neighbor = GridPosition(
        row: position.row + dir.row,
        col: position.col + dir.col,
      );

      // Check bounds and occupancy
      if (_isValidPosition(neighbor, occupiedPositions)) {
        neighbors.add(neighbor);
      }
    }

    _neighborCache[key] = neighbors;
    return neighbors;
  }

  /// Check if position is valid (within bounds and not occupied)
  bool _isValidPosition(
      GridPosition position, Set<GridPosition>? occupiedPositions) {
    // Get grid dimensions from game state
    final grid = gameState.grid;

    // Check bounds
    if (position.row < 0 ||
        position.row >= grid.rows ||
        position.col < 0 ||
        position.col >= grid.cols) {
      return false;
    }

    // Check occupancy
    if (occupiedPositions != null && occupiedPositions.contains(position)) {
      return false;
    }

    return true;
  }

  /// Calculate movement cost between positions
  double _movementCost(GridPosition from, GridPosition to) {
    final rowDiff = (to.row - from.row).abs();
    final colDiff = (to.col - from.col).abs();

    // Diagonal movement costs more (√2 ≈ 1.414)
    if (rowDiff == 1 && colDiff == 1) {
      return 1.414;
    }

    // Orthogonal movement
    return 1;
  }

  /// Component-aware movement cost
  double _componentAwareMovementCost(GridPosition from, GridPosition to) {
    final baseCost = _movementCost(from, to);

    // Add penalties for moving near certain components
    // Check if the target position has a component that affects routing
    final componentAtTarget = gameState.grid.components.values
        .where(
            (component) => component.row == to.row && component.col == to.col)
        .firstOrNull;

    if (componentAtTarget != null) {
      // Penalize moving through component positions (should be avoided)
      return baseCost + 10.0;
    }

    // Prefer routing along existing wire paths
    final wireNeighbors = _getWireNeighbors(to);
    if (wireNeighbors.isNotEmpty) {
      // Slight preference for routing near existing wires
      return baseCost * 0.9;
    }

    return baseCost;
  }

  /// Get neighboring positions that contain wires
  List<GridPosition> _getWireNeighbors(GridPosition position) {
    final neighbors = <GridPosition>[];

    final directions = [
      const GridPosition(row: 0, col: 1),
      const GridPosition(row: 1, col: 0),
      const GridPosition(row: 0, col: -1),
      const GridPosition(row: -1, col: 0),
    ];

    for (final dir in directions) {
      final neighbor = GridPosition(
        row: position.row + dir.row,
        col: position.col + dir.col,
      );

      final componentAtNeighbor = gameState.grid.components.values
          .where((component) =>
              component.row == neighbor.row && component.col == neighbor.col)
          .firstOrNull;

      if (componentAtNeighbor?.type == ComponentType.wire) {
        neighbors.add(neighbor);
      }
    }

    return neighbors;
  }

  /// A* with component-aware routing
  PathfindingResult _findPathAStarComponentAware(
    GridPosition start,
    GridPosition end,
    Set<GridPosition>? occupiedPositions,
    int maxNodes,
    Stopwatch stopwatch,
  ) {
    final openSet = <PathNode>[];
    final closedSet = <GridPosition>{};
    final cameFrom = <GridPosition, PathNode>{};
    final gScore = <GridPosition, double>{};
    final fScore = <GridPosition, double>{};

    // Initialize
    final startNode = PathNode(
      position: start,
      gCost: 0,
      hCost: _heuristic(start, end),
    );

    openSet.add(startNode);
    gScore[start] = 0;
    fScore[start] = startNode.fCost;

    var nodesExplored = 0;

    while (openSet.isNotEmpty && nodesExplored < maxNodes) {
      // Find node with lowest fCost
      openSet.sort((a, b) => a.fCost.compareTo(b.fCost));
      final current = openSet.removeAt(0);
      nodesExplored++;

      if (current.position == end) {
        // Reconstruct path
        final path = _reconstructPath(cameFrom, current);
        return PathfindingResult.success(
          path,
          nodesExplored,
          current.gCost,
          stopwatch.elapsed,
        );
      }

      closedSet.add(current.position);

      for (final neighbor in _getNeighbors(current.position, occupiedPositions,
          allowDiagonal: true)) {
        if (closedSet.contains(neighbor)) continue;

        final movementCost =
            _componentAwareMovementCost(current.position, neighbor);
        final tentativeGScore = current.gCost + movementCost;

        if (!gScore.containsKey(neighbor) ||
            tentativeGScore < gScore[neighbor]!) {
          cameFrom[neighbor] = current;
          gScore[neighbor] = tentativeGScore;

          final hCost = _heuristic(neighbor, end);
          fScore[neighbor] = tentativeGScore + hCost;

          final neighborNode = PathNode(
            position: neighbor,
            gCost: tentativeGScore,
            hCost: hCost,
            parent: current,
          );

          // Remove old entry if exists and add new one
          openSet.removeWhere((node) => node.position == neighbor);
          openSet.add(neighborNode);
        }
      }
    }

    return PathfindingResult.failure(nodesExplored, stopwatch.elapsed);
  }

  /// Calculate total path cost
  double _calculatePathCost(List<GridPosition> path) {
    var cost = 0.0;
    for (var i = 1; i < path.length; i++) {
      cost += _movementCost(path[i - 1], path[i]);
    }
    return cost;
  }

  /// Reconstruct path from A* result
  List<GridPosition> _reconstructPath(
    Map<GridPosition, PathNode> cameFrom,
    PathNode current,
  ) {
    final path = <GridPosition>[];
    var node = current;

    while (node.parent != null) {
      path.insert(0, node.position);
      node = node.parent!;
    }
    path.insert(0, node.position);

    return path;
  }

  /// Precompute heuristics for optimization
  void _precomputeHeuristics(GridPosition end) {
    final grid = gameState.grid;

    for (var row = 0; row < grid.rows; row++) {
      for (var col = 0; col < grid.cols; col++) {
        final position = GridPosition(row: row, col: col);
        _heuristic(position, end);
      }
    }
  }

  /// Precompute neighbors for optimization
  void _precomputeNeighbors(Set<GridPosition>? occupiedPositions) {
    final grid = gameState.grid;

    for (var row = 0; row < grid.rows; row++) {
      for (var col = 0; col < grid.cols; col++) {
        final position = GridPosition(row: row, col: col);
        _getNeighbors(position, occupiedPositions);
      }
    }
  }

  /// Clear caches for memory management
  void clearCaches() {
    _heuristicCache.clear();
    _neighborCache.clear();
  }

  /// Get pathfinding statistics
  Map<String, dynamic> getStatistics() {
    return {
      'heuristicCacheSize': _heuristicCache.length,
      'neighborCacheSize': _neighborCache.length,
    };
  }
}
