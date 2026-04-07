/// OHLC Chart Mapper — pure domain utility.
///
/// Transforms a list of [DailyCandle] into structured OHLC chart data
/// objects suitable for candlestick chart rendering.
library;

import 'package:equatable/equatable.dart';

import 'entities.dart';

/// Whether the candle closed higher or lower than it opened.
enum CandleDirection {
  /// Close >= Open (bullish).
  bullish,

  /// Close < Open (bearish).
  bearish,
}

/// A single OHLC bar ready for chart rendering.
class OhlcBar extends Equatable {
  const OhlcBar({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  final DateTime date;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  /// Whether this candle is bullish or bearish.
  CandleDirection get direction =>
      close >= open ? CandleDirection.bullish : CandleDirection.bearish;

  /// The body height (absolute difference between open and close).
  double get bodyHeight => (close - open).abs();

  /// Upper shadow length.
  double get upperShadow =>
      direction == CandleDirection.bullish ? high - close : high - open;

  /// Lower shadow length.
  double get lowerShadow =>
      direction == CandleDirection.bullish ? open - low : close - low;

  /// The full range from low to high.
  double get range => high - low;

  @override
  List<Object?> get props => [date, open, high, low, close, volume];
}

/// Maps [DailyCandle] lists to chart-ready [OhlcBar] objects.
class OhlcChartMapper {
  const OhlcChartMapper();

  /// Convert a list of daily candles to OHLC bars.
  ///
  /// Returns an empty list for empty input.
  List<OhlcBar> map(List<DailyCandle> candles) => [
    for (final DailyCandle c in candles)
      OhlcBar(
        date: c.date,
        open: c.open,
        high: c.high,
        low: c.low,
        close: c.close,
        volume: c.volume,
      ),
  ];

  /// Convert and return only bars within a date range (inclusive).
  List<OhlcBar> mapRange(
    List<DailyCandle> candles, {
    required DateTime from,
    required DateTime to,
  }) {
    return map(
      candles
          .where(
            (DailyCandle c) => !c.date.isBefore(from) && !c.date.isAfter(to),
          )
          .toList(),
    );
  }
}
