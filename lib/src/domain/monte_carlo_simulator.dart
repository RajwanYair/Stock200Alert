/// Monte Carlo Simulator — pure domain utility.
///
/// Randomizes the order of historical backtest trades to generate
/// distributions of possible outcomes. Useful for estimating confidence
/// intervals on strategy returns and drawdowns.
library;

import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'backtest_result.dart';

/// A single Monte Carlo simulation run result.
class MonteCarloRun extends Equatable {
  const MonteCarloRun({
    required this.runIndex,
    required this.finalEquity,
    required this.totalReturnPct,
    required this.maxDrawdownPct,
  });

  /// Index of this simulation run.
  final int runIndex;

  /// Final equity after replaying shuffled trades.
  final double finalEquity;

  /// Total return %.
  final double totalReturnPct;

  /// Maximum drawdown % encountered.
  final double maxDrawdownPct;

  @override
  List<Object?> get props => [
    runIndex,
    finalEquity,
    totalReturnPct,
    maxDrawdownPct,
  ];
}

/// Summary statistics across all Monte Carlo runs.
class MonteCarloSummary extends Equatable {
  const MonteCarloSummary({
    required this.runs,
    required this.medianReturnPct,
    required this.p5ReturnPct,
    required this.p95ReturnPct,
    required this.medianMaxDrawdownPct,
    required this.worstMaxDrawdownPct,
  });

  /// All individual runs.
  final List<MonteCarloRun> runs;

  /// Median total return %.
  final double medianReturnPct;

  /// 5th percentile return (worst-case).
  final double p5ReturnPct;

  /// 95th percentile return (best-case).
  final double p95ReturnPct;

  /// Median max drawdown %.
  final double medianMaxDrawdownPct;

  /// Worst max drawdown across all runs.
  final double worstMaxDrawdownPct;

  /// Number of simulation runs.
  int get totalRuns => runs.length;

  @override
  List<Object?> get props => [
    runs,
    medianReturnPct,
    p5ReturnPct,
    p95ReturnPct,
    medianMaxDrawdownPct,
    worstMaxDrawdownPct,
  ];
}

/// Runs Monte Carlo simulations on backtest trade sequences.
class MonteCarloSimulator {
  const MonteCarloSimulator({this.defaultRuns = 1000});

  /// Default number of simulation runs.
  final int defaultRuns;

  /// Simulate [numRuns] random permutations of [result]'s trades.
  MonteCarloSummary simulate(BacktestResult result, {int? numRuns, int? seed}) {
    final int runs = numRuns ?? defaultRuns;
    final math.Random rng = seed != null ? math.Random(seed) : math.Random();
    final List<double> tradeReturns = [
      for (final BacktestTrade t in result.trades) t.returnPercent,
    ];

    if (tradeReturns.isEmpty) {
      return const MonteCarloSummary(
        runs: [],
        medianReturnPct: 0,
        p5ReturnPct: 0,
        p95ReturnPct: 0,
        medianMaxDrawdownPct: 0,
        worstMaxDrawdownPct: 0,
      );
    }

    final List<MonteCarloRun> allRuns = [];
    for (int i = 0; i < runs; i++) {
      final List<double> shuffled = List<double>.of(tradeReturns)..shuffle(rng);
      final _EquityCurve curve = _simulateCurve(
        shuffled,
        result.startingEquity,
      );
      allRuns.add(
        MonteCarloRun(
          runIndex: i,
          finalEquity: curve.finalEquity,
          totalReturnPct: curve.totalReturnPct,
          maxDrawdownPct: curve.maxDrawdownPct,
        ),
      );
    }

    final List<double> returnsSorted = [
      for (final MonteCarloRun r in allRuns) r.totalReturnPct,
    ]..sort();
    final List<double> ddSorted = [
      for (final MonteCarloRun r in allRuns) r.maxDrawdownPct,
    ]..sort();

    return MonteCarloSummary(
      runs: allRuns,
      medianReturnPct: _percentile(returnsSorted, 50),
      p5ReturnPct: _percentile(returnsSorted, 5),
      p95ReturnPct: _percentile(returnsSorted, 95),
      medianMaxDrawdownPct: _percentile(ddSorted, 50),
      worstMaxDrawdownPct: ddSorted.last,
    );
  }

  _EquityCurve _simulateCurve(
    List<double> tradeReturns,
    double startingEquity,
  ) {
    double equity = startingEquity;
    double peak = startingEquity;
    double maxDd = 0;
    for (final double r in tradeReturns) {
      equity += equity * r / 100;
      if (equity > peak) peak = equity;
      final double dd = peak > 0 ? (peak - equity) / peak * 100 : 0;
      if (dd > maxDd) maxDd = dd;
    }
    return _EquityCurve(
      finalEquity: equity,
      totalReturnPct: (equity - startingEquity) / startingEquity * 100,
      maxDrawdownPct: maxDd,
    );
  }

  double _percentile(List<double> sorted, int p) {
    if (sorted.isEmpty) return 0;
    final double index = (p / 100) * (sorted.length - 1);
    final int lower = index.floor();
    final int upper = index.ceil();
    if (lower == upper) return sorted[lower];
    return sorted[lower] + (sorted[upper] - sorted[lower]) * (index - lower);
  }
}

class _EquityCurve {
  const _EquityCurve({
    required this.finalEquity,
    required this.totalReturnPct,
    required this.maxDrawdownPct,
  });

  final double finalEquity;
  final double totalReturnPct;
  final double maxDrawdownPct;
}
