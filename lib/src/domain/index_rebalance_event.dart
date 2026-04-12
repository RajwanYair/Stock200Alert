import 'package:equatable/equatable.dart';

/// Type of market index rebalance event.
enum IndexRebalanceType {
  /// Periodic scheduled reconstitution (e.g. quarterly).
  scheduled,

  /// Special off-cycle addition.
  addition,

  /// Special off-cycle removal.
  removal,

  /// Weight-only adjustment with no constituent change.
  weightAdjustment,
}

/// A constituent change or weight adjustment event for a market index.
class IndexRebalanceEvent extends Equatable {
  const IndexRebalanceEvent({
    required this.indexId,
    required this.indexName,
    required this.eventType,
    required this.affectedTicker,
    required this.effectiveDate,
    this.newWeightPercent,
    this.previousWeightPercent,
    this.replacedTicker,
  });

  final String indexId;
  final String indexName;
  final IndexRebalanceType eventType;

  /// Ticker being added, removed, or reweighted.
  final String affectedTicker;

  final DateTime effectiveDate;

  /// New index weight after the rebalance (null for removals).
  final double? newWeightPercent;

  /// Previous index weight (null for additions).
  final double? previousWeightPercent;

  /// Ticker removed when affectedTicker was added (swap events).
  final String? replacedTicker;

  IndexRebalanceEvent copyWith({
    String? indexId,
    String? indexName,
    IndexRebalanceType? eventType,
    String? affectedTicker,
    DateTime? effectiveDate,
    double? newWeightPercent,
    double? previousWeightPercent,
    String? replacedTicker,
  }) => IndexRebalanceEvent(
    indexId: indexId ?? this.indexId,
    indexName: indexName ?? this.indexName,
    eventType: eventType ?? this.eventType,
    affectedTicker: affectedTicker ?? this.affectedTicker,
    effectiveDate: effectiveDate ?? this.effectiveDate,
    newWeightPercent: newWeightPercent ?? this.newWeightPercent,
    previousWeightPercent: previousWeightPercent ?? this.previousWeightPercent,
    replacedTicker: replacedTicker ?? this.replacedTicker,
  );

  @override
  List<Object?> get props => [
    indexId,
    indexName,
    eventType,
    affectedTicker,
    effectiveDate,
    newWeightPercent,
    previousWeightPercent,
    replacedTicker,
  ];
}
