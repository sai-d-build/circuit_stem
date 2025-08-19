
import '../models/component.dart';
import '../engine/game_engine_notifier.dart';

/// Defines the interface for how a component reacts to user input.
abstract class InteractionBehavior {
  void onTap(GameEngineNotifier notifier, ComponentModel component);
  void onDragStart(GameEngineNotifier notifier, ComponentModel component);
  void onDragUpdate(GameEngineNotifier notifier, ComponentModel component);
  void onDragEnd(GameEngineNotifier notifier, ComponentModel component);
}
