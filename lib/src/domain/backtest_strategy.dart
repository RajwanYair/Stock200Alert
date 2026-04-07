/// Backtest Strategy — pure domain value object.
///
/// Defines entry and exit rules for a backtest simulation. Each strategy
/// specifies a method name and the alert types that trigger entries and exits.
library;

import 'package:equatable/equatable.dart';

/// Configurable strategy for the backtest engine.
class BacktestStrategy extends Equatable {
  const BacktestStrategy({
    required this.name,
    required this.entryAlertTypes,
    required this.exitAlertTypes,
    this.stopLossPct,
    this.takeProfitPct,
    this.maxHoldingDays,
  });

  /// Human-readable strategy name.
  final String name;

  /// Alert type names that trigger position entry (buy).
  final Set<String> entryAlertTypes;

  /// Alert type names that trigger position exit (sell).
  final Set<String> exitAlertTypes;

  /// Optional stop-loss as a percent from entry price.
  final double? stopLossPct;

  /// Optional take-profit as a percent from entry price.
  final double? takeProfitPct;

  /// Optional maximum holding period in trading days.
  final int? maxHoldingDays;

  /// Whether this strategy has risk management rules.
  bool get hasRiskRules =>
      stopLossPct != null || takeProfitPct != null || maxHoldingDays != null;

  /// Check if [alertTypeName] triggers an entry.
  bool isEntry(String alertTypeName) => entryAlertTypes.contains(alertTypeName);

  /// Check if [alertTypeName] triggers an exit.
  bool isExit(String alertTypeName) => exitAlertTypes.contains(alertTypeName);

  @override
  List<Object?> get props => [
    name,
    entryAlertTypes,
    exitAlertTypes,
    stopLossPct,
    takeProfitPct,
    maxHoldingDays,
  ];
}
