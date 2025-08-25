import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/application/game_context.dart';
import 'behavior.dart';

/// A pure behavior for moving a component.
/// Depends only on the component + context (no side effects).
class MoveBehavior extends ComponentBehavior {
  @override
  String get behaviorType => 'move';

  @override
  ComponentModel? handle(
    ComponentModel component,
    String action,
    GameContext context,
  ) {
    if (action != 'move') return null;
    if (context.toRow == null || context.toCol == null) return null;

    return component.copyWith(
      r: context.toRow!,
      c: context.toCol!,
    );
  }
}
