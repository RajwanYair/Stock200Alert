import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KellyCriterionResult', () {
    test('compute returns positive fullKellyFraction for positive EV', () {
      final r = KellyCriterionResult.compute(
        ticker: 'AAPL',
        winProbability: 0.6,
        winLossRatio: 2.0,
      );
      // Kelly = (2*0.6 - 0.4) / 2 = (1.2 - 0.4) / 2 = 0.4
      expect(r.fullKellyFraction, closeTo(0.4, 0.001));
      expect(r.isPositiveEV, isTrue);
    });

    test('halfKellyFraction is half of fullKellyFraction', () {
      final r = KellyCriterionResult.compute(
        ticker: 'MSFT',
        winProbability: 0.6,
        winLossRatio: 2.0,
      );
      expect(r.halfKellyFraction, closeTo(r.fullKellyFraction / 2, 0.001));
    });

    test('compute clamps negative Kelly to 0.0', () {
      // Negative EV: win prob 0.3, ratio 1.0 → Kelly = (1.0*0.3 - 0.7)/1.0 = -0.4
      final r = KellyCriterionResult.compute(
        ticker: 'X',
        winProbability: 0.3,
        winLossRatio: 1.0,
      );
      expect(r.fullKellyFraction, 0.0);
      expect(r.isPositiveEV, isFalse);
    });

    test('compute produces full Kelly close to 1 for very high-edge input', () {
      // Kelly = (100 * 0.99 - 0.01) / 100 = 0.9899 — nearly 1 but not clamped
      final r = KellyCriterionResult.compute(
        ticker: 'Y',
        winProbability: 0.99,
        winLossRatio: 100.0,
      );
      expect(r.fullKellyFraction, closeTo(0.9899, 0.001));
      expect(r.isPositiveEV, isTrue);
    });

    test('equality holds for same props', () {
      const a = KellyCriterionResult(
        ticker: 'AAPL',
        winProbability: 0.6,
        winLossRatio: 2.0,
        fullKellyFraction: 0.4,
        halfKellyFraction: 0.2,
      );
      const b = KellyCriterionResult(
        ticker: 'AAPL',
        winProbability: 0.6,
        winLossRatio: 2.0,
        fullKellyFraction: 0.4,
        halfKellyFraction: 0.2,
      );
      expect(a, equals(b));
    });
  });
}
