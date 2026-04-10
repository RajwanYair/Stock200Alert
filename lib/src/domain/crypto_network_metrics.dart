import 'package:equatable/equatable.dart';

/// On-chain network metrics for a cryptocurrency asset.
///
/// Captures health and activity indicators derived from the underlying
/// blockchain network (e.g. Bitcoin, Ethereum).
class CryptoNetworkMetrics extends Equatable {
  /// Creates a [CryptoNetworkMetrics].
  const CryptoNetworkMetrics({
    required this.symbol,
    required this.networkName,
    required this.recordedAt,
    required this.activeAddresses,
    required this.transactionCount,
    required this.hashRateEh,
    required this.averageFeeSat,
    required this.networkValueUsd,
    this.mempoolSizeKb,
  });

  /// Trading symbol (e.g. `'BTC'`).
  final String symbol;

  /// Network/chain name (e.g. `'Bitcoin'`, `'Ethereum'`).
  final String networkName;

  /// Timestamp of the on-chain snapshot.
  final DateTime recordedAt;

  /// 24-hour unique active addresses count.
  final int activeAddresses;

  /// 24-hour on-chain transaction count.
  final int transactionCount;

  /// Network hash rate in Exahashes per second (EH/s).
  final double hashRateEh;

  /// Average transaction fee in satoshis (or gwei equivalent).
  final double averageFeeSat;

  /// Total network value (market cap proxy) in USD.
  final double networkValueUsd;

  /// Current mempool backlog size in kilobytes (`null` when unavailable).
  final double? mempoolSizeKb;

  /// Returns `true` when transaction volume is above 50 000/day —
  /// a rough signal of an active, liquid network.
  bool get isHighActivity => transactionCount >= 50000;

  /// Returns `true` when network value exceeds $1 billion.
  bool get isLargeNetwork => networkValueUsd >= 1e9;

  @override
  List<Object?> get props => [
    symbol,
    networkName,
    recordedAt,
    activeAddresses,
    transactionCount,
    hashRateEh,
    averageFeeSat,
    networkValueUsd,
    mempoolSizeKb,
  ];
}
