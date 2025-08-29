import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/services/power_simulation_service.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/grid.dart';
import 'package:circuit_stem/common/logger.dart'; // Added import

void main() {
  group('PowerSimulationService', () {
    late PowerSimulationService simulationService;

    setUp(() {
      simulationService = const PowerSimulationService();
    });

    test('powers a circuit with a correctly oriented diode', () {
      // Arrange
      final components = [
        const ComponentModel(
          id: 'battery',
          type: 'battery',
          r: 0,
          c: 0,
          terminals: [
            TerminalSpec(
                offset: CellOffset(0, 0),
                direction: Dir.south,
                type: TerminalType.power),
          ],
        ),
        const ComponentModel(
          id: 'diode',
          type: 'diode',
          r: 1,
          c: 0,
          rotation: 0, // Assuming 0 degrees is anode at top, cathode at bottom
          terminals: [
            TerminalSpec(
                offset: CellOffset(0, 0),
                direction: Dir.north,
                type: TerminalType.power), // Anode
            TerminalSpec(
                offset: CellOffset(0, 0),
                direction: Dir.south,
                type: TerminalType.power), // Cathode
          ],
        ),
        const ComponentModel(
          id: 'wire',
          type: 'wire',
          r: 2,
          c: 0,
          terminals: [
            TerminalSpec(
                offset: CellOffset(0, 0),
                direction: Dir.north,
                type: TerminalType.power),
          ],
        ),
      ];
      var grid = Grid(rows: 3, cols: 1, components: components);

      // Act
      grid = simulationService.simulatePowerFlow(grid);

      // Assert
      final wire = grid.componentsById['wire'];
      expect(wire, isNotNull);
      Logger.log('Wire isPowered: ${wire!.isPowered}'); // Added log
      expect(wire!.isPowered, isTrue);
    });

    test('does not power a circuit with an incorrectly oriented diode', () {
      // Arrange
      final components = [
        const ComponentModel(
          id: 'battery',
          type: 'battery',
          r: 0,
          c: 0,
          terminals: [
            TerminalSpec(
                offset: CellOffset(0, 0),
                direction: Dir.south,
                type: TerminalType.power),
          ],
        ),
        const ComponentModel(
          id: 'diode',
          type: 'diode',
          r: 1,
          c: 0,
          rotation:
              2, // Assuming 2 is 180 degrees, so cathode at top, anode at bottom
          terminals: [
            TerminalSpec(
                offset: CellOffset(0, 0),
                direction: Dir.north,
                type: TerminalType.power), // Cathode
            TerminalSpec(
                offset: CellOffset(0, 0),
                direction: Dir.south,
                type: TerminalType.power), // Anode
          ],
        ),
        const ComponentModel(
          id: 'wire',
          type: 'wire',
          r: 2,
          c: 0,
          terminals: [
            TerminalSpec(
                offset: CellOffset(0, 0),
                direction: Dir.north,
                type: TerminalType.power),
          ],
        ),
      ];
      var grid = Grid(rows: 3, cols: 1, components: components);

      // Act
      grid = simulationService.simulatePowerFlow(grid);

      // Assert
      final wire = grid.componentsById['wire'];
      expect(wire, isNotNull);
      expect(wire!.isPowered, isFalse);
    });
  });
}
