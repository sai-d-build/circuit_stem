import 'package:flutter_riverpod/flutter_riverpod.dart';

enum HudOverlayType {
  none,
  pause,
  win,
  settings,
  help,
}

class ProgressData {
  final int currentScore;
  final int bestScore;
  final int starsEarned;
  final int totalStars;
  final int hintsUsed;
  final int totalHints;
  final Duration elapsedTime;
  final bool isComplete;

  const ProgressData({
    required this.currentScore,
    required this.bestScore,
    required this.starsEarned,
    required this.totalStars,
    required this.hintsUsed,
    required this.totalHints,
    required this.elapsedTime,
    required this.isComplete,
  });

  ProgressData copyWith({
    int? currentScore,
    int? bestScore,
    int? starsEarned,
    int? totalStars,
    int? hintsUsed,
    int? totalHints,
    Duration? elapsedTime,
    bool? isComplete,
  }) {
    return ProgressData(
      currentScore: currentScore ?? this.currentScore,
      bestScore: bestScore ?? this.bestScore,
      starsEarned: starsEarned ?? this.starsEarned,
      totalStars: totalStars ?? this.totalStars,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      totalHints: totalHints ?? this.totalHints,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isComplete: isComplete ?? this.isComplete,
    );
  }

  String get formattedTime {
    final minutes = elapsedTime.inMinutes;
    final seconds = elapsedTime.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progressPercentage {
    if (totalStars == 0) return 0.0;
    return starsEarned / totalStars;
  }
}

class HudState {
  final HudOverlayType currentOverlay;
  final bool isProgressVisible;
  final bool isHintsVisible;
  final ProgressData progress;
  final List<String> availableHints;
  final String? currentHint;
  final bool isMenuVisible;
  final bool isAnimating;

  const HudState({
    this.currentOverlay = HudOverlayType.none,
    this.isProgressVisible = true,
    this.isHintsVisible = true,
    required this.progress,
    this.availableHints = const [],
    this.currentHint,
    this.isMenuVisible = false,
    this.isAnimating = false,
  });

  HudState copyWith({
    HudOverlayType? currentOverlay,
    bool? isProgressVisible,
    bool? isHintsVisible,
    ProgressData? progress,
    List<String>? availableHints,
    String? currentHint,
    bool? isMenuVisible,
    bool? isAnimating,
  }) {
    return HudState(
      currentOverlay: currentOverlay ?? this.currentOverlay,
      isProgressVisible: isProgressVisible ?? this.isProgressVisible,
      isHintsVisible: isHintsVisible ?? this.isHintsVisible,
      progress: progress ?? this.progress,
      availableHints: availableHints ?? this.availableHints,
      currentHint: currentHint ?? this.currentHint,
      isMenuVisible: isMenuVisible ?? this.isMenuVisible,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }

  bool get hasOverlay => currentOverlay != HudOverlayType.none;
  bool get isPaused => currentOverlay == HudOverlayType.pause;
  bool get isWinScreenShown => currentOverlay == HudOverlayType.win;
  bool get hasHints => availableHints.isNotEmpty;
}

// Providers
final hudStateProvider = StateNotifierProvider.family<HudStateNotifier, HudState, String>((ref, levelId) {
  return HudStateNotifier(levelId);
});

class HudStateNotifier extends StateNotifier<HudState> {
  final String levelId;

  HudStateNotifier(this.levelId) : super(HudState(
    progress: ProgressData(
      currentScore: 0,
      bestScore: _getBestScore(levelId),
      starsEarned: 0,
      totalStars: 3,
      hintsUsed: 0,
      totalHints: _getAvailableHints(levelId).length,
      elapsedTime: Duration.zero,
      isComplete: false,
    ),
    availableHints: _getAvailableHints(levelId),
  ));

