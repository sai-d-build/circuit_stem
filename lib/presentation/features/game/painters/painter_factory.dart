import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/game/painters/component_painter.dart';
import 'package:sparkcircuit/presentation/features/game/painters/wire_painter.dart';
import 'package:sparkcircuit/presentation/features/game/painters/circuit_components_painter.dart';
import 'package:sparkcircuit/presentation/models/circuit_drawing_models.dart' as drawing_models;
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/core/services/coordinate_service.dart';

/// Factory class for creating painter instances
/// Provides a centralized way to instantiate painters with proper dependencies
class PainterFactory {
  /// Creates a CircuitComponentsPainter with the given parameters
  static CircuitComponentsPainter createCircuitComponentsPainter({
    required List<CircuitComponent> components,
    required List<drawing_models.CircuitWire> wires,
    required CircuitColorScheme circuitColors,
    String? selectedComponentId,
    required CoordinateService coordinateService,
  }) {
    return CircuitComponentsPainter(
      components: components,
      wires: wires,
      circuitColors: circuitColors,
      selectedComponentId: selectedComponentId,
      coordinateService: coordinateService,
    );
  }

  /// Creates a ComponentPainter with the given parameters
  static ComponentPainter createComponentPainter({
    required List<CircuitComponent> components,
    required CircuitColorScheme circuitColors,
    String? selectedComponentId,
    required CoordinateService coordinateService,
  }) {
    return ComponentPainter(
      components: components,
      circuitColors: circuitColors,
      selectedComponentId: selectedComponentId,
      coordinateService: coordinateService,
    );
  }

  /// Creates a WirePainter with the given parameters
  static WirePainter createWirePainter({
    required List<drawing_models.CircuitWire> wires,
    required CircuitColorScheme circuitColors,
    required CoordinateService coordinateService,
  }) {
    return WirePainter(
      wires: wires,
      circuitColors: circuitColors,
      coordinateService: coordinateService,
    );
  }
}