/// Daily Metrics Aggregator — application-layer service.
///
/// Builds [DailyMetrics] snapshots from raw candle data by invoking
/// domain-layer calculators (SMA, RSI, MACD, ATR, Volume).
library;

import 'dart:convert' show JsonEncoder;

import '../domain/domain.dart';

/// Aggregates calculator results into a single [DailyMetrics] snapshot.
class DailyMetricsAggregator {
  DailyMetricsAggregator({
    SmaCalculator smaCalculator = const SmaCalculator(),
    RsiCalculator rsiCalculator = const RsiCalculator(),
    MacdCalculator macdCalculator = const MacdCalculator(),
    AtrCalculator atrCalculator = const AtrCalculator(),
    VolumeCalculator volumeCalculator = const VolumeCalculator(),
  }) : _smaCalculator = smaCalculator,
       _rsiCalculator = rsiCalculator,
       _macdCalculator = macdCalculator,
       _atrCalculator = atrCalculator,
       _volumeCalculator = volumeCalculator;

  final SmaCalculator _smaCalculator;
  final RsiCalculator _rsiCalculator;
  final MacdCalculator _macdCalculator;
  final AtrCalculator _atrCalculator;
  final VolumeCalculator _volumeCalculator;

  /// Build a [DailyMetrics] for the most recent candle in [candles].
  ///
  /// Returns null if [candles] is empty.
  DailyMetrics? aggregate({
    required String ticker,
    required List<DailyCandle> candles,
    int alertsFired = 0,
  }) {
    if (candles.isEmpty) return null;

    final DailyCandle latest = candles.last;

    final double? sma50 = _lastValue(
      _smaCalculator.computeSeries(candles, period: 50),
    );
    final double? sma150 = _lastValue(
      _smaCalculator.computeSeries(candles, period: 150),
    );
    final double? sma200 = _lastValue(
      _smaCalculator.computeSeries(candles, period: 200),
    );

    final double? rsi = _lastValue(_rsiCalculator.computeSeries(candles));

    final macdSeries = _macdCalculator.computeSeries(candles);
    final double? macdLine = macdSeries.isNotEmpty
        ? macdSeries.last.macd
        : null;
    final double? macdSignal = macdSeries.isNotEmpty
        ? macdSeries.last.signal
        : null;

    final atrSeries = _atrCalculator.computeSeries(candles);
    final double? atr = atrSeries.isNotEmpty ? atrSeries.last.atr : null;

    final double? avgVol20 = _volumeCalculator.averageVolume(candles);

    return DailyMetrics(
      ticker: ticker,
      date: latest.date,
      close: latest.close,
      sma50: sma50,
      sma150: sma150,
      sma200: sma200,
      rsi: rsi,
      macdLine: macdLine,
      macdSignal: macdSignal,
      atr: atr,
      volume: latest.volume,
      avgVolume20: avgVol20?.round(),
      alertsFired: alertsFired,
    );
  }

  /// Build metrics for all tickers and serialize to JSON.
  ///
  /// Returns a pretty-printed JSON string.
  String exportJson(List<DailyMetrics> metrics) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(
      metrics.map((DailyMetrics m) => m.toJson()).toList(),
    );
  }

  static double? _lastValue(List<(DateTime, double?)> series) {
    if (series.isEmpty) return null;
    final (DateTime _, double? value) = series.last;
    return value;
  }
}
