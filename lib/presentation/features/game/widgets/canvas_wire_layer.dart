import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers/unified_providers.dart';
import 'package:sparkcircuit/core/migration/migration_tracker.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/core/services/grid_service.dart';
import 'package:sparkcircuit/presentation/models/circuit_drawing_models.dart' as drawing_models;
import 'package:sparkcircuit/domain/entities/entities.dart';

/// CanvasWireLayer handles the rendering of circuit wires and connections.
/// This layer extracts wire rendering logic from GameCanvas.
class CanvasWireLayer extends ConsumerWidget {
  final String levelId;

  const CanvasWireLayer({
    super.key,
    required this.levelId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MigrationTracker.markFileMigrated('canvas_wire_layer.dart', DateTime.now().toIso8601String());
    final gameState = ref.watch(unifiedGameStateProvider);
    final circuitColors = Theme.of(context).extension<CircuitColorScheme>() ??
                         _getDefaultCircuitColors();

    // Convert Grid connections to CircuitWire for rendering
    final circuitWires = _buildCircuitWires(gameState);

    return RepaintBoundary(
      child: CustomPaint(
        painter: WireRenderingPainter(
          wires: circuitWires,
          circuitColors: circuitColors,
        ),
        size: Size.infinite,
      ),
    );
  }

  List<drawing_models.CircuitWire> _buildCircuitWires(GameState gameState) {
    // Basic wire activity detection - could be enhanced with actual simulation later
    final wireActivity = _determineWireActivity(gameState);

    final wires = <drawing_models.CircuitWire>[];

    gameState.grid.connections.forEach((sourceId, connectedIds) {
      final sourceComponent = gameState.grid.getComponentById(sourceId);
      if (sourceComponent != null) {
        for (final targetId in connectedIds) {
          final targetComponent = gameState.grid.getComponentById(targetId);
          if (targetComponent != null) {
            // Ensure each wire is added only once (e.g., A-B, not B-A)
            if (sourceId.hashCode < targetId.hashCode) {
              final wireId = '$sourceId\_$targetId';
              wires.add(drawing_models.CircuitWire(
                id: wireId,
                startX: sourceComponent.col.toDouble(),
                startY: sourceComponent.row.toDouble(),
                endX: targetComponent.col.toDouble(),
                endY: targetComponent.row.toDouble(),
                isActive: wireActivity[wireId] ?? false, // Determine from wire activity
              ));
            }
          }
        }
      }
    });

    return wires;
  }

  Map<String, bool> _determineWireActivity(GameState gameState) {
    // TODO: Replace with actual simulation-based activity detection when simulationResult is available
    // For now, provide basic activity based on component states and connections

    final activityMap = <String, bool>{};

    // Simple heuristic: wires are active if they connect to power sources
    gameState.grid.connections.forEach((sourceId, connectedIds) {
      final sourceComponent = gameState.grid.getComponentById(sourceId);
      if (sourceComponent != null && _isPowerSource(sourceComponent.type)) {
        for (final targetId in connectedIds) {
          if (sourceId.hashCode < targetId.hashCode) {
            final wireId = '$sourceId\_$targetId';
            activityMap[wireId] = true;
          } else {
            final wireId = '$targetId\_$sourceId';
            activityMap[wireId] = true;
          }
        }
      }
    });

    return activityMap;
  }

  bool _isPowerSource(ComponentType type) {
    // Basic power source detection - could be enhanced with component properties
    return type == ComponentType.battery;
  }

  CircuitColorScheme _getDefaultCircuitColors() {
    return const CircuitColorScheme(
      primary: Color(0xFF1E88E5),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE3F2FD),
      onPrimaryContainer: Color(0xFF0D47A1),
      secondary: Color(0xFF43A047),
      onSecondary: Color(0xFFFFFFFF),
      tertiary: Color(0xFFFF8F00),
      onTertiary: Color(0xFFFFFFFF),
      error: Color(0xFFD32F2F),
      onError: Color(0xFFFFFFFF),
      errorContainer: Color(0xFFFFEBEE),
      onErrorContainer: Color(0xFFB71C1C),
      surface: Color(0xFFFAFAFA),
      onSurface: Color(0xFF1C1C1C),
      surfaceContainer: Color(0xFFEFEFEF),
      onSurfaceVariant: Color(0xFF424242),
      shadow: Color(0xFF000000),
      outline: Color(0xFFBDBDBD),
      wireActive: Color(0xFF00E676),
      wireInactive: Color(0xFF616161),
      componentBase: Color(0xFF2196F3),
      gridLine: Color(0xFFE0E0E0),
      glowEffect: Color(0xFF00E5FF),
      neonPrimary: Color(0xFF00E5FF),
      neonAccent: Color(0xFF00BCD4),
      errorGlow: Color(0xFFFF5252),
      energyPulse: Color(0xFF00E676),
      highlightAccent: Color(0xFFFFC107),
    );
  }
}

/// WireRenderingPainter handles the actual rendering of circuit wires
class WireRenderingPainter extends CustomPainter {
  final List<drawing_models.CircuitWire> wires;
  final CircuitColorScheme circuitColors;

  WireRenderingPainter({
    required this.wires,
    required this.circuitColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // TODO: GameState/grid configuration should be passed from the widget
    // For now, using reasonable defaults that match the game's typical grid size
    final gridConfig = GridConfiguration(
      rows: 20, // Standard game grid rows
      cols: 20, // Standard game grid columns
      cellSize: 60.0, // Standard cell size
      scale: 1.0,
      panOffset: Offset.zero,
    );

    for (final wire in wires) {
      final startPos = GridService.gridToScreen(
        Offset(wire.startX, wire.startY),
        gridConfig,
      );
      final endPos = GridService.gridToScreen(
        Offset(wire.endX, wire.endY),
        gridConfig,
      );

      final paint = Paint()
        ..color = wire.isActive ? circuitColors.wireActive : circuitColors.wireInactive
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(startPos, endPos, paint);

      // Draw connection points
      final pointPaint = Paint()
        ..color = circuitColors.primary
        ..style = PaintingStyle.fill;

      canvas.drawCircle(startPos, 4.0, pointPaint);
      canvas.drawCircle(endPos, 4.0, pointPaint);
    }
  }

  @override
  bool shouldRepaint(WireRenderingPainter oldDelegate) {
    return oldDelegate.wires != wires ||
           oldDelegate.circuitColors != circuitColors;
  }
}