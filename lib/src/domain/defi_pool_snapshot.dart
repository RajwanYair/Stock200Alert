import 'package:equatable/equatable.dart';

/// Snapshot of a DeFi liquidity pool at a point in time (S491).
class DefiPoolSnapshot extends Equatable {
  const DefiPoolSnapshot({
    required this.poolId,
    required this.protocolName,
    required this.tokenPair,
    required this.totalValueLockedUsd,
    required this.apyPercent,
    required this.volumeLast24hUsd,
  });

  final String poolId;
  final String protocolName;

  /// Token pair identifier, e.g. 'ETH/USDC'.
  final String tokenPair;
  final double totalValueLockedUsd;
  final double apyPercent;
  final double volumeLast24hUsd;

  bool get isHighYield => apyPercent >= 20.0;
  bool get isHighLiquidity => totalValueLockedUsd >= 1000000.0;
  bool get isActivePool => volumeLast24hUsd > 0;

  @override
  List<Object?> get props => [
    poolId,
    protocolName,
    tokenPair,
    totalValueLockedUsd,
    apyPercent,
    volumeLast24hUsd,
  ];
}
