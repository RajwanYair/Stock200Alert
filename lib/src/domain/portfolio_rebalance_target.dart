import 'package:equatable/equatable.dart';

/// A single target allocation entry for portfolio rebalancing.
class AllocationTarget extends Equatable {
  const AllocationTarget({
    required this.symbol,
    required this.targetWeight,
    this.driftTolerancePct = 5.0,
  }) : assert(
         targetWeight > 0 && targetWeight <= 100,
         'targetWeight must be 0–100',
       ),
       assert(
         driftTolerancePct >= 0 && driftTolerancePct <= 100,
         'driftTolerancePct must be 0–100',
       );

  final String symbol;

  /// Target portfolio weight as a percentage (0–100).
  final double targetWeight;

  /// Acceptable drift before triggering a rebalance (percentage points).
  final double driftTolerancePct;

  /// Lower bound weight before rebalance is triggered.
  double get lowerBound => targetWeight - driftTolerancePct;

  /// Upper bound weight before rebalance is triggered.
  double get upperBound => targetWeight + driftTolerancePct;

  /// Whether [currentWeight] is within the drift tolerance band.
  bool isWithinTolerance(double currentWeight) =>
      currentWeight >= lowerBound && currentWeight <= upperBound;

  @override
  List<Object?> get props => [symbol, targetWeight, driftTolerancePct];
}

/// Portfolio rebalance target with symbol allocations.
class PortfolioRebalanceTarget extends Equatable {
  const PortfolioRebalanceTarget({
    required this.name,
    required this.targets,
    this.rebalanceFrequencyDays = 90,
  }) : assert(rebalanceFrequencyDays > 0, 'rebalanceFrequencyDays must be > 0');

  final String name;
  final List<AllocationTarget> targets;

  /// How often to rebalance in calendar days.
  final int rebalanceFrequencyDays;

  int get symbolCount => targets.length;

  /// Sum of all target weights; should equal 100 for a valid allocation.
  double get totalWeight => targets.fold(
    0.0,
    (final double s, final AllocationTarget t) => s + t.targetWeight,
  );

  bool get isFullyAllocated => (totalWeight - 100.0).abs() < 0.001;

  AllocationTarget? targetFor(String symbol) =>
      targets.where((final AllocationTarget t) => t.symbol == symbol).isEmpty
      ? null
      : targets.firstWhere((final AllocationTarget t) => t.symbol == symbol);

  @override
  List<Object?> get props => [name, targets, rebalanceFrequencyDays];
}
