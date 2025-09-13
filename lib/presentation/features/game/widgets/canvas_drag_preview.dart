import 'package:flutter/material.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';

/// CanvasDragPreview provides a visual preview of components being dragged.
/// This widget extracts the drag preview logic from GameCanvas.
class CanvasDragPreview extends StatelessWidget {
  final String componentType;
  final Offset position;

  const CanvasDragPreview({
    super.key,
    required this.componentType,
    required this.position,
  });

  @override
  Widget build(BuildContext context) {
    final circuitColors = Theme.of(context).extension<CircuitColorScheme>() ??
        _getDefaultCircuitColors();

    return Positioned(
      left: position.dx - 25,
      top: position.dy - 25,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: circuitColors.primary.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: circuitColors.primary,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: circuitColors.shadow.withValues(alpha: 0.3),
              offset: const Offset(0, 4),
              blurRadius: 8,
            ),
          ],
        ),
        child: Center(
          child: _getComponentIcon(componentType, circuitColors.onPrimary),
        ),
      ),
    );
  }

  Icon _getComponentIcon(String componentType, Color color) {
    switch (componentType) {
      case 'battery':
        return Icon(Icons.battery_full, color: color, size: 24);
      case 'resistor':
        return Icon(Icons.linear_scale, color: color, size: 24);
      case 'bulb':
        return Icon(Icons.lightbulb, color: color, size: 24);
      case 'wire':
        return Icon(Icons.horizontal_rule, color: color, size: 24);
      case 'switch':
        return Icon(Icons.power, color: color, size: 24);
      case 'capacitor':
        return Icon(Icons.battery_charging_full, color: color, size: 24);
      case 'inductor':
        return Icon(Icons.settings_ethernet, color: color, size: 24);
      default:
        return Icon(Icons.electrical_services, color: color, size: 24);
    }
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
