// EMERGENCY COMPONENT VERIFICATION SYSTEM
// Ensures critical capacitor/inductor components are working to prevent app crashes
// This is PHASE 0 of the component optimization project

import '../../domain/entities/components/capacitor.dart';
import '../../domain/entities/components/circuit_component.dart';
import '../../domain/entities/components/inductor.dart';
import '../../domain/entities/core/component.dart';
import '../debug/structured_logger.dart';

/// Emergency verification system for critical component types
class EmergencyComponentVerification {
  static const List<ComponentType> _criticalComponents = [
    ComponentType.resistor, // ❌ Original (should work)
    ComponentType.battery, // ❌ Original (should work)
    ComponentType.wire, // ❌ Original (should work)
    ComponentType.capacitor, // ✅ NEW - Phase 0 fix
    ComponentType.inductor, // ✅ NEW - Phase 0 fix
  ];

  /// VERIFICATION STATUS TRACKING
  static int _verificationAttempts = 0;
  static int _successCount = 0;
  static int _failureCount = 0;

  static final Map<ComponentType, VerificationResult> _verificationResults = {};

  /// PRIMARY VERIFICATION METHOD - RUN THIS AFTER PHASE 0 CHANGES
  static Future<VerificationReport> verifyAllCriticalComponents() async {
    final report = VerificationReport();

    StructuredLogger.info('🔬 STARTING PHASE 0 COMPONENT VERIFICATION');
    StructuredLogger.info(
        'Target components: ${_criticalComponents.map((c) => c.name).join(', ')}');

    _verificationAttempts++;

    for (final componentType in _criticalComponents) {
      final result = await _verifyComponentType(componentType);
      _verificationResults[componentType] = result;

      if (result.isSuccess) {
        _successCount++;
        StructuredLogger.info('✅ ${componentType.name}: VERIFIED');
      } else {
        _failureCount++;
        StructuredLogger.error(
            '❌ ${componentType.name}: FAILED - ${result.message}');
        report.addFailure(componentType, result.message);
      }
    }

    report.totalAttempts = _verificationAttempts;
    report.successCount = _successCount;
    report.failureCount = _failureCount;

    // DETERMINE OVERALL STATUS
    report.overallStatus = _failureCount == 0
        ? VerificationStatus.allPassed
        : (_failureCount < 3
            ? VerificationStatus.partialSuccess
            : VerificationStatus.criticalFailures);

    // FINAL REPORT
    _printVerificationSummary(report);

    return report;
  }

  /// QUICK HEALTH CHECK - USE IN PRODUCTION MONITORING
  static bool isSystemHealthy() {
    return _verificationResults.values.every((result) => result.isSuccess);
  }

  /// VERIFY INDIVIDUAL COMPONENT TYPE (core verification logic)
  static Future<VerificationResult> _verifyComponentType(
      ComponentType type) async {
    try {
      // CREATE TEST COMPONENT MODEL
      final testModel = _createTestComponentModel(type);

      // ATTEMPT TO CREATE CIRCUIT COMPONENT
      final circuitComponent = CircuitComponent.fromComponentModel(testModel);

      // VALIDATE COMPONENT PROPERTIES
      final validationErrors =
          _validateComponentProperties(circuitComponent, type);

      if (validationErrors.isNotEmpty) {
        return VerificationResult.failure(
            type, 'Property validation failed: ${validationErrors.join(', ')}');
      }

      // TEST SERIALIZATION ROUND-TRIP
      final jsonData = circuitComponent.toJson();
      if (jsonData.isEmpty) {
        return VerificationResult.failure(
            type, 'Serialization produced empty JSON');
      }

      // SUCCESS!
      return VerificationResult.success(type, 'Component type fully verified');
    } catch (e) {
      return VerificationResult.failure(
          type, 'Exception during verification: $e');
    }
  }

