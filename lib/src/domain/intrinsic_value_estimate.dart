import 'package:equatable/equatable.dart';

/// DCF-based intrinsic value estimate for a ticker (S545).
class IntrinsicValueEstimate extends Equatable {
  const IntrinsicValueEstimate({
    required this.ticker,
    required this.currentPriceUsd,
    required this.intrinsicValueUsd,
    required this.discountRatePercent,
    required this.terminalGrowthRatePercent,
    required this.projectionYears,
  });

  final String ticker;
  final double currentPriceUsd;

  /// DCF-derived intrinsic value per share.
  final double intrinsicValueUsd;

  /// Weighted average cost of capital used in the DCF.
  final double discountRatePercent;

  /// Terminal growth rate assumed at end of projection period.
  final double terminalGrowthRatePercent;
  final int projectionYears;

  double get marginOfSafetyPercent => currentPriceUsd == 0
      ? 0
      : (intrinsicValueUsd - currentPriceUsd) / currentPriceUsd * 100;

  bool get isUndervalued => marginOfSafetyPercent >= 20;
  bool get isOvervalued => marginOfSafetyPercent <= -20;

  @override
  List<Object?> get props => [
    ticker,
    currentPriceUsd,
    intrinsicValueUsd,
    discountRatePercent,
    terminalGrowthRatePercent,
    projectionYears,
  ];
}
