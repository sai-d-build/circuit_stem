# Hybrid GameEngine Implementation Guide

## Overview

This guide demonstrates how to implement the hybrid facade pattern for the GameEngine refactoring. The hybrid approach maintains backward compatibility while introducing granular notifiers for improved performance and maintainability.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    UI Layer (Unchanged)                     │
├─────────────────────────────────────────────────────────────┤
│              HybridGameEngineAdapter                        │
│                 (Facade Pattern)                           │
├─────────────────────────────────────────────────────────────┤
│  GameEngineOrchestrator  │  ComponentSelectionNotifier     │
│  (Core Game Logic)       │  InteractionStateNotifier       │
│                         │  (UI State Management)           │
├─────────────────────────────────────────────────────────────┤
│  GridNotifier │ HistoryNotifier │ GameProgressNotifier      │
│  (Specialized Notifiers)                                   │
└─────────────────────────────────────────────────────────────┘
```

## Key Components

### 1. GameEngineOrchestrator
- Coordinates actions across multiple notifiers
- Maintains atomic transactions
- Handles core game logic

### 2. Specialized Notifiers
- **GridNotifier**: Manages grid state and component positions
- **HistoryNotifier**: Handles undo/redo functionality
- **GameProgressNotifier**: Manages win conditions and scoring
- **ComponentSelectionNotifier**: Tracks selected components
- **InteractionStateNotifier**: Handles drag and drop state

### 3. HybridGameEngineAdapter
- Maintains existing API for backward compatibility
- Delegates to appropriate notifiers
- Provides seamless migration path

## Usage Examples

### Basic Setup

```dart
// In your main app setup
final container = ProviderContainer(
  overrides: [
    sharedPreferencesProvider.overrideWithValue(mockPrefs),
    audioServiceProvider.overrideWithValue(mockAudio),
  ],
);

// Use the hybrid provider instead of the original
final gameEngine = container.read(hybridGameEngineProvider.notifier);
```

### UI Widget Updates (Gradual Migration)

#### Before (Original approach):
```dart
class GameWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameEngineProvider);
    final isWin = gameState.isWin;
    final selectedId = gameState.selectedComponentId;
    
    return Column(
      children: [
        if (isWin) WinScreen(),
        GridWidget(grid: gameState.grid),
        ComponentPalette(selectedId: selectedId),
      ],
    );
  }
}
```

#### After (Optimized with granular providers):
```dart
class GameWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Only rebuilds when win state changes
        Consumer(builder: (context, ref, child) {
          final isWin = ref.watch(isWinProvider);
          return isWin ? WinScreen() : SizedBox.shrink();
        }),
        
        // Only rebuilds when grid changes
        Consumer(builder: (context, ref, child) {
          final grid = ref.watch(gridProvider);
          return GridWidget(grid: grid);
        }),
        
        // Only rebuilds when selection changes
        Consumer(builder: (context, ref, child) {
          final selectedId = ref.watch(selectedComponentIdProvider);
          return ComponentPalette(selectedId: selectedId);
        }),
      ],
    );
  }
}
```

### Action Execution

```dart
// Actions work exactly the same as before
final gameEngine = ref.read(hybridGameEngineProvider.notifier);

// Core game actions
await gameEngine.executeAction(MoveComponentAction(
  componentId: 'component1',
  newRow: 2,
  newCol: 3,
));

// UI actions
gameEngine.selectPaletteComponent(component);
gameEngine.startDrag('component1', Offset(100, 200));
```

## Migration Strategy

### Phase 1: Setup (Week 1)
1. Deploy hybrid providers alongside existing system
2. Add feature flag for gradual rollout
3. Update one widget at a time to use granular providers

### Phase 2: Validation (Week 2)
1. A/B test performance improvements
2. Monitor for regressions
3. Gather performance metrics

### Phase 3: Full Migration (Week 3)
1. Switch all widgets to granular providers
2. Remove old provider references
3. Clean up unused code

## Performance Benefits

### Before:
- Single large state object
- All UI rebuilds on any state change
- Difficult to optimize specific UI sections

### After:
- Granular state slices
- UI rebuilds only when relevant state changes
- Easy to optimize individual components

## Testing Strategy

### Unit Tests
```dart
testWidgets('Grid updates independently', (tester) async {
  final container = ProviderContainer();
  
  // Test that grid changes don't affect selection state
  final gridNotifier = container.read(gridNotifierProvider.notifier);
  final selectionNotifier = container.read(componentSelectionNotifierProvider.notifier);
  
  selectionNotifier.selectComponent('comp1');
  gridNotifier.updateGrid(newGrid);
  
  expect(container.read(selectedComponentIdProvider), equals('comp1'));
});
```

### Integration Tests
```dart
testWidgets('Hybrid adapter maintains compatibility', (tester) async {
  final container = ProviderContainer();
  final adapter = container.read(hybridGameEngineProvider.notifier);
  
  // Test that existing API still works
  await adapter.executeAction(MoveComponentAction(...));
  adapter.selectPaletteComponent(component);
  
  // Verify state is updated correctly
  final state = container.read(hybridGameEngineProvider);
  expect(state.selectedComponentId, equals(component.id));
});
```

## Rollback Strategy

If issues arise, the hybrid approach allows for easy rollback:

1. Switch feature flag back to original implementation
2. All existing UI code continues to work
3. No data loss or state corruption

## Monitoring and Metrics

Track these metrics during migration:

- UI rebuild frequency (should decrease)
- Memory usage (should remain stable)
- Action execution time (should remain stable)
- User interaction responsiveness (should improve)

## Conclusion

The hybrid approach provides:
- ✅ Backward compatibility
- ✅ Gradual migration path
- ✅ Performance improvements
- ✅ Risk mitigation
- ✅ Easy rollback capability

This implementation strategy minimizes risk while delivering the architectural benefits outlined in the GOD_REFACTOR.md document.