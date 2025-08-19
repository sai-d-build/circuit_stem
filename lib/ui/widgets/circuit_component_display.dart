import 'package:flutter/material.dart';
import 'package:circuit_stem/models/component.dart';


class CircuitComponentDisplay extends StatelessWidget {
  final ComponentModel component;
  final double size;
  final bool isPreview;
  
  const CircuitComponentDisplay({
    Key? key,
    required this.component,
    this.size = 40.0,
    this.isPreview = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPowered = component.state['isPowered'] == true; // Assuming isPowered is stored in state
    final isSwitchClosed = component.type == "Component.Switch" ? (component.state['closed'] == true) : false;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: CircuitComponentPainter(
          component: component,
          isPowered: isPowered,
          isSwitchClosed: isSwitchClosed,
          isDark: isDark,
          partOffset: component.shapeOffsets.isNotEmpty ? component.shapeOffsets.first : const CellOffset(0,0), // Use first offset for display
        ),
      ),
    );
  }
}