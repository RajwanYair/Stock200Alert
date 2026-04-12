import 'package:equatable/equatable.dart';

/// Pairwise correlation entry between two tickers in a portfolio.
class PortfolioCorrelationEntry extends Equatable {
  /// Creates a [PortfolioCorrelationEntry].
  const PortfolioCorrelationEntry({
    required this.portfolioId,
    required this.tickerA,
    required this.tickerB,
    required this.correlation,
    required this.observationDays,
  });

  /// Portfolio identifier.
  final String portfolioId;

  /// First ticker in the pair.
  final String tickerA;

  /// Second ticker in the pair.
  final String tickerB;

  /// Pearson correlation coefficient [-1.0, 1.0].
  final double correlation;

  /// Number of trading days used in the calculation.
  final int observationDays;

  /// Returns `true` when the absolute correlation exceeds 0.7.
  bool get isHighlyCorrelated => correlation.abs() > 0.70;

  /// Returns `true` when the correlation is meaningfully negative.
  bool get isNegativelyCorrelated => correlation < -0.30;

  /// Returns `true` when the pair provides diversification benefit.
  bool get isDiversifying => correlation < 0.0;

  @override
  List<Object?> get props => [
    portfolioId,
    tickerA,
    tickerB,
    correlation,
    observationDays,
  ];
}
