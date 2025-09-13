// lib/core/performance/component_cache_manager.dart

import 'dart:ui' show Picture, PictureRecorder, Canvas;

import 'package:flutter/material.dart';
import 'package:sparkcircuit/core/debug/structured_logger.dart';
import 'package:sparkcircuit/domain/entities/entities.dart';
import 'package:sparkcircuit/presentation/core/theme/app_theme.dart';

/// Unified component cache manager for Phase 1 performance optimization
/// Target: 40-50% rendering performance improvement through intelligent caching
class ComponentCacheManager {
  static final ComponentCacheManager _instance =
      ComponentCacheManager._internal(); // ignore: cascade_invocations
  factory ComponentCacheManager() => _instance;
  ComponentCacheManager._internal(); // ignore: cascade_invocations

  // Cache storage for rendered component images
  final Map<String, _ComponentCacheEntry> _imageCache = {};
  final Map<String, Picture> _pictureCache = {};

  // Cache statistics for performance monitoring
  int _cacheHits = 0;
  int _cacheMisses = 0;
  int _cacheInvalidations = 0;

  // Memory management
  static const int _maxCacheSize = 200; // Maximum cached items
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Get cached component rendering with automatic cache management
  Picture? getComponentPicture(
    CircuitComponent component,
    CircuitColorScheme colors,
    Rect bounds,
    double scale,
    bool isSelected,
  ) {
    final cacheKey = _generateCacheKey(component, scale, isSelected);

    // Check if we have a valid cache entry
    final cachedEntry = _imageCache[cacheKey];
    if (cachedEntry != null && !_isExpired(cachedEntry)) {
      _cacheHits++;
      return _pictureCache[cacheKey];
    }

    // Cache miss - remove expired entries first
    _cleanupExpiredEntries();

    // Generate new cached image
    _cacheMisses++;
    final picture =
        _renderComponentToPicture(component, colors, bounds, scale, isSelected);

    if (picture != null) {
      _imageCache[cacheKey] = _ComponentCacheEntry(DateTime.now());
      _pictureCache[cacheKey] = picture;
    }

    return picture;
  }

  /// Invalidate component cache (called when component properties change)
  void invalidateComponentCache(String componentId) {
    final keysToRemove = _imageCache.keys
        .where((key) => key.startsWith('$componentId-'))
        .toList();

    for (final key in keysToRemove) {
      final picture = _pictureCache[key];
      picture?.dispose();

      _imageCache.remove(key);
      _pictureCache.remove(key);
      _cacheInvalidations++;
    }

    StructuredLogger.debug('Invalidated component cache', context: {
      'componentId': componentId,
      'entriesRemoved': keysToRemove.length,
      'totalInvalidations': _cacheInvalidations,
    });
  }

  /// Clear entire cache (for memory management)
  void clearCache() {
    for (final picture in _pictureCache.values) {
      picture.dispose();
    }

    _imageCache.clear();
    _pictureCache.clear();
    _cacheInvalidations = 0;

    StructuredLogger.debug('Component cache cleared');
  }

  /// Get cache performance statistics
  Map<String, double> getPerformanceStats() {
    final totalRequests = _cacheHits + _cacheMisses;
    final hitRate =
        totalRequests > 0 ? (_cacheHits / totalRequests) * 100 : 0.0;

    return {
      'cacheHitRate': hitRate,
      'cacheHits': _cacheHits.toDouble(),
      'cacheMisses': _cacheMisses.toDouble(),
      'cacheSize': _imageCache.length.toDouble(),
      'cacheInvalidations': _cacheInvalidations.toDouble(),
      'memoryEfficiency': _calculateMemoryEfficiency(),
    };
  }

  /// Private: Generate unique cache key for component
  String _generateCacheKey(
      CircuitComponent component, double scale, bool isSelected) {
    // Create cache key based on component state - exclude frequently changing properties
    return '${component.id}-${component.type}-${component.row}-${component.col}-${component.state}-${component.rotation}-$scale-$isSelected';
  }

  /// Private: Render component to a Picture for caching
  Picture? _renderComponentToPicture(
    CircuitComponent component,
    CircuitColorScheme colors,
    Rect bounds,
    double scale,
    bool isSelected,
  ) {
    try {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      canvas.clipRect(bounds);

      // Apply transformations centered at component position
      final centerX = bounds.left + (bounds.width / 2);
      final centerY = bounds.top + (bounds.height / 2);

      canvas.translate(centerX, centerY);
      if (component.rotation != 0) {
        canvas.rotate(component.rotation.toDouble() *
            (3.141592653589793 / 180.0)); // Convert to radians
      }
      canvas.translate(-centerX, -centerY);

      // Render component background
      _renderComponentBackground(
          canvas, bounds, colors, component.state, scale);

      // Render component-specific details using painter delegation
      _renderComponentDetails(
          canvas, bounds, component, colors, scale, isSelected);

      return recorder.endRecording();
    } catch (e) {
      StructuredLogger.error('Failed to render component to cache',
          context: {
            'componentId': component.id,
            'error': e.toString(),
          },
          error: e);
      return null;
    }
  }

