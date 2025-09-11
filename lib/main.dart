import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sparkcircuit/presentation/app.dart';
import 'package:sparkcircuit/infrastructure/persistence/shared_preferences_storage_service.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart';
import 'package:sparkcircuit/application/providers/core_providers.dart' as core_providers;
import 'package:sparkcircuit/core/debug/structured_logger.dart';

void main() async {
  StructuredLogger.info('🚀 APPLICATION STARTUP - main() called', context: {
    'timestamp': DateTime.now().toIso8601String(),
    'flutterBindingInitialized': false,
  });

  WidgetsFlutterBinding.ensureInitialized();

  StructuredLogger.info('🔧 Flutter binding initialized', context: {
    'timestamp': DateTime.now().toIso8601String(),
    'flutterBindingInitialized': true,
  });

  // Initialize Firebase with error handling
  try {
    StructuredLogger.info('🔥 Starting Firebase initialization', context: {
      'timestamp': DateTime.now().toIso8601String(),
    });

    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "demo-key",
        authDomain: "demo.firebaseapp.com",
        projectId: "demo-project",
        storageBucket: "demo-project.appspot.com",
        messagingSenderId: "123456789",
        appId: "1:123456789:web:abcdef123456",
      ),
    );

    StructuredLogger.info('✅ Firebase initialized successfully', context: {
      'timestamp': DateTime.now().toIso8601String(),
    });
  } catch (e) {
    // Firebase initialization failed, continue without Firebase
    StructuredLogger.warning('⚠️ Firebase initialization failed - continuing without Firebase', context: {
      'error': e.toString(),
      'service': 'Firebase',
      'fallback': 'proceed_without_firestore',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // Initialize storage service
  StructuredLogger.info('💾 Initializing storage service', context: {
    'timestamp': DateTime.now().toIso8601String(),
  });

  final storageService = SharedPreferencesStorageService();
  await storageService.init();

  StructuredLogger.info('✅ Storage service initialized', context: {
    'timestamp': DateTime.now().toIso8601String(),
    'storageServiceType': storageService.runtimeType.toString(),
  });

  StructuredLogger.info('🏗️ Creating ProviderScope with overrides', context: {
    'timestamp': DateTime.now().toIso8601String(),
    'overridesCount': 1,
    'overriddenProviders': ['storageServiceProvider'],
  });

  runApp(
    ProviderScope(
      overrides: [
        // Override the storage service provider with the initialized instance
        storageServiceProvider.overrideWith((ref) => storageService),
        // Also override the core providers version
        core_providers.storageServiceProvider.overrideWith((ref) => storageService),
      ],
      child: const CircuitStemApp(),
    ),
  );

  StructuredLogger.info('🎯 Application startup complete - runApp() called', context: {
    'timestamp': DateTime.now().toIso8601String(),
    'appType': 'CircuitStemApp',
  });
}
