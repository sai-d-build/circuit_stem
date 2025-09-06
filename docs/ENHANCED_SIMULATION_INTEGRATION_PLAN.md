# 🚀 Enhanced Simulation Integration Plan

## Executive Summary

This plan outlines the implementation of advanced simulation capabilities for the circuit simulation system, building upon the foundational wire active state detection already implemented. The enhanced simulation system will provide real-time circuit analysis, component interaction modeling, and interactive feedback mechanisms.

## Current State Assessment

### ✅ Completed Foundation
- Basic wire activity detection implemented in `CanvasWireLayer` and `GameCanvas`
- Wire connections render with active/inactive states based on power sources
- Provider architecture supports real-time state updates
- Layered UI components ready for simulation overlays

### 🎯 Enhancement Opportunities
- Expand from wire-only activity to full circuit simulation
- Add real-time component behavior modeling
- Implement user interaction feedback
- Create extensible measurement and analysis tools

## Phase 1: Circuit Analysis Engine (Week 1-2)

### Core Simulation Components

#### 1. Circuit Analysis Service
```dart
// lib/application/services/interfaces/circuit_simulation_service.dart
abstract class CircuitSimulationService {
  Future<CircuitAnalysisResult> analyzeCircuit(String levelId);
  Stream<CircuitState> watchCircuitState(String levelId);
  Future<ComponentBehavior> simulateComponentInteraction(String componentId, InteractionType type);
}
```

#### 2. Real-Time State Manager
```dart
// lib/application/states/circuit_state.dart
@freezed
class CircuitAnalysisResult with _$CircuitAnalysisResult {
  const factory CircuitAnalysisResult({
    required bool isCircuitComplete,
    required List<PoweredPath> poweredPaths,
    required List<ComponentState> componentStates,
    required CircuitMetrics metrics,
    @Default([]) List<String> warnings,
  }) = _CircuitAnalysisResult;
}

@freezed
class ComponentState with _$ComponentState {
  const factory ComponentState({
    required String componentId,
    required ComponentType type,
    required PowerState powerState,
    required double voltage,
    required double current,
    @Default(false) bool isOverloaded,
  }) = _ComponentState;
}
```

#### 3. Power Path Tracing
```dart
// lib/domain/models/power_system.dart
class PowerPathTracer {
  List<PoweredPath> tracePowerPaths(Grid grid, List<ComponentModel> components) {
    final paths = <PoweredPath>[];
    final visited = <String>{};

    // Find all battery components
    final batteries = components.where((c) => c.type == ComponentType.battery);

    for (final battery in batteries) {
      final path = _traceFromPowerSource(grid, battery.id, visited);
      if (path.isNotEmpty) {
        paths.add(PoweredPath(
          sourceId: battery.id,
          components: path,
          totalResistance: _calculatePathResistance(grid, path),
        ));
      }
    }

    return paths;
  }
}
```

## Phase 2: Visual Feedback System (Week 3-4)

### Enhanced UI Components

#### 1. Circuit Status Overlay
```dart
// lib/presentation/features/game/widgets/circuit_status_overlay.dart
class CircuitStatusOverlay extends ConsumerWidget {
  final String levelId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulationState = ref.watch(circuitSimulationProvider(levelId));

    return Positioned.fill(
      child: IgnorePointer(
        child: CustomPaint(
          painter: CircuitStatusPainter(
            poweredPaths: simulationState.poweredPaths,
            componentStates: simulationState.componentStates,
            warnings: simulationState.warnings,
          ),
        ),
      ),
    );
  }
}
```

#### 2. Interactive Component Feedback
```dart
// lib/presentation/features/game/widgets/interactive_component_feedback.dart
class InteractiveComponentFeedback extends ConsumerWidget {
  final ComponentModel component;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final componentState = ref.watch(
      circuitSimulationProvider(component.levelId)
          .select((state) => state.componentStates[component.id])
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        border: Border.all(
          color: _getComponentColor(componentState),
          width: componentState?.isSelected ?? false ? 3.0 : 1.0,
        ),
        boxShadow: componentState?.powerState == PowerState.powered
            ? [BoxShadow(color: Colors.yellow.withOpacity(0.3), blurRadius: 8)]
            : null,
      ),
      child: // Existing component widget
    );
  }
}
```

