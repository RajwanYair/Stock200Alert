/// Keltner Channel — Pure domain logic.
///
/// Middle = EMA(close, period)
/// Upper  = Middle + multiplier × ATR(atrPeriod)
/// Lower  = Middle − multiplier × ATR(atrPeriod)
///
/// Default: 20-period EMA, 10-period ATR, 2× multiplier.
library;

import 'package:equatable/equatable.dart';

import 'atr_calculator.dart';
import 'ema_calculator.dart';
import 'entities.dart';

/// A single Keltner Channel data point.
class KeltnerResult extends Equatable {
  const KeltnerResult({
    required this.date,
    required this.upper,
    required this.middle,
    required this.lower,
  });

  final DateTime date;
  final double upper;
  final double middle;
  final double lower;

  @override
  List<Object?> get props => [date, upper, middle, lower];
}

/// Computes the Keltner Channel series for [DailyCandle] data.
class KeltnerCalculator {
  const KeltnerCalculator({
    this.emaPeriod = 20,
    this.atrPeriod = 10,
    this.multiplier = 2.0,
    this.emaCalculator = const EmaCalculator(),
    this.atrCalculator = const AtrCalculator(),
  });

  final int emaPeriod;
  final int atrPeriod;
  final double multiplier;
  final EmaCalculator emaCalculator;
  final AtrCalculator atrCalculator;

  /// Compute the most recent Keltner Channel value.
  KeltnerResult? compute(List<DailyCandle> candles) {
    final series = computeSeries(candles);
    return series.isEmpty ? null : series.last;
  }

  /// Compute a full Keltner Channel series.
  ///
  /// Only emits results where both EMA and ATR are available.
  List<KeltnerResult> computeSeries(List<DailyCandle> candles) {
    final emaSeries = emaCalculator.computeSeries(candles, period: emaPeriod);
    final atrSeries = atrCalculator.computeSeries(candles, period: atrPeriod);

    // Build a date→ATR lookup
    final Map<DateTime, double> atrByDate = {};
    for (final AtrResult a in atrSeries) {
      atrByDate[a.date] = a.atr;
    }

    final List<KeltnerResult> results = [];
    for (final (DateTime date, double? ema) in emaSeries) {
      if (ema == null) continue;
      final double? atr = atrByDate[date];
      if (atr == null) continue;
      results.add(
        KeltnerResult(
          date: date,
          upper: ema + multiplier * atr,
          middle: ema,
          lower: ema - multiplier * atr,
        ),
      );
    }
    return results;
  }
}
