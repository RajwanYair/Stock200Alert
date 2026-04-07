/// Donchian Channel — Pure domain logic.
///
/// Upper band = highest high over N periods.
/// Lower band = lowest low over N periods.
/// Middle = (upper + lower) / 2.
/// Default period: 20.
library;

import 'package:equatable/equatable.dart';

import 'entities.dart';

/// A single Donchian Channel data point.
class DonchianResult extends Equatable {
  const DonchianResult({
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

/// Computes the Donchian Channel series for [DailyCandle] data.
class DonchianCalculator {
  const DonchianCalculator();

  /// Compute the most recent Donchian value.
  ///
  /// Returns null when fewer than [period] candles are available.
  DonchianResult? compute(List<DailyCandle> candles, {int period = 20}) {
    final series = computeSeries(candles, period: period);
    return series.isEmpty ? null : series.last;
  }

  /// Compute a full Donchian series.
  ///
  /// Returns results starting at index [period − 1].
  List<DonchianResult> computeSeries(
    List<DailyCandle> candles, {
    int period = 20,
  }) {
    if (candles.length < period) return [];

    final List<DonchianResult> results = [];

    for (int i = period - 1; i < candles.length; i++) {
      double highest = candles[i].high;
      double lowest = candles[i].low;
      for (int j = i - period + 1; j < i; j++) {
        if (candles[j].high > highest) highest = candles[j].high;
        if (candles[j].low < lowest) lowest = candles[j].low;
      }
      results.add(
        DonchianResult(
          date: candles[i].date,
          upper: highest,
          middle: (highest + lowest) / 2,
          lower: lowest,
        ),
      );
    }
    return results;
  }
}
