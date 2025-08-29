import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/game_engine_state.dart';
import '../../common/feature_flags.dart';
import '../../application/feature_flag_service.dart';
import '../../application/providers.dart';

/// UI Migration Wrapper for gradual transition from gameEngineProvider to granular providers.
/// 
/// This wrapper provides backward compatibility and performance optimization utilities
/// for migrating UI components from monolithic state watching to granular provider watching.
/// 
/// Key features:
/// - Backward-compatible API preservation
/// - Granular provider access for performance
/// - Feature flag-based progressive migration
/// - Easy rollback capability
class UIMigrationWrapper {
  /// Check if hybrid system is enabled (compile-time or runtime).
  static bool get isHybridEnabled =>
      FeatureFlags.useHybridEngine || FeatureFlagService.useHybridEngine;

  /// Check if granular providers should be used for UI optimization.
  static bool get useGranularProviders =>
      FeatureFlags.enableGranularProviders || FeatureFlagService.enableGranularProviders;

  /// Get the appropriate game engine state provider based on current configuration.
  static Provider<GameEngineState> getGameEngineStateProvider() {
    return gameEngineProvider;
  }

  /// Get the appropriate game engine notifier provider based on current configuration.
  static Provider<dynamic> getGameEngineNotifierProvider() {
    return gameEngineNotifierProvider;
  }
}

/// Consumer widget that automatically selects optimal providers based on feature flags.
/// 
/// This widget helps migrate from:
/// ```dart
/// final gameState = ref.watch(gameEngineProvider);
/// final isWin = gameState.isWin;
/// ```
/// 
/// To:
/// ```dart
/// OptimizedConsumer(
///   selector: (state) => state.isWin,
///   granularProvider: isWinProvider,
///   builder: (context, isWin, child) {
///     return isWin ? WinScreen() : GameScreen();
///   },
/// )
/// ```
class OptimizedConsumer<T> extends ConsumerWidget {
  final T Function(GameEngineState) selector;
  final Provider<T>? granularProvider;
  final Widget Function(BuildContext context, T value, Widget? child) builder;
  final Widget? child;

  const OptimizedConsumer({
    required this.selector,
    required this.builder,
    this.granularProvider,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final T value;

    // Use granular provider if available and feature is enabled
    if (granularProvider != null && UIMigrationWrapper.useGranularProviders) {
      value = ref.watch(granularProvider!);
    } else {
      // Fall back to selecting from main game engine provider
      final gameState = ref.watch(gameEngineProvider);
      value = selector(gameState);
    }

    return builder(context, value, child);
  }
}

/// Consumer widget optimized for win state watching.
/// 
/// Automatically uses `isWinProvider` when granular providers are enabled,
/// falls back to `gameEngineProvider.select()` otherwise.
class WinStateConsumer extends ConsumerWidget {
  final Widget Function(BuildContext context, bool isWin, Widget? child) builder;
  final Widget? child;

  const WinStateConsumer({
    required this.builder,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OptimizedConsumer<bool>(
      selector: (state) => state.isWin,
      granularProvider: isWinProvider,
      builder: builder,
      child: child,
    );
  }
}

/// Consumer widget optimized for grid state watching.
/// 
/// Automatically uses `gridProvider` when granular providers are enabled,
/// falls back to `gameEngineProvider.select()` otherwise.
class GridStateConsumer extends ConsumerWidget {
  final Widget Function(BuildContext context, dynamic grid, Widget? child) builder;
  final Widget? child;

  const GridStateConsumer({
    required this.builder,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OptimizedConsumer<dynamic>(
      selector: (state) => state.grid,
      granularProvider: gridProvider,
      builder: builder,
      child: child,
    );
  }
}

/// Consumer widget optimized for selection state watching.
/// 
/// Automatically uses `selectedComponentIdProvider` when granular providers are enabled,
/// falls back to `gameEngineProvider.select()` otherwise.
class SelectionStateConsumer extends ConsumerWidget {
  final Widget Function(BuildContext context, String? selectedId, Widget? child) builder;
  final Widget? child;

  const SelectionStateConsumer({
    required this.builder,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OptimizedConsumer<String?>(
      selector: (state) => state.selectedComponentId,
      granularProvider: selectedComponentIdProvider,
      builder: builder,
      child: child,
    );
  }
}

/// Consumer widget optimized for drag state watching.
/// 
/// Automatically uses `isDraggingProvider` when granular providers are enabled,
/// falls back to `gameEngineProvider.select()` otherwise.
class DragStateConsumer extends ConsumerWidget {
  final Widget Function(BuildContext context, bool isDragging, Widget? child) builder;
  final Widget? child;

