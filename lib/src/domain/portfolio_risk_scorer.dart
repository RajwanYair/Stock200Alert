/// Portfolio Risk Scorer — assigns a 0–100 risk score to a portfolio
/// based on concentration, diversification, and volatility inputs.
library;

import 'package:equatable/equatable.dart';

/// Risk assessment result for a portfolio.
class PortfolioRiskScore extends Equatable {
  const PortfolioRiskScore({
    required this.overallScore,
    required this.concentrationScore,
    required this.diversificationScore,
    required this.volatilityScore,
    required this.riskLevel,
  });

  /// Composite 0–100 risk score (100 = highest risk).
  final double overallScore;

  /// Concentration component (higher = more concentrated = riskier).
  final double concentrationScore;

  /// Diversification component (higher = less diversified = riskier).
  final double diversificationScore;

  /// Volatility component (higher = more volatile = riskier).
  final double volatilityScore;

  /// 'LOW', 'MODERATE', 'HIGH', or 'EXTREME'.
  final String riskLevel;

  @override
  List<Object?> get props => [
    overallScore,
    concentrationScore,
    diversificationScore,
    volatilityScore,
    riskLevel,
  ];
}

/// Computes a portfolio risk score from position weights and volatilities.
class PortfolioRiskScorer {
  const PortfolioRiskScorer();

  /// Score portfolio risk.
  ///
  /// [positionWeights] maps ticker → fraction of portfolio (0–1, summing to 1).
  /// [positionVolatilities] maps ticker → annualized volatility (e.g. 0.25 = 25%).
  /// [sectorCount] is the number of distinct sectors held.
  PortfolioRiskScore score({
    required Map<String, double> positionWeights,
    required Map<String, double> positionVolatilities,
    required int sectorCount,
  }) {
    if (positionWeights.isEmpty) {
      return const PortfolioRiskScore(
        overallScore: 0,
        concentrationScore: 0,
        diversificationScore: 0,
        volatilityScore: 0,
        riskLevel: 'LOW',
      );
    }

    // Concentration: Herfindahl–Hirschman Index (HHI) normalized to 0–100.
    // HHI = sum(w_i^2). For N equal-weight positions, HHI = 1/N.
    // Max HHI = 1 (single position). Min meaningful = 1/N.
    final hhi = positionWeights.values.fold<double>(
      0,
      (double acc, double w) => acc + w * w,
    );
    // Normalize: HHI=1 → 100, HHI→0 → 0
    final concentrationScore = (hhi * 100).clamp(0.0, 100.0);

    // Diversification: penalize low sector count.
    // 1 sector → 100, 2 → 80, 4 → 60, 8 → 30, 11+ → 0.
    final diversificationScore = sectorCount >= 11
        ? 0.0
        : (100.0 - sectorCount * 9.0).clamp(0.0, 100.0);

    // Volatility: weighted-average annualized vol, scaled to 0–100.
    var weightedVol = 0.0;
    for (final MapEntry<String, double> e in positionWeights.entries) {
      final vol = positionVolatilities[e.key] ?? 0.2;
      weightedVol += e.value * vol;
    }
    // Scale: 0% vol → 0, 50% vol → 100
    final volatilityScore = (weightedVol * 200).clamp(0.0, 100.0);

    final overall =
        concentrationScore * 0.35 +
        diversificationScore * 0.30 +
        volatilityScore * 0.35;

    final riskLevel = switch (overall) {
      < 25 => 'LOW',
      < 50 => 'MODERATE',
      < 75 => 'HIGH',
      _ => 'EXTREME',
    };

    return PortfolioRiskScore(
      overallScore: overall,
      concentrationScore: concentrationScore,
      diversificationScore: diversificationScore,
      volatilityScore: volatilityScore,
      riskLevel: riskLevel,
    );
  }
}
