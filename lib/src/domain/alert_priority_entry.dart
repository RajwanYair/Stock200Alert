import 'package:equatable/equatable.dart';

/// Priority level for an alert entry.
enum AlertPriorityLevel { critical, high, medium, low, informational }

/// Maps a specific alert to a user-assigned priority level.
class AlertPriorityEntry extends Equatable {
  const AlertPriorityEntry({
    required this.alertId,
    required this.ticker,
    required this.priorityLevel,
    required this.createdAt,
    this.note,
  });

  final String alertId;
  final String ticker;
  final AlertPriorityLevel priorityLevel;
  final DateTime createdAt;

  /// Optional user note explaining the priority assignment.
  final String? note;

  /// Returns true when the priority warrants immediate user attention.
  bool get isUrgent =>
      priorityLevel == AlertPriorityLevel.critical ||
      priorityLevel == AlertPriorityLevel.high;

  /// Numeric rank for sorting (lower is higher priority).
  int get sortRank => priorityLevel.index;

  @override
  List<Object?> get props => [alertId, ticker, priorityLevel, createdAt, note];
}
