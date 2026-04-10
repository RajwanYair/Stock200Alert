import 'package:equatable/equatable.dart';

/// Reinvestment frequency for a DRIP plan.
enum DripFrequency {
  /// Dividends are reinvested monthly.
  monthly,

  /// Dividends are reinvested quarterly.
  quarterly,

  /// Dividends are reinvested annually.
  annually,

  /// Dividends are reinvested only when cash reaches [minimumCashThreshold].
  thresholdBased,
}

/// A dividend reinvestment plan (DRIP) configuration for a holding.
///
/// Tracks whether dividends are automatically reinvested and the
/// fractional share accumulation that results.
class DividendReinvestmentPlan extends Equatable {
  /// Creates a [DividendReinvestmentPlan].
  const DividendReinvestmentPlan({
    required this.ticker,
    required this.isEnabled,
    required this.frequency,
    required this.fractionalSharesAccumulated,
    this.minimumCashThreshold,
    this.startedAt,
  });

  /// Ticker for which the DRIP is configured.
  final String ticker;

  /// Whether the plan is currently active.
  final bool isEnabled;

  /// How frequently dividends are reinvested.
  final DripFrequency frequency;

  /// Total fractional shares accumulated via reinvestment.
  final double fractionalSharesAccumulated;

  /// Minimum cash balance before reinvestment triggers (threshold-based only).
  final double? minimumCashThreshold;

  /// Date the plan was initiated (`null` when not yet started).
  final DateTime? startedAt;

  /// Returns `true` when there are unconverted fractional shares.
  bool get hasFractionalShares => fractionalSharesAccumulated > 0;

  @override
  List<Object?> get props => [
    ticker,
    isEnabled,
    frequency,
    fractionalSharesAccumulated,
    minimumCashThreshold,
    startedAt,
  ];
}