#### 3. Real-Time Metrics Display
```dart
// lib/presentation/features/game/widgets/simulation_metrics_display.dart
class SimulationMetricsDisplay extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final simulationState = ref.watch(circuitSimulationProvider);

    return Positioned(
      top: 16,
      right: 16,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Circuit Analysis',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              _buildMetric('Voltage', '${simulationState.metrics.averageVoltage.toStringAsFixed(1)}V'),
              _buildMetric('Current', '${simulationState.metrics.totalCurrent.toStringAsFixed(2)}A'),
              _buildMetric('Power', '${simulationState.metrics.totalPower.toStringAsFixed(1)}W'),
              _buildMetric('Efficiency', '${(simulationState.metrics.efficiency * 100).toStringAsFixed(0)}%'),

              if (simulationState.warnings.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...simulationState.warnings.map((warning) => Text(
                  warning,
                  style: TextStyle(color: Colors.orange.shade700, fontSize: 12),
                )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
```

## Phase 3: Component Behavior Modeling (Week 5-6)

### Advanced Component Simulations

#### 1. Switch Toggle Simulation
```dart
// lib/domain/behaviors/switch_behavior.dart
class SwitchBehavior extends ComponentBehavior {
  @override
  Future<ComponentState> onInteraction(ComponentModel component, InteractionEvent event) async {
    if (event.type == InteractionType.toggle) {
      final newState = component.properties['isOn'] == true ? false : true;

      return ComponentState(
        componentId: component.id,
        type: ComponentType.switch_,
        powerState: newState ? PowerState.powered : PowerState.unpowered,
        voltage: newState ? 5.0 : 0.0,
        current: newState ? 0.1 : 0.0,
      );
    }

    return component.currentState;
  }
}
```

#### 2. Resistor Load Calculation
```dart
// lib/domain/behaviors/resistor_behavior.dart
class ResistorBehavior extends ComponentBehavior {
  @override
  Future<ComponentState> onPowerFlow(ComponentModel component, PowerFlowState flowState) async {
    final resistance = component.properties['resistance'] ?? 100.0; // ohms
    final voltage = flowState.inputVoltage;
    final current = voltage / resistance;

    return ComponentState(
      componentId: component.id,
      type: ComponentType.resistor,
      powerState: voltage > 0 ? PowerState.powered : PowerState.unpowered,
      voltage: voltage,
      current: current,
      power: voltage * current,
    );
  }
}
```

#### 3. LED Brightness Simulation
```dart
// lib/domain/behaviors/led_behavior.dart
class LEDBehavior extends ComponentBehavior {
  @override
  Future<ComponentState> onPowerFlow(ComponentModel component, PowerFlowState flowState) async {
    final voltage = flowState.inputVoltage;
    final current = flowState.inputCurrent;

    // LED characteristics
    final forwardVoltage = 2.1; // V
    final maxCurrent = 0.02; // A

    if (voltage >= forwardVoltage && current <= maxCurrent) {
      final brightness = (voltage - forwardVoltage) / (5.0 - forwardVoltage); // Normalized

      return ComponentState(
        componentId: component.id,
        type: ComponentType.led,
        powerState: PowerState.powered,
        voltage: voltage,
        current: current,
        brightness: brightness.clamp(0.0, 1.0),
        isOverloaded: current > maxCurrent,
      );
    }

    return ComponentState(
      componentId: component.id,
      type: ComponentType.led,
      powerState: PowerState.unpowered,
      voltage: voltage,
      current: 0,
      brightness: 0.0,
    );
  }
}
```

## Phase 4: Integration & Optimization (Week 7-8)

### System Integration

#### 1. Game Engine Integration
```dart
// lib/application/game_engine/v3/game_engine_notifier_v3.dart
class GameEngineNotifierV3 extends StateNotifier<GameState> {
  final CircuitSimulationService _simulationService;

  Future<void> _updateSimulationOnComponentChange(ComponentModel component) async {
    final analysisResult = await _simulationService.analyzeCircuit(component.levelId);

    // Update game state with simulation results
    state = state.copyWith(
      grid: state.grid.copyWith(
        components: state.grid.components.map((id, comp) {
          final simState = analysisResult.componentStates[id];
          return MapEntry(id, comp.copyWith(
            voltage: simState?.voltage,
            current: simState?.current,
            powerState: simState?.powerState,
          ));
        }),
      ),
      simulationResult: analysisResult,
    );
  }
}
```

