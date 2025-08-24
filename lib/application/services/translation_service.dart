import 'package:circuit_stem/domain/entities/component.dart'; // Old ComponentModel
import 'package:circuit_stem/domain/entities/component_entity.dart'; // New ComponentEntity
import 'package:circuit_stem/domain/value_objects/component_type.dart';
import 'package:circuit_stem/domain/value_objects/position.dart';
import 'package:circuit_stem/domain/behaviors/behavior.dart';
import 'package:circuit_stem/domain/behaviors/interaction_behavior.dart'; // For ToggleBehavior

class TranslationService {
  /// Convert legacy model to domain entity (one-way only)
  ComponentEntity toDomain(ComponentModel legacyModel) {
    return ComponentEntity(
      id: legacyModel.id,
      type: stringToComponentType(legacyModel.type),
      position: Position(r: legacyModel.r, c: legacyModel.c),
      state: Map<String, dynamic>.from(legacyModel.state),
      behaviors: _createBehaviorsForType(stringToComponentType(legacyModel.type)),
    );
  }

  /// Apply domain changes back to legacy model
  ComponentModel applyDomainChanges(
    ComponentModel original,
    ComponentEntity updated,
  ) {
    return original.copyWith(
      r: updated.position.r,
      c: updated.position.c,
      state: Map<String, dynamic>.from(updated.state),
      // Assuming isPowered is derived from state in the old model, or needs explicit mapping
      // isPowered: updated.state['powered'] as bool? ?? original.isPowered,
    );
  }

  List<Behavior> _createBehaviorsForType(ComponentType type) {
    switch (type) {
      case ComponentType.switchComponent:
        return [ToggleBehavior()];
      // case ComponentType.bulb:
      //   return [PowerConsumptionBehavior()];
      default:
        return [];
    }
  }
}
