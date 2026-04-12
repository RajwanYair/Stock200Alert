import 'package:equatable/equatable.dart';

/// Risk assessment for potential latency arbitrage exposure (S507).
class LatencyArbitrageFlag extends Equatable {
  const LatencyArbitrageFlag({
    required this.ticker,
    required this.flagId,
    required this.detectedAtMs,
    required this.priceDiscrepancyBps,
    required this.affectedVenueCount,
    this.isActive = true,
  });

  final String ticker;
  final String flagId;

  /// Epoch milliseconds when the discrepancy was detected.
  final int detectedAtMs;

  /// Price discrepancy between venues in basis points.
  final double priceDiscrepancyBps;

  /// Number of venues showing the discrepancy.
  final int affectedVenueCount;
  final bool isActive;

  bool get isSignificant => priceDiscrepancyBps >= 5.0;
  bool get isMultiVenue => affectedVenueCount >= 2;

  @override
  List<Object?> get props => [
    ticker,
    flagId,
    detectedAtMs,
    priceDiscrepancyBps,
    affectedVenueCount,
    isActive,
  ];
}
