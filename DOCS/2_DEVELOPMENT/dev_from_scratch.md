# Development From Scratch: A Reference Guide

This document outlines the architectural changes that were attempted to improve the application's startup sequence and theme management. It serves as a reference for re-implementing these changes in a more incremental and testable way.

## 1. Architectural Goals

The primary goals of the refactoring were:

-   **Asynchronous App Startup:** Prevent the UI from building before essential services (like `AssetManager` and `SharedPreferences`) are ready. This was to be achieved using a `FutureProvider`.
-   **Dependency Injection:** Refactor services like `LevelManager` to receive their dependencies via the constructor, making them more modular and testable.
-   **Provider-Based Theme Management:** Replace the unreliable global theme variables with a Riverpod provider-based system to ensure the theme is always available when the widget tree is built.

## 2. File-by-File Implementation Details

### `lib/main.dart`

The `main` function was updated to initialize services asynchronously and override the corresponding providers in the `ProviderScope`.

```dart
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flame/flame.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app.dart';
import 'services/asset_manager.dart';
import 'common/logger.dart';
import 'core/providers.dart';

void main() async {
  Logger.log('main() called');
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  // --- Service Initialization ---
  Logger.log('Initializing services...');
  FlameAudio.audioCache.prefix = '';

  // Initialize services that need to be available synchronously.
  final prefs = await SharedPreferences.getInstance();
  final assetManager = AssetManager();
  await assetManager.loadAllAssets();

  Logger.log('Base services initialized.');

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        assetManagerProvider.overrideWithValue(assetManager),
      ],
      child: const App(),
    ),
  );
  Logger.log('runApp() called');
}
```

### `lib/core/providers.dart`

An `appStartupProvider` was added to manage the asynchronous startup sequence.

```dart
// ... (other providers)

// 3. Application Startup Provider

final appStartupProvider = FutureProvider<void>((ref) async {
  // This provider is now empty, but can be used for other async startup tasks.
});

// ... (other providers)
```

### `lib/app.dart`

The `App` widget was converted to a `ConsumerWidget` to watch the `appStartupProvider` and the new `darkThemeProvider`.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:circuit_stem/routes.dart';
import 'package:circuit_stem/common/theme_provider.dart';
import 'package:circuit_stem/core/providers.dart';

class App extends ConsumerWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appStartup = ref.watch(appStartupProvider);
    final darkTheme = ref.watch(darkThemeProvider);

    return appStartup.when(
      data: (_) {
        return MaterialApp(
          title: 'Circuit STEM',
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.mainMenu,
          onGenerateRoute: AppRoutes.onGenerateRoute,
        );
      },
      loading: () => const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
      error: (err, stack) => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Error initializing app: $err'),
          ),
        ),
      ),
    );
  }
}
```

### `lib/common/theme_provider.dart`

This new file was created to house the theme definitions as Riverpod providers.

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

// ... (Color, Gradient, Text Style, and Font Size definitions)

final lightThemeProvider = Provider<ThemeData>((ref) {
  // ... (light theme definition)
});

final darkThemeProvider = Provider<ThemeData>((ref) {
  // ... (dark theme definition)
});
```

### `lib/services/level_manager.dart`

The `LevelManagerNotifier` was refactored to accept `AssetManager` as a dependency.

```dart
class LevelManagerNotifier extends StateNotifier<LevelManagerState> {
  final SharedPreferences _sharedPrefs;
  final AssetManager _assetManager;

  LevelManagerNotifier(this._sharedPrefs, this._assetManager) : super(const LevelManagerState()) {
    _init();
  }

  // ... (rest of the implementation)
}
```

## 3. Debugging Summary

The application consistently crashed with an `Unexpected null value` error when building the `MaterialApp`. The debugging process revealed that the `darkTheme` object was `null` at the point of use, even after refactoring the theme to use a Riverpod provider. The final debugging attempt, which involved adding logging to the `darkThemeProvider` itself, showed that the provider was not even being created. This indicates a deep and complex issue with the application's initialization sequence, likely a subtle interaction between the asynchronous startup, Riverpod, and the Flutter widget lifecycle.

## 4. Next Steps

The recommended next step is to reset the repository to the last known working commit (`44c949b4`) and then re-implement the architectural changes one by one, with careful testing at each step.
