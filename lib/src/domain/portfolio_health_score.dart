import 'package:equatable/equatable.dart';

/// Composite portfolio health score components.
class PortfolioHealthComponent extends Equatable {
  const PortfolioHealthComponent({
    required this.name,
    required this.score,
    required this.weight,
  });

  final String name;

  /// Component score (0–100).
  final double score;

  /// Weight of this component in the overall score (0.0–1.0).
  final double weight;

  @override
  List<Object?> get props => [name, score, weight];
}

/// A composite 0–100 score representing the overall health of a portfolio,
/// based on diversification, drawdown, volatility, and signal alignment.
class PortfolioHealthScore extends Equatable {
  const PortfolioHealthScore({
    required this.portfolioId,
    required this.overallScore,
    required this.components,
    required this.calculatedAt,
    this.grade,
  });

  final String portfolioId;

  /// Overall composite health score (0–100).
  final double overallScore;

  final List<PortfolioHealthComponent> components;
  final DateTime calculatedAt;

  /// Letter grade derived from overallScore (A–F).
  final String? grade;

  PortfolioHealthScore copyWith({
    String? portfolioId,
    double? overallScore,
    List<PortfolioHealthComponent>? components,
    DateTime? calculatedAt,
    String? grade,
  }) => PortfolioHealthScore(
    portfolioId: portfolioId ?? this.portfolioId,
    overallScore: overallScore ?? this.overallScore,
    components: components ?? this.components,
    calculatedAt: calculatedAt ?? this.calculatedAt,
    grade: grade ?? this.grade,
  );

  @override
  List<Object?> get props => [
    portfolioId,
    overallScore,
    components,
    calculatedAt,
    grade,
  ];
}
