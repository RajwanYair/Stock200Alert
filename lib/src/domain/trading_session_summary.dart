import 'package:equatable/equatable.dart';

/// A summary of trading activity within a single market session.
///
/// Captures open, high, low, close, volume, and session metadata for a
/// named exchange session (e.g. pre-market, regular, after-hours).
class TradingSessionSummary extends Equatable {
  /// Creates a [TradingSessionSummary].
  const TradingSessionSummary({
    required this.ticker,
    required this.sessionLabel,
    required this.sessionDate,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.vwap,
  });

  /// Ticker symbol.
  final String ticker;

  /// Human-readable session label (e.g. `'Regular'`, `'Pre-Market'`).
  final String sessionLabel;

  /// Calendar date of the session.
  final DateTime sessionDate;

  /// Opening price.
  final double open;

  /// Session high.
  final double high;

  /// Session low.
  final double low;

  /// Closing/last price.
  final double close;

  /// Total volume traded.
  final int volume;

  /// Volume-weighted average price for the session (`null` when unavailable).
  final double? vwap;

  /// Session range (high − low).
  double get range => high - low;

  /// Percentage change from open to close.
  double get changePct => open == 0 ? 0.0 : (close - open) / open * 100;

  /// Returns `true` when the session closed above the open.
  bool get isBullishSession => close > open;

  @override
  List<Object?> get props => [
    ticker,
    sessionLabel,
    sessionDate,
    open,
    high,
    low,
    close,
    volume,
    vwap,
  ];
}
