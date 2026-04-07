/// Performance Benchmark — pure domain logic.
///
/// Computes relative performance of a ticker against a benchmark
/// (typically S&P 500) over a given period. Returns normalized %
/// returns for easy comparison.
library;

import 'package:equatable/equatable.dart';

import 'entities.dart';

/// One data point in the performance comparison series.
class BenchmarkPoint extends Equatable {
  const BenchmarkPoint({
    required this.date,
    required this.tickerReturn,
    required this.benchmarkReturn,
  });

  /// The date of this observation.
  final DateTime date;

  /// Cumulative % return of the ticker from start.
  final double tickerReturn;

  /// Cumulative % return of the benchmark from start.
  final double benchmarkReturn;

  /// Alpha = ticker return - benchmark return.
  double get alpha => tickerReturn - benchmarkReturn;

  @override
  List<Object?> get props => [date, tickerReturn, benchmarkReturn];
}

/// Result of a performance benchmark comparison.
class BenchmarkResult extends Equatable {
  const BenchmarkResult({
    required this.ticker,
    required this.benchmarkSymbol,
    required this.series,
    required this.tickerTotalReturn,
    required this.benchmarkTotalReturn,
  });

  /// The ticker being evaluated.
  final String ticker;

  /// The benchmark symbol (e.g. '^GSPC').
  final String benchmarkSymbol;

  /// Time series of returns.
  final List<BenchmarkPoint> series;

  /// Total cumulative % return of the ticker.
  final double tickerTotalReturn;

  /// Total cumulative % return of the benchmark.
  final double benchmarkTotalReturn;

  /// Total alpha (outperformance of ticker vs benchmark).
  double get totalAlpha => tickerTotalReturn - benchmarkTotalReturn;

  @override
  List<Object?> get props => [
    ticker,
    benchmarkSymbol,
    series,
    tickerTotalReturn,
    benchmarkTotalReturn,
  ];
}

/// Computes normalized performance comparison between ticker and benchmark.
class PerformanceBenchmark {
  const PerformanceBenchmark();

  /// Compare [tickerCandles] against [benchmarkCandles].
  ///
  /// Both lists must be sorted by date and aligned by date. The calculator
  /// takes the intersection of dates. Returns null if fewer than 2 matching
  /// dates are found.
  BenchmarkResult? compare({
    required String ticker,
    required List<DailyCandle> tickerCandles,
    required String benchmarkSymbol,
    required List<DailyCandle> benchmarkCandles,
  }) {
    // Build date → close maps
    final Map<DateTime, double> tickerMap = {
      for (final DailyCandle c in tickerCandles)
        DateTime(c.date.year, c.date.month, c.date.day): c.close,
    };
    final Map<DateTime, double> benchMap = {
      for (final DailyCandle c in benchmarkCandles)
        DateTime(c.date.year, c.date.month, c.date.day): c.close,
    };

    // Find common dates sorted
    final List<DateTime> commonDates =
        tickerMap.keys.where(benchMap.containsKey).toList()..sort();

    if (commonDates.length < 2) return null;

    final double tickerBase = tickerMap[commonDates.first]!;
    final double benchBase = benchMap[commonDates.first]!;

    final List<BenchmarkPoint> series = [];
    for (final DateTime date in commonDates) {
      final double tReturn = (tickerMap[date]! - tickerBase) / tickerBase * 100;
      final double bReturn = (benchMap[date]! - benchBase) / benchBase * 100;
      series.add(
        BenchmarkPoint(
          date: date,
          tickerReturn: tReturn,
          benchmarkReturn: bReturn,
        ),
      );
    }

    return BenchmarkResult(
      ticker: ticker,
      benchmarkSymbol: benchmarkSymbol,
      series: series,
      tickerTotalReturn: series.last.tickerReturn,
      benchmarkTotalReturn: series.last.benchmarkReturn,
    );
  }
}
