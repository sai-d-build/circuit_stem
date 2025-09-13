import 'package:freezed_annotation/freezed_annotation.dart';

part 'simulation_result.freezed.dart';
part 'simulation_result.g.dart';

@freezed
class SimulationResult with _$SimulationResult {
  const factory SimulationResult({
    required Map<String, double> nodeVoltages,
    required Map<String, double> branchCurrents,
    required Map<String, ComponentState> componentStates,
    required Map<String, ConnectionState> connectionStates,
    required List<SimulationDiagnostic> diagnostics,
    required DateTime timestamp,
    required bool isValid,
  }) = _SimulationResult;

  factory SimulationResult.fromJson(Map<String, dynamic> json) =>
      _$SimulationResultFromJson(json);
}

@freezed
class ComponentState with _$ComponentState {
  const factory ComponentState({
    required String id,
    required Map<String, dynamic> properties,
  }) = _ComponentState;

  factory ComponentState.fromJson(Map<String, dynamic> json) =>
      _$ComponentStateFromJson(json);
}

@freezed
class ConnectionState with _$ConnectionState {
  const factory ConnectionState({
    required String id,
    required Map<String, dynamic> properties,
  }) = _ConnectionState;

  factory ConnectionState.fromJson(Map<String, dynamic> json) =>
      _$ConnectionStateFromJson(json);
}

@freezed
class SimulationDiagnostic with _$SimulationDiagnostic {
  const factory SimulationDiagnostic({
    required String message,
    required String level,
    String? componentId,
  }) = _SimulationDiagnostic;

  factory SimulationDiagnostic.fromJson(Map<String, dynamic> json) =>
      _$SimulationDiagnosticFromJson(json);
}
