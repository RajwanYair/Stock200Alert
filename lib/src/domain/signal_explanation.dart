/// Signal Explanation — human-readable explanation for why a trading signal
/// fired, including contributing factors and confidence level (v1.9).
library;

import 'package:equatable/equatable.dart';

/// Qualitative confidence level of a signal explanation.
enum ExplanationConfidenceLevel {
  /// High confidence — strong agreement across methods.
  high,

  /// Moderate confidence — partial indicator alignment.
  moderate,

  /// Low confidence — weak or conflicting signals.
  low,
}

/// A single factor that contributed to (or against) firing the signal.
class ExplanationFactor extends Equatable {
  const ExplanationFactor({
    required this.label,
    required this.description,
    required this.isBullish,
    required this.weight,
  }) : assert(
         weight >= 0.0 && weight <= 1.0,
         'weight must be between 0.0 and 1.0',
       );

  /// Short label (e.g. "RSI oversold exit", "Price above SMA50").
  final String label;

  /// One-sentence human-readable description of this factor.
  final String description;

  /// True if this factor supports a bullish/buy signal.
  final bool isBullish;

  /// Relative importance weight in the range [0.0, 1.0].
  final double weight;

  @override
  List<Object?> get props => [label, description, isBullish, weight];
}

/// Human-readable explanation of why a specific alert fired.
class SignalExplanation extends Equatable {
  const SignalExplanation({
    required this.ticker,
    required this.methodName,
    required this.summary,
    required this.factors,
    required this.confidenceLevel,
    required this.explainedAt,
  });

  final String ticker;
  final String methodName;

  /// One-sentence summary suitable for display in a notification or tooltip.
  final String summary;

  final List<ExplanationFactor> factors;
  final ExplanationConfidenceLevel confidenceLevel;
  final DateTime explainedAt;

  /// Returns only factors that support the signal direction.
  List<ExplanationFactor> get supportingFactors =>
      factors.where((ExplanationFactor f) => f.isBullish).toList();

  /// Returns factors that argue against the signal direction.
  List<ExplanationFactor> get conflictingFactors =>
      factors.where((ExplanationFactor f) => !f.isBullish).toList();

  bool get isHighConfidence =>
      confidenceLevel == ExplanationConfidenceLevel.high;

  @override
  List<Object?> get props => [
    ticker,
    methodName,
    summary,
    factors,
    confidenceLevel,
    explainedAt,
  ];
}
