import 'package:equatable/equatable.dart';

/// Risk category for a single portfolio position.
enum PositionRiskCategory {
  /// Minimal risk exposure.
  low,

  /// Moderate risk — within normal tolerance.
  moderate,

  /// Elevated risk — warrants attention.
  high,

  /// Unacceptable risk — immediate action required.
  extreme,
}

/// Per-position risk assessment used in portfolio risk dashboards.
class PositionRiskEntry extends Equatable {
  /// Creates a [PositionRiskEntry].
  const PositionRiskEntry({
    required this.ticker,
    required this.positionValue,
    required this.riskPercent,
    required this.betaAdjustedRisk,
    required this.riskCategory,
  });

  /// Ticker symbol.
  final String ticker;

  /// Current market value of the position in base currency.
  final double positionValue;

  /// Position weight as a percentage of total portfolio value.
  final double riskPercent;

  /// Beta-adjusted risk contribution (riskPercent × beta).
  final double betaAdjustedRisk;

  /// Qualitative risk tier for this position.
  final PositionRiskCategory riskCategory;

  /// Returns `true` when [riskCategory] is [high] or [extreme].
  bool get isHighRisk =>
      riskCategory == PositionRiskCategory.high ||
      riskCategory == PositionRiskCategory.extreme;

  /// Returns `true` when [riskCategory] is [extreme].
  bool get isExtreme => riskCategory == PositionRiskCategory.extreme;

  /// Beta-adjusted exposure value.
  double get adjustedExposure => positionValue * betaAdjustedRisk;

  @override
  List<Object?> get props => [
    ticker,
    positionValue,
    riskPercent,
    betaAdjustedRisk,
    riskCategory,
  ];
}
