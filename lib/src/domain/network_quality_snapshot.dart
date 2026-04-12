import 'package:equatable/equatable.dart';

/// Network connection quality rating.
enum NetworkQualityRating { excellent, good, fair, poor, offline }

/// Point-in-time measurement of network quality from the app's perspective.
class NetworkQualitySnapshot extends Equatable {
  const NetworkQualitySnapshot({
    required this.rating,
    required this.latencyMs,
    required this.jitterMs,
    required this.packetLossPercent,
    required this.measuredAt,
    this.providerHost,
  });

  final NetworkQualityRating rating;

  /// Round-trip latency in milliseconds.
  final int latencyMs;

  /// Jitter (latency variance) in milliseconds.
  final int jitterMs;

  /// Packet loss percentage (0.0–100.0).
  final double packetLossPercent;

  final DateTime measuredAt;

  /// The market data provider host used for measurement.
  final String? providerHost;

  NetworkQualitySnapshot copyWith({
    NetworkQualityRating? rating,
    int? latencyMs,
    int? jitterMs,
    double? packetLossPercent,
    DateTime? measuredAt,
    String? providerHost,
  }) => NetworkQualitySnapshot(
    rating: rating ?? this.rating,
    latencyMs: latencyMs ?? this.latencyMs,
    jitterMs: jitterMs ?? this.jitterMs,
    packetLossPercent: packetLossPercent ?? this.packetLossPercent,
    measuredAt: measuredAt ?? this.measuredAt,
    providerHost: providerHost ?? this.providerHost,
  );

  @override
  List<Object?> get props => [
    rating,
    latencyMs,
    jitterMs,
    packetLossPercent,
    measuredAt,
    providerHost,
  ];
}
