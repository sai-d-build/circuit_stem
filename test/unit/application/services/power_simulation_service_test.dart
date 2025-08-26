import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/services/power_simulation_service.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/grid.dart';

void main() {
  group('PowerSimulationService', () {
    late PowerSimulationService simulationService;

    setUp(() {
      simulationService = const PowerSimulationService();
    });

    test('powers a simple circuit with a battery and a wire', () {
      // Arrange
      final components = [
        const ComponentModel(
          id: 'battery',
          type: 'battery',
          r: 0,
          c: 0,
          terminals: [
            TerminalSpec(offset: CellOffset(0, 0), direction: Dir.south, type: TerminalType.power),
          ],
        ),
        const ComponentModel(
          id: 'wire',
          type: 'wire',
          r: 1,
          c: 0,
          terminals: [
            TerminalSpec(offset: CellOffset(0, 0), direction: Dir.north, type: TerminalType.power),
            TerminalSpec(offset: CellOffset(0, 0), direction: Dir.south, type: TerminalType.power),
          ],
        ),
      ];
      var grid = Grid(rows: 2, cols: 1, components: components);

      // Act
      grid = simulationService.simulatePowerFlow(grid);

      // Assert
      final wire = grid.componentsById['wire'];
      expect(wire, isNotNull);
      expect(wire!.isPowered, isTrue);
    });
  });
}
