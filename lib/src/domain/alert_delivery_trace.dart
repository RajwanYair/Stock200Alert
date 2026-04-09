/// Alert Delivery Trace — records the per-sink delivery outcome for each
/// fired alert, enabling retry logic and delivery dashboards.
library;

import 'package:equatable/equatable.dart';

/// Outcome of a single delivery attempt to one sink.
enum DeliveryStatus {
  /// Successfully delivered on the first attempt.
  delivered,

  /// Delivery failed but will be retried.
  retrying,

  /// All retry attempts exhausted; message was not delivered.
  failed,

  /// Delivery was skipped (e.g. disabled sink, quiet hours).
  skipped,
}

/// Result of one delivery attempt to a specific sink.
class DeliverySinkResult extends Equatable {
  const DeliverySinkResult({
    required this.sinkId,
    required this.sinkName,
    required this.status,
    required this.attemptedAt,
    this.errorMessage,
    this.attemptCount = 1,
  }) : assert(attemptCount >= 1, 'attemptCount must be at least 1');

  final String sinkId;
  final String sinkName;
  final DeliveryStatus status;
  final DateTime attemptedAt;
  final String? errorMessage;
  final int attemptCount;

  bool get wasSuccessful => status == DeliveryStatus.delivered;

  @override
  List<Object?> get props => [
    sinkId,
    sinkName,
    status,
    attemptedAt,
    errorMessage,
    attemptCount,
  ];
}

/// Aggregated delivery trace for a single alert across all configured sinks.
class AlertDeliveryTrace extends Equatable {
  const AlertDeliveryTrace({
    required this.alertId,
    required this.ticker,
    required this.firedAt,
    required this.sinkResults,
  });

  final String alertId;
  final String ticker;
  final DateTime firedAt;
  final List<DeliverySinkResult> sinkResults;

  /// Returns true if every configured sink delivered successfully.
  bool get allDelivered =>
      sinkResults.isNotEmpty &&
      sinkResults.every((DeliverySinkResult r) => r.wasSuccessful);

  /// Returns sink results that still need a retry.
  List<DeliverySinkResult> get pendingRetries => sinkResults
      .where((DeliverySinkResult r) => r.status == DeliveryStatus.retrying)
      .toList();

  @override
  List<Object?> get props => [alertId, ticker, firedAt, sinkResults];
}
