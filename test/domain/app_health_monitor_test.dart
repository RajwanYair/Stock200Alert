import 'package:cross_tide/src/domain/app_health_monitor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppHealthMonitor', () {
    test('equality', () {
      final a = AppHealthMonitor(
        sessionId: 'sess1',
        events: const [],
        overallHealthy: true,
        capturedAt: DateTime(2025, 4, 10),
      );
      final b = AppHealthMonitor(
        sessionId: 'sess1',
        events: const [],
        overallHealthy: true,
        capturedAt: DateTime(2025, 4, 10),
      );
      expect(a, b);
    });

    test('copyWith changes overallHealthy', () {
      final base = AppHealthMonitor(
        sessionId: 'sess1',
        events: const [],
        overallHealthy: true,
        capturedAt: DateTime(2025, 4, 10),
      );
      final updated = base.copyWith(overallHealthy: false);
      expect(updated.overallHealthy, false);
    });

    test('props length is 4', () {
      final obj = AppHealthMonitor(
        sessionId: 'sess1',
        events: const [],
        overallHealthy: true,
        capturedAt: DateTime(2025, 4, 10),
      );
      expect(obj.props.length, 4);
    });
  });
}
