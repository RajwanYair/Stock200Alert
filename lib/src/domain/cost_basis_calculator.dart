/// Trade Log — domain entities for tracking buy/sell trade entries
/// and computing average cost basis.
library;

import 'package:equatable/equatable.dart';

/// Direction of a trade.
enum TradeDirection { buy, sell }

/// A single trade entry.
class TradeEntry extends Equatable {
  const TradeEntry({
    required this.ticker,
    required this.direction,
    required this.shares,
    required this.pricePerShare,
    required this.executedAt,
    this.fees = 0,
  });

  final String ticker;
  final TradeDirection direction;
  final double shares;
  final double pricePerShare;
  final DateTime executedAt;
  final double fees;

  /// Total cost of this trade including fees.
  double get totalCost => shares * pricePerShare + fees;

  @override
  List<Object?> get props => [
    ticker,
    direction,
    shares,
    pricePerShare,
    executedAt,
    fees,
  ];
}

/// Result of computing the average cost basis for one ticker.
class CostBasisResult extends Equatable {
  const CostBasisResult({
    required this.ticker,
    required this.totalShares,
    required this.averageCost,
    required this.totalInvested,
    required this.totalFees,
    required this.tradeCount,
  });

  final String ticker;
  final double totalShares;
  final double averageCost;
  final double totalInvested;
  final double totalFees;
  final int tradeCount;

  /// Unrealized P&L given current price.
  double unrealizedPnl(double currentPrice) =>
      totalShares * (currentPrice - averageCost);

  /// Unrealized P&L as a percentage.
  double unrealizedPnlPct(double currentPrice) =>
      averageCost > 0 ? ((currentPrice - averageCost) / averageCost) * 100 : 0;

  @override
  List<Object?> get props => [
    ticker,
    totalShares,
    averageCost,
    totalInvested,
    totalFees,
    tradeCount,
  ];
}

/// Computes average cost basis from a trade log using FIFO-style averaging.
class CostBasisCalculator {
  const CostBasisCalculator();

  /// Compute the average cost basis for a single ticker.
  ///
  /// Only BUY trades increase the position; SELL trades reduce shares
  /// but do not affect average cost (FIFO-like simplification).
  CostBasisResult compute(List<TradeEntry> trades) {
    if (trades.isEmpty) {
      return const CostBasisResult(
        ticker: '',
        totalShares: 0,
        averageCost: 0,
        totalInvested: 0,
        totalFees: 0,
        tradeCount: 0,
      );
    }

    final ticker = trades.first.ticker;
    var totalShares = 0.0;
    var totalCost = 0.0;
    var totalFees = 0.0;
    var buyCount = 0;

    final sorted = trades.toList()
      ..sort(
        (TradeEntry a, TradeEntry b) => a.executedAt.compareTo(b.executedAt),
      );

    for (final TradeEntry t in sorted) {
      totalFees += t.fees;
      if (t.direction == TradeDirection.buy) {
        totalCost += t.shares * t.pricePerShare;
        totalShares += t.shares;
        buyCount++;
      } else {
        // Sell reduces shares but keeps average cost unchanged.
        totalShares -= t.shares;
        if (totalShares < 0) totalShares = 0;
        // Proportionally reduce total cost
        if (totalShares > 0 && t.shares > 0) {
          final ratio = t.shares / (totalShares + t.shares);
          totalCost -= totalCost * ratio;
        } else if (totalShares <= 0) {
          totalCost = 0;
        }
      }
    }

    final avgCost = totalShares > 0 ? totalCost / totalShares : 0.0;

    return CostBasisResult(
      ticker: ticker,
      totalShares: totalShares,
      averageCost: avgCost,
      totalInvested: totalCost,
      totalFees: totalFees,
      tradeCount: buyCount,
    );
  }
}
