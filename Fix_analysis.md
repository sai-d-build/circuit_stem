# Robust Riverpod Architecture Solution

## Problem Analysis

The root cause is a **race condition** in the asynchronous loading pattern that creates an "empty state" period where:
- UI builds before level data is loaded
- GameEngineNotifier starts with null level data
- ComponentPalette and GameCanvas render blank screens
- State updates after UI initialization may not trigger proper rebuilds

## Architectural Solution

### Phase 1: Modern Async Pattern with AsyncNotifierProvider

Replace the current pattern with modern Riverpod best practices using `AsyncNotifierProvider` for robust async state management.

#### 1.1 Level Definition Provider (Data Layer)

```dart
// lib/core/providers.dart

import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'providers.g.dart';

// Clean separation: Pure data fetching
@riverpod
Future<LevelDefinition> levelDefinition(LevelDefinitionRef ref, int levelNumber) async {
  final levelManager = ref.watch(levelManagerProvider);
  return await levelManager.getLevelDefinition(levelNumber);
}
```

#### 1.2 Game Engine Async Notifier (Business Logic Layer)

```dart
// Game state with proper async handling
@riverpod
class GameEngine extends _$GameEngine {
  @override
  FutureOr<GameState> build(int levelNumber) async {
    // Load level data first
    final levelDefinition = await ref.watch(levelDefinitionProvider(levelNumber).future);
    
    // Initialize game state with loaded data
    return GameState.initial(levelDefinition);
  }

  // All game operations are now sync since we have the data
  void placeComponent(ComponentType type, Position position) {
    final currentState = state.valueOrNull;
    if (currentState == null) return; // Handle loading state gracefully
    
    state = AsyncValue.data(
      currentState.copyWith(
        grid: currentState.grid.placeComponent(type, position),
        renderState: _calculateRenderState(currentState),
      ),
    );
  }

  void removeComponent(Position position) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    
    state = AsyncValue.data(
      currentState.copyWith(
        grid: currentState.grid.removeComponent(position),
        renderState: _calculateRenderState(currentState),
      ),
    );
  }

  RenderState _calculateRenderState(GameState gameState) {
    // Render state calculation logic
    return RenderState.fromGameState(gameState);
  }
}
```

#### 1.3 Derived State Providers

```dart
// Clean derived state providers
@riverpod
Grid? gameGrid(GameGridRef ref, int levelNumber) {
  final gameState = ref.watch(gameEngineProvider(levelNumber));
  return gameState.valueOrNull?.grid;
}

@riverpod
RenderState? renderState(RenderStateRef ref, int levelNumber) {
  final gameState = ref.watch(gameEngineProvider(levelNumber));
  return gameState.valueOrNull?.renderState;
}

@riverpod
List<ComponentType> paletteComponents(PaletteComponentsRef ref, int levelNumber) {
  final gameState = ref.watch(gameEngineProvider(levelNumber));
  return gameState.valueOrNull?.currentLevel.paletteComponents ?? [];
}
```

### Phase 2: Robust UI Layer

#### 2.1 Main Game Screen with Loading States

```dart
// lib/screens/game_screen.dart

class GameScreen extends ConsumerWidget {
  final int levelNumber;
  
  const GameScreen({required this.levelNumber, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStateAsync = ref.watch(gameEngineProvider(levelNumber));
    
    return Scaffold(
      body: gameStateAsync.when(
        loading: () => const GameLoadingScreen(),
        error: (error, stack) => GameErrorScreen(
          error: error,
          onRetry: () => ref.invalidate(gameEngineProvider(levelNumber)),
        ),
        data: (gameState) => GamePlayScreen(
          levelNumber: levelNumber,
          gameState: gameState,
        ),
      ),
    );
  }
}
```

#### 2.2 Loading Screen Component

```dart
class GameLoadingScreen extends StatelessWidget {
  const GameLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading level...'),
        ],
      ),
    );
  }
}
```

#### 2.3 Error Screen Component

```dart
class GameErrorScreen extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;

  const GameErrorScreen({
    required this.error,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64),
          const SizedBox(height: 16),
          Text('Failed to load level: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
```

#### 2.4 Game Play Screen (Data-Ready State)

```dart
class GamePlayScreen extends ConsumerWidget {
  final int levelNumber;
  final GameState gameState;

  const GamePlayScreen({
    required this.levelNumber,
    required this.gameState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Component palette - now guaranteed to have data
        ComponentPalette(
          levelNumber: levelNumber,
          components: gameState.currentLevel.paletteComponents,
        ),
        // Game canvas - now guaranteed to have render state
        Expanded(
          child: GameCanvas(
            levelNumber: levelNumber,
            renderState: gameState.renderState,
          ),
        ),
      ],
    );
  }
}
```

