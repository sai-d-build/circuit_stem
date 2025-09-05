import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/grid_service.dart';

/// Provider for GridService singleton
final gridServiceProvider = Provider<GridService>((ref) {
  return GridService(); // GridService is stateless and thread-safe
});

/// Provider for creating GridConfiguration from various contexts
final gridConfigurationProvider = Provider<GridConfiguration>((ref) {
  // Default configuration - should be overridden in specific contexts
  return GridConfiguration(
    rows: 10,
    cols: 15,
    cellSize: GridConstants.defaultCellSize,
    scale: 1.0,
    panOffset: Offset.zero,
  );
});

/// Provider for RenderConfiguration
final renderConfigurationProvider = Provider<RenderConfiguration>((ref) {
  return const RenderConfiguration(
    gridLineColor: GridConstants.defaultGridLineColor,
    majorGridLineColor: GridConstants.defaultMajorGridLineColor,
  );
});