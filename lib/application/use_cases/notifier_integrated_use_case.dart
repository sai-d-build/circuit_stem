import '../core/result.dart';
import '../transaction.dart';
import 'component_action.dart';

/// Context object passed to notifier-integrated use cases
class NotifierContext {
  final dynamic grid;
  final dynamic history;
  final dynamic progress;
  final dynamic selection;
  final dynamic interaction;
  final dynamic paletteManager;
  
  const NotifierContext({
    required this.grid,
    required this.history,
    required this.progress,
    required this.selection,
    required this.interaction,
    required this.paletteManager,
  });
}
 
/// Interface for use cases that work directly with granular notifiers
/// instead of producing a full GameEngineState diff
abstract class NotifierIntegratedUseCase<TAction extends ComponentAction> {
  const NotifierIntegratedUseCase();
 
  /// Execute the use case by applying changes directly to notifiers within a transaction
  /// This is more efficient than the legacy approach as it avoids state diff computation
  Future<Result<void>> executeWithNotifiers(
    TAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  );
 
  /// Validate the action before execution (optional override)
  Result<void> validate(TAction action, NotifierContext notifiers) {
    return const Success(null);
  }
}