import 'package:equatable/equatable.dart';

/// Health level of a market data provider (S475).
enum DataProviderHealthLevel { healthy, degraded, unavailable }

/// Health status record for a market data provider (S475).
class DataProviderHealthStatus extends Equatable {
  const DataProviderHealthStatus({
    required this.providerId,
    required this.providerName,
    required this.level,
    required this.latencyMs,
    required this.successRateLast100,
    this.errorMessage = '',
  });

  final String providerId;
  final String providerName;
  final DataProviderHealthLevel level;

  /// Most recent response latency in milliseconds.
  final int latencyMs;

  /// Success rate over last 100 requests (0.0–1.0).
  final double successRateLast100;
  final String errorMessage;

  bool get isHealthy => level == DataProviderHealthLevel.healthy;
  bool get isUnavailable => level == DataProviderHealthLevel.unavailable;
  bool get hasError => errorMessage.isNotEmpty;
  bool get isHighLatency => latencyMs > 2000;

  @override
  List<Object?> get props => [
    providerId,
    providerName,
    level,
    latencyMs,
    successRateLast100,
    errorMessage,
  ];
}
