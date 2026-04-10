import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RiskMetricsBundle', () {
    RiskMetricsBundle buildBundle({
      double beta = 1.0,
      double annualisedVolatilityPct = 20.0,
    }) {
      return RiskMetricsBundle(
        ticker: 'AAPL',
        beta: beta,
        annualisedVolatilityPct: annualisedVolatilityPct,
        valueAtRisk95Pct: 2.5,
        maxDrawdownPct: 15.0,
        calmarRatio: 1.2,
        calculatedAt: DateTime(2024, 6, 1),
      );
    }

    test('isHighBeta is true when beta > 1.5', () {
      expect(buildBundle(beta: 1.6).isHighBeta, isTrue);
    });

    test('isHighBeta is false when beta <= 1.5', () {
      expect(buildBundle(beta: 1.5).isHighBeta, isFalse);
    });

    test('isHighVolatility is true when annualisedVolatilityPct > 30', () {
      expect(
        buildBundle(annualisedVolatilityPct: 30.1).isHighVolatility,
        isTrue,
      );
    });

    test('isHighVolatility is false when annualisedVolatilityPct <= 30', () {
      expect(
        buildBundle(annualisedVolatilityPct: 30.0).isHighVolatility,
        isFalse,
      );
    });

    test('equality holds for same props', () {
      expect(buildBundle(), equals(buildBundle()));
    });
  });
}
