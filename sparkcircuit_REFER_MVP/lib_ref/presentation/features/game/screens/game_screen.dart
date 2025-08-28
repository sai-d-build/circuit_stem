import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';
import 'package:sparkcircuit/presentation/core/widgets/responsive_scaffold.dart';
import 'package:sparkcircuit/presentation/features/game/widgets/game_canvas.dart';
import 'package:sparkcircuit/presentation/features/palette/widgets/component_palette.dart';
import 'package:sparkcircuit/presentation/features/hud/widgets/progress_hud.dart';
import 'package:sparkcircuit/presentation/state/game_state.dart';
import 'package:sparkcircuit/presentation/state/hud_state.dart';
import 'package:sparkcircuit/presentation/state/palette_state.dart';
import 'package:sparkcircuit/presentation/features/hud/screens/pause_menu.dart';
import 'package:sparkcircuit/presentation/features/hud/screens/win_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen>
    with TickerProviderStateMixin {
  late AnimationController _slideAnimationController;
  late Animation<Offset> _canvasSlideAnimation;
  late Animation<Offset> _paletteSlideAnimation;
  
  bool _isPaletteVisible = true;

  @override
  void initState() {
    super.initState();
    
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _canvasSlideAnimation = Tween<Offset>(
      begin: const Offset(0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _paletteSlideAnimation = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _slideAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circuitColors = theme.extension<CircuitColorScheme>()!;
    final gameState = ref.watch(gameStateProvider(widget.levelId));
    final hudState = ref.watch(hudStateProvider(widget.levelId));
    
    // Update HUD with game progress
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateHudFromGameState(gameState);
    });
    
    return ResponsiveScaffold(
      backgroundColor: circuitColors.surface,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  circuitColors.surface,
                  circuitColors.surfaceContainer.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
          
          // Main game layout
          Row(
            children: [
              // Component palette (left side)
              if (_isPaletteVisible)
                SlideTransition(
                  position: _paletteSlideAnimation,
                  child: Container(
                    width: 280,
                    child: ComponentPalette(levelId: widget.levelId),
                  ),
                ),
              
              // Game canvas (center/right)
              Expanded(
                child: SlideTransition(
                  position: _canvasSlideAnimation,
                  child: Column(
                    children: [
                      // Top HUD
                      Container(
                        height: 80,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16, 
                          vertical: 8,
                        ),
                        child: ProgressHud(levelId: widget.levelId),
                      ),
                      
                      // Game canvas
                      Expanded(
                        child: GameCanvas(levelId: widget.levelId),
                      ),
                      
                      // Bottom controls
                      Container(
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _buildBottomControls(circuitColors),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          // Floating action buttons
          Positioned(
            top: 100,
            right: 16,
            child: _buildFloatingControls(circuitColors),
          ),
          
          // Overlay screens
          if (hudState.hasOverlay) _buildOverlay(hudState),
        ],
      ),
    );
  }

  Widget _buildBottomControls(CircuitColorScheme circuitColors) {
    return Row(
      children: [
        // Palette toggle
        IconButton(
          onPressed: _togglePalette,
          icon: Icon(
            _isPaletteVisible ? Icons.chevron_left : Icons.chevron_right,
            color: circuitColors.onSurface,
          ),
          tooltip: _isPaletteVisible ? 'Hide palette' : 'Show palette',
        ),
        
        const Spacer(),
        
        // Simulation controls
        Row(
          children: [
            IconButton(
              onPressed: _resetLevel,
              icon: Icon(
                Icons.refresh,
                color: circuitColors.onSurface,
              ),
              tooltip: 'Reset level',
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: _toggleSimulation,
              icon: Icon(
                ref.watch(gameStateProvider(widget.levelId)).isSimulating
                    ? Icons.pause
                    : Icons.play_arrow,
              ),
              label: Text(
                ref.watch(gameStateProvider(widget.levelId)).isSimulating
                    ? 'Pause'
                    : 'Simulate',
              ),
            ),
          ],
        ),
        
        const Spacer(),
        
        // Menu button
        IconButton(
          onPressed: _showPauseMenu,
          icon: Icon(
            Icons.menu,
            color: circuitColors.onSurface,
          ),
          tooltip: 'Menu',
        ),
      ],
    );
  }

  Widget _buildFloatingControls(CircuitColorScheme circuitColors) {
    return Column(
      children: [
        FloatingActionButton.small(
          heroTag: 'help',
          onPressed: _showHint,
          backgroundColor: circuitColors.secondary,
          foregroundColor: circuitColors.onSecondary,
          child: const Icon(Icons.lightbulb_outline),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'zoom_in',
          onPressed: _zoomIn,
          backgroundColor: circuitColors.surfaceContainer,
          foregroundColor: circuitColors.onSurface,
          child: const Icon(Icons.zoom_in),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'zoom_out',
          onPressed: _zoomOut,
          backgroundColor: circuitColors.surfaceContainer,
          foregroundColor: circuitColors.onSurface,
          child: const Icon(Icons.zoom_out),
        ),
      ],
    );
  }

  Widget _buildOverlay(HudState hudState) {
    Widget overlayContent;
    
    switch (hudState.currentOverlay) {
      case HudOverlayType.pause:
        overlayContent = PauseMenu(levelId: widget.levelId);
        break;
      case HudOverlayType.win:
        overlayContent = WinScreen(levelId: widget.levelId);
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(child: overlayContent),
    );
  }

  void _togglePalette() {
    setState(() {
      _isPaletteVisible = !_isPaletteVisible;
    });
    
    if (_isPaletteVisible) {
      _slideAnimationController.forward();
    } else {
      _slideAnimationController.reverse();
    }
  }

  void _toggleSimulation() {
    ref.read(gameStateProvider(widget.levelId).notifier).toggleSimulation();
  }

  void _resetLevel() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Level'),
        content: const Text('Are you sure you want to reset this level? All progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(gameStateProvider(widget.levelId).notifier).resetLevel();
              ref.read(hudStateProvider(widget.levelId).notifier).reset();
              ref.read(paletteStateProvider(widget.levelId).notifier).reset();
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _showPauseMenu() {
    ref.read(hudStateProvider(widget.levelId).notifier).togglePause();
  }

  void _showHint() {
    ref.read(hudStateProvider(widget.levelId).notifier).useHint(0);
    ref.read(gameStateProvider(widget.levelId).notifier).useHint();
  }

  void _zoomIn() {
    // TODO: Implement zoom functionality in game canvas controller
  }

  void _zoomOut() {
    // TODO: Implement zoom functionality in game canvas controller
  }

  void _updateHudFromGameState(GameState gameState) {
    final hudNotifier = ref.read(hudStateProvider(widget.levelId).notifier);
    
    final progress = ProgressData(
      currentScore: gameState.score,
      bestScore: 1500, // From persistent storage
      starsEarned: gameState.starsEarned,
      totalStars: 3,
      hintsUsed: gameState.hintsUsed,
      totalHints: 4,
      elapsedTime: gameState.elapsedTime,
      isComplete: gameState.isComplete,
    );
    
    hudNotifier.updateProgress(progress);
  }
}