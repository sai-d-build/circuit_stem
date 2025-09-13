import 'performance_monitor.dart';

class AdaptiveQualityManager {
  static QualityLevel _currentLevel = QualityLevel.high;

  static QualityLevel get currentLevel => _currentLevel;

  static void assessDeviceCapabilities() {
    PerformanceMonitor.startStaticMonitoring();

    // Initial assessment based on device info
    // This would be expanded with actual device detection
    if (!PerformanceMonitor.isHighPerformanceDevice) {
      _currentLevel = QualityLevel.medium;
    }
  }

  static void reduceQuality() {
    switch (_currentLevel) {
      case QualityLevel.high:
        _currentLevel = QualityLevel.medium;
        break;
      case QualityLevel.medium:
        _currentLevel = QualityLevel.low;
        break;
      case QualityLevel.low:
        // Already at lowest quality
        break;
    }
  }

  static void increaseQuality() {
    if (PerformanceMonitor.averageFrameTime < 16.67) {
      switch (_currentLevel) {
        case QualityLevel.low:
          _currentLevel = QualityLevel.medium;
          break;
        case QualityLevel.medium:
          _currentLevel = QualityLevel.high;
          break;
        case QualityLevel.high:
          // Already at highest quality
          break;
      }
    }
  }

  static double getAdaptiveBlurStrength() {
    switch (_currentLevel) {
      case QualityLevel.low:
        return 3;
      case QualityLevel.medium:
        return 6;
      case QualityLevel.high:
        return 10;
    }
  }

  static bool shouldUseBackdropFilter() {
    return _currentLevel != QualityLevel.low;
  }

  static bool shouldUseParticleEffects() {
    return _currentLevel == QualityLevel.high;
  }

  static int getMaxParticles() {
    switch (_currentLevel) {
      case QualityLevel.low:
        return 50;
      case QualityLevel.medium:
        return 150;
      case QualityLevel.high:
        return 300;
    }
  }
}

enum QualityLevel {
  low,
  medium,
  high,
}
