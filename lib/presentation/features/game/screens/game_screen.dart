// Game screen for SparkCircuit educational gaming platform

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive_utils.dart';
import '../../../core/utils/animation_utils.dart';
import '../../../core/utils/error_utils.dart';
import '../widgets/game_canvas.dart';
import 'package:sparkcircuit/application/game_engine/v3/providers_v3.dart';
import 'package:sparkcircuit/presentation/features/palette/widgets/horizontal_component_palette.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

class GameScreen extends ConsumerStatefulWidget {
  final String levelId;

  const GameScreen({super.key, required this.levelId});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with TickerProviderStateMixin {
  late Timer _levelTimer;
  Duration _elapsedTime = Duration.zero;
  bool _isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    if (!_isTimerRunning) {
      _isTimerRunning = true;
      _levelTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            _elapsedTime += const Duration(seconds: 1);
          });
        }
      });
    }
  }

  void _stopTimer() {
    _isTimerRunning = false;
    _levelTimer.cancel();
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _elapsedTime = Duration.zero;
    });
    _startTimer();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final levelIdStr = widget.levelId.toString();
    final isLandscape = context.isLandscape;
    final isMobile = context.isMobile;

    StructuredLogger.info('Game screen building', context: {
      'levelId': levelIdStr,
      'device': {
        'isLandscape': isLandscape,
        'isMobile': isMobile,
        'screenSize': MediaQuery.of(context).size.toString(),
      },
    });

    return Scaffold(
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      appBar: _buildResponsiveAppBar(context),
      body: _buildResponsiveBody(context, levelIdStr, isLandscape, isMobile),
    );
  }

  PreferredSizeWidget _buildResponsiveAppBar(BuildContext context) {
    final isMobile = context.isMobile;
    final appBarHeight = isMobile ? kToolbarHeight * 0.9 : kToolbarHeight;

    return PreferredSize(
      preferredSize: Size.fromHeight(appBarHeight),
      child: AppBar(
        title: Text(
          'Level ${widget.levelId}',
          style: TextStyle(
            fontSize: context.responsiveFontSize(20),
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: AppTheme.lightTheme.colorScheme.onPrimary,
        toolbarHeight: appBarHeight,
        actions: [
          if (!context.isMobile) ...[
            IconButton(
              icon: Icon(
                Icons.undo,
                size: context.responsiveIconSize(24),
              ),
              onPressed: () {
                ref.read(enhancedGameStateNotifierProvider.notifier).undo();
              },
              tooltip: 'Undo',
            ),
          ],
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: context.responsiveIconSize(24),
            ),
            onPressed: () {
              // Restart level functionality
              _resetTimer();
              ref.read(enhancedGameStateNotifierProvider.notifier).resetLevel();

              // Show success feedback
              SuccessUtils.showSuccess(
                context,
                'Level has been reset successfully',
                title: 'Level Reset',
              );
            },
            tooltip: 'Restart Level',
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveBody(BuildContext context, String levelIdStr, bool isLandscape, bool isMobile) {
    StructuredLogger.info('Building responsive game screen layout', context: {
      'levelId': levelIdStr,
      'device': {
        'isLandscape': isLandscape,
        'isMobile': isMobile,
      },
      'layoutStrategy': isLandscape && isMobile ? 'horizontal_mobile' : 'vertical_default',
    });

    // Add debug logging for component initialization
    debugPrint('🎮 GameScreen: Building body for level $levelIdStr');
    debugPrint('🎮 GameScreen: Passing levelId to GameCanvas: $levelIdStr');
    debugPrint('🎮 GameScreen: Passing levelId to HorizontalComponentPalette: $levelIdStr');

    if (isLandscape && isMobile) {
      // Landscape mobile: horizontal layout
      StructuredLogger.debug('Using horizontal mobile layout for optimal screen usage');
      return Row(
        children: [
          // Game Canvas takes most space
          Expanded(
            flex: 3,
            child: GameCanvas(levelId: levelIdStr),
          ),
          // HUD and Palette in a column on the side
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Column(
              children: [
                _buildResponsiveHud(context),
                Expanded(
                  child: HorizontalComponentPalette(levelId: levelIdStr),
                ),
              ],
            ),
          ),
        ],
      );
    } else {
      // Portrait or tablet/desktop: vertical layout
      StructuredLogger.debug('Using vertical layout for portrait/tablet/desktop', context: {
        'orientation': isLandscape ? 'landscape' : 'portrait',
        'palettePlacement': 'bottom_sized',
      });
      return Column(
        children: [
          _buildResponsiveHud(context),
          // Game Canvas
          Expanded(
            child: GameCanvas(levelId: levelIdStr),
          ),
          // Component Palette
          SizedBox(
            height: context.paletteHeight,
            child: HorizontalComponentPalette(levelId: levelIdStr),
          ),
        ],
      );
    }
  }

  Widget _buildResponsiveHud(BuildContext context) {
    final isMobile = context.isMobile;
    final padding = context.responsivePadding;
    final spacing = context.responsiveSpacing();

    return AnimatedListItem(
      index: 0,
      delay: AnimationUtils.fast,
      slideBegin: const Offset(0.0, -0.2),
      child: Container(
        height: context.hudHeight,
        padding: EdgeInsets.symmetric(
          horizontal: padding.left,
          vertical: padding.top * 0.5,
        ),
        color: AppTheme.lightTheme.colorScheme.surface,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Level ${widget.levelId}',
                style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                  fontSize: context.responsiveFontSize(
                    isMobile ? 18 : 20,
                  ),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AnimatedListItem(
              index: 1,
              delay: AnimationUtils.fast,
              slideBegin: const Offset(0.2, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer,
                    size: context.responsiveIconSize(20),
                    color: AppTheme.lightTheme.colorScheme.onSurface,
                  ),
                  SizedBox(width: spacing),
                  Text(
                    _formatDuration(_elapsedTime),
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontSize: context.responsiveFontSize(
                        isMobile ? 14 : 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}