import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sparkcircuit/presentation/features/game/services/viewport_service.dart';

void main() {
  group('ViewportService', () {
    late ViewportService service;

    setUp(() {
      service = ViewportService(initialState: const ViewportState());
    });

    test('should initialize with default state', () {
      expect(service.state.scale, 1.0);
      expect(service.state.panOffset, Offset.zero);
      expect(service.state.canvasSize, Size.zero);
      expect(service.state.gridConfiguration, const Size(20, 15));
      expect(service.state.cellSize, 60.0);
    });

    test('should update scale correctly', () {
      service.updateScale(1.5);
      expect(service.state.scale, 1.5);

      // Test scale clamping
      service.updateScale(10); // Above max
      expect(service.state.scale, 5.0);

      service.updateScale(0.1); // Below min
      expect(service.state.scale, 0.1);
    });

    test('should update pan offset correctly', () {
      const delta = Offset(10, 20);
      service.updatePan(delta);

      expect(service.state.panOffset, delta);

      // Test cumulative pan
      service.updatePan(delta);
      expect(service.state.panOffset, delta * 2);
    });

    test('should update canvas size correctly', () {
      const newSize = Size(800, 600);
      service.setCanvasSize(newSize);

      expect(service.state.canvasSize, newSize);
    });

    test('should reset to initial state', () {
      // Modify state
      service.updateScale(2);
      service.updatePan(const Offset(100, 100));
      service.setCanvasSize(const Size(800, 600));

      // Reset
      service.reset();

      // Should be back to initial state
      expect(service.state.scale, 1.0);
      expect(service.state.panOffset, Offset.zero);
      expect(service.state.canvasSize, Size.zero);
    });

    test('should calculate visible grid bounds correctly', () {
      service.setCanvasSize(const Size(800, 600));
      service.updateScale(1.5);
      service.updatePan(const Offset(50, 25));

      final bounds = service.getVisibleGridBounds();

      // Should return a valid Rect
      expect(bounds, isA<Rect>());
      expect(bounds.width, greaterThan(0));
      expect(bounds.height, greaterThan(0));
    });

    test('should handle scale transformations correctly', () {
      service.updateScale(2); // 2x zoom

      // Scale should be updated
      expect(service.state.scale, 2.0);
    });

    test('should handle pan transformations correctly', () {
      service.updatePan(const Offset(100, 50));

      expect(service.state.panOffset, const Offset(100, 50));
    });

    test('should maintain state consistency across operations', () {
      // Perform multiple operations
      service.updateScale(1.2);
      service.updatePan(const Offset(30, 40));
      service.setCanvasSize(const Size(1024, 768));

      // Verify all changes are maintained
      expect(service.state.scale, 1.2);
      expect(service.state.panOffset, const Offset(30, 40));
      expect(service.state.canvasSize, const Size(1024, 768));
    });
  });
}
