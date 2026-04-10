import 'package:equatable/equatable.dart';

/// Cost analysis and holding period metrics for a single position.
class HoldingCostAnalysis extends Equatable {
  const HoldingCostAnalysis({
    required this.symbol,
    required this.avgCostBasis,
    required this.currentPrice,
    required this.quantity,
    required this.holdingDays,
  }) : assert(avgCostBasis > 0, 'avgCostBasis must be > 0'),
       assert(currentPrice >= 0, 'currentPrice must be >= 0'),
       assert(quantity > 0, 'quantity must be > 0'),
       assert(holdingDays >= 0, 'holdingDays must be >= 0');

  final String symbol;

  /// Average cost basis per share.
  final double avgCostBasis;
  final double currentPrice;
  final int quantity;

  /// Number of calendar days held.
  final int holdingDays;

  double get totalCostBasis => avgCostBasis * quantity;
  double get marketValue => currentPrice * quantity;
  double get unrealizedPnl => marketValue - totalCostBasis;
  double get unrealizedPnlPct => (unrealizedPnl / totalCostBasis) * 100;

  bool get isProfit => unrealizedPnl > 0;
  bool get isLoss => unrealizedPnl < 0;

  /// Long-term holding (>= 365 days) qualifies for preferred tax treatment in
  /// many jurisdictions.
  bool get isLongTerm => holdingDays >= 365;

  @override
  List<Object?> get props => [
    symbol,
    avgCostBasis,
    currentPrice,
    quantity,
    holdingDays,
  ];
}
