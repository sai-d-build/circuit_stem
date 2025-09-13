import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sparkcircuit/application/providers/unified_providers.dart';
import 'package:sparkcircuit/application/use_cases/component_interaction_use_case.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/core/migration/migration_tracker.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/features/game/painters/component_painter.dart';

// ✅ CLEAN ARCHITECTURE: Component Interaction Service
class ComponentInteractionService {
  final ComponentInteractionUseCase _useCase;

  ComponentInteractionService(this._useCase);

  void handleTap(String componentId) {
    _useCase.handleComponentTap(componentId);
  }

  void handleDragStart(String componentId, Offset position) {
    _useCase.handleComponentDragStart(componentId, position);
  }

  void handleDragUpdate(Offset position) {
    _useCase.handleComponentDragUpdate(position);
  }

  void handleDragEnd() {
    _useCase.handleComponentDragEnd();
  }
}

final componentInteractionServiceProvider =
    Provider.family<ComponentInteractionService, String>((ref, levelId) {
  final useCase = ref.watch(componentInteractionUseCaseProvider(levelId));
  return ComponentInteractionService(useCase);
});

class CircuitComponentWidget extends ConsumerWidget {
  final ComponentModel component;
  final String levelId; // Add levelId parameter

  const CircuitComponentWidget({
    super.key,
    required this.component,
    required this.levelId, // Require levelId
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedComponentId = ref.watch(unifiedGameStateProvider
        .select((state) => state.interactionState.selectedComponentId));
    final isSelected = selectedComponentId == component.id;
    final interactionService =
        ref.watch(componentInteractionServiceProvider(levelId));

    // Mark file as migrated to unified provider
    MigrationTracker.markFileMigrated(
        'lib/presentation/features/game/widgets/circuit_component_widget.dart',
        DateTime.now().toIso8601String());

    // The Positioned widget was removed from here.
    // The parent (GameCanvas) is now responsible for positioning this widget in the Stack.
    return GestureDetector(
      onTap: () {
        StructuredLogger.info('👆 COMPONENT TAPPED', context: {
          'componentId': component.id,
          'componentType': component.type.toString(),
          'currentlySelected': selectedComponentId,
          'willSelectThis': component.id,
          'levelId': levelId,
          'timestamp': DateTime.now().toIso8601String(),
        });
        interactionService.handleTap(component.id);
      },
      onPanStart: (details) {
        StructuredLogger.info('🎯 COMPONENT DRAG STARTED', context: {
          'componentId': component.id,
          'componentType': component.type.toString(),
          'localPosition': details.localPosition.toString(),
          'globalPosition': details.globalPosition.toString(),
          'componentRow': component.row,
          'componentCol': component.col,
          'levelId': levelId,
          'timestamp': DateTime.now().toIso8601String(),
        });
        interactionService.handleDragStart(component.id, details.localPosition);
      },
      onPanUpdate: (details) {
        StructuredLogger.debug('🔄 COMPONENT DRAG UPDATE', context: {
          'componentId': component.id,
          'componentType': component.type.toString(),
          'localPosition': details.localPosition.toString(),
          'globalPosition': details.globalPosition.toString(),
          'delta': details.delta.toString(),
          'levelId': levelId,
          'timestamp': DateTime.now().toIso8601String(),
        });
        interactionService.handleDragUpdate(details.localPosition);
      },
      onPanEnd: (details) {
        StructuredLogger.info('🏁 COMPONENT DRAG ENDED', context: {
          'componentId': component.id,
          'componentType': component.type.toString(),
          'velocity': details.velocity.toString(),
          'levelId': levelId,
          'timestamp': DateTime.now().toIso8601String(),
        });
        interactionService.handleDragEnd();
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