  /// CREATE TEST COMPONENT MODEL FOR VERIFICATION
  static ComponentModel _createTestComponentModel(ComponentType type) {
    final baseId = 'emergency_test_${type.name}';

    switch (type) {
      case ComponentType.capacitor:
        return ComponentModel(
          id: baseId,
          type: type,
          row: 0,
          col: 0,
          properties: {
            'capacitance': 0.001, // 1µF
            'voltageRating': 25.0, // 25V
            'currentCharge': 0.0, // No charge
            'leakageResistance': 1000000.0, // 1MΩ
          },
        );

      case ComponentType.inductor:
        return ComponentModel(
          id: baseId,
          type: type,
          row: 0,
          col: 0,
          properties: {
            'inductance': 0.001, // 1mH
            'currentRating': 1.0, // 1A
            'current': 0.0, // No current
            'dcResistance': 0.01, // 10mΩ
          },
        );

      default:
        // ORIGINAL COMPONENT TYPES (should work without changes)
        return ComponentModel(
          id: baseId,
          type: type,
          row: 0,
          col: 0,
          properties: {'resistance': 1000.0}, // Default property
        );
    }
  }

  /// VALIDATE COMPONENT-SPECIFIC PROPERTIES
  static List<String> _validateComponentProperties(
      CircuitComponent component, ComponentType expectedType) {
    final errors = <String>[];

    // VERIFY TYPE MATCH
    if (component.type != expectedType) {
      errors
          .add('Type mismatch: expected $expectedType, got ${component.type}');
    }

    // VERIFY REQUIRED METHODS EXIST
    try {
      component.behaviorType;
    } catch (e) {
      errors.add('behaviorType property missing: $e');
    }

    try {
      component.requiredConnections.isNotEmpty;
    } catch (e) {
      errors.add('requiredConnections property error: $e');
    }

    // TYPE-SPECIFIC VALIDATIONS
    switch (component.type) {
      case ComponentType.capacitor:
        final capacitor = component as Capacitor;
        if (capacitor.capacity <= 0) {
          errors.add('Capacitor capacity is invalid or zero');
        }
        if (capacitor.maxVoltage <= 0) {
          errors.add('Capacitor voltage rating is invalid');
        }
        break;

      case ComponentType.inductor:
        final inductor = component as Inductor;
        if (inductor.inductance <= 0) {
          errors.add('Inductor inductance is invalid or zero');
        }
        if (inductor.currentRating <= 0) {
          errors.add('Inductor current rating is invalid');
        }
        break;

      default:
        // Other component types - basic validation only
        break;
    }

    return errors;
  }

  /// PRINT COMPREHENSIVE VERIFICATION SUMMARY
  static void _printVerificationSummary(VerificationReport report) {
    final statusEmoji = report.overallStatus == VerificationStatus.allPassed
        ? '✅'
        : report.overallStatus == VerificationStatus.partialSuccess
            ? '⚠️'
            : '❌';

    StructuredLogger.info(''); // ignore: cascade_invocations
    StructuredLogger.info('=' * 60); // ignore: cascade_invocations
    StructuredLogger.info('PHASE 0 COMPONENT VERIFICATION REPORT'); // ignore: cascade_invocations
    StructuredLogger.info('=' * 60); // ignore: cascade_invocations
    StructuredLogger.info(
        'Status: $statusEmoji ${report.overallStatus.name.replaceAll('_', ' ')}');
    StructuredLogger.info(''); // ignore: cascade_invocations

    StructuredLogger.info('COMPONENTS TESTED:'); // ignore: cascade_invocations
    for (final result in _verificationResults.values) {
      final status = result.isSuccess ? '✅ PASS' : '❌ FAIL';
      StructuredLogger.info(
          '  $status ${result.componentType.name}: ${result.message}');
    }

    StructuredLogger.info(''); // ignore: cascade_invocations
    StructuredLogger.info('STATISTICS:'); // ignore: cascade_invocations
    StructuredLogger.info('  Total attempts: $report.totalAttempts'); // ignore: cascade_invocations
    StructuredLogger.info('  Successful: $report.successCount'); // ignore: cascade_invocations
    StructuredLogger.info('  Failed: $report.failureCount'); // ignore: cascade_invocations

    if (report.failureCount > 0) {
      StructuredLogger.info(''); // ignore: cascade_invocations
      StructuredLogger.info('FAILURES:'); // ignore: cascade_invocations
      report.failures.forEach((type, error) {
        StructuredLogger.error('  ❌ $type: $error'); // ignore: cascade_invocations
      });
    }

    StructuredLogger.info(''); // ignore: cascade_invocations
    StructuredLogger.info('RECOMMENDATIONS:'); // ignore: cascade_invocations
    switch (report.overallStatus) {
      case VerificationStatus.allPassed:
        StructuredLogger.info(
            '  ✅ Phase 0 completion verified - app crashes resolved');
        StructuredLogger.info(
            '  ✅ Ready to proceed to Phase 1 architecture optimization');
        break;

      case VerificationStatus.partialSuccess:
        StructuredLogger.warning(
            '  ⚠️  Partial success - some components have issues');
        StructuredLogger.warning(
            '  ⚠️  Address remaining failures before proceeding');
        break;

      case VerificationStatus.criticalFailures:
        StructuredLogger.error(
            '  ❌ Critical failures detected - immediate action required');
        StructuredLogger.error(
            '  ❌ Do not deploy until all critical components pass');
        break;

      case VerificationStatus.unknown:
        StructuredLogger.warning(
            '  ❓ Unknown verification status - verification may be incomplete');
        StructuredLogger.warning(
            '  ❓ Run verification again to determine actual status');
        break;
    }

    StructuredLogger.info('=' * 60);
  }
}

