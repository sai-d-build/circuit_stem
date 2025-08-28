
// PURPOSE: Manage UI-specific state for the Heads-Up Display (HUD).
import 'package:flutter_riverpod/flutter_riverpod.dart';

// This manages state that is purely for the UI, like showing a pause menu.
final hudStateProvider = StateNotifierProvider<HudStateNotifier, HudState>((ref) {
  return HudStateNotifier();
});

final debugOverlayProvider = StateProvider<bool>((ref) => false);

class HudState {
  final bool isPaused;
  final bool showWinScreen;
  
  const HudState({
    this.isPaused = false,
    this.showWinScreen = false,
  });

  HudState copyWith({bool? isPaused, bool? showWinScreen}) {
    return HudState(
      isPaused: isPaused ?? this.isPaused,
      showWinScreen: showWinScreen ?? this.showWinScreen,
    );
  }
}

class HudStateNotifier extends StateNotifier<HudState> {
  HudStateNotifier() : super(const HudState());

  void togglePause() {
    state = state.copyWith(isPaused: !state.isPaused);
  }

  void showWinScreen() {
    state = state.copyWith(showWinScreen: true);
  }

  void hideWinScreen() {
    state = state.copyWith(showWinScreen: false);
  }
}
