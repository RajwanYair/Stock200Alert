import 'package:equatable/equatable.dart';

/// Estimated market-impact type of an order.
enum MarketImpactLevel { negligible, low, moderate, high, severe }

/// Market impact estimate for a proposed order.
class MarketImpactEstimate extends Equatable {
  const MarketImpactEstimate({
    required this.ticker,
    required this.orderSizeShares,
    required this.avgDailyVolumeShares,
    required this.estimatedSlippagePct,
    required this.impactLevel,
  });

  final String ticker;

  /// Proposed order size in shares.
  final int orderSizeShares;

  /// Average daily traded volume in shares.
  final int avgDailyVolumeShares;

  /// Estimated price slippage as a percentage.
  final double estimatedSlippagePct;

  final MarketImpactLevel impactLevel;

  /// Order size as a fraction of average daily volume.
  double get participationRate =>
      avgDailyVolumeShares > 0 ? orderSizeShares / avgDailyVolumeShares : 0.0;

  /// Returns true when slippage is likely to be material (>= 0.5 %).
  bool get isMaterial => estimatedSlippagePct >= 0.5;

  @override
  List<Object?> get props => [
    ticker,
    orderSizeShares,
    avgDailyVolumeShares,
    estimatedSlippagePct,
    impactLevel,
  ];
}
