import 'package:equatable/equatable.dart';

/// Value factor signal based on price-to-book and earnings yield (S538).
class ValueFactorSignal extends Equatable {
  const ValueFactorSignal({
    required this.ticker,
    required this.bookToMarketRatio,
    required this.earningsYieldPercent,
    required this.universePercentileRank,
    required this.isBuy,
  });

  final String ticker;

  /// Book value divided by market cap (higher = cheaper).
  final double bookToMarketRatio;

  /// Earnings yield = E/P × 100.
  final double earningsYieldPercent;

  /// Percentile rank in the value universe (0–100).
  final double universePercentileRank;

  /// True → value buy; false → growth tilt or sell value.
  final bool isBuy;

  bool get isCheap => universePercentileRank >= 80;
  bool get isExpensive => universePercentileRank <= 20;
  bool get isHighEarningsYield => earningsYieldPercent >= 6;

  @override
  List<Object?> get props => [
    ticker,
    bookToMarketRatio,
    earningsYieldPercent,
    universePercentileRank,
    isBuy,
  ];
}
