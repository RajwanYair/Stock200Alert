import 'package:equatable/equatable.dart';

/// Kelly Criterion position-sizing result for a given trade setup.
class KellyCriterionResult extends Equatable {
  const KellyCriterionResult({
    required this.ticker,
    required this.winProbability,
    required this.winLossRatio,
    required this.fullKellyFraction,
    required this.halfKellyFraction,
  });

  final String ticker;

  /// Estimated probability of a winning trade (0.0–1.0).
  final double winProbability;

  /// Ratio of average win to average loss (must be positive).
  final double winLossRatio;

  /// Full Kelly optimal fraction of capital to risk.
  final double fullKellyFraction;

  /// Half-Kelly (conservative) fraction — recommended for real trading.
  final double halfKellyFraction;

  /// Computes full Kelly from win probability and win/loss ratio.
  static KellyCriterionResult compute({
    required String ticker,
    required double winProbability,
    required double winLossRatio,
  }) {
    final p = winProbability;
    final b = winLossRatio;
    final q = 1.0 - p;
    final full = (b * p - q) / b;
    final clamped = full.clamp(0.0, 1.0);
    return KellyCriterionResult(
      ticker: ticker,
      winProbability: p,
      winLossRatio: b,
      fullKellyFraction: clamped,
      halfKellyFraction: clamped / 2.0,
    );
  }

  /// Returns true when the setup has a positive expected value.
  bool get isPositiveEV => fullKellyFraction > 0;

  @override
  List<Object?> get props => [
    ticker,
    winProbability,
    winLossRatio,
    fullKellyFraction,
    halfKellyFraction,
  ];
}
