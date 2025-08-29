import '../core/result.dart';
import '../transaction.dart';
import '../grid_notifier.dart';
import '../history_notifier.dart';
import '../game_progress_notifier.dart';
import '../component_selection_notifier.dart';
import '../interaction_state_notifier.dart';
import '../services/component_palette_manager.dart';
import 'component_action.dart';
 
/// Context object passed to notifier-integrated use cases
class NotifierContext {
  final GridNotifier grid;
  final HistoryNotifier history;
  final GameProgressNotifier progress;
  final ComponentSelectionNotifier selection;
  final InteractionStateNotifier interaction;
  final ComponentPaletteManager paletteManager;
  
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