import 'dart:ui';
import '../entity/grid_configuration.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/grid_service.dart';

/// Provider for GridService singleton
final gridServiceProvider = Provider<GridService>((ref) {
  return GridService(); // GridService is stateless and thread-safe
});

// GridConfigurationProvider has been moved to lib/core/entity/grid_configuration.dart for canonical definition
// This file remains for backward compatibility and GridService provider only

/// Provider for RenderConfiguration
final renderConfigurationProvider = Provider<RenderConfiguration>((ref) {
  return const RenderConfiguration(
    gridLineColor: GridConstants.defaultGridLineColor,
    majorGridLineColor: GridConstants.defaultMajorGridLineColor,
  );
});
