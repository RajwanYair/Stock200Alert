import 'package:cross_tide/src/domain/network_quality_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkQualitySnapshot', () {
    test('equality', () {
      final a = NetworkQualitySnapshot(
        rating: NetworkQualityRating.good,
        latencyMs: 45,
        jitterMs: 5,
        packetLossPercent: 0.2,
        measuredAt: DateTime(2025, 6, 15),
      );
      final b = NetworkQualitySnapshot(
        rating: NetworkQualityRating.good,
        latencyMs: 45,
        jitterMs: 5,
        packetLossPercent: 0.2,
        measuredAt: DateTime(2025, 6, 15),
      );
      expect(a, b);
    });

    test('copyWith changes latencyMs', () {
      final base = NetworkQualitySnapshot(
        rating: NetworkQualityRating.good,
        latencyMs: 45,
        jitterMs: 5,
        packetLossPercent: 0.2,
        measuredAt: DateTime(2025, 6, 15),
      );
      final updated = base.copyWith(latencyMs: 100);
      expect(updated.latencyMs, 100);
    });

    test('props length is 6', () {
      final obj = NetworkQualitySnapshot(
        rating: NetworkQualityRating.good,
        latencyMs: 45,
        jitterMs: 5,
        packetLossPercent: 0.2,
        measuredAt: DateTime(2025, 6, 15),
      );
      expect(obj.props.length, 6);
    });
  });
}
