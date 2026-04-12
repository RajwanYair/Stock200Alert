import 'package:equatable/equatable.dart';

/// Strategy for evicting stale cache entries (S494).
enum EvictionStrategy { lru, lfu, ttlOnly, fifo }

/// Configuration for a cache eviction policy (S494).
class CacheEvictionPolicy extends Equatable {
  const CacheEvictionPolicy({
    required this.policyId,
    required this.cacheName,
    required this.strategy,
    required this.maxEntries,
    required this.ttlSeconds,
    this.isEnabled = true,
  });

  final String policyId;
  final String cacheName;
  final EvictionStrategy strategy;

  /// Maximum number of entries before eviction is triggered.
  final int maxEntries;

  /// Time-to-live for each entry in seconds.
  final int ttlSeconds;
  final bool isEnabled;

  bool get isAggressiveEviction => ttlSeconds <= 60 || maxEntries <= 50;
  bool get isLruOrLfu =>
      strategy == EvictionStrategy.lru || strategy == EvictionStrategy.lfu;

  @override
  List<Object?> get props => [
    policyId,
    cacheName,
    strategy,
    maxEntries,
    ttlSeconds,
    isEnabled,
  ];
}
