import 'package:equatable/equatable.dart';

/// Color scheme options for a portfolio heatmap.
enum HeatmapColorScheme {
  /// Standard red (down) / green (up) scheme.
  redGreen,

  /// Blue (down) / orange (up) — color-blind friendly.
  blueOrange,

  /// Grayscale — maximum accessibility.
  grayScale,
}

/// Metric used to determine each cell's intensity in a portfolio heatmap.
enum HeatmapMetric {
  /// Percentage price change versus prior session close.
  priceChange,

  /// Percentage change in session volume versus 20-day average.
  volumeChange,

  /// Distance from SMA200 as a percentage.
  smaDistance,

  /// Current RSI value (14-period).
  rsi,
}

/// Configures how a portfolio heatmap is rendered.
class PortfolioHeatmapConfig extends Equatable {
  /// Creates a [PortfolioHeatmapConfig].
  const PortfolioHeatmapConfig({
    required this.configId,
    required this.colorScheme,
    required this.metric,
    this.normalizePercentile = false,
  });

  /// Unique identifier for this configuration.
  final String configId;

  /// Color scheme applied to heatmap cells.
  final HeatmapColorScheme colorScheme;

  /// Metric that drives cell intensity.
  final HeatmapMetric metric;

  /// When `true`, cell intensity is normalized to the percentile
  /// distribution rather than absolute values.
  final bool normalizePercentile;

  /// Returns `true` for schemes that are accessible to color-blind users.
  bool get isColorBlindFriendly =>
      colorScheme == HeatmapColorScheme.blueOrange ||
      colorScheme == HeatmapColorScheme.grayScale;

  @override
  List<Object?> get props => [
    configId,
    colorScheme,
    metric,
    normalizePercentile,
  ];
}
