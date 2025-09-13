import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/core/services/coordinate_service.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/game/painters/painter_factory.dart';
import 'package:sparkcircuit/presentation/models/circuit_drawing_models.dart'
    as drawing_models;

import '../../../../application/providers/unified_providers.dart';
import '../../../../core/migration/migration_tracker.dart';

/// A dedicated widget for handling all canvas rendering operations
/// This abstracts rendering logic from the main GameCanvas widget for better separation of concerns
class CanvasRenderingLayer extends ConsumerWidget {
  final String levelId;

  const CanvasRenderingLayer({
    super.key,
    required this.levelId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    MigrationTracker.markFileMigrated(
        'canvas_rendering_layer.dart', DateTime.now().toIso8601String());
    final gameState = ref.watch(unifiedGameStateProvider);
    final theme = Theme.of(context);
    final circuitColors =
        theme.extension<CircuitColorScheme>() ?? _getDefaultCircuitColors();

    // Convert ComponentModel to CircuitComponent for painter
    final circuitComponents = gameState.grid.components.values
        .map(CircuitComponent.fromComponentModel)
        .toList()
        .cast<CircuitComponent>();

    // Convert Grid connections to CircuitWire for painter
    final circuitWires = <drawing_models.CircuitWire>[];
    gameState.grid.connections.forEach((sourceId, connectedIds) {
      final sourceComponent = gameState.grid.getComponentById(sourceId);
      if (sourceComponent != null) {
        for (final targetId in connectedIds) {
          final targetComponent = gameState.grid.getComponentById(targetId);
          if (targetComponent != null) {
            // Ensure each wire is added only once (e.g., A-B, not B-A)
            if (sourceId.hashCode < targetId.hashCode) {
              circuitWires.add(drawing_models.CircuitWire(
                id: '$sourceId-$targetId',
                startX: sourceComponent.col.toDouble(),
                startY: sourceComponent.row.toDouble(),
                endX: targetComponent.col.toDouble(),
                endY: targetComponent.row.toDouble(),
                isActive:
                    false, // TODO: Determine active state from simulationResult
              ));
            }
          }
        }
      }
    });

    return RepaintBoundary(
      child: CustomPaint(
        painter: PainterFactory.createCircuitComponentsPainter(
          components: circuitComponents,
          wires: circuitWires,
          circuitColors: circuitColors,
          selectedComponentId: gameState.interactionState.selectedComponentId,
          coordinateService: _createDefaultCoordinateService(gameState),
        ),
        size: Size.infinite,
      ),
    );
  }

  /// Create a default coordinate service for painters
  CoordinateService _createDefaultCoordinateService(dynamic gameState) {
    return CoordinateService(
      cellSize: 60,
      scale: 1,
      panOffset: Offset.zero,
      gridWidth: gameState.grid.cols,
      gridHeight: gameState.grid.rows,
    );
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
