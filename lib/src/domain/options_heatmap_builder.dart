/// Options Heatmap — domain entities for visualizing options open interest
/// and implied volatility across strike prices.
library;

import 'package:equatable/equatable.dart';

/// Type of option contract.
enum OptionType { call, put }

/// A single options strike data point.
class OptionsStrike extends Equatable {
  const OptionsStrike({
    required this.strike,
    required this.type,
    required this.openInterest,
    required this.impliedVolatility,
    required this.volume,
    required this.expiration,
  });

  final double strike;
  final OptionType type;
  final int openInterest;

  /// Implied volatility as a decimal (e.g. 0.35 = 35%).
  final double impliedVolatility;
  final int volume;
  final DateTime expiration;

  @override
  List<Object?> get props => [
    strike,
    type,
    openInterest,
    impliedVolatility,
    volume,
    expiration,
  ];
}

/// Aggregated heatmap cell for one strike across calls and puts.
class OptionsHeatmapCell extends Equatable {
  const OptionsHeatmapCell({
    required this.strike,
    required this.callOI,
    required this.putOI,
    required this.totalOI,
    required this.callIV,
    required this.putIV,
    required this.putCallRatio,
  });

  final double strike;
  final int callOI;
  final int putOI;
  final int totalOI;
  final double callIV;
  final double putIV;

  /// Put/call ratio by open interest. > 1 = bearish bias.
  final double putCallRatio;

  @override
  List<Object?> get props => [
    strike,
    callOI,
    putOI,
    totalOI,
    callIV,
    putIV,
    putCallRatio,
  ];
}

/// Summary of the options landscape for one ticker.
class OptionsHeatmapSummary extends Equatable {
  const OptionsHeatmapSummary({
    required this.ticker,
    required this.cells,
    required this.maxPainStrike,
    required this.overallPutCallRatio,
    required this.averageIV,
  });

  final String ticker;
  final List<OptionsHeatmapCell> cells;

  /// Strike where total open interest pain is maximized.
  final double maxPainStrike;

  /// Overall put/call ratio across all strikes.
  final double overallPutCallRatio;

  /// Average implied volatility across all strikes.
  final double averageIV;

  @override
  List<Object?> get props => [
    ticker,
    cells,
    maxPainStrike,
    overallPutCallRatio,
    averageIV,
  ];
}

/// Builds an options heatmap from strike-level data.
class OptionsHeatmapBuilder {
  const OptionsHeatmapBuilder();

  /// Build heatmap summary from a list of strikes.
  OptionsHeatmapSummary build({
    required String ticker,
    required List<OptionsStrike> strikes,
  }) {
    if (strikes.isEmpty) {
      return OptionsHeatmapSummary(
        ticker: ticker,
        cells: const [],
        maxPainStrike: 0,
        overallPutCallRatio: 0,
        averageIV: 0,
      );
    }

    // Group by strike price
    final grouped = <double, List<OptionsStrike>>{};
    for (final OptionsStrike s in strikes) {
      grouped.putIfAbsent(s.strike, () => []).add(s);
    }

    var totalCallOI = 0;
    var totalPutOI = 0;
    var ivSum = 0.0;
    var ivCount = 0;

    final cells = <OptionsHeatmapCell>[];
    for (final MapEntry<double, List<OptionsStrike>> entry in grouped.entries) {
      var callOI = 0;
      var putOI = 0;
      var callIV = 0.0;
      var putIV = 0.0;
      var callCount = 0;
      var putCount = 0;

      for (final OptionsStrike s in entry.value) {
        if (s.type == OptionType.call) {
          callOI += s.openInterest;
          callIV += s.impliedVolatility;
          callCount++;
        } else {
          putOI += s.openInterest;
          putIV += s.impliedVolatility;
          putCount++;
        }
        ivSum += s.impliedVolatility;
        ivCount++;
      }

      totalCallOI += callOI;
      totalPutOI += putOI;

      final avgCallIV = callCount > 0 ? callIV / callCount : 0.0;
      final avgPutIV = putCount > 0 ? putIV / putCount : 0.0;
      final pcr = callOI > 0 ? putOI / callOI : 0.0;

      cells.add(
        OptionsHeatmapCell(
          strike: entry.key,
          callOI: callOI,
          putOI: putOI,
          totalOI: callOI + putOI,
          callIV: avgCallIV,
          putIV: avgPutIV,
          putCallRatio: pcr,
        ),
      );
    }

    cells.sort(
      (OptionsHeatmapCell a, OptionsHeatmapCell b) =>
          a.strike.compareTo(b.strike),
    );

    // Max pain: strike with highest total OI
    final maxPainCell = cells.reduce(
      (OptionsHeatmapCell best, OptionsHeatmapCell c) =>
          c.totalOI > best.totalOI ? c : best,
    );

    final overallPCR = totalCallOI > 0 ? totalPutOI / totalCallOI : 0.0;
    final avgIV = ivCount > 0 ? ivSum / ivCount : 0.0;

    return OptionsHeatmapSummary(
      ticker: ticker,
      cells: cells,
      maxPainStrike: maxPainCell.strike,
      overallPutCallRatio: overallPCR,
      averageIV: avgIV,
    );
  }
}
