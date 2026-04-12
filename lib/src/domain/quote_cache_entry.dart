import 'package:equatable/equatable.dart';

/// A cached quote entry with TTL metadata (S472).
class QuoteCacheEntry extends Equatable {
  const QuoteCacheEntry({
    required this.ticker,
    required this.bidPrice,
    required this.askPrice,
    required this.lastPrice,
    required this.cachedAtMs,
    required this.ttlSeconds,
  });

  final String ticker;
  final double bidPrice;
  final double askPrice;
  final double lastPrice;

  /// Unix epoch milliseconds when the entry was cached.
  final int cachedAtMs;

  /// Life-to-live for this entry in seconds.
  final int ttlSeconds;

  double get midPrice => (bidPrice + askPrice) / 2;
  bool isStale(int nowMs) => nowMs - cachedAtMs > ttlSeconds * 1000;
  bool get hasSpread => askPrice > bidPrice;

  @override
  List<Object?> get props => [
    ticker,
    bidPrice,
    askPrice,
    lastPrice,
    cachedAtMs,
    ttlSeconds,
  ];
}
