import 'package:equatable/equatable.dart';

/// Estimated rate of alpha decay for a trading signal over time (S476).
class AlphaDecayEstimate extends Equatable {
  const AlphaDecayEstimate({
    required this.ticker,
    required this.methodName,
    required this.halfLifeDays,
    required this.initialAlphaBps,
    required this.residualAlphaBps,
  });

  final String ticker;
  final String methodName;

  /// Estimated half-life of the alpha signal in days.
  final double halfLifeDays;

  /// Initial annualized alpha in basis points.
  final double initialAlphaBps;

  /// Remaining exploitable alpha in basis points.
  final double residualAlphaBps;

  double get decayPercent => initialAlphaBps > 0
      ? (1 - residualAlphaBps / initialAlphaBps) * 100
      : 0.0;
  bool get isDecayed => residualAlphaBps < initialAlphaBps * 0.20;
  bool get isViable => residualAlphaBps > 20;

  @override
  List<Object?> get props => [
    ticker,
    methodName,
    halfLifeDays,
    initialAlphaBps,
    residualAlphaBps,
  ];
}