#### 2.5 Updated Component Palette

```dart
class ComponentPalette extends ConsumerWidget {
  final int levelNumber;
  final List<ComponentType> components;

  const ComponentPalette({
    required this.levelNumber,
    required this.components,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No more null checks needed - data is guaranteed
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Components', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...components.map((component) => ComponentTile(
            type: component,
            onTap: () {
              final notifier = ref.read(gameEngineProvider(levelNumber).notifier);
              // Set selected component or place it
              notifier.selectComponent(component);
            },
          )),
        ],
      ),
    );
  }
}
```

#### 2.6 Updated Game Canvas

```dart
class GameCanvas extends ConsumerWidget {
  final int levelNumber;
  final RenderState renderState;

  const GameCanvas({
    required this.levelNumber,
    required this.renderState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTapDown: (details) {
        final position = _calculateGridPosition(details.localPosition);
        final notifier = ref.read(gameEngineProvider(levelNumber).notifier);
        notifier.handleCanvasTap(position);
      },
      child: CustomPaint(
        painter: CanvasPainter(renderState: renderState), // Always has data
        child: Container(),
      ),
    );
  }
}
```

### Phase 3: Enhanced Error Handling & Resilience

#### 3.1 Retry Logic in Providers

```dart
@riverpod
class GameEngine extends _$GameEngine {
  @override
  FutureOr<GameState> build(int levelNumber) async {
    try {
      final levelDefinition = await ref.watch(levelDefinitionProvider(levelNumber).future);
      return GameState.initial(levelDefinition);
    } catch (error) {
      // Log error for debugging
      debugPrint('Failed to initialize game engine: $error');
      rethrow; // Let UI handle the error
    }
  }

  Future<void> retry() async {
    state = const AsyncValue.loading();
    try {
      final levelDefinition = await ref.read(levelDefinitionProvider(levelNumber).future);
      state = AsyncValue.data(GameState.initial(levelDefinition));
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}
```

#### 3.2 Graceful Degradation

```dart
// Fallback providers for partial functionality
@riverpod
bool isGameReady(IsGameReadyRef ref, int levelNumber) {
  final gameState = ref.watch(gameEngineProvider(levelNumber));
  return gameState.hasValue;
}

@riverpod
String gameStatusMessage(GameStatusMessageRef ref, int levelNumber) {
  final gameState = ref.watch(gameEngineProvider(levelNumber));
  return gameState.when(
    loading: () => 'Loading level $levelNumber...',
    error: (error, _) => 'Error loading level: ${error.toString()}',
    data: (_) => 'Level $levelNumber ready',
  );
}
```

## Key Benefits of This Architecture

### 1. **Eliminated Race Conditions**
- UI waits for data before rendering game components
- Loading states provide user feedback
- Error states allow for recovery

### 2. **Separation of Concerns**
- Data fetching isolated in `levelDefinitionProvider`
- Business logic in `GameEngine` async notifier
- UI components only handle rendering

### 3. **Type Safety**
- No more null checks in game components
- Guaranteed data availability in play screen
- AsyncValue provides exhaustive state handling

### 4. **Error Resilience**
- Comprehensive error handling at each layer
- Retry mechanisms for failed operations
- Graceful fallbacks for partial failures

### 5. **Modern Riverpod Patterns**
- Uses latest `AsyncNotifierProvider` pattern
- Leverages `@riverpod` annotation for cleaner code
- Follows official Riverpod best practices

## Migration Steps

1. **Install Dependencies**: Add `riverpod_annotation` and `riverpod_generator`
2. **Update Providers**: Replace existing providers with new async pattern
3. **Update UI Components**: Add loading/error state handling
4. **Test Thoroughly**: Verify all edge cases work correctly
5. **Monitor Performance**: Ensure no regressions in app performance

This architecture ensures robust, predictable behavior while following modern Flutter/Riverpod patterns for handling asynchronous operations.

v// lib/core/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/level_definition.dart';
import '../models/game_state.dart';
import '../models/grid.dart';
import '../models/render_state.dart';
import '../models/component_type.dart';
import '../models/position.dart';
import '../services/level_manager.dart';

part 'providers.g.dart';

// =============================================================================
// LEVEL MANAGER PROVIDER
// =============================================================================

@riverpod
LevelManager levelManager(LevelManagerRef ref) {
  return LevelManager();
}

// =============================================================================
// DATA LAYER - LEVEL DEFINITION
// =============================================================================

