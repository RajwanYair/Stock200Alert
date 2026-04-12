import 'package:equatable/equatable.dart';

/// Cross-sectional momentum factor signal for a ticker (S537).
class MomentumFactorSignal extends Equatable {
  const MomentumFactorSignal({
    required this.ticker,
    required this.return12m1mPercent,
    required this.universePercentileRank,
    required this.isBuy,
  });

  final String ticker;

  /// 12-month minus 1-month return (momentum signal).
  final double return12m1mPercent;

  /// Percentile rank within the investable universe (0–100).
  final double universePercentileRank;

  /// True → buy signal (high momentum); false → sell.
  final bool isBuy;

  bool get isTopDecile => universePercentileRank >= 90;
  bool get isBottomDecile => universePercentileRank <= 10;
  bool get isStrongMomentum => return12m1mPercent >= 20;

  @override
  List<Object?> get props => [
    ticker,
    return12m1mPercent,
    universePercentileRank,
    isBuy,
  ];
}
