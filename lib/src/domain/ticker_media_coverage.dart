import 'package:equatable/equatable.dart';

/// Ticker media coverage — news article volume and sentiment intensity.
enum MediaCoverageIntensity { minimal, low, moderate, high, viral }

class TickerMediaCoverage extends Equatable {
  const TickerMediaCoverage({
    required this.ticker,
    required this.articleCount,
    required this.intensity,
    required this.sentimentScore,
    required this.coverageDate,
  });

  final String ticker;
  final int articleCount;
  final MediaCoverageIntensity intensity;
  final double sentimentScore;
  final String coverageDate;

  TickerMediaCoverage copyWith({
    String? ticker,
    int? articleCount,
    MediaCoverageIntensity? intensity,
    double? sentimentScore,
    String? coverageDate,
  }) => TickerMediaCoverage(
    ticker: ticker ?? this.ticker,
    articleCount: articleCount ?? this.articleCount,
    intensity: intensity ?? this.intensity,
    sentimentScore: sentimentScore ?? this.sentimentScore,
    coverageDate: coverageDate ?? this.coverageDate,
  );

  @override
  List<Object?> get props => [
    ticker,
    articleCount,
    intensity,
    sentimentScore,
    coverageDate,
  ];
}