@riverpod
Future<LevelDefinition> levelDefinition(
  LevelDefinitionRef ref, 
  int levelNumber,
) async {
  final levelManager = ref.watch(levelManagerProvider);
  
  try {
    return await levelManager.getLevelDefinition(levelNumber);
  } catch (error) {
    // Add specific error handling for common cases
    if (error is LevelNotFoundException) {
      throw LevelNotFoundException('Level $levelNumber not found');
    }
    rethrow;
  }
}

// =============================================================================
// BUSINESS LOGIC LAYER - GAME ENGINE
// =============================================================================

@riverpod
class GameEngine extends _$GameEngine {
  @override
  FutureOr<GameState> build(int levelNumber) async {
    // Load level definition first
    final levelDefinition = await ref.watch(levelDefinitionProvider(levelNumber).future);
    
    // Initialize game state with loaded data
    return GameState.initial(levelDefinition);
  }

  // =============================================================================
  // GAME OPERATIONS
  // =============================================================================

  void placeComponent(ComponentType type, Position position) {
    final currentState = state.valueOrNull;
    if (currentState == null) {
      // Gracefully handle calls during loading
      return;
    }
    
    // Validate placement
    if (!_canPlaceComponent(type, position, currentState)) {
      return;
    }
    
    final newGrid = currentState.grid.placeComponent(type, position);
    final newRenderState = _calculateRenderState(currentState.copyWith(grid: newGrid));
    
    state = AsyncValue.data(
      currentState.copyWith(
        grid: newGrid,
        renderState: newRenderState,
        selectedComponent: null, // Clear selection after placement
      ),
    );
  }

  void removeComponent(Position position) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    
    final newGrid = currentState.grid.removeComponent(position);
    final newRenderState = _calculateRenderState(currentState.copyWith(grid: newGrid));
    
