import 'package:equatable/equatable.dart';

/// Direction of an analyst rating change.
enum RatingChangeDirection { upgrade, downgrade, initiation, reiteration }

/// Analyst rating tier (firm-independent normalisation).
enum AnalystRatingTier { strongBuy, buy, hold, underperform, sell }

/// A broker analyst rating change event for a ticker.
class AnalystRatingChange extends Equatable {
  const AnalystRatingChange({
    required this.ticker,
    required this.analystFirm,
    required this.direction,
    required this.newRating,
    required this.publishedAt,
    this.previousRating,
    this.priceTarget,
    this.analystName,
  });

  final String ticker;
  final String analystFirm;
  final RatingChangeDirection direction;
  final AnalystRatingTier newRating;
  final DateTime publishedAt;
  final AnalystRatingTier? previousRating;

  /// New 12-month price target in USD, if provided.
  final double? priceTarget;

  final String? analystName;

  AnalystRatingChange copyWith({
    String? ticker,
    String? analystFirm,
    RatingChangeDirection? direction,
    AnalystRatingTier? newRating,
    DateTime? publishedAt,
    AnalystRatingTier? previousRating,
    double? priceTarget,
    String? analystName,
  }) => AnalystRatingChange(
    ticker: ticker ?? this.ticker,
    analystFirm: analystFirm ?? this.analystFirm,
    direction: direction ?? this.direction,
    newRating: newRating ?? this.newRating,
    publishedAt: publishedAt ?? this.publishedAt,
    previousRating: previousRating ?? this.previousRating,
    priceTarget: priceTarget ?? this.priceTarget,
    analystName: analystName ?? this.analystName,
  );

  @override
  List<Object?> get props => [
    ticker,
    analystFirm,
    direction,
    newRating,
    publishedAt,
    previousRating,
    priceTarget,
    analystName,
  ];
}
