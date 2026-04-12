import 'package:equatable/equatable.dart';

/// Low-volatility factor signal for a ticker (S541).
class VolatilityFactorSignal extends Equatable {
  const VolatilityFactorSignal({
    required this.ticker,
    required this.annualisedVolatilityPercent,
    required this.betaToMarket,
    required this.universePercentileRank,
    required this.isBuy,
  });

  final String ticker;

  /// Annualised historical volatility in percent.
  final double annualisedVolatilityPercent;

  /// Equity beta relative to the broad market.
  final double betaToMarket;

  /// Percentile rank (0 = highest-vol, 100 = lowest-vol).
  final double universePercentileRank;

  /// True → low-volatility buy signal.
  final bool isBuy;

  bool get isLowVolatility => universePercentileRank >= 70;
  bool get isHighVolatility => annualisedVolatilityPercent >= 40;
  bool get isDefensive => betaToMarket <= 0.7;

  @override
  List<Object?> get props => [
    ticker,
    annualisedVolatilityPercent,
    betaToMarket,
    universePercentileRank,
    isBuy,
  ];
}
