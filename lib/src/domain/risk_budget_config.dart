import 'package:equatable/equatable.dart';

/// A risk budget allocation entry for a single strategy.
class StrategyRiskAllocation extends Equatable {
  const StrategyRiskAllocation({
    required this.strategyName,
    required this.maxRiskPct,
  }) : assert(maxRiskPct >= 0 && maxRiskPct <= 100, 'maxRiskPct must be 0–100');

  final String strategyName;

  /// Maximum percentage of total portfolio at risk for this strategy (0–100).
  final double maxRiskPct;

  bool get isUnallocated => maxRiskPct == 0;

  @override
  List<Object?> get props => [strategyName, maxRiskPct];
}

/// Named risk budget configuration across multiple strategies.
class RiskBudgetConfig extends Equatable {
  const RiskBudgetConfig({
    required this.name,
    required this.allocations,
    required this.totalBudgetPct,
  }) : assert(
         totalBudgetPct > 0 && totalBudgetPct <= 100,
         'totalBudgetPct must be 0–100',
       );

  final String name;
  final List<StrategyRiskAllocation> allocations;

  /// Total risk budget as a percentage of portfolio (0–100).
  final double totalBudgetPct;

  double get usedBudgetPct => allocations.fold(
    0.0,
    (final double s, final StrategyRiskAllocation a) => s + a.maxRiskPct,
  );

  double get remainingBudgetPct => totalBudgetPct - usedBudgetPct;

  bool get isOverallocated => usedBudgetPct > totalBudgetPct;
  bool get isFullyAllocated => (usedBudgetPct - totalBudgetPct).abs() < 0.001;

  StrategyRiskAllocation? allocationFor(String strategy) =>
      allocations
          .where((final StrategyRiskAllocation a) => a.strategyName == strategy)
          .isEmpty
      ? null
      : allocations.firstWhere(
          (final StrategyRiskAllocation a) => a.strategyName == strategy,
        );

  @override
  List<Object?> get props => [name, allocations, totalBudgetPct];
}
