import 'package:equatable/equatable.dart';

/// Confidence level for a Value at Risk estimate.
enum VarConfidenceLevel {
  /// 90% confidence — more tolerant, smaller estimated loss.
  p90,

  /// 95% confidence — industry standard.
  p95,

  /// 99% confidence — conservative; larger estimated loss.
  p99,
}

/// A Value at Risk (VaR) estimate for a portfolio over a given horizon.
///
/// Estimates the maximum expected loss at the chosen confidence level
/// under normal market conditions.
class VarEstimate extends Equatable {
  /// Creates a [VarEstimate].
  const VarEstimate({
    required this.portfolioId,
    required this.confidence,
    required this.horizonDays,
    required this.estimatedLoss,
    required this.estimationMethod,
  });

  /// Portfolio identifier.
  final String portfolioId;

  /// Confidence level of the estimate.
  final VarConfidenceLevel confidence;

  /// Time horizon in trading days.
  final int horizonDays;

  /// Estimated maximum loss as a fraction of portfolio value (e.g. 0.05 = 5%).
  final double estimatedLoss;

  /// Methodology used (e.g. `'historical'`, `'parametric'`, `'monte_carlo'`).
  final String estimationMethod;

  /// Returns `true` when using the most conservative confidence level.
  bool get isConservative => confidence == VarConfidenceLevel.p99;

  /// Returns `true` when the horizon is a single trading day.
  bool get isOneDay => horizonDays == 1;

  /// Annualised loss assuming 252 trading days.
  double get annualizedLoss => estimatedLoss * (252.0 / horizonDays);

  @override
  List<Object?> get props => [
    portfolioId,
    confidence,
    horizonDays,
    estimatedLoss,
    estimationMethod,
  ];
}
