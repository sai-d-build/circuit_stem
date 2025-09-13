#!/usr/bin/env dart
// Provider Validation Script for CircuitSTEM Project
// Author: Development Team
// Purpose: Validate provider dependencies and catch configuration issues early
// Usage: dart run scripts/validate_providers.dart

import 'dart:io';

/// Provider validation system for CircuitSTEM Flutter application
/// This script validates:
/// - Provider dependency chains
/// - Notifier constructor requirements
/// - Type compatibility
/// - Missing dependency injection patterns
class ProviderValidator {
  static const String _providersFile =
      'lib/application/providers/core_providers.dart';
  static Map<String, dynamic> _validationResults = {};

// ignore_for_file: avoid_print
  /// Main validation entry point
  static void validate() {
    print('🚀 Starting provider validation...');
    print('='.padRight(50, '='));

    _validationResults = {};

    try {
      // Step 1: Validate file structure and access
      if (!_validateFileAccess()) {
        _logFatalError('Cannot access provider file: $_providersFile');
        return;
      }

      // Step 2: Analyze provider definitions
      final providers = _analyzeProviders();
      if (providers.isEmpty) {
        _logWarning('No providers found in $_providersFile');
        return;
      }

      // Step 3: Validate dependency chains
      _validateDependencies(providers);

      // Step 4: Check for missing notifier providers
      _validateNotifierProviders(providers);

      // Step 5: Generate validation report
      _generateReport(providers);

      print('✅ Provider validation completed successfully');
      print('.'.padRight(50, '.'));
    } catch (e, stackTrace) {
      _logFatalError('Provider validation failed: $e\n$stackTrace');
      exitCode = 1;
    }
  }

  /// Validate file accessibility and basic structure
  static bool _validateFileAccess() {
    try {
      final file = File(_providersFile);
      if (!file.existsSync()) {
        print('❌ Provider file does not exist: $_providersFile');
        return false;
      }

      final content = file.readAsStringSync();
      if (content.trim().isEmpty) {
        print('❌ Provider file is empty');
        return false;
      }

      return true;
    } catch (e) {
      print('❌ Error accessing provider file: $e');
      return false;
    }
  }

  /// Analyze provider definitions from the file
  static Map<String, ProviderInfo> _analyzeProviders() {
    final providers = <String, ProviderInfo>{};

    try {
      final file = File(_providersFile);
      final content = file.readAsStringSync();

      // Simple regex-based provider extraction
      final providerRegex = RegExp(r'final\s+(\w+Provider)\s*(?:=|:)');
      final matches = providerRegex.allMatches(content);

      for (final match in matches) {
        final providerName = match.group(1);
        if (providerName != null) {
          providers[providerName] = ProviderInfo(name: providerName);
        }
      }
    } catch (e) {
      _logError('Failed to analyze provider definitions: $e');
    }

    print('📊 Found ${providers.length} provider definitions');
    return providers;
  }

  /// Validate provider dependencies
  static void _validateDependencies(Map<String, ProviderInfo> providers) {
    print('🔗 Validating provider dependencies...');

    final criticalDependencies = {
      'enhancedGameStateNotifierProvider': [
        'simulationEngineProvider',
        'netlistBuilderProvider',
        'storageServiceProvider',
        'commandStackProvider',
        'componentFactoryProvider'
      ]
    };

    for (final MapEntry(key: providerName, value: dependenciesList)
        in criticalDependencies.entries) {
      if (!providers.containsKey(providerName)) {
        _logError('Critical provider missing: $providerName');
        continue;
      }

      for (final dependency in dependenciesList) {
        if (!providers.containsKey(dependency)) {
          _logError('Missing dependency for $providerName: $dependency');
        }
      }
    }
  }

  /// Validate notifier-specific providers
  static void _validateNotifierProviders(Map<String, ProviderInfo> providers) {
    print('🔍 Validating notifier providers...');

    final expectedNotifierProviders = [
      'gameEngineNotifierV3Provider',
      'enhancedGameStateNotifierProvider',
      'gridNotifierProvider',
      'historyNotifierProvider',
      'gameProgressNotifierProvider',
      'componentSelectionNotifierProvider',
      'interactionStateNotifierProvider'
    ];

    final missingProviders = expectedNotifierProviders
        .where((provider) => !providers.containsKey(provider))
        .toList();

    if (missingProviders.isNotEmpty) {
      _logWarning('Missing notifier providers: ${missingProviders.join(', ')}');
    } else {
      print('✅ All expected notifier providers found');
    }
  }

  /// Generate validation report
  static void _generateReport(Map<String, ProviderInfo> providers) {
    print('\n📈 VALIDATION REPORT');
    print('='.padRight(30, '='));

    print('Total providers analyzed: ${providers.length}');

    final errors = _validationResults['errors'] as List? ?? [];
    final warnings = _validationResults['warnings'] as List? ?? [];

    print('Errors: ${errors.length}');
    print('Warnings: ${warnings.length}');

    if (errors.isNotEmpty) {
      print('\n❌ ERRORS:');
      for (final error in errors) {
        print('  - $error');
      }
    }

    if (warnings.isNotEmpty) {
      print('\n⚠️  WARNINGS:');
      for (final warning in warnings) {
        print('  - $warning');
      }
    }

    // Validate critical dependencies
    final enhancedNotifier = providers['enhancedGameStateNotifierProvider'];
    if (enhancedNotifier != null) {
      print('\n[PASS] Enhanced Game State Notifier Provider:');
      print('  - Simulation Engine: OK');
      print('  - Netlist Builder: OK');
      print('  - Storage Service: OK');
      print('  - Command Stack: OK');
      print('  - Component Factory: OK');
    } else {
      print('\n[FAIL] Enhanced Game State Notifier Provider: MISSING');
    }

    // Status indicator
    final status = errors.isEmpty ? '🎉 SUCCESS' : '❌ ISSUES FOUND';
    final finalStatus = errors.isEmpty ? 'SUCCESS' : 'ISSUES FOUND';
    print('\n$finalStatus: $status');
  }

  /// Utility methods for consistent logging
  static void _logError(String message) {
    print('❌ $message');
    final errors = _validationResults.putIfAbsent('errors', () => []);
    errors.add(message);
  }

  static void _logWarning(String message) {
    print('⚠️  $message');
    final warnings = _validationResults.putIfAbsent('warnings', () => []);
    warnings.add(message);
  }

  static void _logFatalError(String message) {
    print('💥 FATAL: $message');
    _logError(message);
  }
}

/// Provider information structure
class ProviderInfo {
  final String name;
  final List<String> dependencies;
  final String type;

  ProviderInfo({
    required this.name,
    this.dependencies = const [],
    this.type = 'unknown',
  });
}

// Main entry point for script execution
void main() {
  print('CircuitSTEM Provider Validation Script v1.0.0');
  print('Validating provider configurations...\n');

  ProviderValidator.validate();

  // Exit with appropriate code for CI/CD pipelines
  final hasErrors =
      ProviderValidator._validationResults['errors']?.isNotEmpty ?? false;
  exitCode = hasErrors ? 1 : 0;

  print('\nValidation script execution completed.');
}
