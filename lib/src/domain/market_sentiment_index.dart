import 'package:equatable/equatable.dart';

/// Qualitative sentiment label derived from a fear/greed score.
enum SentimentLabel { extremeFear, fear, neutral, greed, extremeGreed }

/// A constituent component of the market sentiment composite index.
class SentimentComponent extends Equatable {
  const SentimentComponent({
    required this.name,
    required this.score,
    this.weight = 1.0,
  }) : assert(score >= 0 && score <= 100, 'score must be 0–100'),
       assert(weight > 0, 'weight must be > 0');

  final String name;

  /// Normalised score in the range 0–100 (0 = extreme fear, 100 = extreme greed).
  final double score;
  final double weight;

  @override
  List<Object?> get props => [name, score, weight];
}

/// A composite fear/greed market sentiment index snapshot.
class MarketSentimentIndex extends Equatable {
  const MarketSentimentIndex({
    required this.fearGreedScore,
    required this.components,
    required this.measuredAt,
  }) : assert(
         fearGreedScore >= 0 && fearGreedScore <= 100,
         'fearGreedScore must be 0–100',
       );

  /// Composite score in range 0–100 (0 = extreme fear, 100 = extreme greed).
  final double fearGreedScore;
  final List<SentimentComponent> components;
  final DateTime measuredAt;

  SentimentLabel get label {
    if (fearGreedScore < 20) return SentimentLabel.extremeFear;
    if (fearGreedScore < 40) return SentimentLabel.fear;
    if (fearGreedScore < 60) return SentimentLabel.neutral;
    if (fearGreedScore < 80) return SentimentLabel.greed;
    return SentimentLabel.extremeGreed;
  }

  bool get isGreedy => fearGreedScore >= 60;
  bool get isFearful => fearGreedScore < 40;
  bool get isNeutral => !isGreedy && !isFearful;

  int get componentCount => components.length;

  @override
  List<Object?> get props => [fearGreedScore, components, measuredAt];
}
