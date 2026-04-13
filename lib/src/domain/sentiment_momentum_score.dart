import 'package:equatable/equatable.dart';

/// Sentiment momentum score — aggregate news/social sentiment rating.
enum SentimentMomentumRating {
  veryBearish,
  bearish,
  neutral,
  bullish,
  veryBullish,
}

class SentimentMomentumScore extends Equatable {
  const SentimentMomentumScore({
    required this.ticker,
    required this.score,
    required this.rating,
    required this.sampleSize,
    required this.dataSource,
  });

  final String ticker;
  final double score;
  final SentimentMomentumRating rating;
  final int sampleSize;
  final String dataSource;

  SentimentMomentumScore copyWith({
    String? ticker,
    double? score,
    SentimentMomentumRating? rating,
    int? sampleSize,
    String? dataSource,
  }) => SentimentMomentumScore(
    ticker: ticker ?? this.ticker,
    score: score ?? this.score,
    rating: rating ?? this.rating,
    sampleSize: sampleSize ?? this.sampleSize,
    dataSource: dataSource ?? this.dataSource,
  );

  @override
  List<Object?> get props => [ticker, score, rating, sampleSize, dataSource];
}
