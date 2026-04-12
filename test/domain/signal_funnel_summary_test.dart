import 'package:cross_tide/src/domain/signal_funnel_summary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignalFunnelSummary', () {
    test('equality', () {
      final a = SignalFunnelSummary(
        ticker: 'AAPL',
        detectedCount: 10,
        evaluatedCount: 8,
        triggeredCount: 3,
        sentCount: 3,
        periodStart: DateTime(2025, 1, 1),
        periodEnd: DateTime(2025, 1, 31),
      );
      final b = SignalFunnelSummary(
        ticker: 'AAPL',
        detectedCount: 10,
        evaluatedCount: 8,
        triggeredCount: 3,
        sentCount: 3,
        periodStart: DateTime(2025, 1, 1),
        periodEnd: DateTime(2025, 1, 31),
      );
      expect(a, b);
    });

    test('copyWith changes sentCount', () {
      final base = SignalFunnelSummary(
        ticker: 'AAPL',
        detectedCount: 10,
        evaluatedCount: 8,
        triggeredCount: 3,
        sentCount: 3,
        periodStart: DateTime(2025, 1, 1),
        periodEnd: DateTime(2025, 1, 31),
      );
      final updated = base.copyWith(sentCount: 5);
      expect(updated.sentCount, 5);
    });

    test('props length is 7', () {
      final obj = SignalFunnelSummary(
        ticker: 'AAPL',
        detectedCount: 10,
        evaluatedCount: 8,
        triggeredCount: 3,
        sentCount: 3,
        periodStart: DateTime(2025, 1, 1),
        periodEnd: DateTime(2025, 1, 31),
      );
      expect(obj.props.length, 7);
    });
  });
}
