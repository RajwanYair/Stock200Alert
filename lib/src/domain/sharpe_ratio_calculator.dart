/// Sharpe Ratio Calculator — pure domain logic.
///
/// Computes the annualized Sharpe ratio from daily returns, which measures
/// risk-adjusted return. Higher values indicate better risk-adjusted
/// performance (>1 is good, >2 is very good, >3 is excellent).
library;

import 'dart:math' show sqrt;

import 'entities.dart';

/// Computes the Sharpe ratio.
class SharpeRatioCalculator {
  const SharpeRatioCalculator();

  /// Annualized trading days (standard assumption).
  static const int tradingDaysPerYear = 252;

  /// Compute the annualized Sharpe ratio from candle closing prices.
  ///
  /// [riskFreeRate] is the annualized risk-free rate (e.g. 0.05 = 5%).
  /// Returns null if [candles] has fewer than 3 entries or if standard
  /// deviation is zero.
  double? compute(List<DailyCandle> candles, {double riskFreeRate = 0.0}) {
    if (candles.length < 3) return null;

    // Compute daily returns
    final List<double> returns = [];
    for (int i = 1; i < candles.length; i++) {
      final double prev = candles[i - 1].close;
      if (prev == 0) continue;
      returns.add((candles[i].close - prev) / prev);
    }

    if (returns.length < 2) return null;

    // Mean daily return
    double sum = 0;
    for (final double r in returns) {
      sum += r;
    }
    final double meanReturn = sum / returns.length;

    // Standard deviation of daily returns
    double sumSqDiff = 0;
    for (final double r in returns) {
      final double diff = r - meanReturn;
      sumSqDiff += diff * diff;
    }
    final double stdDev = sqrt(sumSqDiff / returns.length);

    if (stdDev == 0) return null;

    // Annualize
    final double dailyRiskFree = riskFreeRate / tradingDaysPerYear;
    final double excessReturn = meanReturn - dailyRiskFree;

    return (excessReturn / stdDev) * sqrt(tradingDaysPerYear.toDouble());
  }
}
