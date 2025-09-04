import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:sparkcircuit/presentation/app.dart';
import 'package:sparkcircuit/infrastructure/persistence/shared_preferences_storage_service.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with error handling
  try {
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
  } catch (e) {
    // Firebase initialization failed, continue without Firebase
    StructuredLogger.warning('Firebase initialization failed - continuing without Firebase', context: {
      'error': e.toString(),
      'service': 'Firebase',
      'fallback': 'proceed_without_firestore',
    });
  }

  // Initialize storage service
  final storageService = SharedPreferencesStorageService();
  await storageService.init();

  runApp(
    ProviderScope(
      overrides: [
        // Override the storage service provider with the initialized instance
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const CircuitStemApp(),
    ),
  );
}