  /// Private: Render component background with state effects
  void _renderComponentBackground(
    Canvas canvas,
    Rect bounds,
    CircuitColorScheme colors,
    ComponentState state,
    double scale,
  ) {
    // Main background
    final backgroundPaint = Paint()
      ..color = colors.componentBase.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final roundedRect = RRect.fromRectAndRadius(
      bounds,
      Radius.circular(8.0 * scale),
    );
    canvas.drawRRect(roundedRect, backgroundPaint);

    // State-based glow effects
    Color? glowColor;
    if (state == ComponentState.powered) {
      glowColor = colors.energyPulse;
    } else if (state == ComponentState.error) {
      glowColor = colors.errorGlow;
    }

    if (glowColor != null) {
      final glowPaint = Paint()
        ..color = glowColor.withValues(alpha: 0.6)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 12.0 * scale)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0 * scale;

      canvas.drawRRect(roundedRect, glowPaint);
    }

    // Component border
    final borderPaint = Paint()
      ..color = colors.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * scale;

    canvas.drawRRect(roundedRect, borderPaint);
  }

  /// Private: Render component-specific details by delegating to existing painter logic
  void _renderComponentDetails(
    Canvas canvas,
    Rect bounds,
    CircuitComponent component,
    CircuitColorScheme colors,
    double scale,
    bool isSelected,
  ) {
    final center = bounds.center;
    final paint = Paint()
      ..color = colors.onSurface
      ..strokeWidth = 2.0 * scale
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Render based on component type (simplified for Phase 1)
    switch (component.type) {
      case ComponentType.battery:
        _renderBatterySymbol(canvas, center, bounds.width * 0.3, paint, scale);
        break;
      case ComponentType.capacitor:
        _renderCapacitorSymbol(canvas, center, bounds.width * 0.3, paint);
        break;
      default:
        // Simplified default symbol for Phase 1
        _renderDefaultSymbol(canvas, center, bounds.width * 0.25, paint);
    }

    // Add selection highlight if selected
    if (isSelected) {
      final selectionPaint = Paint()
        ..color = colors.neonPrimary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0 * scale
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.0 * scale);

      canvas.drawRect(bounds, selectionPaint);
    }
  }

  /// Private: Render battery symbol
  void _renderBatterySymbol(
      Canvas canvas, Offset center, double size, Paint paint, double scale) {
    // Positive terminal
    canvas.drawLine(
      Offset(center.dx - size * 0.25, center.dy - size * 0.5),
      Offset(center.dx - size * 0.25, center.dy + size * 0.5),
      paint..strokeWidth = 3.0 * scale,
    );

    // Negative terminal
    canvas.drawLine(
      Offset(center.dx + size * 0.25, center.dy - size * 0.33),
      Offset(center.dx + size * 0.25, center.dy + size * 0.33),
      paint..strokeWidth = 2.0 * scale,
    );
  }

  /// Private: Render capacitor symbol
  void _renderCapacitorSymbol(
      Canvas canvas, Offset center, double size, Paint paint) {
    final plateHeight = size * 0.6;

    // Parallel plates
    canvas.drawLine(
      Offset(center.dx - size * 0.16, center.dy - plateHeight),
      Offset(center.dx - size * 0.16, center.dy + plateHeight),
      paint..strokeWidth = 3.0,
    );

    canvas.drawLine(
      Offset(center.dx + size * 0.16, center.dy - plateHeight),
      Offset(center.dx + size * 0.16, center.dy + plateHeight),
      paint..strokeWidth = 3.0,
    );
  }

  /// Private: Render default component symbol
  void _renderDefaultSymbol(
      Canvas canvas, Offset center, double size, Paint paint) {
    // Simple diagonal cross
    canvas.drawLine(
      Offset(center.dx - size, center.dy - size),
      Offset(center.dx + size, center.dy + size),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx + size, center.dy - size),
      Offset(center.dx - size, center.dy + size),
      paint,
    );
  }

  /// Private: Check if cache entry is expired
  bool _isExpired(_ComponentCacheEntry entry) {
    return DateTime.now().difference(entry.createdAt) > _cacheExpiry;
  }

  /// Private: Cleanup expired cache entries
  void _cleanupExpiredEntries() {
    final expiredKeys = _imageCache.entries
        .where((entry) => _isExpired(entry.value))
        .map((entry) => entry.key)
        .toList();

    for (final key in expiredKeys) {
      _pictureCache[key]?.dispose();
      _imageCache.remove(key);
      _pictureCache.remove(key);
    }

    // Also cleanup if cache is too large
    if (_imageCache.length > _maxCacheSize) {
      final overflowCount = _imageCache.length - (_maxCacheSize * 0.8).toInt();

      final keysToRemove = _imageCache.keys.take(overflowCount).toList();
      for (final key in keysToRemove) {
        _pictureCache[key]?.dispose();
        _imageCache.remove(key);
        _pictureCache.remove(key);
      }
    }
  }

  /// Private: Calculate memory efficiency percentage
  double _calculateMemoryEfficiency() {
    final totalRequests = _cacheHits + _cacheMisses;
    if (totalRequests == 0) return 0;

    // Efficiency = (hits / total) * (1 / cache_size_factor)
    final cacheSizeFactor = (_imageCache.length + 1.0) / _maxCacheSize;
    return ((_cacheHits / totalRequests) / cacheSizeFactor).clamp(0.0, 1.0);
  }
}

/// Private cache entry class
class _ComponentCacheEntry {
  final DateTime createdAt;

  _ComponentCacheEntry(this.createdAt);
}
