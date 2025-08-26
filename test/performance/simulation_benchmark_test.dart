
import 'package:flutter_test/flutter_test.dart';
import 'package:circuit_stem/application/services/power_simulation_service.dart';
import 'package:circuit_stem/domain/entities/component.dart';
import 'package:circuit_stem/domain/entities/grid.dart';

void main() {
  group('PowerSimulationService Benchmarks', () {
    late PowerSimulationService simulationService;

    setUp(() {
      simulationService = const PowerSimulationService();
    });

    test('Benchmark power simulation on a large grid', () {
      // Arrange
      const gridSize = 100;
      final components = <ComponentModel>[];

      // Create a complex grid
      for (var r = 0; r < gridSize; r++) {
        for (var c = 0; c < gridSize; c++) {
          final type = (r + c) % 3 == 0 ? 'battery' : 'wire';
          components.add(
            ComponentModel(
              id: 'c_${r}_$c',
              type: type,
              r: r,
              c: c,
              terminals: [
                const TerminalSpec(offset: CellOffset(0, 0), direction: Dir.north, type: TerminalType.power),
                const TerminalSpec(offset: CellOffset(0, 0), direction: Dir.south, type: TerminalType.power),
                const TerminalSpec(offset: CellOffset(0, 0), direction: Dir.east, type: TerminalType.power),
                const TerminalSpec(offset: CellOffset(0, 0), direction: Dir.west, type: TerminalType.power),
              ],
            ),
          );
        }
      }

      final grid = Grid(rows: gridSize, cols: gridSize, components: components);

      // Act
      const numberOfRuns = 10;
      final stopwatch = Stopwatch()..start();
      for (var i = 0; i < numberOfRuns; i++) {
        simulationService.simulatePowerFlow(grid);
      }
      stopwatch.stop();

      // Assert
      final averageTime = stopwatch.elapsedMilliseconds / numberOfRuns;
      print('Average simulation time for a $gridSize x $gridSize grid: $averageTime ms');
      expect(averageTime, lessThan(1000)); // Expect it to be reasonably fast
    });
  });
}
