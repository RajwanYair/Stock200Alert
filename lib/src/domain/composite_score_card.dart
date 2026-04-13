import 'package:equatable/equatable.dart';

/// Composite score card — per-dimension ranked score for a ticker.
enum ScoreCardDimension { momentum, quality, value, growth, safety }

class CompositeScoreCard extends Equatable {
  const CompositeScoreCard({
    required this.ticker,
    required this.dimension,
    required this.score,
    required this.rank,
    required this.percentile,
  });

  final String ticker;
  final ScoreCardDimension dimension;
  final double score;
  final int rank;
  final double percentile;

  CompositeScoreCard copyWith({
    String? ticker,
    ScoreCardDimension? dimension,
    double? score,
    int? rank,
    double? percentile,
  }) => CompositeScoreCard(
    ticker: ticker ?? this.ticker,
    dimension: dimension ?? this.dimension,
    score: score ?? this.score,
    rank: rank ?? this.rank,
    percentile: percentile ?? this.percentile,
  );

  @override
  List<Object?> get props => [ticker, dimension, score, rank, percentile];
}
