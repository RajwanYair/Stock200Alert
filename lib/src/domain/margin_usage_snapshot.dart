import 'package:equatable/equatable.dart';

/// Point-in-time snapshot of margin utilisation for a trading account.
class MarginUsageSnapshot extends Equatable {
  /// Creates a [MarginUsageSnapshot].
  const MarginUsageSnapshot({
    required this.snapshotId,
    required this.accountId,
    required this.capturedAt,
    required this.totalEquity,
    required this.usedMargin,
    required this.availableMargin,
  });

  /// Unique identifier for this snapshot.
  final String snapshotId;

  /// Broker account identifier.
  final String accountId;

  /// Timestamp of the snapshot.
  final DateTime capturedAt;

  /// Total account equity (net liquidation value).
  final double totalEquity;

  /// Margin currently in use.
  final double usedMargin;

  /// Margin available for new positions.
  final double availableMargin;

  /// Margin utilisation as a fraction of total equity.
  double get marginUtilizationRate =>
      totalEquity == 0.0 ? 0.0 : usedMargin / totalEquity;

  /// Returns `true` when used margin exceeds total equity.
  bool get isOverMargin => usedMargin > totalEquity;

  /// Returns `true` when utilisation exceeds 80%.
  bool get isHighUtilization => marginUtilizationRate > 0.80;

  @override
  List<Object?> get props => [
    snapshotId,
    accountId,
    capturedAt,
    totalEquity,
    usedMargin,
    availableMargin,
  ];
}
