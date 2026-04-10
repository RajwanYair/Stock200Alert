import 'package:equatable/equatable.dart';

/// Standard market-cap size classifications.
enum MarketCapTier {
  /// Micro-cap: < $300 M.
  micro,

  /// Small-cap: $300 M – $2 B.
  small,

  /// Mid-cap: $2 B – $10 B.
  mid,

  /// Large-cap: $10 B – $200 B.
  large,

  /// Mega-cap: > $200 B.
  mega,
}

/// A market-capitalisation bucket assignment for a ticker.
///
/// Assigns a [MarketCapTier] based on the [marketCapUsd] value and exposes
/// convenience accessors for size-based filtering.
class MarketCapBucket extends Equatable {
  /// Creates a [MarketCapBucket].
  const MarketCapBucket({
    required this.ticker,
    required this.marketCapUsd,
    required this.recordedAt,
  });

  /// Ticker symbol.
  final String ticker;

  /// Market capitalisation in USD.
  final double marketCapUsd;

  /// Timestamp of the market-cap quote.
  final DateTime recordedAt;

  /// Derived market-cap tier.
  MarketCapTier get tier {
    if (marketCapUsd >= 200e9) return MarketCapTier.mega;
    if (marketCapUsd >= 10e9) return MarketCapTier.large;
    if (marketCapUsd >= 2e9) return MarketCapTier.mid;
    if (marketCapUsd >= 300e6) return MarketCapTier.small;
    return MarketCapTier.micro;
  }

  /// Returns `true` when the ticker is large-cap or above.
  bool get isLargeOrAbove =>
      tier == MarketCapTier.large || tier == MarketCapTier.mega;

  @override
  List<Object?> get props => [ticker, marketCapUsd, recordedAt];
}
