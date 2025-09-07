import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/features/game/painters/component_painter.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';

class CircuitComponentWidget extends ConsumerWidget {
  final ComponentModel component;

  const CircuitComponentWidget({super.key, required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedComponentId = ref.watch(enhancedGameStateNotifierProvider.select((state) => state.interactionState.selectedComponentId));
    final isSelected = selectedComponentId == component.id;

    // The Positioned widget was removed from here.
    // The parent (GameCanvas) is now responsible for positioning this widget in the Stack.
    return GestureDetector(
      onTap: () {
        ref.read(enhancedGameStateNotifierProvider.notifier).tapComponent(component.id);
      },
      onPanStart: (details) {
        ref.read(enhancedGameStateNotifierProvider.notifier).startDragging(component.id, details.localPosition);
      },
      onPanUpdate: (details) {
        ref.read(enhancedGameStateNotifierProvider.notifier).dragUpdate(details.localPosition);
      },
      onPanEnd: (details) {
        ref.read(enhancedGameStateNotifierProvider.notifier).endDragging();
      },
      child: Stack(
        children: [
          // Main component
          CustomPaint(
            painter: ComponentPainter(
              components: [CircuitComponent.fromComponentModel(component)],
              circuitColors: Theme.of(context).extension<CircuitColorScheme>()!,
              selectedComponentId: selectedComponentId,
            ),
            size: const Size(60, 60),
          ),

          // Visual indicator overlay for placed components
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue[600] : Colors.green[600],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
              ),
              child: Text(
                _getComponentTypeAbbrev(component.type),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Grid position indicator (bottom left)
          Positioned(
            bottom: 2,
            left: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${component.row},${component.col}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 6,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getComponentTypeAbbrev(ComponentType type) {
    switch (type) {
      case ComponentType.battery:
        return 'BAT';
      case ComponentType.resistor:
        return 'RES';
      case ComponentType.bulb:
        return 'LED';
      case ComponentType.wire:
        return 'WIR';
      case ComponentType.switch_:
        return 'SWT';
      case ComponentType.capacitor:
        return 'CAP';
      case ComponentType.inductor:
        return 'IND';
      case ComponentType.buzzer:
        return 'BUZ';
      default:
        return 'UNK';
    }
  }
}
