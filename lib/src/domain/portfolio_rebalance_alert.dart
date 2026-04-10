import 'package:equatable/equatable.dart';

/// Severity of a portfolio rebalance drift alert.
enum RebalanceAlertSeverity {
  /// Drift is approaching the threshold — informational notice.
  info,

  /// Drift has breached the warning threshold.
  warning,

  /// Drift has breached the critical threshold and action is required.
  critical,
}

/// An alert fired when a portfolio position drifts beyond its target.
class PortfolioRebalanceAlert extends Equatable {
  /// Creates a [PortfolioRebalanceAlert].
  const PortfolioRebalanceAlert({
    required this.ticker,
    required this.severity,
    required this.firedAt,
    required this.currentPct,
    required this.targetPct,
    required this.driftPct,
    this.suggestedActionUsd,
  });

  /// Ticker that is out of balance.
  final String ticker;

  /// Alert severity level.
  final RebalanceAlertSeverity severity;

  /// Timestamp when the alert was generated.
  final DateTime firedAt;

  /// Current portfolio weight as a percentage (0–100).
  final double currentPct;

  /// Target portfolio weight as a percentage (0–100).
  final double targetPct;

  /// Actual drift as a signed percentage (positive = overweight).
  final double driftPct;

  /// Suggested trade size in USD to restore target weight (`null` if unavailable).
  final double? suggestedActionUsd;

  /// Returns `true` when the position is overweight.
  bool get isOverweight => driftPct > 0;

  /// Returns `true` when the alert severity is critical.
  bool get isCritical => severity == RebalanceAlertSeverity.critical;

  @override
  List<Object?> get props => [
    ticker,
    severity,
    firedAt,
    currentPct,
    targetPct,
    driftPct,
    suggestedActionUsd,
  ];
}