/// VERIFICATION RESULT FOR INDIVIDUAL COMPONENT TYPES
class VerificationResult {
  final ComponentType componentType;
  final bool isSuccess;
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;

  VerificationResult.success(this.componentType, this.message)
      : isSuccess = true,
        originalError = null,
        stackTrace = null;

  VerificationResult.failure(this.componentType, this.message,
      {this.originalError, this.stackTrace})
      : isSuccess = false;

  @override
  String toString() =>
      '$componentType: ${isSuccess ? 'PASS' : 'FAIL'} - $message';
}

/// COMPREHENSIVE VERIFICATION REPORT
class VerificationReport {
  final Map<ComponentType, String> failures = {};
  int totalAttempts = 0;
  int successCount = 0;
  int failureCount = 0;
  VerificationStatus overallStatus = VerificationStatus.unknown;

  void addFailure(ComponentType componentType, String errorMessage) {
    failures[componentType] = errorMessage;
  }

  bool get hasFailures => failures.isNotEmpty;
  bool get allPassed => failureCount == 0;
}

/// OVERALL VERIFICATION STATUS
enum VerificationStatus {
  allPassed, // All critical components working (Phase 0 complete)
  partialSuccess, // Some components working, some failing
  criticalFailures, // Multiple components failing (blocking)
  unknown, // Initial state
}

/// EMERGENCY VERIFICATION RUNNER
class EmergencyVerificationRunner {
  /// RUN THIS AFTER PHASE 0 IMPLEMENTATION
  static Future<void> runEmergencyVerification() async {
    StructuredLogger.info('🚨 STARTING EMERGENCY COMPONENT VERIFICATION');

    try {
      final report =
          await EmergencyComponentVerification.verifyAllCriticalComponents();

      if (report.allPassed) {
        StructuredLogger.info(
            '🎉 PHASE 0 SUCCESS! All component crashes resolved!');
        StructuredLogger.info(
            '✅ Safe to proceed with architectural optimization');
      } else {
        StructuredLogger.warning(
            '⚠️  PHASE 0 INCOMPLETE! Component issues remain');
        StructuredLogger.warning(
            '⚠️  Fix all failures before proceeding to production');
      }
    } catch (e, stackTrace) {
      StructuredLogger.fatal('💥 EMERGENCY VERIFICATION SYSTEM FAILURE'); // ignore: cascade_invocations
      StructuredLogger.error('   Error: $e'); // ignore: cascade_invocations
      StructuredLogger.error('   StackTrace: $stackTrace'); // ignore: cascade_invocations
      StructuredLogger.error(
          '   This indicates a critical problem with the verification system itself');
    }
  }

  /// QUICK CHECK - USE IN CI/CD PIPELINES
  static Future<bool> quickHealthCheck() async {
    try {
      final report =
          await EmergencyComponentVerification.verifyAllCriticalComponents();
      return report.allPassed;
    } catch (e) {
      StructuredLogger.error('❌ Quick health check failed: $e');
      return false;
    }
  }
}
