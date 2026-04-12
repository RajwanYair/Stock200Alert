import 'package:equatable/equatable.dart';

/// Type of trading execution venue (S503).
enum ExecutionVenueType { exchange, ecn, darkPool, ats, otc }

/// Configuration for a trading execution venue (S503).
class ExecutionVenueConfig extends Equatable {
  const ExecutionVenueConfig({
    required this.venueId,
    required this.venueName,
    required this.venueType,
    required this.takerFeeBps,
    required this.makerFeeBps,
    this.isEnabled = true,
    this.minOrderSize = 1,
  });

  final String venueId;
  final String venueName;
  final ExecutionVenueType venueType;

  /// Taker fee in basis points.
  final double takerFeeBps;

  /// Maker fee in basis points (may be negative for rebates).
  final double makerFeeBps;
  final bool isEnabled;

  /// Minimum order size in shares.
  final int minOrderSize;

  bool get isDarkPool => venueType == ExecutionVenueType.darkPool;
  bool get hasMakerRebate => makerFeeBps < 0;
  bool get isLowCost => takerFeeBps <= 5;

  @override
  List<Object?> get props => [
    venueId,
    venueName,
    venueType,
    takerFeeBps,
    makerFeeBps,
    isEnabled,
    minOrderSize,
  ];
}
