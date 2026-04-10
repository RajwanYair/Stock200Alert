import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarketImpactLevel', () {
    test('has 5 values', () {
      expect(MarketImpactLevel.values.length, 5);
    });
  });

  group('MarketImpactEstimate', () {
    const base = MarketImpactEstimate(
      ticker: 'AAPL',
      orderSizeShares: 10000,
      avgDailyVolumeShares: 100000,
      estimatedSlippagePct: 0.3,
      impactLevel: MarketImpactLevel.low,
    );

    test('participationRate is orderSize / avgDailyVolume', () {
      expect(base.participationRate, closeTo(0.1, 0.0001));
    });

    test('participationRate is 0 when avgDailyVolumeShares is 0', () {
      const zero = MarketImpactEstimate(
        ticker: 'X',
        orderSizeShares: 100,
        avgDailyVolumeShares: 0,
        estimatedSlippagePct: 0.0,
        impactLevel: MarketImpactLevel.negligible,
      );
      expect(zero.participationRate, 0.0);
    });

    test('isMaterial is true when slippage >= 0.5', () {
      const m = MarketImpactEstimate(
        ticker: 'TSLA',
        orderSizeShares: 5000,
        avgDailyVolumeShares: 50000,
        estimatedSlippagePct: 0.5,
        impactLevel: MarketImpactLevel.moderate,
      );
      expect(m.isMaterial, isTrue);
    });

    test('isMaterial is false when slippage < 0.5', () {
      expect(base.isMaterial, isFalse);
    });

    test('equality holds for same props', () {
      const copy = MarketImpactEstimate(
        ticker: 'AAPL',
        orderSizeShares: 10000,
        avgDailyVolumeShares: 100000,
        estimatedSlippagePct: 0.3,
        impactLevel: MarketImpactLevel.low,
      );
      expect(base, equals(copy));
    });
  });
}
