import '../simulation/circuit_netlist.dart';

/// Result of circuit validation
class ValidationResult {
  final bool isValid;
  final List<ValidationError> errors;
  final List<ValidationWarning> warnings;
  final CircuitDiagnostics diagnostics;

  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
    required this.diagnostics,
  });

  factory ValidationResult.valid(CircuitDiagnostics diagnostics) {
    return ValidationResult(
      isValid: true,
      diagnostics: diagnostics,
    );
  }

  factory ValidationResult.invalid(
    List<ValidationError> errors,
    CircuitDiagnostics diagnostics, {
    List<ValidationWarning> warnings = const [],
  }) {
    return ValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
      diagnostics: diagnostics,
    );
  }
}

/// Validation error with details
class ValidationError {
  final String code;
  final String message;
  final String componentId;
  final Map<String, dynamic> details;

  const ValidationError({
    required this.code,
    required this.message,
    required this.componentId,
    this.details = const {},
  });
}

/// Validation warning (non-blocking)
class ValidationWarning {
  final String code;
  final String message;
  final String componentId;
  final Map<String, dynamic> details;

  const ValidationWarning({
    required this.code,
    required this.message,
    required this.componentId,
    this.details = const {},
  });
}

/// Circuit diagnostics and analysis
class CircuitDiagnostics {
  final int totalComponents;
  final int totalConnections;
  final int totalNodes;
  final bool hasPowerSource;
  final bool hasGround;
  final List<String> floatingNodes;
  final List<String> shortCircuits;
  final Map<String, double> componentCounts;

  const CircuitDiagnostics({
    required this.totalComponents,
    required this.totalConnections,
    required this.totalNodes,
    required this.hasPowerSource,
    required this.hasGround,
    this.floatingNodes = const [],
    this.shortCircuits = const [],
    this.componentCounts = const {},
  });
}

/// Circuit validator interface
abstract class CircuitValidator {
  /// Validate component placement rules
  ValidationResult validatePlacement(
    SimComponent component,
    int row,
    int col,
    List<SimComponent> existingComponents,
  );

  /// Validate complete circuit topology
  ValidationResult validateCircuit(CircuitNetlist netlist);

  /// Check for common circuit issues
  CircuitDiagnostics analyzeCircuit(CircuitNetlist netlist);

  /// Validate educational circuit requirements
  ValidationResult validateEducationalRequirements(
    CircuitNetlist netlist,
    List<String> requiredComponents,
  );
}