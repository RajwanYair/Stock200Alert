import 'package:cross_tide/src/domain/portfolio_risk_scorer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scorer = PortfolioRiskScorer();

  group('PortfolioRiskScorer', () {
    test('empty portfolio returns LOW risk', () {
      final result = scorer.score(
        positionWeights: {},
        positionVolatilities: {},
        sectorCount: 0,
      );
      expect(result.overallScore, 0);
      expect(result.riskLevel, 'LOW');
    });

    test('single position scores high concentration', () {
      final result = scorer.score(
        positionWeights: {'AAPL': 1.0},
        positionVolatilities: {'AAPL': 0.25},
        sectorCount: 1,
      );
      // HHI = 1.0 → concentration = 100
      expect(result.concentrationScore, closeTo(100, 0.01));
      expect(result.riskLevel, isNotEmpty);
    });

    test('well-diversified portfolio scores lower risk', () {
      final weights = {for (var i = 0; i < 20; i++) 'T$i': 0.05};
      final vols = {for (var i = 0; i < 20; i++) 'T$i': 0.15};
      final result = scorer.score(
        positionWeights: weights,
        positionVolatilities: vols,
        sectorCount: 10,
      );
      expect(result.overallScore, lessThan(50));
    });

    test('high volatility increases risk', () {
      final lowVol = scorer.score(
        positionWeights: {'A': 0.5, 'B': 0.5},
        positionVolatilities: {'A': 0.1, 'B': 0.1},
        sectorCount: 2,
      );
      final highVol = scorer.score(
        positionWeights: {'A': 0.5, 'B': 0.5},
        positionVolatilities: {'A': 0.5, 'B': 0.5},
        sectorCount: 2,
      );
      expect(highVol.volatilityScore, greaterThan(lowVol.volatilityScore));
    });

    test('risk levels are correctly assigned', () {
      // EXTREME: all-in one volatile stock in one sector
      final extreme = scorer.score(
        positionWeights: {'A': 1.0},
        positionVolatilities: {'A': 0.6},
        sectorCount: 1,
      );
      expect(extreme.riskLevel, 'EXTREME');
    });

    test('PortfolioRiskScore props equality', () {
      const a = PortfolioRiskScore(
        overallScore: 50,
        concentrationScore: 40,
        diversificationScore: 30,
        volatilityScore: 60,
        riskLevel: 'MODERATE',
      );
      const b = PortfolioRiskScore(
        overallScore: 50,
        concentrationScore: 40,
        diversificationScore: 30,
        volatilityScore: 60,
        riskLevel: 'MODERATE',
      );
      expect(a, equals(b));
    });
  });
}
