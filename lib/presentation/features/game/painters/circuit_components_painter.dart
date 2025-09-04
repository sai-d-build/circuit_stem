import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/game/painters/component_painter.dart';
import 'package:sparkcircuit/presentation/features/game/painters/wire_painter.dart';
import 'package:sparkcircuit/presentation/models/circuit_drawing_models.dart' as drawing_models;
import 'package:sparkcircuit/domain/entities/entities.dart';

class CircuitComponentsPainter extends CustomPainter {
  final List<CircuitComponent> components;
  final List<drawing_models.CircuitWire> wires;
  final CircuitColorScheme circuitColors;
  final String? selectedComponentId;
  final double scale;

  CircuitComponentsPainter({
    required this.components,
    required this.wires,
    required this.circuitColors,
    this.selectedComponentId,
    this.scale = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw wires first
    WirePainter(
      wires: wires,
      circuitColors: circuitColors,
      scale: scale,
    ).paint(canvas, size);

    // Draw components on top of wires
    ComponentPainter(
      components: components,
      circuitColors: circuitColors,
      selectedComponentId: selectedComponentId,
      scale: scale,
    ).paint(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CircuitComponentsPainter oldDelegate) {
    return oldDelegate.components != components ||
           oldDelegate.wires != wires ||
           oldDelegate.circuitColors != circuitColors ||
           oldDelegate.selectedComponentId != selectedComponentId ||
           oldDelegate.scale != scale;
  }
}
