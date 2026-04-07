/// Data Freshness Tracker — application-layer service.
///
/// Maintains a map of ticker → last-fetched time and produces
/// [DataFreshness] snapshots on demand. Does not persist state itself;
/// callers feed in timestamps after each successful fetch.
library;

import '../domain/domain.dart';

/// Tracks per-ticker data freshness timestamps.
class DataFreshnessTracker {
  DataFreshnessTracker();

  final Map<String, DateTime> _timestamps = {};

  /// Record that [ticker] data was fetched at [fetchedAt].
  void recordFetch(String ticker, {required DateTime fetchedAt}) {
    _timestamps[ticker.toUpperCase()] = fetchedAt;
  }

  /// Remove a ticker from tracking.
  void remove(String ticker) {
    _timestamps.remove(ticker.toUpperCase());
  }

  /// Get the last-fetched time for [ticker], or null if never fetched.
  DateTime? lastFetchedAt(String ticker) => _timestamps[ticker.toUpperCase()];

  /// Build a [DataFreshness] snapshot for [ticker] at the given [now].
  ///
  /// Returns null if the ticker has never been fetched.
  DataFreshness? freshness(String ticker, {required DateTime now}) {
    final DateTime? lastUpdated = lastFetchedAt(ticker);
    if (lastUpdated == null) return null;
    return DataFreshness(
      ticker: ticker.toUpperCase(),
      lastUpdatedAt: lastUpdated,
      now: now,
    );
  }

  /// Build [DataFreshness] for all tracked tickers.
  List<DataFreshness> all({required DateTime now}) => _timestamps.entries
      .map(
        (MapEntry<String, DateTime> e) =>
            DataFreshness(ticker: e.key, lastUpdatedAt: e.value, now: now),
      )
      .toList();

  /// Number of tracked tickers.
  int get count => _timestamps.length;

  /// Clear all tracked timestamps.
  void clear() => _timestamps.clear();
}