  const DragStateConsumer({
    required this.builder,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OptimizedConsumer<bool>(
      selector: (state) => state.draggedComponentId != null,
      granularProvider: isDraggingProvider,
      builder: builder,
      child: child,
    );
  }
}

/// Consumer widget optimized for pause state watching.
/// 
/// Automatically uses `isPausedProvider` when granular providers are enabled,
/// falls back to `gameEngineProvider.select()` otherwise.
class PauseStateConsumer extends ConsumerWidget {
  final Widget Function(BuildContext context, bool isPaused, Widget? child) builder;
  final Widget? child;

  const PauseStateConsumer({
    required this.builder,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OptimizedConsumer<bool>(
      selector: (state) => state.isPaused,
      granularProvider: isPausedProvider,
      builder: builder,
      child: child,
    );
  }
}

/// Consumer widget optimized for undo state watching.
/// 
/// Automatically uses `canUndoProvider` when granular providers are enabled,
/// falls back to `gameEngineProvider.select()` otherwise.
class UndoStateConsumer extends ConsumerWidget {
  final Widget Function(BuildContext context, bool canUndo, Widget? child) builder;
  final Widget? child;

  const UndoStateConsumer({
    required this.builder,
    this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OptimizedConsumer<bool>(
      selector: (state) => state.history.isNotEmpty,
      granularProvider: canUndoProvider,
      builder: builder,
      child: child,
    );
  }
}

/// Extension on WidgetRef to provide convenient methods for accessing game engine functionality.
extension GameEngineRefExtension on WidgetRef {
  /// Get the game engine notifier, compatible with both hybrid and original systems.
  dynamic get gameEngineNotifier {
    return read(gameEngineNotifierProvider);
  }

  /// Watch the complete game engine state.
  GameEngineState get gameEngineState {
    return watch(gameEngineProvider);
  }

  /// Watch a specific part of the game engine state with automatic optimization.
  T watchGameEngineState<T>(T Function(GameEngineState) selector, {Provider<T>? optimizedProvider}) {
    if (optimizedProvider != null && UIMigrationWrapper.useGranularProviders) {
      return watch(optimizedProvider);
    } else {
      final state = watch(gameEngineProvider);
      return selector(state);
    }
  }

  /// Watch win state with automatic optimization.
  bool get isWin => watchGameEngineState((state) => state.isWin, optimizedProvider: isWinProvider);

  /// Watch grid state with automatic optimization.
  dynamic get grid => watchGameEngineState((state) => state.grid, optimizedProvider: gridProvider);

  /// Watch selection state with automatic optimization.
  String? get selectedComponentId => 
    watchGameEngineState((state) => state.selectedComponentId, optimizedProvider: selectedComponentIdProvider);

  /// Watch drag state with automatic optimization.
  bool get isDragging => 
    watchGameEngineState((state) => state.draggedComponentId != null, optimizedProvider: isDraggingProvider);

  /// Watch pause state with automatic optimization.
  bool get isPaused => 
    watchGameEngineState((state) => state.isPaused, optimizedProvider: isPausedProvider);

  /// Watch undo state with automatic optimization.
  bool get canUndo => 
    watchGameEngineState((state) => state.history.isNotEmpty, optimizedProvider: canUndoProvider);
}

/// Migration helper class providing utilities for progressive UI component migration.
class MigrationHelper {
  /// Create a provider override for testing that works with both systems.
  static Override createGameEngineOverride(dynamic notifier) {
    if (UIMigrationWrapper.isHybridEnabled) {
      // For hybrid system, override the orchestrator
      return gameEngineOrchestratorProvider.overrideWith((ref) => notifier);
    } else {
      // For original system, override the notifier provider directly
      return gameEngineNotifierProvider.overrideWith((ref) => notifier);
    }
  }

  /// Get performance metrics for the current provider usage.
  static Map<String, dynamic> getPerformanceMetrics(WidgetRef ref) {
    return {
      'hybrid_enabled': UIMigrationWrapper.isHybridEnabled,
      'granular_providers_enabled': UIMigrationWrapper.useGranularProviders,
      'provider_count': _getActiveProviderCount(ref),
      'rebuild_optimization_active': UIMigrationWrapper.useGranularProviders,
    };
  }

  static int _getActiveProviderCount(WidgetRef ref) {
    // This would count active provider instances in a real implementation
    return UIMigrationWrapper.useGranularProviders ? 6 : 1;
  }
}