    state = AsyncValue.data(
      currentState.copyWith(
        grid: newGrid,
        renderState: newRenderState,
      ),
    );
  }

  void selectComponent(ComponentType? type) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    
    state = AsyncValue.data(
      currentState.copyWith(selectedComponent: type),
    );
  }

  void handleCanvasTap(Position position) {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    
    if (currentState.selectedComponent != null) {
      // Place the selected component
      placeComponent(currentState.selectedComponent!, position);
    } else {
      // Remove component if one exists at this position
      if (currentState.grid.hasComponentAt(position)) {
        removeComponent(position);
      }
    }
  }

  Future<void> retry() async {
    state = const AsyncValue.loading();
    
    try {
      ref.invalidate(levelDefinitionProvider(levelNumber));
      final levelDefinition = await ref.read(levelDefinitionProvider(levelNumber).future);
      state = AsyncValue.data(GameState.initial(levelDefinition));
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> resetLevel() async {
    final currentState = state.valueOrNull;
    if (currentState == null) return;
    
    state = AsyncValue.data(GameState.initial(currentState.currentLevel));
  }

  // =============================================================================
  // PRIVATE HELPERS
  // =============================================================================

  bool _canPlaceComponent(ComponentType type, Position position, GameState gameState) {
    // Add validation logic here
    return !gameState.grid.hasComponentAt(position) && 
           gameState.grid.isPositionValid(position);
  }

  RenderState _calculateRenderState(GameState gameState) {
    return RenderState.fromGameState(gameState);
  }
}

// =============================================================================
// DERIVED STATE PROVIDERS
// =============================================================================

@riverpod
Grid? gameGrid(GameGridRef ref, int levelNumber) {
  final gameState = ref.watch(gameEngineProvider(levelNumber));
  return gameState.valueOrNull?.grid;
}

@riverpod
RenderState? renderState(RenderStateRef ref, int levelNumber) {
  final gameState = ref.watch(gameEngineProvider(levelNumber));
  return gameState.valueOrNull?.renderState;
}

@riverpod
List<ComponentType> paletteComponents(PaletteComponentsRef ref, int levelNumber) {
  final gameState = ref.watch(gameEngineProvider(levelNumber));
  return gameState.valueOrNull?.currentLevel.paletteComponents ?? [];
}

@riverpod
ComponentType? selectedComponent(SelectedComponentRef ref, int levelNumber) {
  final gameState = ref.watch(gameEngineProvider(levelNumber));
  return gameState.valueOrNull?.selectedComponent;
}

@riverpod
bool isGameReady(IsGameReadyRef ref, int levelNumber) {
  final gameState = ref.watch(gameEngineProvider(levelNumber));
  return gameState.hasValue;
}

@riverpod
String gameStatusMessage(GameStatusMessageRef ref, int levelNumber) {
  final gameState = ref.watch(gameEngineProvider(levelNumber));
  return gameState.when(
    loading: () => 'Loading level $levelNumber...',
    error: (error, _) => 'Error: ${error.toString()}',
    data: (_) => 'Level $levelNumber ready',
  );
}

@riverpod
bool isLevelComplete(IsLevelCompleteRef ref, int levelNumber) {
  final gameState = ref.watch(gameEngineProvider(levelNumber));
  final currentState = gameState.valueOrNull;
  if (currentState == null) return false;
  
  // Add your level completion logic here
  return currentState.isComplete;
}

// =============================================================================
// UTILITY PROVIDERS
// =============================================================================

@riverpod
int currentLevelNumber(CurrentLevelNumberRef ref) {
  // This could be managed by a separate navigation/routing provider
  // For now, return a default level
  return 1;
}

// =============================================================================
// ERROR HANDLING EXTENSIONS
// =============================================================================

class LevelNotFoundException implements Exception {
  final String message;
  LevelNotFoundException(this.message);
  
  @override
  String toString() => 'LevelNotFoundException: $message';
}

// lib/screens/game_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/providers.dart';
import '../models/game_state.dart';
import '../models/component_type.dart';
import '../models/render_state.dart';

// =============================================================================
// MAIN GAME SCREEN
// =============================================================================

class GameScreen extends ConsumerWidget {
  final int levelNumber;
  
  const GameScreen({required this.levelNumber, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameStateAsync = ref.watch(gameEngineProvider(levelNumber));
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Level $levelNumber'),
        actions: [
          // Status indicator
          _buildStatusIndicator(ref, levelNumber),
        ],
      ),
      body: gameStateAsync.when(
        loading: () => GameLoadingScreen(levelNumber: levelNumber),
        error: (error, stack) => GameErrorScreen(
          levelNumber: levelNumber,
          error: error,
          onRetry: () => ref.read(gameEngineProvider(levelNumber).notifier).retry(),
        ),
        data: (gameState) => GamePlayScreen(
          levelNumber: levelNumber,
          gameState: gameState,
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(WidgetRef ref, int levelNumber) {
    final statusMessage = ref.watch(gameStatusMessageProvider(levelNumber));
    final isReady = ref.watch(isGameReadyProvider(levelNumber));
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isReady ? Icons.check_circle : Icons.hourglass_empty,
            color: isReady ? Colors.green : Colors.orange,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            statusMessage,
            style: TextStyle(
              fontSize: 12,
              color: isReady ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// LOADING SCREEN
// =============================================================================

class GameLoadingScreen extends StatelessWidget {
  final int levelNumber;
  
  const GameLoadingScreen({required this.levelNumber, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator.adaptive(),
          const SizedBox(height: 24),
          Text(
            'Loading Level $levelNumber',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Preparing game components and level data...',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// ERROR SCREEN
// =============================================================================

class GameErrorScreen extends StatelessWidget {
  final int levelNumber;
  final Object error;
  final VoidCallback onRetry;

  const GameErrorScreen({
    required this.levelNumber,
    required this.error,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to Load Level $levelNumber',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              _formatErrorMessage(error),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Go Back'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatErrorMessage(Object error) {
    if (error is LevelNotFoundException) {
      return 'This level could not be found. Please check if the level number is correct.';
    }
    return 'An unexpected error occurred: ${error.toString()}';
  }
}

// =============================================================================
// GAME PLAY SCREEN
// =============================================================================

class GamePlayScreen extends ConsumerWidget {
  final int levelNumber;
  final GameState gameState;

  const GamePlayScreen({
    required this.levelNumber,
    required this.gameState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Component palette - guaranteed to have data
        ComponentPalette(
          levelNumber: levelNumber,
          components: gameState.currentLevel.paletteComponents,
          selectedComponent: gameState.selectedComponent,
        ),
        // Game canvas - guaranteed to have render state
        Expanded(
          child: GameCanvas(
            levelNumber: levelNumber,
            renderState: gameState.renderState,
          ),
        ),
        // Game controls sidebar
        GameControlsSidebar(levelNumber: levelNumber),
      ],
    );
  }
}

// =============================================================================
// COMPONENT PALETTE
// =============================================================================

class ComponentPalette extends ConsumerWidget {
  final int levelNumber;
  final List<ComponentType> components;
  final ComponentType? selectedComponent;

  const ComponentPalette({
    required this.levelNumber,
    required this.components,
    required this.selectedComponent,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 200,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            child: Text(
              'Components',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          // Component list
          Expanded(
            child: components.isEmpty 
              ? const Center(
                  child: Text(
                    'No components\navailable',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: components.length,
                  itemBuilder: (context, index) {
                    final component = components[index];
                    final isSelected = selectedComponent == component;
                    
                    return ComponentTile(
                      type: component,
                      isSelected: isSelected,
                      onTap: () {
                        final notifier = ref.read(gameEngineProvider(levelNumber).notifier);
                        notifier.selectComponent(isSelected ? null : component);
                      },
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// COMPONENT TILE
// =============================================================================

class ComponentTile extends StatelessWidget {
  final ComponentType type;
  final bool isSelected;
  final VoidCallback onTap;

  const ComponentTile({
    required this.type,
    required this.isSelected,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: isSelected ? 4 : 1,
      color: isSelected 
        ? Theme.of(context).colorScheme.primaryContainer
        : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Component icon
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getComponentColor(type),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  _getComponentIcon(type),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Component name
              Expanded(
                child: Text(
                  type.displayName,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected 
                      ? Theme.of(context).colorScheme.onPrimaryContainer
                      : null,
                  ),
                ),
              ),
              // Selection indicator
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getComponentColor(ComponentType type) {
    switch (type) {
      case ComponentType.resistor:
        return Colors.brown;
      case ComponentType.capacitor:
        return Colors.blue;
      case ComponentType.inductor:
        return Colors.green;
      case ComponentType.transistor:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getComponentIcon(ComponentType type) {
    switch (type) {
      case ComponentType.resistor:
        return Icons.linear_scale;
      case ComponentType.capacitor:
        return Icons.battery_full;
      case ComponentType.inductor:
        return Icons.waves;
      case ComponentType.transistor:
        return Icons.memory;
      default:
        return Icons.help_outline;
    }
  }
}

// =============================================================================
// GAME CANVAS
// =============================================================================

class GameCanvas extends ConsumerWidget {
  final int levelNumber;
  final RenderState renderState;

  const GameCanvas({
    required this.levelNumber,
    required this.renderState,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: GestureDetector(
          onTapDown: (details) {
            final position = _calculateGridPosition(details.localPosition);
            if (position != null) {
              final notifier = ref.read(gameEngineProvider(levelNumber).notifier);
              notifier.handleCanvasTap(position);
            }
          },
          child: CustomPaint(
            painter: CanvasPainter(renderState: renderState),
            child: Container(),
          ),
        ),
      ),
    );
  }

  Position? _calculateGridPosition(Offset localPosition) {
    // Calculate grid position from local canvas coordinates
    // This would depend on your grid size and canvas dimensions
    const gridSize = 20; // Example grid size
    final x = (localPosition.dx / gridSize).floor();
    final y = (localPosition.dy / gridSize).floor();
    
    // Validate bounds
    if (x >= 0 && x < renderState.gridWidth && y >= 0 && y < renderState.gridHeight) {
      return Position(x: x, y: y);
    }
    return null;
  }
}

// =============================================================================
// CANVAS PAINTER
// =============================================================================

class CanvasPainter extends CustomPainter {
  final RenderState renderState;

  const CanvasPainter({required this.renderState});

  @override
  void paint(Canvas canvas, Size size) {
    // Now we're guaranteed to have a valid renderState
    _drawGrid(canvas, size);
    _drawComponents(canvas, size);
    _drawConnections(canvas, size);
    _drawHighlights(canvas, size);
  }

  void _drawGrid(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 1;

    const gridSpacing = 20.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  void _drawComponents(Canvas canvas, Size size) {
    for (final component in renderState.components) {
      _drawComponent(canvas, component);
    }
  }

  void _drawComponent(Canvas canvas, RenderComponent component) {
    final paint = Paint()
      ..color = component.color
      ..style = PaintingStyle.fill;

    final rect = Rect.fromLTWH(
      component.position.x * 20.0,
      component.position.y * 20.0,
      component.width * 20.0,
      component.height * 20.0,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );

    // Draw component label
    final textPainter = TextPainter(
      text: TextSpan(
        text: component.label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        rect.center.dx - textPainter.width / 2,
        rect.center.dy - textPainter.height / 2,
      ),
    );
  }

  void _drawConnections(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    for (final connection in renderState.connections) {
      canvas.drawLine(
        Offset(connection.start.x * 20.0, connection.start.y * 20.0),
        Offset(connection.end.x * 20.0, connection.end.y * 20.0),
        paint,
      );
    }
  }

  void _drawHighlights(Canvas canvas, Size size) {
    if (renderState.highlightedPosition != null) {
      final paint = Paint()
        ..color = Colors.yellow.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      final rect = Rect.fromLTWH(
        renderState.highlightedPosition!.x * 20.0,
        renderState.highlightedPosition!.y * 20.0,
        20.0,
        20.0,
      );

      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(CanvasPainter oldDelegate) {
    return renderState != oldDelegate.renderState;
  }
}

// =============================================================================
// GAME CONTROLS SIDEBAR
// =============================================================================

class GameControlsSidebar extends ConsumerWidget {
  final int levelNumber;

  const GameControlsSidebar({required this.levelNumber, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isComplete = ref.watch(isLevelCompleteProvider(levelNumber));
    final gameEngine = ref.read(gameEngineProvider(levelNumber).notifier);

    return Container(
      width: 200,
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            child: Text(
              'Controls',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          
          // Control buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: () => gameEngine.resetLevel(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Level'),
                ),
                
                const SizedBox(height: 12),
                
                OutlinedButton.icon(
                  onPressed: () {
                    // Clear selection
                    gameEngine.selectComponent(null);
                  },
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear Selection'),
                ),
                
                const SizedBox(height: 24),
                
                // Level completion status
                if (isComplete) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Level Complete!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to next level
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => GameScreen(levelNumber: levelNumber + 1),
                        ),
                      );
                    },
                    child: const Text('Next Level'),
                  ),
                ],
              ],
            ),
          ),
          
          const Spacer(),
          
          // Level info
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level $levelNumber',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Consumer(
                  builder: (context, ref, child) {
                    final gameState = ref.watch(gameEngineProvider(levelNumber));
                    final levelDefinition = gameState.valueOrNull?.currentLevel;
                    
                    if (levelDefinition == null) {
                      return const Text('Loading...');
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          levelDefinition.name,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          levelDefinition.description,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUPPORTING MODELS (if not already defined)
// =============================================================================

class RenderComponent {
  final Position position;
  final ComponentType type;
  final Color color;
  final double width;
  final double height;
  final String label;

  const RenderComponent({
    required this.position,
    required this.type,
    required this.color,
    required this.width,
    required this.height,
    required this.label,
  });
}

class RenderConnection {
  final Position start;
  final Position end;

  const RenderConnection({
    required this.start,
    required this.end,
  });
}

// Extension to add displayName to ComponentType
extension ComponentTypeExtension on ComponentType {
  String get displayName {
    switch (this) {
      case ComponentType.resistor:
        return 'Resistor';
      case ComponentType.capacitor:
        return 'Capacitor';
      case ComponentType.inductor:
        return 'Inductor';
      case ComponentType.transistor:
        return 'Transistor';
      default:
        return 'Unknown';
    }
  }
}

# Complete Migration Guide

## Step 1: Update Dependencies

Add these to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5

dev_dependencies:
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.9
  riverpod_lint: ^2.3.10
```

## Step 2: Update Model Classes

### GameState Model

```dart
// lib/models/game_state.dart
import 'package:flutter/foundation.dart';
import 'level_definition.dart';
import 'grid.dart';
import 'render_state.dart';
import 'component_type.dart';

@immutable
class GameState {
  final LevelDefinition currentLevel;
  final Grid grid;
  final RenderState renderState;
  final ComponentType? selectedComponent;
  final bool isComplete;

  const GameState({
    required this.currentLevel,
    required this.grid,
    required this.renderState,
    this.selectedComponent,
    this.isComplete = false,
  });

  factory GameState.initial(LevelDefinition levelDefinition) {
    final initialGrid = Grid.fromLevelDefinition(levelDefinition);
    return GameState(
      currentLevel: levelDefinition,
      grid: initialGrid,
      renderState: RenderState.fromGameState(
        GameState(
          currentLevel: levelDefinition,
          grid: initialGrid,
          renderState: RenderState.empty(), // Temporary for calculation
        ),
      ),
    );
  }

  GameState copyWith({
    LevelDefinition? currentLevel,
    Grid? grid,
    RenderState? renderState,
    ComponentType? selectedComponent,
    bool? isComplete,
  }) {
    return GameState(
      currentLevel: currentLevel ?? this.currentLevel,
      grid: grid ?? this.grid,
      renderState: renderState ?? this.renderState,
      selectedComponent: selectedComponent,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameState &&
          runtimeType == other.runtimeType &&
          currentLevel == other.currentLevel &&
          grid == other.grid &&
          renderState == other.renderState &&
          selectedComponent == other.selectedComponent &&
          isComplete == other.isComplete;

  @override
  int get hashCode =>
      currentLevel.hashCode ^
      grid.hashCode ^
      renderState.hashCode ^
      selectedComponent.hashCode ^
      isComplete.hashCode;
}
```

### RenderState Model

```dart
// lib/models/render_state.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'game_state.dart';
import 'position.dart';
import 'component_type.dart';

@immutable
class RenderState {
  final List<RenderComponent> components;
  final List<RenderConnection> connections;
  final Position? highlightedPosition;
  final int gridWidth;
  final int gridHeight;

  const RenderState({
    required this.components,
    required this.connections,
    this.highlightedPosition,
    required this.gridWidth,
    required this.gridHeight,
  });

  factory RenderState.empty() {
    return const RenderState(
      components: [],
      connections: [],
      gridWidth: 0,
      gridHeight: 0,
    );
  }

  factory RenderState.fromGameState(GameState gameState) {
    final components = <RenderComponent>[];
    final connections = <RenderConnection>[];

    // Convert grid components to render components
    for (final gridComponent in gameState.grid.components) {
      components.add(RenderComponent(
        position: gridComponent.position,
        type: gridComponent.type,
        color: _getComponentColor(gridComponent.type),
        width: 1, // Grid units
        height: 1, // Grid units
        label: gridComponent.type.shortName,
      ));
    }

    // Calculate connections
    // Add your connection logic here

    return RenderState(
      components: components,
      connections: connections,
      gridWidth: gameState.currentLevel.gridWidth,
      gridHeight: gameState.currentLevel.gridHeight,
    );
  }

  static Color _getComponentColor(ComponentType type) {
    switch (type) {
      case ComponentType.resistor:
        return Colors.brown;
      case ComponentType.capacitor:
        return Colors.blue;
      case ComponentType.inductor:
        return Colors.green;
      case ComponentType.transistor:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RenderState &&
          runtimeType == other.runtimeType &&
          listEquals(components, other.components) &&
          listEquals(connections, other.connections) &&
          highlightedPosition == other.highlightedPosition &&
          gridWidth == other.gridWidth &&
          gridHeight == other.gridHeight;

  @override
  int get hashCode =>
      Object.hash(
        Object.hashAll(components),
        Object.hashAll(connections),
        highlightedPosition,
        gridWidth,
        gridHeight,
      );
}

@immutable
class RenderComponent {
  final Position position;
  final ComponentType type;
  final Color color;
  final double width;
  final double height;
  final String label;

  const RenderComponent({
    required this.position,
    required this.type,
    required this.color,
    required this.width,
    required this.height,
    required this.label,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RenderComponent &&
          runtimeType == other.runtimeType &&
          position == other.position &&
          type == other.type &&
          color == other.color &&
          width == other.width &&
          height == other.height &&
          label == other.label;

  @override
  int get hashCode => Object.hash(position, type, color, width, height, label);
}

@immutable
class RenderConnection {
  final Position start;
  final Position end;

  const RenderConnection({
    required this.start,
    required this.end,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RenderConnection &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end;

  @override
  int get hashCode => start.hashCode ^ end.hashCode;
}
```

### ComponentType Enhancement

```dart
// lib/models/component_type.dart
enum ComponentType {
  resistor,
  capacitor,
  inductor,
  transistor,
  wire,
  battery,
}

extension ComponentTypeExtension on ComponentType {
  String get displayName {
    switch (this) {
      case ComponentType.resistor:
        return 'Resistor';
      case ComponentType.capacitor:
        return 'Capacitor';
      case ComponentType.inductor:
        return 'Inductor';
      case ComponentType.transistor:
        return 'Transistor';
      case ComponentType.wire:
        return 'Wire';
      case ComponentType.battery:
        return 'Battery';
    }
  }

  String get shortName {
    switch (this) {
      case ComponentType.resistor:
        return 'R';
      case ComponentType.capacitor:
        return 'C';
      case ComponentType.inductor:
        return 'L';
      case ComponentType.transistor:
        return 'T';
      case ComponentType.wire:
        return 'W';
      case ComponentType.battery:
        return 'B';
    }
  }
}
```

## Step 3: Migration Script

Create a migration script to help transition your existing codebase:

```bash
#!/bin/bash
# migrate_to_async_riverpod.sh

echo "Starting migration to async Riverpod pattern..."

# Backup existing files
mkdir -p backup
cp -r lib/core backup/
cp -r lib/screens backup/
cp -r lib/widgets backup/

# Generate new providers
echo "Generating new provider code..."
dart run build_runner build --delete-conflicting-outputs

# Run tests to verify migration
echo "Running tests..."
flutter test

echo "Migration complete! Check the backup directory if you need to revert changes."
```

## Step 4: Testing Strategy

### Unit Tests for Providers

```dart
// test/providers_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import '../lib/core/providers.dart';
import '../lib/models/level_definition.dart';

class MockLevelManager extends Mock implements LevelManager {}

void main() {
  group('GameEngine Provider Tests', () {
    late ProviderContainer container;
    late MockLevelManager mockLevelManager;

    setUp(() {
      mockLevelManager = MockLevelManager();
      container = ProviderContainer(
        overrides: [
          levelManagerProvider.overrideWithValue(mockLevelManager),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should load level definition and initialize game state', () async {
      // Arrange
      final testLevel = LevelDefinition(
        id: 1,
        name: 'Test Level',
        description: 'A test level',
        gridWidth: 10,
        gridHeight: 10,
        paletteComponents: [ComponentType.resistor],
      );
      
      when(mockLevelManager.getLevelDefinition(1))
          .thenAnswer((_) async => testLevel);

      // Act
      final gameState = await container.read(gameEngineProvider(1).future);

      // Assert
      expect(gameState.currentLevel, equals(testLevel));
      expect(gameState.grid, isNotNull);
      expect(gameState.renderState, isNotNull);
    });

    test('should handle level loading errors gracefully', () async {
      // Arrange
      when(mockLevelManager.getLevelDefinition(999))
          .thenThrow(LevelNotFoundException('Level 999 not found'));

      // Act & Assert
      expect(
        () => container.read(gameEngineProvider(999).future),
        throwsA(isA<LevelNotFoundException>()),
      );
    });
  });
}
```

### Widget Tests

```dart
// test/widgets/game_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';

import '../../lib/screens/game_screen.dart';
import '../../lib/core/providers.dart';

void main() {
  group('GameScreen Widget Tests', () {
    testWidgets('should show loading screen while data is loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: GameScreen(levelNumber: 1),
          ),
        ),
      );

      // Should show loading initially
      expect(find.byType(GameLoadingScreen), findsOneWidget);
      expect(find.text('Loading Level 1'), findsOneWidget);
    });

    testWidgets('should show error screen on load failure', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            levelDefinitionProvider(1).overrideWith(
              (ref) => throw Exception('Test error'),
            ),
          ],
          child: MaterialApp(
            home: GameScreen(levelNumber: 1),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(GameErrorScreen), findsOneWidget);
      expect(find.text('Failed to Load Level 1'), findsOneWidget);
    });
  });
}
```

## Step 5: Performance Considerations

### Provider Optimization

```dart
// Use autoDispose to prevent memory leaks
@riverpod
Future<LevelDefinition> levelDefinition(LevelDefinitionRef ref, int levelNumber) async {
  // Keep provider alive for 5 minutes after last use
  ref.keepAlive();
  
  // Cancel if no longer needed
  Timer(Duration(minutes: 5), () {
    ref.invalidateSelf();
  });
  
  final levelManager = ref.watch(levelManagerProvider);
  return await levelManager.getLevelDefinition(levelNumber);
}
```

### Selective Rebuilds

```dart
// Use select to prevent unnecessary rebuilds
Widget build(BuildContext context, WidgetRef ref) {
  // Only rebuild when selected component changes
  final selectedComponent = ref.watch(
    gameEngineProvider(levelNumber).select((state) => 
      state.valueOrNull?.selectedComponent
    ),
  );
  
  return ComponentPalette(selectedComponent: selectedComponent);
}
```

## Step 6: Error Monitoring

```dart
// lib/core/error_monitoring.dart
class ErrorMonitor {
  static void logProviderError(String providerName, Object error, StackTrace stack) {
    // Log to your error monitoring service
    print('Provider Error in $providerName: $error');
    // FirebaseCrashlytics.instance.recordError(error, stack);
  }
}

// In providers.dart
@riverpod
class GameEngine extends _$GameEngine {
  @override
  FutureOr<GameState> build(int levelNumber) async {
    try {
      final levelDefinition = await ref.watch(levelDefinitionProvider(levelNumber).future);
      return GameState.initial(levelDefinition);
    } catch (error, stack) {
      ErrorMonitor.logProviderError('GameEngine', error, stack);
      rethrow;
    }
  }
}
```

## Benefits Summary

1. **Eliminated Race Conditions**: UI waits for data before rendering
2. **Better Error Handling**: Comprehensive error states and recovery
3. **Type Safety**: No more null checks in UI components
4. **Modern Patterns**: Uses latest Riverpod best practices
5. **Testability**: Easy to unit test with clear separation of concerns
6. **Performance**: Selective rebuilds and proper provider lifecycle
7. **Developer Experience**: Clear loading states and error messages

This architecture ensures your game will load reliably and provide a great user experience even when network conditions are poor or data loading takes time.