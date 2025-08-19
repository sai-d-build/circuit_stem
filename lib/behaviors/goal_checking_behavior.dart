
import '../engine/game_engine_state.dart';

/// Defines the interface for checking if a goal is met.
abstract class GoalCheckingBehavior {
  bool isMet(GameEngineState state);
}
