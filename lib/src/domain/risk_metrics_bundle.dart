import 'package:equatable/equatable.dart';

/// A bundle of standard risk metrics for a ticker or portfolio.
class RiskMetricsBundle extends Equatable {
  const RiskMetricsBundle({
    required this.ticker,
    required this.beta,
    required this.annualisedVolatilityPct,
    required this.valueAtRisk95Pct,
    required this.maxDrawdownPct,
    required this.calmarRatio,
    required this.calculatedAt,
  });

  final String ticker;

  /// Beta relative to the benchmark index (1.0 = market).
  final double beta;

  /// Annualised historical volatility as a percentage.
  final double annualisedVolatilityPct;

  /// 1-day 95 % Value-at-Risk as a percentage of position size.
  final double valueAtRisk95Pct;

  /// Maximum peak-to-trough drawdown as a percentage.
  final double maxDrawdownPct;

  /// Calmar ratio = annualised return / max drawdown.
  final double calmarRatio;

  final DateTime calculatedAt;

  /// Returns true when beta indicates the asset is more volatile than market.
  bool get isHighBeta => beta > 1.5;

  /// Returns true when annualised volatility is above 30 % (high risk).
  bool get isHighVolatility => annualisedVolatilityPct > 30.0;

  @override
  List<Object?> get props => [
    ticker,
    beta,
    annualisedVolatilityPct,
    valueAtRisk95Pct,
    maxDrawdownPct,
    calmarRatio,
    calculatedAt,
  ];
}
