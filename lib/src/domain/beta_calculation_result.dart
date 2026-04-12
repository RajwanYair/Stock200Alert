import 'package:equatable/equatable.dart';

/// Beta calculation result for a ticker against a benchmark (S456).
class BetaCalculationResult extends Equatable {
  const BetaCalculationResult({
    required this.ticker,
    required this.benchmarkTicker,
    required this.beta,
    required this.rSquared,
    required this.periodDays,
  });

  final String ticker;
  final String benchmarkTicker;

  /// Beta coefficient (1.0 = moves with market, >1 = amplified, <1 = muted).
  final double beta;

  /// R-squared of the regression (0–1).
  final double rSquared;
  final int periodDays;

  bool get isHighBeta => beta > 1.5;
  bool get isLowBeta => beta < 0.5;
  bool get isNegativeBeta => beta < 0;
  bool get isStatisticallySignificant => rSquared >= 0.7;

  @override
  List<Object?> get props => [
    ticker,
    benchmarkTicker,
    beta,
    rSquared,
    periodDays,
  ];
}
