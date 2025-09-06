import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/game/painters/painter_factory.dart';
import 'package:sparkcircuit/presentation/models/circuit_drawing_models.dart' as drawing_models;
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/core/services/coordinate_service.dart';

class CircuitComponentsPainter extends CustomPainter {
  final List<CircuitComponent> components;
  final List<drawing_models.CircuitWire> wires;
  final CircuitColorScheme circuitColors;
  final String? selectedComponentId;
  final CoordinateService coordinateService;

  CircuitComponentsPainter({
    required this.components,
    required this.wires,
    required this.circuitColors,
    this.selectedComponentId,
    required this.coordinateService,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw wires first using factory
    PainterFactory.createWirePainter(
      wires: wires,
      circuitColors: circuitColors,
      coordinateService: coordinateService,
    ).paint(canvas, size);

    // Draw components on top of wires using factory
    PainterFactory.createComponentPainter(
      components: components,
      circuitColors: circuitColors,
      selectedComponentId: selectedComponentId,
      coordinateService: coordinateService,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CircuitComponentsPainter oldDelegate) {
    return oldDelegate.components != components ||
            oldDelegate.wires != wires ||
            oldDelegate.circuitColors != circuitColors ||
            oldDelegate.selectedComponentId != selectedComponentId ||
            oldDelegate.coordinateService != coordinateService;
  }
}
