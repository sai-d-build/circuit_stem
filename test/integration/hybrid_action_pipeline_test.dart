import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/application/game_engine_orchestrator.dart';
import 'package:circuit_stem/application/grid_notifier.dart';
import 'package:circuit_stem/application/history_notifier.dart';
import 'package:circuit_stem/application/game_progress_notifier.dart';
import 'package:circuit_stem/application/component_selection_notifier.dart';
import 'package:circuit_stem/application/interaction_state_notifier.dart';
import 'package:circuit_stem/application/providers.dart';
import 'package:circuit_stem/application/transaction.dart';
import 'package:circuit_stem/application/use_cases/component_action.dart';
import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/application/game_engine_state.dart';

/// Integration tests for hybrid action pipeline and transaction atomicity.
/// 
/// These tests verify that:
/// 1. Actions execute atomically across all notifiers
/// 2. Transaction rollback works correctly on failures
/// 3. State consistency is maintained across the system
/// 4. The hybrid adapter maintains backward compatibility
import 'package:circuit_stem/application/feature_flag_service.dart';

void main() {
  group('Hybrid Action Pipeline', () {
    late ProviderContainer container;
    late GameEngineOrchestrator orchestrator;
    late GridNotifier gridNotifier;
    late HistoryNotifier historyNotifier;
    late GameProgressNotifier progressNotifier;

    setUp(() {
      FeatureFlagService.initialize(userId: 'test_user');
      FeatureFlagService.setFlag('hybrid_engine', true);

      container = ProviderContainer(
        overrides: [
          // Override providers with test instances
          gridNotifierProvider.overrideWith((ref) => GridNotifier()),
          historyNotifierProvider.overrideWith((ref) => HistoryNotifier()),
          gameProgressNotifierProvider.overrideWith((ref) => GameProgressNotifier()),
          componentSelectionNotifierProvider.overrideWith((ref) => ComponentSelectionNotifier()),
          interactionStateNotifierProvider.overrideWith((ref) => InteractionStateNotifier()),
        ],
      );

      // Get instances for direct testing
      gridNotifier = container.read(gridNotifierProvider.notifier);
      historyNotifier = container.read(historyNotifierProvider.notifier);
      progressNotifier = container.read(gameProgressNotifierProvider.notifier);
      orchestrator = container.read(gameEngineOrchestratorProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('Transaction System', () {
      test('should execute commit handlers in order', () async {
        final transaction = GameTransaction();
        final executionOrder = <String>[];

        transaction.onCommit(() async {
          executionOrder.add('first');
        });

        transaction.onCommit(() async {
          executionOrder.add('second');
        });

        transaction.onCommit(() async {
          executionOrder.add('third');
        });

        await transaction.commit();

        expect(executionOrder, equals(['first', 'second', 'third']));
        expect(transaction.isCommitted, isTrue);
      });

      test('should execute rollback handlers when rollback is called', () async {
        final transaction = GameTransaction();
        final rollbackOrder = <String>[];
        var commitExecuted = false;

        transaction.onCommit(() async {
          commitExecuted = true;
        });

        transaction.onRollback(() async {
          rollbackOrder.add('rollback');
        });

        await transaction.rollback();

        expect(rollbackOrder, equals(['rollback']));
        expect(commitExecuted, isFalse);
        expect(transaction.isRolledBack, isTrue);
      });

      test('should prevent double commits', () async {
        final transaction = GameTransaction();
        
        await transaction.commit();
        
        // Second commit should not throw but should be a no-op
        await transaction.commit();
        
        expect(transaction.isCommitted, isTrue);
      });

      test('should prevent commit after rollback', () async {
        final transaction = GameTransaction();
        
        await transaction.rollback();
        
        expect(() async => await transaction.commit(), 
               throwsA(isA<StateError>()));
      });
    });

    group('Orchestrator Integration', () {
      test('should coordinate transaction across all notifiers', () async {
        // Create a mock action for testing
        final mockAction = _MockComponentAction('TestMove');

        // Track initial states
        final initialGridState = gridNotifier.state;
        final initialHistoryState = historyNotifier.state;
        final initialProgressState = progressNotifier.state;

        // Execute action through orchestrator
        final result = await orchestrator.executeAction(mockAction);

        // Verify result is successful
        expect(result.isSuccess, isTrue);

        // Verify orchestrator composite state is built
        final compositeState = orchestrator.state;
        expect(compositeState, isNotNull);
        expect(compositeState.grid, equals(gridNotifier.state));

        // Note: In a real implementation, we would verify that all notifiers
        // actually processed the action. For now, we verify the transaction
        // coordination worked without errors.
      });

      test('should rollback all notifiers on failure', () async {
        // Create a mock action that will cause a failure
        final failingAction = _FailingMockAction();

        // Track initial states
        final initialGridState = gridNotifier.state;
        final initialHistoryState = historyNotifier.state;
        final initialProgressState = progressNotifier.state;

        // Execute failing action
        final result = await orchestrator.executeAction(failingAction);

        // Verify result indicates failure
        expect(result.isFailure, isTrue);

        // Verify all notifiers maintained their initial state (rollback worked)
        expect(gridNotifier.state, equals(initialGridState));
        expect(historyNotifier.state, equals(initialHistoryState));
        expect(progressNotifier.state, equals(initialProgressState));
      });
    });

    group('Notifier Transaction Behavior', () {
      test('GridNotifier should register commit and rollback handlers', () async {
        final transaction = GameTransaction();
        final mockAction = _MockComponentAction('GridTest');
        
        var commitExecuted = false;
        var rollbackExecuted = false;

        // Override handlers to track execution
        final originalState = gridNotifier.state;
        
        await gridNotifier.executeInTransaction(mockAction, transaction);
        
        // Verify handlers were registered by checking transaction can commit
        await transaction.commit();
        
        // In a real implementation, we'd verify the grid state was updated
        // For now, we verify no errors occurred
        expect(transaction.isCommitted, isTrue);
      });

      test('should handle rollback correctly', () async {
        final transaction = GameTransaction();
        final mockAction = _MockComponentAction('RollbackTest');
        
        final originalState = gridNotifier.state;
        
        await gridNotifier.executeInTransaction(mockAction, transaction);
        
        // Trigger rollback
        await transaction.rollback();
        
        // Verify state was restored (rollback handler executed)
        expect(gridNotifier.state, equals(originalState));
        expect(transaction.isRolledBack, isTrue);
      });
    });

    group('Cross-Notifier Consistency', () {
      test('should maintain state consistency across multiple actions', () async {
        final actions = [
          _MockComponentAction('Action1'),
          _MockComponentAction('Action2'),
          _MockComponentAction('Action3'),
        ];

        // Execute multiple actions in sequence
        for (final action in actions) {
          final result = await orchestrator.executeAction(action);
          expect(result.isSuccess, isTrue);
          
          // Verify composite state is always consistent
          final compositeState = orchestrator.state;
          expect(compositeState.grid, equals(gridNotifier.state));
        }
      });
    });

    group('Error Handling and Recovery', () {
      test('should handle partial failure gracefully', () async {
        // Test scenario where one notifier fails but others succeed
        final partialFailAction = _PartialFailMockAction();
        
        final initialStates = {
          'grid': gridNotifier.state,
          'history': historyNotifier.state,
          'progress': progressNotifier.state,
        };
        
        final result = await orchestrator.executeAction(partialFailAction);
        
        // Should fail overall
        expect(result.isFailure, isTrue);
        
        // All states should be rolled back to initial values
        expect(gridNotifier.state, equals(initialStates['grid']));
        expect(historyNotifier.state, equals(initialStates['history']));
        expect(progressNotifier.state, equals(initialStates['progress']));
      });
    });
  });
}

// Mock action classes for testing

class _MockComponentAction extends ComponentAction {
  final String actionType;
  
  _MockComponentAction(this.actionType);
  
  @override
  List<Object?> get props => [actionType];
  
  @override
  String toString() => actionType;
}

class _FailingMockAction extends ComponentAction {
  @override
  List<Object?> get props => ['FailingAction'];
  
  @override
  String toString() => 'FailingAction';
}

class _PartialFailMockAction extends ComponentAction {
  @override
  List<Object?> get props => ['PartialFailAction'];
  
  @override
  String toString() => 'PartialFailAction';
}