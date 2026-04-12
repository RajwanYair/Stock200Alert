import 'package:equatable/equatable.dart';

/// Status of a single rebalance trade leg.
enum RebalanceLegStatus { pending, submitted, filled, cancelled }

/// A single trade leg within a rebalance execution plan.
class RebalanceLeg extends Equatable {
  const RebalanceLeg({
    required this.ticker,
    required this.currentWeightPercent,
    required this.targetWeightPercent,
    required this.driftPercent,
    required this.status,
    this.requiredTradeValue,
  });

  final String ticker;
  final double currentWeightPercent;
  final double targetWeightPercent;

  /// Absolute drift from target (positive = overweight).
  final double driftPercent;

  final RebalanceLegStatus status;

  /// Estimated notional trade value in portfolio currency.
  final double? requiredTradeValue;

  RebalanceLeg copyWith({
    String? ticker,
    double? currentWeightPercent,
    double? targetWeightPercent,
    double? driftPercent,
    RebalanceLegStatus? status,
    double? requiredTradeValue,
  }) => RebalanceLeg(
    ticker: ticker ?? this.ticker,
    currentWeightPercent: currentWeightPercent ?? this.currentWeightPercent,
    targetWeightPercent: targetWeightPercent ?? this.targetWeightPercent,
    driftPercent: driftPercent ?? this.driftPercent,
    status: status ?? this.status,
    requiredTradeValue: requiredTradeValue ?? this.requiredTradeValue,
  );

  @override
  List<Object?> get props => [
    ticker,
    currentWeightPercent,
    targetWeightPercent,
    driftPercent,
    status,
    requiredTradeValue,
  ];
}

/// Proposed rebalance execution plan: an ordered set of trade legs
/// derived from drift-to-target analysis.
class RebalanceExecution extends Equatable {
  const RebalanceExecution({
    required this.executionId,
    required this.portfolioId,
    required this.legs,
    required this.totalTurnoverPercent,
    required this.proposedAt,
    this.notes,
  });

  final String executionId;
  final String portfolioId;
  final List<RebalanceLeg> legs;

  /// Total portfolio turnover implied by this rebalance (%).
  final double totalTurnoverPercent;

  final DateTime proposedAt;
  final String? notes;

  RebalanceExecution copyWith({
    String? executionId,
    String? portfolioId,
    List<RebalanceLeg>? legs,
    double? totalTurnoverPercent,
    DateTime? proposedAt,
    String? notes,
  }) => RebalanceExecution(
    executionId: executionId ?? this.executionId,
    portfolioId: portfolioId ?? this.portfolioId,
    legs: legs ?? this.legs,
    totalTurnoverPercent: totalTurnoverPercent ?? this.totalTurnoverPercent,
    proposedAt: proposedAt ?? this.proposedAt,
    notes: notes ?? this.notes,
  );

  @override
  List<Object?> get props => [
    executionId,
    portfolioId,
    legs,
    totalTurnoverPercent,
    proposedAt,
    notes,
  ];
}
