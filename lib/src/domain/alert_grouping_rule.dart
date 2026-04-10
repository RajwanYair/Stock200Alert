import 'package:equatable/equatable.dart';

/// Strategy for grouping related alerts into a single notification.
enum GroupingStrategy {
  byTicker,
  byMethod,
  byAlertType,
  bySeverity,
  byCustomTag,
}

/// Configuration rule for how alerts are grouped before delivery.
class AlertGroupingRule extends Equatable {
  const AlertGroupingRule({
    required this.ruleId,
    required this.groupingStrategy,
    required this.maxGroupSize,
    required this.groupingWindowSeconds,
    this.isEnabled = true,
  });

  final String ruleId;
  final GroupingStrategy groupingStrategy;

  /// Maximum number of alerts combined into one batch notification.
  final int maxGroupSize;

  /// Seconds to wait while accumulating alerts into a group.
  final int groupingWindowSeconds;

  final bool isEnabled;

  /// Returns true when the grouping window is sub-minute (real-time feel).
  bool get isRealTime => groupingWindowSeconds <= 60;

  @override
  List<Object?> get props => [
    ruleId,
    groupingStrategy,
    maxGroupSize,
    groupingWindowSeconds,
    isEnabled,
  ];
}
