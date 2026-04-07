/// Multi-Timeframe Analyzer — aggregates signals across different
/// timeframes (daily, weekly, monthly) for confluence detection.
library;

import 'package:equatable/equatable.dart';

import 'entities.dart';

/// Timeframe classification.
enum Timeframe { daily, weekly, monthly }

/// Signal bias for one timeframe.
class TimeframeBias extends Equatable {
  const TimeframeBias({
    required this.timeframe,
    required this.bias,
    required this.strength,
    required this.signalCount,
  });

  final Timeframe timeframe;

  /// 'BUY', 'SELL', or 'NEUTRAL'.
  final String bias;

  /// Strength of the bias (0.0 – 1.0).
  final double strength;

  /// Number of signals contributing to this bias.
  final int signalCount;

  @override
  List<Object?> get props => [timeframe, bias, strength, signalCount];
}

/// Multi-timeframe confluence result.
class MultiTimeframeResult extends Equatable {
  const MultiTimeframeResult({
    required this.ticker,
    required this.biases,
    required this.confluenceBias,
    required this.confluenceScore,
  });

  final String ticker;
  final List<TimeframeBias> biases;

  /// Overall bias when multiple timeframes agree ('BUY', 'SELL', 'NEUTRAL').
  final String confluenceBias;

  /// 0–100 confluence score: 100 = all timeframes agree strongly.
  final double confluenceScore;

  @override
  List<Object?> get props => [ticker, biases, confluenceBias, confluenceScore];
}

/// Aggregates candles into weekly/monthly bars.
class CandleAggregator {
  const CandleAggregator();

  /// Aggregate daily candles into weekly candles (Mon–Fri groups).
  List<DailyCandle> toWeekly(List<DailyCandle> daily) {
    if (daily.isEmpty) return [];

    final weeks = <int, List<DailyCandle>>{};
    for (final DailyCandle c in daily) {
      // Week key: year * 100 + ISO week number
      final weekOfYear = _isoWeek(c.date);
      final key = c.date.year * 100 + weekOfYear;
      weeks.putIfAbsent(key, () => []).add(c);
    }

    final result = <DailyCandle>[];
    final sortedKeys = weeks.keys.toList()..sort();
    for (final int key in sortedKeys) {
      final bars = weeks[key]!;
      result.add(_aggregate(bars));
    }
    return result;
  }

  /// Aggregate daily candles into monthly candles.
  List<DailyCandle> toMonthly(List<DailyCandle> daily) {
    if (daily.isEmpty) return [];

    final months = <int, List<DailyCandle>>{};
    for (final DailyCandle c in daily) {
      final key = c.date.year * 100 + c.date.month;
      months.putIfAbsent(key, () => []).add(c);
    }

    final result = <DailyCandle>[];
    final sortedKeys = months.keys.toList()..sort();
    for (final int key in sortedKeys) {
      final bars = months[key]!;
      result.add(_aggregate(bars));
    }
    return result;
  }

  DailyCandle _aggregate(List<DailyCandle> bars) {
    var high = bars.first.high;
    var low = bars.first.low;
    var volume = 0;

    for (final DailyCandle b in bars) {
      if (b.high > high) high = b.high;
      if (b.low < low) low = b.low;
      volume += b.volume;
    }

    return DailyCandle(
      date: bars.first.date,
      open: bars.first.open,
      high: high,
      low: low,
      close: bars.last.close,
      volume: volume,
    );
  }

  int _isoWeek(DateTime date) {
    // ISO 8601 week number calculation.
    final dayOfYear = date.difference(DateTime(date.year)).inDays + 1;
    final wday = date.weekday; // 1=Mon, 7=Sun
    return ((dayOfYear - wday + 10) / 7).floor();
  }
}

/// Analyzes signal confluence across multiple timeframes.
class MultiTimeframeAnalyzer {
  const MultiTimeframeAnalyzer();

  /// Compute multi-timeframe result.
  ///
  /// [timeframeBiases] provides the bias for each timeframe.
  MultiTimeframeResult analyze({
    required String ticker,
    required List<TimeframeBias> timeframeBiases,
  }) {
    if (timeframeBiases.isEmpty) {
      return MultiTimeframeResult(
        ticker: ticker,
        biases: const [],
        confluenceBias: 'NEUTRAL',
        confluenceScore: 0,
      );
    }

    var buyScore = 0.0;
    var sellScore = 0.0;

    // Weight: daily=1, weekly=2, monthly=3
    for (final TimeframeBias tb in timeframeBiases) {
      final weight = switch (tb.timeframe) {
        Timeframe.daily => 1.0,
        Timeframe.weekly => 2.0,
        Timeframe.monthly => 3.0,
      };
      if (tb.bias == 'BUY') {
        buyScore += tb.strength * weight;
      } else if (tb.bias == 'SELL') {
        sellScore += tb.strength * weight;
      }
    }

    final totalWeight = timeframeBiases.fold<double>(
      0,
      (double acc, TimeframeBias tb) =>
          acc +
          switch (tb.timeframe) {
            Timeframe.daily => 1.0,
            Timeframe.weekly => 2.0,
            Timeframe.monthly => 3.0,
          },
    );

    final String confluenceBias;
    final double dominantScore;
    if (buyScore > sellScore) {
      confluenceBias = 'BUY';
      dominantScore = buyScore;
    } else if (sellScore > buyScore) {
      confluenceBias = 'SELL';
      dominantScore = sellScore;
    } else {
      confluenceBias = 'NEUTRAL';
      dominantScore = 0;
    }

    final confluenceScore = totalWeight > 0
        ? (dominantScore / totalWeight) * 100
        : 0.0;

    return MultiTimeframeResult(
      ticker: ticker,
      biases: timeframeBiases,
      confluenceBias: confluenceBias,
      confluenceScore: confluenceScore,
    );
  }
}
