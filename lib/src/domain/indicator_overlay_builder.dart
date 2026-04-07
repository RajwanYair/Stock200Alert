/// Indicator Overlay Builder — pure domain assembler.
///
/// Combines multiple indicator series (SMA, EMA, RSI, MACD, Bollinger, ATR)
/// with price candles to produce a unified [ChartDataPoint] list.
library;

import 'chart_data_point.dart';
import 'entities.dart';

/// An indicator series keyed by date.
typedef IndicatorSeries = Map<DateTime, double>;

/// Assembles [ChartDataPoint] objects from candles and indicator series.
class IndicatorOverlayBuilder {
  const IndicatorOverlayBuilder();

  /// Build chart data points from [candles] and optional indicator maps.
  ///
  /// Each indicator parameter is a map from date → value. Only dates
  /// present in [candles] are included; indicator values are looked up
  /// by candle date.
  List<ChartDataPoint> build(
    List<DailyCandle> candles, {
    IndicatorSeries sma50 = const {},
    IndicatorSeries sma150 = const {},
    IndicatorSeries sma200 = const {},
    IndicatorSeries ema12 = const {},
    IndicatorSeries ema26 = const {},
    IndicatorSeries rsi = const {},
    IndicatorSeries macdLine = const {},
    IndicatorSeries macdSignal = const {},
    IndicatorSeries macdHistogram = const {},
    IndicatorSeries bollingerUpper = const {},
    IndicatorSeries bollingerMiddle = const {},
    IndicatorSeries bollingerLower = const {},
    IndicatorSeries atr = const {},
  }) {
    return [
      for (final DailyCandle c in candles)
        ChartDataPoint(
          date: c.date,
          open: c.open,
          high: c.high,
          low: c.low,
          close: c.close,
          volume: c.volume,
          sma50: sma50[c.date],
          sma150: sma150[c.date],
          sma200: sma200[c.date],
          ema12: ema12[c.date],
          ema26: ema26[c.date],
          rsi: rsi[c.date],
          macdLine: macdLine[c.date],
          macdSignal: macdSignal[c.date],
          macdHistogram: macdHistogram[c.date],
          bollingerUpper: bollingerUpper[c.date],
          bollingerMiddle: bollingerMiddle[c.date],
          bollingerLower: bollingerLower[c.date],
          atr: atr[c.date],
        ),
    ];
  }
}