  void showOverlay(HudOverlayType overlayType) {
    state = state.copyWith(
      currentOverlay: overlayType,
      isAnimating: true,
    );
    
    // Reset animation flag after a brief delay
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        state = state.copyWith(isAnimating: false);
      }
    });
  }

  void hideOverlay() {
    state = state.copyWith(
      currentOverlay: HudOverlayType.none,
      isAnimating: true,
    );
    
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        state = state.copyWith(isAnimating: false);
      }
    });
  }

  void togglePause() {
    if (state.currentOverlay == HudOverlayType.pause) {
      hideOverlay();
    } else {
      showOverlay(HudOverlayType.pause);
    }
  }

  void showWinScreen() {
    showOverlay(HudOverlayType.win);
  }

  void toggleProgressVisibility() {
    state = state.copyWith(isProgressVisible: !state.isProgressVisible);
  }

  void toggleHintsVisibility() {
    state = state.copyWith(isHintsVisible: !state.isHintsVisible);
  }

  void toggleMenuVisibility() {
    state = state.copyWith(isMenuVisible: !state.isMenuVisible);
  }

  void updateProgress(ProgressData newProgress) {
    state = state.copyWith(progress: newProgress);
    
    // Auto-show win screen when level is completed
    if (newProgress.isComplete && !state.isWinScreenShown) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) showWinScreen();
      });
    }
  }

  void useHint(int hintIndex) {
    if (hintIndex >= 0 && hintIndex < state.availableHints.length) {
      final hint = state.availableHints[hintIndex];
      final updatedProgress = state.progress.copyWith(
        hintsUsed: state.progress.hintsUsed + 1,
      );
      
      state = state.copyWith(
        currentHint: hint,
        progress: updatedProgress,
      );
      
      // Clear hint after some time
      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          state = state.copyWith(currentHint: null);
        }
      });
    }
  }

  void clearCurrentHint() {
    state = state.copyWith(currentHint: null);
  }

  void updateScore(int newScore) {
    final updatedProgress = state.progress.copyWith(currentScore: newScore);
    state = state.copyWith(progress: updatedProgress);
  }

  void updateStars(int starsEarned) {
    final updatedProgress = state.progress.copyWith(starsEarned: starsEarned);
    state = state.copyWith(progress: updatedProgress);
  }

  void updateElapsedTime(Duration elapsedTime) {
    final updatedProgress = state.progress.copyWith(elapsedTime: elapsedTime);
    state = state.copyWith(progress: updatedProgress);
  }

  void markComplete() {
    final updatedProgress = state.progress.copyWith(isComplete: true);
    state = state.copyWith(progress: updatedProgress);
  }

  void reset() {
    state = HudState(
      progress: ProgressData(
        currentScore: 0,
        bestScore: _getBestScore(levelId),
        starsEarned: 0,
        totalStars: 3,
        hintsUsed: 0,
        totalHints: _getAvailableHints(levelId).length,
        elapsedTime: Duration.zero,
        isComplete: false,
      ),
      availableHints: _getAvailableHints(levelId),
    );
  }
}

// Helper functions for sample data
int _getBestScore(String levelId) {
  // In a real app, this would come from persistent storage
  final bestScores = {
    '1': 1250,
    '2': 1100,
    '3': 980,
  };
  return bestScores[levelId] ?? 0;
}

List<String> _getAvailableHints(String levelId) {
  final hints = {
    '1': [
      'Start by placing the battery - it provides the power for your circuit.',
      'LEDs need current limiting! Add a resistor in series with the LED.',
      'Connect the positive terminal of the battery to one end of the resistor.',
      'Complete the circuit by connecting the LED cathode back to the battery negative terminal.',
    ],
    '2': [
      'In a series circuit, current flows through one path.',
      'Place all components in a single loop - no branches!',
      'The same current flows through each component in series.',
      'Check that there are no gaps in your circuit path.',
    ],
    '3': [
      'Parallel circuits have multiple paths for current.',
      'Create branches from the main circuit path.',
      'Each branch in parallel has the same voltage across it.',
      'Use the switch to control one of the parallel branches.',
    ],
  };
  return hints[levelId] ?? [];
}