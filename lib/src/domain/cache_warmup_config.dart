import 'package:equatable/equatable.dart';

/// Cache pre-warming strategy for a set of tickers.
enum WarmupStrategy {
  /// Warm tickers from the user's watchlist first.
  watchlistFirst,

  /// Warm the most-recently viewed tickers first.
  recentFirst,

  /// Warm all tickers in random order.
  randomShuffle,
}

/// Configuration that controls which tickers to pre-warm in the local
/// cache at app startup and how to prioritise them.
class CacheWarmupConfig extends Equatable {
  const CacheWarmupConfig({
    required this.strategy,
    required this.maxTickersToWarm,
    required this.lookbackDays,
    this.enabled = true,
    this.pinnedTickers = const [],
  });

  final WarmupStrategy strategy;

  /// Maximum number of tickers to warm per startup cycle.
  final int maxTickersToWarm;

  /// Number of historical candles (days) to pre-fetch per ticker.
  final int lookbackDays;

  /// Whether cache warming is active.
  final bool enabled;

  /// Tickers always warmed first regardless of strategy.
  final List<String> pinnedTickers;

  CacheWarmupConfig copyWith({
    WarmupStrategy? strategy,
    int? maxTickersToWarm,
    int? lookbackDays,
    bool? enabled,
    List<String>? pinnedTickers,
  }) => CacheWarmupConfig(
    strategy: strategy ?? this.strategy,
    maxTickersToWarm: maxTickersToWarm ?? this.maxTickersToWarm,
    lookbackDays: lookbackDays ?? this.lookbackDays,
    enabled: enabled ?? this.enabled,
    pinnedTickers: pinnedTickers ?? this.pinnedTickers,
  );

  @override
  List<Object?> get props => [
    strategy,
    maxTickersToWarm,
    lookbackDays,
    enabled,
    pinnedTickers,
  ];
}
