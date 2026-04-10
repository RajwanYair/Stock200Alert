import 'package:equatable/equatable.dart';

/// The source platform for a social sentiment signal.
enum SentimentPlatform {
  /// Reddit (e.g. r/wallstreetbets, r/investing).
  reddit,

  /// Twitter / X.
  twitter,

  /// StockTwits.
  stockTwits,

  /// YouTube comment scraping.
  youtube,

  /// Aggregated across multiple platforms.
  aggregated,
}

/// Directional sentiment derived from social media data.
enum SocialSentimentDirection {
  /// Strong positive buzz — significantly net bullish posts/comments.
  strongBullish,

  /// Net bullish sentiment.
  bullish,

  /// Mixed or unavailable sentiment with no clear bias.
  neutral,

  /// Net bearish sentiment.
  bearish,

  /// Strong negative buzz — significantly net bearish posts/comments.
  strongBearish,
}

/// A social-media-derived sentiment signal for a given ticker.
///
/// Aggregates post volume, bullish/bearish ratios, and overall direction
/// from one or more social platforms over a rolling observation window.
class SocialSentimentSignal extends Equatable {
  /// Creates a [SocialSentimentSignal].
  const SocialSentimentSignal({
    required this.ticker,
    required this.platform,
    required this.direction,
    required this.observedAt,
    required this.totalMentions,
    required this.bullishMentions,
    required this.bearishMentions,
    required this.sentimentScore,
  });

  /// Ticker for which the signal applies.
  final String ticker;

  /// Source platform from which mentions were collected.
  final SentimentPlatform platform;

  /// Aggregated directional label.
  final SocialSentimentDirection direction;

  /// End of the observation window.
  final DateTime observedAt;

  /// Total mention count within the observation window.
  final int totalMentions;

  /// Count of mentions with a bullish disposition.
  final int bullishMentions;

  /// Count of mentions with a bearish disposition.
  final int bearishMentions;

  /// Composite sentiment score in [-1.0, 1.0] (positive = bullish).
  final double sentimentScore;

  /// Percentage of mentions that are bullish (0–100).
  double get bullishPct =>
      totalMentions == 0 ? 0.0 : bullishMentions / totalMentions * 100;

  /// Returns `true` when direction is bullish or strongly bullish.
  bool get isBullish =>
      direction == SocialSentimentDirection.bullish ||
      direction == SocialSentimentDirection.strongBullish;

  /// Returns `true` when direction is bearish or strongly bearish.
  bool get isBearish =>
      direction == SocialSentimentDirection.bearish ||
      direction == SocialSentimentDirection.strongBearish;

  /// Returns `true` when the signal has high activity (>= 1 000 mentions).
  bool get isHighActivity => totalMentions >= 1000;

  @override
  List<Object?> get props => [
    ticker,
    platform,
    direction,
    observedAt,
    totalMentions,
    bullishMentions,
    bearishMentions,
    sentimentScore,
  ];
}
