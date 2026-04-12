import 'package:equatable/equatable.dart';

/// Routing strategy for smart order execution (S501).
enum OrderRoutingStrategy {
  smart,
  direct,
  dma,
  algorithmicTwap,
  algorithmicVwap,
}

/// User preference for order routing and execution venue (S501).
class OrderRoutingPreference extends Equatable {
  const OrderRoutingPreference({
    required this.preferenceId,
    required this.userId,
    required this.strategy,
    this.preferredVenueId = '',
    this.avoidDarkPools = false,
    this.maxSlippageBps = 10,
  });

  final String preferenceId;
  final String userId;
  final OrderRoutingStrategy strategy;

  /// Optional specific venue override.
  final String preferredVenueId;
  final bool avoidDarkPools;

  /// Maximum tolerated slippage in basis points.
  final int maxSlippageBps;

  bool get hasVenuePreference => preferredVenueId.isNotEmpty;
  bool get isAlgorithmic =>
      strategy == OrderRoutingStrategy.algorithmicTwap ||
      strategy == OrderRoutingStrategy.algorithmicVwap;
  bool get isTightSlippage => maxSlippageBps <= 5;

  @override
  List<Object?> get props => [
    preferenceId,
    userId,
    strategy,
    preferredVenueId,
    avoidDarkPools,
    maxSlippageBps,
  ];
}
