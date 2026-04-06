/// Market Data Provider — Abstract interface.
///
/// Implement this to add new data sources (Alpha Vantage, Twelve Data, etc.).
/// The app resolves the active provider at runtime based on settings.
library;

import '../../domain/entities.dart';

abstract class IMarketDataProvider {
  /// Human-readable name for display in settings.
  String get name;

  /// Unique identifier used in settings/persistence.
  String get id;

  /// Fetch daily price history for [ticker].
  /// Returns candles sorted ascending by date.
  /// Should return at least 200+ trading days for SMA200 computation.
  ///
  /// Throws [MarketDataException] on failure.
  Future<List<DailyCandle>> fetchDailyHistory(String ticker);
}

class MarketDataException implements Exception {
  const MarketDataException(
    this.message, {
    this.statusCode,
    this.isRetryable = false,
  });

  final String message;
  final int? statusCode;
  final bool isRetryable;

  @override
  String toString() => 'MarketDataException($statusCode): $message';
}
