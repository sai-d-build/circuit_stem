
import '../models/component.dart';
import '../engine/game_engine_notifier.dart';

/// Defines the interface for how a component reacts to user input.
abstract class InteractionBehavior {
  void onTap(GameEngineNotifierV2 notifier, ComponentModel component);
  void onDragStart(GameEngineNotifierV2 notifier, ComponentModel component);
  void onDragUpdate(GameEngineNotifierV2 notifier, ComponentModel component);
  void onDragEnd(GameEngineNotifierV2 notifier, ComponentModel component);
}
