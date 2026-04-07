/// Forex Pair — domain entities and calculator for currency pair analysis.
library;

import 'package:equatable/equatable.dart';

import 'entities.dart';

/// A currency pair identifier.
class ForexPair extends Equatable {
  const ForexPair({required this.base, required this.quote});

  /// Base currency (e.g. 'EUR').
  final String base;

  /// Quote currency (e.g. 'USD').
  final String quote;

  /// Standard pair symbol (e.g. 'EURUSD').
  String get symbol => '$base$quote';

  /// Display name (e.g. 'EUR/USD').
  String get displayName => '$base/$quote';

  @override
  List<Object?> get props => [base, quote];
}

/// Pip value information for a forex pair.
class PipInfo extends Equatable {
  const PipInfo({
    required this.pair,
    required this.pipSize,
    required this.pipValue,
    required this.spread,
  });

  final ForexPair pair;

  /// Size of one pip (e.g. 0.0001 for most pairs, 0.01 for JPY pairs).
  final double pipSize;

  /// Value of one pip in quote currency for one standard lot.
  final double pipValue;

  /// Current spread in pips.
  final double spread;

  @override
  List<Object?> get props => [pair, pipSize, pipValue, spread];
}

/// Forex summary for one pair over a period.
class ForexSummary extends Equatable {
  const ForexSummary({
    required this.pair,
    required this.currentRate,
    required this.dailyChangePct,
    required this.weeklyChangePct,
    required this.dailyRange,
    required this.averageDailyRange,
  });

  final ForexPair pair;
  final double currentRate;
  final double dailyChangePct;
  final double weeklyChangePct;

  /// Today's high − low.
  final double dailyRange;

  /// Average daily range over the period.
  final double averageDailyRange;

  @override
  List<Object?> get props => [
    pair,
    currentRate,
    dailyChangePct,
    weeklyChangePct,
    dailyRange,
    averageDailyRange,
  ];
}

/// Computes forex-specific analysis from candle data.
class ForexCalculator {
  const ForexCalculator();

  /// Determine pip size for a pair (JPY pairs use 0.01, others 0.0001).
  double pipSize(ForexPair pair) {
    return pair.quote.toUpperCase() == 'JPY' ? 0.01 : 0.0001;
  }

  /// Compute the average daily range in pips over the given candles.
  double averageDailyRangePips(ForexPair pair, List<DailyCandle> candles) {
    if (candles.isEmpty) return 0;

    final pip = pipSize(pair);
    var totalRange = 0.0;
    for (final DailyCandle c in candles) {
      totalRange += (c.high - c.low) / pip;
    }
    return totalRange / candles.length;
  }

  /// Compute spread in pips given bid and ask.
  double spreadPips(ForexPair pair, double bid, double ask) {
    return (ask - bid) / pipSize(pair);
  }

  /// Build a summary from candle data.
  ForexSummary summarize({
    required ForexPair pair,
    required List<DailyCandle> candles,
  }) {
    if (candles.isEmpty) {
      return ForexSummary(
        pair: pair,
        currentRate: 0,
        dailyChangePct: 0,
        weeklyChangePct: 0,
        dailyRange: 0,
        averageDailyRange: 0,
      );
    }

    final last = candles.last;
    final dailyChange = candles.length >= 2
        ? ((last.close - candles[candles.length - 2].close) /
                  candles[candles.length - 2].close) *
              100
        : 0.0;

    final weekAgo = candles.length >= 6
        ? candles[candles.length - 6]
        : candles.first;
    final weeklyChange = ((last.close - weekAgo.close) / weekAgo.close) * 100;

    var avgRange = 0.0;
    for (final DailyCandle c in candles) {
      avgRange += c.high - c.low;
    }
    avgRange /= candles.length;

    return ForexSummary(
      pair: pair,
      currentRate: last.close,
      dailyChangePct: dailyChange,
      weeklyChangePct: weeklyChange,
      dailyRange: last.high - last.low,
      averageDailyRange: avgRange,
    );
  }
}
