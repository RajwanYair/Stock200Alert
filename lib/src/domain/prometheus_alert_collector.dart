/// Prometheus Alert Collector — gathers per-ticker alert rate metrics for
/// the optional `/metrics` Prometheus exposition endpoint (v1.7).
library;

import 'package:equatable/equatable.dart';

/// The observation window over which alert rates are computed.
enum AlertRateWindow {
  /// Rolling 1-hour window.
  oneHour,

  /// Rolling 24-hour window.
  twentyFourHours,

  /// Rolling 7-day window.
  sevenDays,
}

/// A single alert-count data point for one ticker + window combination.
class AlertMetricPoint extends Equatable {
  const AlertMetricPoint({
    required this.ticker,
    required this.window,
    required this.alertCount,
    required this.sampledAt,
  }) : assert(alertCount >= 0, 'alertCount must be non-negative');

  final String ticker;
  final AlertRateWindow window;
  final int alertCount;
  final DateTime sampledAt;

  /// Alerts per hour (normalised regardless of window size).
  double get alertsPerHour {
    switch (window) {
      case AlertRateWindow.oneHour:
        return alertCount.toDouble();
      case AlertRateWindow.twentyFourHours:
        return alertCount / 24.0;
      case AlertRateWindow.sevenDays:
        return alertCount / (7.0 * 24.0);
    }
  }

  @override
  List<Object?> get props => [ticker, window, alertCount, sampledAt];
}

/// Collects [AlertMetricPoint] entries from multiple tickers and produces a
/// summary suitable for Prometheus gauge metrics.
class PrometheusAlertCollector extends Equatable {
  const PrometheusAlertCollector({
    required this.points,
    required this.collectedAt,
  });

  final List<AlertMetricPoint> points;
  final DateTime collectedAt;

  /// Total alert count across all tickers for a given [window].
  int totalAlertsForWindow(AlertRateWindow window) => points
      .where((AlertMetricPoint p) => p.window == window)
      .fold(0, (int acc, AlertMetricPoint p) => acc + p.alertCount);

  /// Returns only the points matching [ticker].
  List<AlertMetricPoint> pointsForTicker(String ticker) =>
      points.where((AlertMetricPoint p) => p.ticker == ticker).toList();

  @override
  List<Object?> get props => [points, collectedAt];
}
