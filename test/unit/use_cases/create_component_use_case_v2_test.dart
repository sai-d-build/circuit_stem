import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/use_cases/create_component_use_case_v2.dart';
import 'package:circuit_stem/application/services/power_simulation_service.dart';
import 'package:circuit_stem/application/services/component_factory.dart';
import 'package:circuit_stem/application/use_cases/notifier_integrated_use_case.dart';
import 'package:circuit_stem/application/grid_notifier.dart';
import 'package:circuit_stem/application/history_notifier.dart';
import 'package:circuit_stem/application/game_progress_notifier.dart';
import 'package:circuit_stem/application/component_selection_notifier.dart';
import 'package:circuit_stem/application/interaction_state_notifier.dart';
import 'package:circuit_stem/application/transaction.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'package:circuit_stem/application/services/component_palette_manager.dart';

void main() {
  group('CreateComponentFromTemplateUseCaseV2 (smoke tests)', () {
    test('validate returns Failure for negative coordinates', () {
      final simulation = PowerSimulationService();
      final factory = ComponentFactory();
      final grid = GridNotifier();
      final history = HistoryNotifier();
      final progress = GameProgressNotifier();
      final selection = ComponentSelectionNotifier();
      final interaction = InteractionStateNotifier();

      final context = NotifierContext(
        grid: grid,
        history: history,
        progress: progress,
        selection: selection,
        interaction: interaction,
        paletteManager: const ComponentPaletteManager([]),
      );

      final useCase = CreateComponentFromTemplateUseCaseV2(simulation, factory);
      final action = CreateComponentFromTemplateAction(
        templateId: 'tpl',
        row: -1,
        col: 0,
      );

      final result = useCase.validate(action, context);
      expect(result.isFailure, true);
    });

    test('executeWithNotifiers returns Failure for missing template', () async {
      final simulation = PowerSimulationService();
      final factory = ComponentFactory();
      final grid = GridNotifier();
      final history = HistoryNotifier();
      final progress = GameProgressNotifier();
      final selection = ComponentSelectionNotifier();
      final interaction = InteractionStateNotifier();

      final context = NotifierContext(
        grid: grid,
        history: history,
        progress: progress,
        selection: selection,
        interaction: interaction,
        paletteManager: const ComponentPaletteManager([]),
      );

      final useCase = CreateComponentFromTemplateUseCaseV2(simulation, factory);
      final action = CreateComponentFromTemplateAction(
        templateId: 'non-existent-template',
        row: 1,
        col: 1,
      );

      final tx = GameTransaction();
      final result = await useCase.executeWithNotifiers(action, context, tx);
      expect(result.isFailure, true);
    });
  });
}
