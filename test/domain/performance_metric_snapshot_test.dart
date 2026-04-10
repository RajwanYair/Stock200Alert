import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PerformanceMetricSnapshot', () {
    late DateTime captured;

    setUp(() => captured = DateTime(2025, 6, 1, 12));

    test('creates snapshot without baseline', () {
      final snap = PerformanceMetricSnapshot(
        metricName: 'quote_fetch_latency',
        value: 250.0,
        unit: 'ms',
        capturedAt: captured,
      );
      expect(snap.hasBaseline, isFalse);
      expect(snap.deviationPct, isNull);
      expect(snap.isRegression, isFalse);
      expect(snap.isImprovement, isFalse);
    });

    test('deviationPct when above baseline is regression', () {
      final snap = PerformanceMetricSnapshot(
        metricName: 'render_time',
        value: 300.0,
        unit: 'ms',
        capturedAt: captured,
        baseline: 200.0,
      );
      expect(snap.deviationPct, closeTo(50.0, 0.001));
      expect(snap.isRegression, isTrue);
      expect(snap.isImprovement, isFalse);
    });

    test('deviationPct when below baseline is improvement', () {
      final snap = PerformanceMetricSnapshot(
        metricName: 'startup_time',
        value: 150.0,
        unit: 'ms',
        capturedAt: captured,
        baseline: 200.0,
      );
      expect(snap.deviationPct, closeTo(-25.0, 0.001));
      expect(snap.isImprovement, isTrue);
      expect(snap.isRegression, isFalse);
    });

    test('deviationPct is null when baseline is 0', () {
      final snap = PerformanceMetricSnapshot(
        metricName: 'error_count',
        value: 5.0,
        unit: 'count',
        capturedAt: captured,
        baseline: 0.0,
      );
      expect(snap.deviationPct, isNull);
    });

    test('tags map is stored correctly', () {
      final snap = PerformanceMetricSnapshot(
        metricName: 'mem_usage',
        value: 128.0,
        unit: 'MB',
        capturedAt: captured,
        tags: const {'platform': 'android', 'arch': 'arm64'},
      );
      expect(snap.tags['platform'], 'android');
    });

    test('equality holds for identical snapshots', () {
      final a = PerformanceMetricSnapshot(
        metricName: 'm',
        value: 100.0,
        unit: 'ms',
        capturedAt: captured,
      );
      final b = PerformanceMetricSnapshot(
        metricName: 'm',
        value: 100.0,
        unit: 'ms',
        capturedAt: captured,
      );
      expect(a, equals(b));
    });
  });
}
