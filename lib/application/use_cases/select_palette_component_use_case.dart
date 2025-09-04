import '../core/result.dart';
import '../transaction.dart';
import 'component_action.dart';
import 'notifier_integrated_use_case.dart';

class SelectPaletteComponentUseCase extends NotifierIntegratedUseCase<SelectPaletteComponentAction> {
  const SelectPaletteComponentUseCase();

  @override
  Result<void> validate(SelectPaletteComponentAction action, NotifierContext notifiers) {
    if (action.componentId.isEmpty) {
      return const Failure('Component ID cannot be empty');
    }
    return const Success(null);
  }

  @override
  Future<Result<void>> executeWithNotifiers(
    SelectPaletteComponentAction action,
    NotifierContext notifiers,
    GameTransaction transaction,
  ) async {
    // Register selection change with transaction
    transaction.onCommit(() async {
      notifiers.selection.selectComponent(action.componentId);
    });

    // Register rollback handler
    transaction.onRollback(() {
      // Rollback is handled automatically by the selection notifier's transaction support
    });

    return const Success(null);
  }
}