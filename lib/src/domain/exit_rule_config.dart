import 'package:equatable/equatable.dart';

/// Exit condition type for a strategy rule (S485).
enum ExitTriggerType {
  trailingStop,
  fixedStop,
  takeProfitTarget,
  timeExit,
  signalExit,
}

/// Declarative configuration for a trade exit rule (S485).
class ExitRuleConfig extends Equatable {
  const ExitRuleConfig({
    required this.ruleId,
    required this.trigger,
    required this.triggerValue,
    this.description = '',
    this.isEnabled = true,
  });

  final String ruleId;
  final ExitTriggerType trigger;

  /// Numeric threshold (e.g. stop %, trailing %, target %).
  final double triggerValue;
  final String description;
  final bool isEnabled;

  bool get isStopBased =>
      trigger == ExitTriggerType.trailingStop ||
      trigger == ExitTriggerType.fixedStop;

  bool get isTimeBased => trigger == ExitTriggerType.timeExit;
  bool get hasDescription => description.isNotEmpty;

  @override
  List<Object?> get props => [
    ruleId,
    trigger,
    triggerValue,
    description,
    isEnabled,
  ];
}
