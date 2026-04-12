import 'package:equatable/equatable.dart';

/// Assessment of position concentration risk for a single ticker.
///
/// Flags positions that exceed a configurable weight threshold,
/// helping portfolio managers avoid over-concentration.
class PositionConcentrationRisk extends Equatable {
  /// Creates a [PositionConcentrationRisk].
  const PositionConcentrationRisk({
    required this.portfolioId,
    required this.ticker,
    required this.weightPercent,
    required this.thresholdPercent,
  });

  /// Portfolio identifier.
  final String portfolioId;

  /// Ticker symbol.
  final String ticker;

  /// Actual weight of this position as a percentage (0–100).
  final double weightPercent;

  /// Maximum acceptable position weight as a percentage.
  final double thresholdPercent;

  /// Returns `true` when [weightPercent] exceeds [thresholdPercent].
  bool get isAboveThreshold => weightPercent > thresholdPercent;

  /// Excess over the threshold (0.0 when within tolerance).
  double get excessPercent =>
      isAboveThreshold ? weightPercent - thresholdPercent : 0.0;

  /// Returns `true` when the excess is larger than 5 percentage points.
  bool get isMaterial => excessPercent > 5.0;

  @override
  List<Object?> get props => [
    portfolioId,
    ticker,
    weightPercent,
    thresholdPercent,
  ];
}
