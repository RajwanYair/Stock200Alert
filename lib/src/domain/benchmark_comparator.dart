/// Benchmark Comparator — pure domain calculator.
///
/// Normalizes two price series to a common starting base (default 100)
/// so their percentage performance can be overlaid on the same chart.
library;

import 'package:equatable/equatable.dart';

import 'entities.dart';

/// A single point in a normalized comparison series.
class NormalizedPoint extends Equatable {
  const NormalizedPoint({
    required this.date,
    required this.tickerValue,
    required this.benchmarkValue,
  });

  /// The date of this point.
  final DateTime date;

  /// Normalized ticker value (base = 100 at start).
  final double tickerValue;

  /// Normalized benchmark value (base = 100 at start).
  final double benchmarkValue;

  /// Ticker outperformance vs benchmark (positive = outperforming).
  double get spread => tickerValue - benchmarkValue;

  @override
  List<Object?> get props => [date, tickerValue, benchmarkValue];
}

/// Normalizes two candle series for % comparison on a common base.
class BenchmarkComparator {
  const BenchmarkComparator();

  /// Align and normalize [ticker] and [benchmark] candles to a common
  /// base of [base] (default 100). Only dates present in both series
  /// are included, in chronological order.
  ///
  /// Returns an empty list if fewer than 2 common dates exist.
  List<NormalizedPoint> compare(
    List<DailyCandle> ticker,
    List<DailyCandle> benchmark, {
    double base = 100,
  }) {
    if (ticker.isEmpty || benchmark.isEmpty) return const [];

    final Map<DateTime, double> tickerMap = {
      for (final DailyCandle c in ticker) c.date: c.close,
    };
    final Map<DateTime, double> benchmarkMap = {
      for (final DailyCandle c in benchmark) c.date: c.close,
    };

    final List<DateTime> commonDates =
        tickerMap.keys.where(benchmarkMap.containsKey).toList()..sort();

    if (commonDates.length < 2) return const [];

    final double tickerBase = tickerMap[commonDates.first]!;
    final double benchmarkBase = benchmarkMap[commonDates.first]!;

    if (tickerBase == 0 || benchmarkBase == 0) return const [];

    return [
      for (final DateTime date in commonDates)
        NormalizedPoint(
          date: date,
          tickerValue: tickerMap[date]! / tickerBase * base,
          benchmarkValue: benchmarkMap[date]! / benchmarkBase * base,
        ),
    ];
  }
}
