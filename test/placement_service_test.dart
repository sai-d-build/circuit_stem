import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/application/services/placement_service.dart';
import 'package:sparkcircuit/application/states/game_state.dart';
import 'package:sparkcircuit/application/states/history_state.dart';
import 'package:sparkcircuit/application/states/interaction_state.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';

void main() {
  group('PlacementService', () {
    late PlacementService placementService;
    late GameState initialState;

    GameState createInitialState() {
      return GameState(
        grid: Grid(rows: 10, cols: 15), // Standard 10x15 grid
        isPaused: false,
        isWin: false,
        lastUpdated: DateTime.now(),
        interactionState: InteractionState.initial(),
        history: HistoryState.initial(),
      );
    }

    setUp(() {
      placementService = PlacementService();
      initialState = createInitialState();
    });

    test('should place component successfully', () {
      const transactionId = 'test_tx_1';
      const componentType = ComponentType.resistor;
      const row = 1;
      const col = 2;

      final result = placementService.placeComponentWithTransaction(
        transactionId: transactionId,
        componentType: componentType,
        row: row,
        col: col,
        currentState: initialState,
      );

      expect(result, isTrue);
      expect(placementService.isTransactionActive(transactionId), isTrue);
    });

    test('should reject duplicate transactions', () {
      const transactionId = 'test_tx_2';
      const componentType = ComponentType.battery;
      const row = 2;
      const col = 3;

      // First placement should succeed
      final firstResult = placementService.placeComponentWithTransaction(
        transactionId: transactionId,
        componentType: componentType,
        row: row,
        col: col,
        currentState: initialState,
      );
      expect(firstResult, isTrue);

      // Second placement with same transaction ID should be rejected
      final secondResult = placementService.placeComponentWithTransaction(
        transactionId: transactionId,
        componentType: componentType,
        row: row,
        col: col,
        currentState: initialState,
      );
      expect(secondResult, isFalse);
    });

    test('should reject placement on occupied position', () {
      const transactionId = 'test_tx_3';
      const componentType = ComponentType.wire;
      const row = 0;
      const col = 0;

      // Create state with component already at (0,0)
      final existingComponent = ComponentModel(
        id: 'existing_comp',
        type: ComponentType.wire,
        row: row,
        col: col,
      );
      final occupiedGrid = initialState.grid.placeComponent(existingComponent);
      final occupiedState = initialState.copyWith(grid: occupiedGrid);

      final result = placementService.placeComponentWithTransaction(
        transactionId: transactionId,
        componentType: componentType,
        row: row,
        col: col,
        currentState: occupiedState,
      );

      expect(result, isFalse);
    });

    test('should reject placement outside grid bounds', () {
      const transactionId = 'test_tx_4';
      const componentType = ComponentType.capacitor;
      const row = 99; // Outside bounds
      const col = 99; // Outside bounds

      final result = placementService.placeComponentWithTransaction(
        transactionId: transactionId,
        componentType: componentType,
        row: row,
        col: col,
        currentState: initialState,
      );

      expect(result, isFalse);
    });

    test('should track active transaction count', () {
      expect(placementService.activeTransactionCount, 0);

      // Add a transaction
      placementService.placeComponentWithTransaction(
        transactionId: 'test_tx_5',
        componentType: ComponentType.inductor,
        row: 1,
        col: 1,
        currentState: initialState,
      );

      expect(placementService.activeTransactionCount, 1);

      // Clear transactions
      placementService.clearTransactions();
      expect(placementService.activeTransactionCount, 0);
    });
  });
}
