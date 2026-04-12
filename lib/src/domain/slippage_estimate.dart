import 'package:equatable/equatable.dart';

/// Estimated price slippage for an order (S502).
class SlippageEstimate extends Equatable {
  const SlippageEstimate({
    required this.orderId,
    required this.ticker,
    required this.orderSizeShares,
    required this.estimatedSlippageBps,
    required this.marketImpactBps,
    required this.spreadCostBps,
  });

  final String orderId;
  final String ticker;
  final int orderSizeShares;

  /// Total estimated slippage in basis points.
  final double estimatedSlippageBps;

  /// Market impact component in basis points.
  final double marketImpactBps;

  /// Half-spread cost in basis points.
  final double spreadCostBps;

  double get totalCostBps => estimatedSlippageBps + spreadCostBps;
  bool get isHighSlippage => estimatedSlippageBps >= 20;
  bool get isDominatedByImpact => marketImpactBps > spreadCostBps;

  @override
  List<Object?> get props => [
    orderId,
    ticker,
    orderSizeShares,
    estimatedSlippageBps,
    marketImpactBps,
    spreadCostBps,
  ];
}