#### 2. Canvas Integration
```dart
// lib/presentation/features/game/widgets/game_canvas.dart
class _GameCanvasState extends ConsumerState<GameCanvas> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          // Base canvas layers
          CanvasDragDropLayer(levelId: widget.levelId),
          CanvasWireLayer(levelId: widget.levelId),
          CanvasComponentLayer(levelId: widget.levelId),
          CanvasGestureLayer(levelId: widget.levelId),

          // Enhanced simulation overlays
          CircuitStatusOverlay(levelId: widget.levelId),
          SimulationMetricsDisplay(),
          ConnectionFlowVisualization(levelId: widget.levelId),
        ],
      ),
    );
  }
}
```

#### 3. Performance Monitoring
```dart
// lib/application/performance/simulation_performance_monitor.dart
class SimulationPerformanceMonitor {
  final StreamController<SimulationMetrics> _metricsController =
      StreamController<SimulationMetrics>.broadcast();

  void recordAnalysisTime(String levelId, Duration time) {
    _metricsController.add(SimulationMetrics(
      levelId: levelId,
      analysisDuration: time,
      timestamp: DateTime.now(),
    ));

    // Adaptive quality based on performance
    if (time > const Duration(milliseconds: 100)) {
      _reduceSimulationQuality();
    }
  }

  void _reduceSimulationQuality() {
    // Reduce update frequency or complexity
    // Cache simulation results
    // Implement level-of-detail system
  }
}
```

## Technical Implementation Details

### State Management Architecture

```dart
// Enhanced provider structure
final circuitSimulationProvider = StateNotifierProvider.family<
    CircuitSimulationNotifier,
    CircuitSimulationState,
    String>((ref, levelId) {

  final gameState = ref.watch(enhancedGameStateNotifierProvider);
  final simulationService = ref.watch(circuitSimulationServiceProvider);

  return CircuitSimulationNotifier(
    levelId: levelId,
    gameState: gameState,
    simulationService: simulationService,
  );
});
```

### Real-Time Updates

```dart
// Reactive simulation updates
class CircuitSimulationNotifier extends StateNotifier<CircuitSimulationState> {
  Timer? _analysisTimer;

  void startRealTimeAnalysis() {
    _analysisTimer = Timer.periodic(
      const Duration(milliseconds: 100), // 10 FPS simulation updates
      (_) => _performCircuitAnalysis(),
    );
  }

  Future<void> _performCircuitAnalysis() async {
    final result = await _simulationService.analyzeCircuit(levelId);

    if (mounted) {
      state = state.copyWith(
        analysisResult: result,
        lastUpdate: DateTime.now(),
      );
    }
  }
}
```

## Testing Strategy

### Unit Tests
- Component behavior validation
- Circuit analysis accuracy
- State management correctness

### Integration Tests
- End-to-end circuit simulation
- UI feedback mechanisms
- Performance benchmarks

### Performance Tests
- Circuit complexity vs analysis time
- Memory usage with large circuits
- Frame rate under simulation load

## Success Metrics

### Technical KPIs
- Circuit analysis time: <50ms for medium complexity circuits
- Real-time update frequency: 10 FPS minimum
- Memory usage: <50MB for simulation state
- Accuracy: 99% for power flow calculations

### User Experience KPIs
- Visual feedback latency: <100ms
- Component interaction response: <50ms
- Circuit completion detection: Real-time
- Error feedback clarity: Immediate

## Risk Mitigation

### Technical Risks
1. **Performance Issues**: Implement adaptive quality and caching
2. **Memory Leaks**: Use weak references and proper cleanup
3. **Complex Calculations**: Parallel processing and Web Workers

### Business Risks
1. **Scope Creep**: Phase-based delivery with clear milestones
2. **Integration Issues**: Comprehensive testing before deployment
3. **User Adoption**: Gradual rollout with feature flags

## Timeline & Deliverables

- **Week 1-2**: Core simulation engine ✅
- **Week 3-4**: Visual feedback system 🔄 (Current)
- **Week 5-6**: Component behavior modeling 📅
- **Week 7-8**: Integration & optimization 📅

## Conclusion

This enhanced simulation integration plan will transform the basic wire activity detection into a comprehensive circuit simulation system, providing users with real-time feedback, interactive component behavior, and advanced circuit analysis capabilities.