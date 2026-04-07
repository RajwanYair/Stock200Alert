/// Chart Data Point — pure domain value object.
///
/// A single point on a price chart with optional indicator overlay values.
/// Used by the presentation layer to render price + indicator charts.
library;

import 'package:equatable/equatable.dart';

import 'entities.dart';

/// A chart-ready data point combining price and optional indicator values.
class ChartDataPoint extends Equatable {
  const ChartDataPoint({
    required this.date,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    this.sma50,
    this.sma150,
    this.sma200,
    this.ema12,
    this.ema26,
    this.rsi,
    this.macdLine,
    this.macdSignal,
    this.macdHistogram,
    this.bollingerUpper,
    this.bollingerMiddle,
    this.bollingerLower,
    this.atr,
  });

  /// Create from a [DailyCandle] with no indicator values.
  factory ChartDataPoint.fromCandle(DailyCandle candle) => ChartDataPoint(
    date: candle.date,
    open: candle.open,
    high: candle.high,
    low: candle.low,
    close: candle.close,
    volume: candle.volume,
  );

  /// The bar date.
  final DateTime date;

  /// OHLCV fields.
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  /// Simple moving average overlays.
  final double? sma50;
  final double? sma150;
  final double? sma200;

  /// Exponential moving average overlays.
  final double? ema12;
  final double? ema26;

  /// RSI value (0–100).
  final double? rsi;

  /// MACD components.
  final double? macdLine;
  final double? macdSignal;
  final double? macdHistogram;

  /// Bollinger Band values.
  final double? bollingerUpper;
  final double? bollingerMiddle;
  final double? bollingerLower;

  /// Average True Range.
  final double? atr;

  /// Whether any indicator overlay is populated.
  bool get hasIndicators =>
      sma50 != null ||
      sma150 != null ||
      sma200 != null ||
      ema12 != null ||
      ema26 != null ||
      rsi != null ||
      macdLine != null ||
      bollingerUpper != null ||
      atr != null;

  /// Return a copy with updated fields.
  ChartDataPoint copyWith({
    DateTime? date,
    double? open,
    double? high,
    double? low,
    double? close,
    int? volume,
    double? Function()? sma50,
    double? Function()? sma150,
    double? Function()? sma200,
    double? Function()? ema12,
    double? Function()? ema26,
    double? Function()? rsi,
    double? Function()? macdLine,
    double? Function()? macdSignal,
    double? Function()? macdHistogram,
    double? Function()? bollingerUpper,
    double? Function()? bollingerMiddle,
    double? Function()? bollingerLower,
    double? Function()? atr,
  }) => ChartDataPoint(
    date: date ?? this.date,
    open: open ?? this.open,
    high: high ?? this.high,
    low: low ?? this.low,
    close: close ?? this.close,
    volume: volume ?? this.volume,
    sma50: sma50 != null ? sma50() : this.sma50,
    sma150: sma150 != null ? sma150() : this.sma150,
    sma200: sma200 != null ? sma200() : this.sma200,
    ema12: ema12 != null ? ema12() : this.ema12,
    ema26: ema26 != null ? ema26() : this.ema26,
    rsi: rsi != null ? rsi() : this.rsi,
    macdLine: macdLine != null ? macdLine() : this.macdLine,
    macdSignal: macdSignal != null ? macdSignal() : this.macdSignal,
    macdHistogram: macdHistogram != null ? macdHistogram() : this.macdHistogram,
    bollingerUpper: bollingerUpper != null
        ? bollingerUpper()
        : this.bollingerUpper,
    bollingerMiddle: bollingerMiddle != null
        ? bollingerMiddle()
        : this.bollingerMiddle,
    bollingerLower: bollingerLower != null
        ? bollingerLower()
        : this.bollingerLower,
    atr: atr != null ? atr() : this.atr,
  );

  @override
  List<Object?> get props => [
    date,
    open,
    high,
    low,
    close,
    volume,
    sma50,
    sma150,
    sma200,
    ema12,
    ema26,
    rsi,
    macdLine,
    macdSignal,
    macdHistogram,
    bollingerUpper,
    bollingerMiddle,
    bollingerLower,
    atr,
  ];
}
