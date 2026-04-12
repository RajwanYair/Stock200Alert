import 'package:equatable/equatable.dart';

/// Signal indicating dark pool activity for a ticker (S504).
class DarkPoolIndicator extends Equatable {
  const DarkPoolIndicator({
    required this.ticker,
    required this.darkPoolVolumePercent,
    required this.blockTradeCount,
    required this.estimatedNotionalUsd,
    required this.isBullishFlow,
  });

  final String ticker;

  /// Percentage of total volume executed in dark pools (0–100).
  final double darkPoolVolumePercent;

  /// Number of block trades ≥ 10,000 shares.
  final int blockTradeCount;
  final double estimatedNotionalUsd;

  /// True when net dark pool flow is to the buy side.
  final bool isBullishFlow;

  bool get isHighDarkActivity => darkPoolVolumePercent >= 40;
  bool get hasBlockTrades => blockTradeCount > 0;
  bool get isLargeNotional => estimatedNotionalUsd >= 1000000;

  @override
  List<Object?> get props => [
    ticker,
    darkPoolVolumePercent,
    blockTradeCount,
    estimatedNotionalUsd,
    isBullishFlow,
  ];
}
