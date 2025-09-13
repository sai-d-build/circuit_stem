import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/services/coordinate_system_service.dart';
import 'package:sparkcircuit/core/services/pathfinding_service.dart';

// Wire routing result
class WireRoutingResult {
  final bool isSuccess;
  final List<GridPosition>? path;
  final String? error;
  final WirePath? wirePath;

  const WireRoutingResult.success(this.path, this.wirePath)
      : isSuccess = true,
        error = null;

  const WireRoutingResult.failure(this.error)
      : isSuccess = false,
        path = null,
        wirePath = null;
}

// Simplified wire model for the result
class WirePath {
  final String id;
  final List<GridPosition> path;
  final DateTime createdAt;

  const WirePath({
    required this.id,
    required this.path,
    required this.createdAt,
  });

  GridPosition get startPosition => path.first;
  GridPosition get endPosition => path.last;
}

// ✅ SPECIALIZED: WireRoutingService for complex wire pathfinding
class WireRoutingService {
  final PathfindingService _pathfindingService;

  WireRoutingService(this._pathfindingService);

  /// Find optimal path for wire routing between two points
  Future<WireRoutingResult> findPath(
    GridPosition start,
    GridPosition end,
    GameState gameState,
  ) async {
    try {
      StructuredLogger.info('🎯 ===== WIRE ROUTING START =====', context: {
        'startPosition': {'row': start.row, 'col': start.col},
        'endPosition': {'row': end.row, 'col': end.col},
        'gridSize': '${gameState.grid.rows}x${gameState.grid.cols}',
      });

      // Get occupied positions (components and existing wires)
      final occupiedPositions = _getOccupiedPositions(gameState);

      // Use A* pathfinding with Manhattan heuristic
      final pathResult = await _pathfindingService.findPath(
        start,
        end,
        algorithm: PathfindingAlgorithm.astar,
        occupiedPositions: occupiedPositions,
        maxNodes: 500, // Limit for performance
      );

      if (!pathResult.success || pathResult.path.isEmpty) {
        StructuredLogger.warning('🎯 WIRE ROUTING FAILED - No path found',
            context: {
              'startPosition': {'row': start.row, 'col': start.col},
              'endPosition': {'row': end.row, 'col': end.col},
              'occupiedPositions': occupiedPositions.length,
            });
        return const WireRoutingResult.failure(
            'No valid path found between points');
      }

      // Create wire path from path
      final wirePath = WirePath(
        id: 'wire_${DateTime.now().millisecondsSinceEpoch}',
        path: pathResult.path,
        createdAt: DateTime.now(),
      );

      StructuredLogger.info('🎯 ===== WIRE ROUTING SUCCESS =====', context: {
        'wireId': wirePath.id,
        'pathLength': pathResult.path.length,
        'startPosition': {'row': start.row, 'col': start.col},
        'endPosition': {'row': end.row, 'col': end.col},
      });

      return WireRoutingResult.success(pathResult.path, wirePath);
    } catch (e, stackTrace) {
      StructuredLogger.error('🎯 WIRE ROUTING ERROR', context: {
        'error': e.toString(),
        'stackTrace': stackTrace.toString(),
        'startPosition': {'row': start.row, 'col': start.col},
        'endPosition': {'row': end.row, 'col': end.col},
      });
      return WireRoutingResult.failure('Wire routing failed: $e');
    }
  }

  /// Get all occupied positions from components and existing wires
  Set<GridPosition> _getOccupiedPositions(GameState gameState) {
    final occupied = <GridPosition>{};

    // Add component positions
    for (final component in gameState.grid.components.values) {
      occupied.add(GridPosition(row: component.row, col: component.col));
    }

    // ✅ FIXED: Implement proper wire position tracking
    // Wire components occupy their individual grid positions
    for (final wire in gameState.wires) {
      occupied.add(GridPosition(row: wire.row, col: wire.col));
    }

    StructuredLogger.debug('Occupied positions calculated', context: {
      'componentCount': gameState.grid.components.length,
      'wireCount': gameState.wires.length,
      'totalOccupied': occupied.length,
    });

    return occupied;
  }
}
