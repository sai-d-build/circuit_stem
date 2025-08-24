import 'package:circuit_stem/application/animation_scheduler.dart';
import 'mock_logger.dart';

class MockAnimationScheduler implements AnimationScheduler {
  final List<AnimationCallback> _callbacks = [];
  bool _isRunning = false;
  int _frameCount = 0;
  static const int _maxFrames = 60; // Auto-stop after 60 frames (~1 second at 60fps)

  @override
  double get bulbIntensity => _isRunning ? 0.5 + 0.5 * (_frameCount / _maxFrames) : 1.0;

  @override
  double get wireOffset => _isRunning ? (_frameCount % 10) / 10.0 : 0.0;

  @override
  void addCallback(AnimationCallback callback) {
    Logger.log('[MockAnimationScheduler] Adding callback');
    _callbacks.add(callback);
  }

  @override
  void dispose() {
    Logger.log('[MockAnimationScheduler] Disposing');
    _callbacks.clear();
    _isRunning = false;
    _frameCount = 0;
  }

  @override
  void pause() {
    Logger.log('[MockAnimationScheduler] Pausing');
    _isRunning = false;
  }

  @override
  void removeCallback(AnimationCallback callback) {
    Logger.log('[MockAnimationScheduler] Removing callback');
    _callbacks.remove(callback);
  }

  @override
  void reset() {
    Logger.log('[MockAnimationScheduler] Resetting');
    _isRunning = false;
    _frameCount = 0;
  }

  @override
  void resume() {
    Logger.log('[MockAnimationScheduler] Resuming');
    _isRunning = true;
  }

  @override
  void start() {
    Logger.log('[MockAnimationScheduler] Starting');
    _isRunning = true;
    _frameCount = 0;
  }

  @override
  void stop() {
    Logger.log('[MockAnimationScheduler] Stopping');
    _isRunning = false;
    _frameCount = 0;
  }

  bool get isRunning => _isRunning;
  int get frameCount => _frameCount;

  void triggerManualFrame(double dt) {
    if (!_isRunning) return;
    
    _frameCount++;
    Logger.log('[MockAnimationScheduler] Triggering frame: $_frameCount');
    
    // Create a copy to avoid concurrent modification issues
    final List<AnimationCallback> currentCallbacks = List.from(_callbacks);
    for (final callback in currentCallbacks) {
      callback(dt);
    }
    
    // Auto-stop after enough frames to simulate animation completion
    if (_frameCount >= _maxFrames) {
      Logger.log('[MockAnimationScheduler] Max frames reached, stopping animation');
      _isRunning = false;
      _frameCount = 0;
    }
  }

  /// Force the animation to complete immediately
  void completeAnimation() {
    Logger.log('[MockAnimationScheduler] Forcing animation completion');
    if (_isRunning) {
      _frameCount = _maxFrames;
      triggerManualFrame(0.016); // This will auto-stop the animation
    }
  }

  /// Reset and ensure the animation is stopped (for test cleanup)
  void forceStop() {
    Logger.log('[MockAnimationScheduler] Forcing stop');
    _isRunning = false;
    _frameCount = 0;
  }
}