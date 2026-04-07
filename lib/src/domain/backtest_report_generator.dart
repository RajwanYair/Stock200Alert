/// Backtest Report Generator — pure domain utility.
///
/// Computes extended statistics from a [BacktestResult] that go beyond the
/// basic metrics already on the result object (e.g., Sharpe ratio,
/// profit factor, max consecutive wins/losses).
library;

import 'dart:math' as math;

import 'package:equatable/equatable.dart';

import 'backtest_result.dart';

/// Extended report metrics for a backtest run.
class BacktestReport extends Equatable {
  const BacktestReport({
    required this.ticker,
    required this.methodName,
    required this.totalTrades,
    required this.winRate,
    required this.totalReturnPct,
    required this.profitFactor,
    required this.maxConsecutiveWins,
    required this.maxConsecutiveLosses,
    required this.avgWinPct,
    required this.avgLossPct,
    required this.maxDrawdownPct,
    required this.sharpeRatio,
  });

  final String ticker;
  final String methodName;
  final int totalTrades;
  final double winRate;
  final double totalReturnPct;
  final double profitFactor;
  final int maxConsecutiveWins;
  final int maxConsecutiveLosses;
  final double avgWinPct;
  final double avgLossPct;
  final double maxDrawdownPct;
  final double sharpeRatio;

  @override
  List<Object?> get props => [
    ticker,
    methodName,
    totalTrades,
    winRate,
    totalReturnPct,
    profitFactor,
    maxConsecutiveWins,
    maxConsecutiveLosses,
    avgWinPct,
    avgLossPct,
    maxDrawdownPct,
    sharpeRatio,
  ];
}

/// Generates a [BacktestReport] from a [BacktestResult].
class BacktestReportGenerator {
  const BacktestReportGenerator();

  /// Generate the extended report.
  BacktestReport generate(BacktestResult result) {
    final List<BacktestTrade> trades = result.trades;
    if (trades.isEmpty) {
      return BacktestReport(
        ticker: result.ticker,
        methodName: result.methodName,
        totalTrades: 0,
        winRate: 0,
        totalReturnPct: 0,
        profitFactor: 0,
        maxConsecutiveWins: 0,
        maxConsecutiveLosses: 0,
        avgWinPct: 0,
        avgLossPct: 0,
        maxDrawdownPct: 0,
        sharpeRatio: 0,
      );
    }

    final List<double> returns = [
      for (final BacktestTrade t in trades) t.returnPercent,
    ];

    final List<BacktestTrade> wins = trades
        .where((BacktestTrade t) => t.isWinner)
        .toList();
    final List<BacktestTrade> losses = trades
        .where((BacktestTrade t) => !t.isWinner)
        .toList();

    final double grossProfit = wins.fold<double>(
      0,
      (double sum, BacktestTrade t) => sum + t.profitLoss,
    );
    final double grossLoss = losses.fold<double>(
      0,
      (double sum, BacktestTrade t) => sum + t.profitLoss.abs(),
    );

    return BacktestReport(
      ticker: result.ticker,
      methodName: result.methodName,
      totalTrades: result.totalTrades,
      winRate: result.winRate,
      totalReturnPct: result.totalReturnPercent,
      profitFactor: grossLoss > 0
          ? grossProfit / grossLoss
          : (grossProfit > 0 ? double.infinity : 0),
      maxConsecutiveWins: _maxConsecutive(trades, true),
      maxConsecutiveLosses: _maxConsecutive(trades, false),
      avgWinPct: wins.isEmpty
          ? 0
          : wins.fold<double>(
                  0,
                  (double s, BacktestTrade t) => s + t.returnPercent,
                ) /
                wins.length,
      avgLossPct: losses.isEmpty
          ? 0
          : losses.fold<double>(
                  0,
                  (double s, BacktestTrade t) => s + t.returnPercent,
                ) /
                losses.length,
      maxDrawdownPct: _maxDrawdown(returns, result.startingEquity),
      sharpeRatio: _sharpeRatio(returns),
    );
  }

  int _maxConsecutive(List<BacktestTrade> trades, bool winners) {
    int max = 0;
    int current = 0;
    for (final BacktestTrade t in trades) {
      if (t.isWinner == winners) {
        current++;
        if (current > max) max = current;
      } else {
        current = 0;
      }
    }
    return max;
  }

  double _maxDrawdown(List<double> returns, double startingEquity) {
    double peak = startingEquity;
    double equity = startingEquity;
    double maxDd = 0;
    for (final double r in returns) {
      equity += equity * r / 100;
      if (equity > peak) peak = equity;
      final double dd = (peak - equity) / peak * 100;
      if (dd > maxDd) maxDd = dd;
    }
    return maxDd;
  }

  double _sharpeRatio(List<double> returns) {
    if (returns.length < 2) return 0;
    final double mean =
        returns.reduce((double a, double b) => a + b) / returns.length;
    final double variance =
        returns.fold<double>(
          0,
          (double sum, double r) => sum + (r - mean) * (r - mean),
        ) /
        (returns.length - 1);
    final double stdDev = math.sqrt(variance);
    if (stdDev == 0) return 0;
    return mean / stdDev;
  }
}
