import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/application/use_case_adapter.dart';
import 'package:circuit_stem/application/use_cases/toggle_pause_use_case.dart';
import 'package:circuit_stem/application/use_cases/select_palette_component_use_case.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'package:circuit_stem/application/providers.dart';
import 'package:circuit_stem/application/game_engine_state.dart';
import 'package:circuit_stem/application/feature_flag_service.dart';
import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/domain/entities/level_definition.dart';

void main() {
  group('UseCase Integration Tests', () {
    late ProviderContainer container;
    
    setUp(() {
      FeatureFlagService.initialize(userId: 'test_user');

      // Create test level
      final testLevel = LevelDefinition.fromJson({
        'id': 'test-level',
        'title': 'Test Level',
        'description': 'Test level description',
        'levelNumber': 1,
        'author': 'test',
        'version': 1,
        'rows': 5,
        'cols': 5,
        'blockedCells': [],
        'initialComponents': [],
        'paletteComponents': [],
        'goals': [],
        'hints': [],
      });
      
      // Enable runtime feature flags to activate hybrid system during tests.
      // FeatureFlagService is used by providers to decide hybrid vs monolithic wiring.
      FeatureFlagService.setFlag('hybrid_engine', true);
      FeatureFlagService.setFlag('granular_providers', true);

      container = ProviderContainer();
      
      // Initialize with test state
      final orchestrator = container.read(gameEngineOrchestratorProvider.notifier);
      orchestrator.state = GameEngineState.initial(testLevel);
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('TogglePauseUseCase integrates with hybrid system', (tester) async {
      final adapter = container.read(useCaseAdapterProvider);
      final initialState = container.read(gameEngineOrchestratorProvider);
      
      // Verify initial state is not paused
      expect(initialState.isPaused, false);
      
      // Execute toggle pause use case
      final useCase = const TogglePauseUseCase();
      final action = const TogglePauseAction();
      
      final result = await adapter.executeUseCase(useCase, action);
      
      // Verify successful execution
      expect(result.isSuccess, true);
      
      // Verify state changed in orchestrator
      final newState = container.read(gameEngineOrchestratorProvider);
      expect(newState.isPaused, true);
      
      // Verify granular provider also reflects change
      final isPaused = container.read(isPausedProvider);
      expect(isPaused, true);
    });

    testWidgets('SelectPaletteComponentUseCase integrates with hybrid system', (tester) async {
      final adapter = container.read(useCaseAdapterProvider);
      final initialState = container.read(gameEngineOrchestratorProvider);
      
      // Verify initial selection is null
      expect(initialState.selectedComponentId, null);
      
      // Execute select component use case
      const componentId = 'test-component-123';
      final useCase = const SelectPaletteComponentUseCase();
      final action = const SelectPaletteComponentAction(componentId: componentId);
      
      final result = await adapter.executeUseCase(useCase, action);
      
      // Verify successful execution
      expect(result.isSuccess, true);
      
      // Verify state changed in orchestrator
      final newState = container.read(gameEngineOrchestratorProvider);
      expect(newState.selectedComponentId, componentId);
      
      // Verify granular provider also reflects change
      final selectedId = container.read(selectedComponentIdProvider);
      expect(selectedId, componentId);
    });

    test('UseCase adapter preserves transaction atomicity', () async {
      final adapter = container.read(useCaseAdapterProvider);
      
      // Create a use case that should fail validation
      final useCase = const SelectPaletteComponentUseCase();
      const invalidAction = SelectPaletteComponentAction(componentId: ''); // Empty ID should fail
      
      final result = await adapter.executeUseCase(useCase, invalidAction);
      
      // If validation fails, state should remain unchanged
      final state = container.read(gameEngineOrchestratorProvider);
      expect(state.selectedComponentId, null);
      
      // All granular providers should also remain unchanged
      final selectedId = container.read(selectedComponentIdProvider);
      expect(selectedId, null);
    });

    test('UseCase adapter handles multiple sequential operations', () async {
      final adapter = container.read(useCaseAdapterProvider);
      
      // First operation: select component
      const componentId = 'component-1';
      final selectUseCase = const SelectPaletteComponentUseCase();
      final selectAction = const SelectPaletteComponentAction(componentId: componentId);
      
      final selectResult = await adapter.executeUseCase(selectUseCase, selectAction);
      expect(selectResult.isSuccess, true);
      
      // Verify selection worked
      expect(container.read(selectedComponentIdProvider), componentId);
      
      // Second operation: toggle pause
      final pauseUseCase = const TogglePauseUseCase();
      final pauseAction = const TogglePauseAction();
      
      final pauseResult = await adapter.executeUseCase(pauseUseCase, pauseAction);
      expect(pauseResult.isSuccess, true);
      
      // Verify both changes are preserved
      expect(container.read(selectedComponentIdProvider), componentId);
      expect(container.read(isPausedProvider), true);
    });
  });
}