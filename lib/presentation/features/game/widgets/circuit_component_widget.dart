import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/enhanced_game_state.dart';
import 'package:sparkcircuit/application/providers.dart';
import 'package:sparkcircuit/domain/entities/component.dart';
import 'package:sparkcircuit/presentation/features/game/painters/component_painter.dart';
import 'package:sparkcircuit/presentation/models/circuit_drawing_models.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';

class CircuitComponentWidget extends ConsumerWidget {
  final ComponentModel component;

  const CircuitComponentWidget({super.key, required this.component});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedComponentId = ref.watch(enhancedGameStateNotifierProvider.select((state) => (state as GameState).interactionState.selectedComponentId));
    final isSelected = selectedComponentId == component.id;

    return Positioned(
      left: component.col * 60.0,
      top: component.row * 60.0,
      child: GestureDetector(
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
        child: CustomPaint(
          painter: ComponentPainter(
            components: [CircuitComponent.fromComponentModel(component)],
            circuitColors: Theme.of(context).extension<CircuitColorScheme>()!,
            selectedComponentId: selectedComponentId,
          ),
          size: const Size(60, 60),
        ),
      ),
    );
  }
}