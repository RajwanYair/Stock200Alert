import 'package:equatable/equatable.dart';

/// Strategy execution metrics — signal and trade counts for a running strategy.
enum StrategyExecutionStatus { running, paused, completed, failed, cancelled }

class StrategyExecutionMetrics extends Equatable {
  const StrategyExecutionMetrics({
    required this.strategyId,
    required this.status,
    required this.totalSignals,
    required this.executedTrades,
    required this.successRate,
  });

  final String strategyId;
  final StrategyExecutionStatus status;
  final int totalSignals;
  final int executedTrades;
  final double successRate;

  StrategyExecutionMetrics copyWith({
    String? strategyId,
    StrategyExecutionStatus? status,
    int? totalSignals,
    int? executedTrades,
    double? successRate,
  }) => StrategyExecutionMetrics(
    strategyId: strategyId ?? this.strategyId,
    status: status ?? this.status,
    totalSignals: totalSignals ?? this.totalSignals,
    executedTrades: executedTrades ?? this.executedTrades,
    successRate: successRate ?? this.successRate,
  );

  @override
  List<Object?> get props => [
    strategyId,
    status,
    totalSignals,
    executedTrades,
    successRate,
  ];
}
