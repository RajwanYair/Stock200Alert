import 'package:equatable/equatable.dart';

/// A single performance metric snapshot for the app or a feature.
class PerformanceMetricSnapshot extends Equatable {
  const PerformanceMetricSnapshot({
    required this.metricName,
    required this.value,
    required this.unit,
    required this.capturedAt,
    this.baseline,
    this.tags = const {},
  }) : assert(value >= 0, 'value must be >= 0');

  final String metricName;
  final double value;

  /// Unit label (e.g. 'ms', 'MB', 'req/s', 'count').
  final String unit;
  final DateTime capturedAt;

  /// Optional baseline for regression comparison.
  final double? baseline;

  /// Arbitrary string tags for grouping (e.g. {'platform': 'android'}).
  final Map<String, String> tags;

  bool get hasBaseline => baseline != null;

  /// Deviation percentage vs baseline (positive = worse for latency).
  double? get deviationPct {
    if (baseline == null || baseline! == 0) return null;
    return ((value - baseline!) / baseline!) * 100;
  }

  bool get isRegression => deviationPct != null && deviationPct! > 10.0;

  bool get isImprovement => deviationPct != null && deviationPct! < -10.0;

  @override
  List<Object?> get props => [
    metricName,
    value,
    unit,
    capturedAt,
    baseline,
    tags,
  ];
}
