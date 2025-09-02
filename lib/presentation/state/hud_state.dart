import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../../core/persistence/storage_service.dart';
import '../../application/game_engine_v3/providers_v3.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';

enum HudOverlayType {
  none,
  pause,
  win,
  settings,
  help,
}

class ProgressData {
  final String levelId;
  final int currentScore;
  final int bestScore;
  final int starsEarned;
  final int totalStars;
  final int hintsUsed;
  final int totalHints;
  final Duration elapsedTime;
  final bool isComplete;
  final DateTime? completionTime;

  const ProgressData({
    required this.levelId,
    required this.currentScore,
    required this.bestScore,
    required this.starsEarned,
    required this.totalStars,
    required this.hintsUsed,
    required this.totalHints,
    required this.elapsedTime,
    required this.isComplete,
    this.completionTime,
  });

  ProgressData copyWith({
    String? levelId,
    int? currentScore,
    int? bestScore,
    int? starsEarned,
    int? totalStars,
    int? hintsUsed,
    int? totalHints,
    Duration? elapsedTime,
    bool? isComplete,
    DateTime? completionTime,
  }) {
    return ProgressData(
      levelId: levelId ?? this.levelId,
      currentScore: currentScore ?? this.currentScore,
      bestScore: bestScore ?? this.bestScore,
      starsEarned: starsEarned ?? this.starsEarned,
      totalStars: totalStars ?? this.totalStars,
      hintsUsed: hintsUsed ?? this.hintsUsed,
      totalHints: totalHints ?? this.totalHints,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      isComplete: isComplete ?? this.isComplete,
      completionTime: completionTime ?? this.completionTime,
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

  // JSON serialization methods
  Map<String, dynamic> toJson() {
    return {
      'levelId': levelId,
      'currentScore': currentScore,
      'bestScore': bestScore,
      'starsEarned': starsEarned,
      'totalStars': totalStars,
      'hintsUsed': hintsUsed,
      'totalHints': totalHints,
      'elapsedTimeInSeconds': elapsedTime.inSeconds,
      'isComplete': isComplete,
      'completionTime': completionTime?.toIso8601String(),
    };
  }

  factory ProgressData.fromJson(Map<String, dynamic> json) {
    return ProgressData(
      levelId: json['levelId'] ?? '',
      currentScore: json['currentScore'] ?? 0,
      bestScore: json['bestScore'] ?? 0,
      starsEarned: json['starsEarned'] ?? 0,
      totalStars: json['totalStars'] ?? 3,
      hintsUsed: json['hintsUsed'] ?? 0,
      totalHints: json['totalHints'] ?? 0,
      elapsedTime: Duration(seconds: json['elapsedTimeInSeconds'] ?? 0),
      isComplete: json['isComplete'] ?? false,
      completionTime: json['completionTime'] != null
          ? DateTime.parse(json['completionTime'])
          : null,
    );
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
  final storageService = ref.watch(storageServiceProvider);
  return HudStateNotifier(levelId, storageService);
});

class HudStateNotifier extends StateNotifier<HudState> {
  final String levelId;
  final StorageService _storageService;

  HudStateNotifier(this.levelId, this._storageService) : super(HudState(
    progress: ProgressData(
      levelId: levelId,
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
  )) {
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final savedData = _storageService.readData<String>('progress_$levelId');
    if (savedData != null) {
      try {
        final progressJson = jsonDecode(savedData) as Map<String, dynamic>;
        final savedProgress = ProgressData.fromJson(progressJson);
        state = state.copyWith(progress: savedProgress);
      } catch (e) {
        // If loading fails, keep default progress
        StructuredLogger.warning('Failed to load HUD progress data', context: {
          'levelId': levelId,
          'dataKey': 'progress_$levelId',
          'error': e.toString(),
        }, error: e);
      }
    }
  }

  Future<void> _saveProgress() async {
    try {
      final progressJson = state.progress.toJson();
      final progressString = jsonEncode(progressJson);
      await _storageService.saveData<String>('progress_$levelId', progressString);
    } catch (e) {
      StructuredLogger.error('Failed to save HUD progress data', context: {
        'levelId': levelId,
        'dataKey': 'progress_$levelId',
        'currentScore': state.progress.currentScore,
        'isComplete': state.progress.isComplete,
        'error': e.toString(),
      }, error: e);
    }
  }

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
    _saveProgress();

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

      _saveProgress();

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
    final updatedProgress = state.progress.copyWith(
      isComplete: true,
      completionTime: DateTime.now(),
    );
    state = state.copyWith(progress: updatedProgress);
    _saveProgress();
  }

  void reset() {
    state = HudState(
      progress: ProgressData(
        levelId: levelId,
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