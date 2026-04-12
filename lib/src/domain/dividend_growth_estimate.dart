import 'package:equatable/equatable.dart';

/// Dividend growth projection for a ticker (S542).
class DividendGrowthEstimate extends Equatable {
  const DividendGrowthEstimate({
    required this.ticker,
    required this.currentAnnualDividendUsd,
    required this.estimatedGrowthRate3yPercent,
    required this.estimatedGrowthRate5yPercent,
    required this.dividendPayoutRatioPercent,
    required this.currentYieldPercent,
  });

  final String ticker;

  /// Current annualised dividend per share in USD.
  final double currentAnnualDividendUsd;

  /// Consensus 3-year dividend CAGR estimate in percent.
  final double estimatedGrowthRate3yPercent;

  /// Consensus 5-year dividend CAGR estimate in percent.
  final double estimatedGrowthRate5yPercent;

  /// Dividend payout ratio as % of earnings.
  final double dividendPayoutRatioPercent;
  final double currentYieldPercent;

  bool get isHighYield => currentYieldPercent >= 4;
  bool get isStrongGrowth => estimatedGrowthRate5yPercent >= 8;
  bool get isSustainablePayout => dividendPayoutRatioPercent <= 70;

  @override
  List<Object?> get props => [
    ticker,
    currentAnnualDividendUsd,
    estimatedGrowthRate3yPercent,
    estimatedGrowthRate5yPercent,
    dividendPayoutRatioPercent,
    currentYieldPercent,
  ];
}
