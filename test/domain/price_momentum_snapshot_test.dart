import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriceMomentumSnapshot', () {
    late DateTime measured;

    setUp(() => measured = DateTime(2025, 7, 1));

    test('creates positive momentum snapshot', () {
      final snap = PriceMomentumSnapshot(
        symbol: 'AAPL',
        momentumPct: 15.5,
        lookbackDays: 20,
        measuredAt: measured,
      );
      expect(snap.isPositive, isTrue);
      expect(snap.isNegative, isFalse);
      expect(snap.isStrong, isTrue);
      expect(snap.direction, MomentumDirection.flat);
      expect(snap.hasRelativeStrength, isFalse);
    });

    test('isNegative true for negative momentum', () {
      final snap = PriceMomentumSnapshot(
        symbol: 'TSLA',
        momentumPct: -8.0,
        lookbackDays: 10,
        measuredAt: measured,
      );
      expect(snap.isNegative, isTrue);
      expect(snap.isStrong, isFalse);
    });

    test('isStrong true when abs > 10', () {
      final snap = PriceMomentumSnapshot(
        symbol: 'NVDA',
        momentumPct: -12.0,
        lookbackDays: 30,
        measuredAt: measured,
      );
      expect(snap.isStrong, isTrue);
    });

    test('isAccelerating true when direction is accelerating', () {
      final snap = PriceMomentumSnapshot(
        symbol: 'MSFT',
        momentumPct: 5.0,
        lookbackDays: 20,
        measuredAt: measured,
        direction: MomentumDirection.accelerating,
      );
      expect(snap.isAccelerating, isTrue);
    });

    test('hasRelativeStrength true when provided', () {
      final snap = PriceMomentumSnapshot(
        symbol: 'AMZN',
        momentumPct: 7.0,
        lookbackDays: 20,
        measuredAt: measured,
        relativeStrength: 75.0,
      );
      expect(snap.hasRelativeStrength, isTrue);
      expect(snap.relativeStrength, 75.0);
    });

    test('equality holds for identical snapshots', () {
      final a = PriceMomentumSnapshot(
        symbol: 'Z',
        momentumPct: 3.0,
        lookbackDays: 10,
        measuredAt: measured,
      );
      final b = PriceMomentumSnapshot(
        symbol: 'Z',
        momentumPct: 3.0,
        lookbackDays: 10,
        measuredAt: measured,
      );
      expect(a, equals(b));
    });
  });
}
