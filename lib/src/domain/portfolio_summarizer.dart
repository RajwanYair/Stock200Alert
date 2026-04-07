/// Portfolio Holding — immutable value object representing one position.
library;

import 'package:equatable/equatable.dart';

/// A single portfolio holding with cost basis and current valuation.
class PortfolioHolding extends Equatable {
  const PortfolioHolding({
    required this.ticker,
    required this.shares,
    required this.averageCost,
    required this.currentPrice,
    this.sector = '',
  });

  final String ticker;
  final double shares;
  final double averageCost;
  final double currentPrice;
  final String sector;

  /// Total cost basis.
  double get costBasis => shares * averageCost;

  /// Current market value.
  double get marketValue => shares * currentPrice;

  /// Unrealized profit/loss in dollars.
  double get unrealizedPnl => marketValue - costBasis;

  /// Unrealized P&L as a percentage of cost basis.
  double get unrealizedPnlPct =>
      costBasis > 0 ? (unrealizedPnl / costBasis) * 100 : 0;

  @override
  List<Object?> get props => [
    ticker,
    shares,
    averageCost,
    currentPrice,
    sector,
  ];
}

/// Aggregated summary of a collection of portfolio holdings.
class PortfolioSummary extends Equatable {
  const PortfolioSummary({
    required this.totalCost,
    required this.totalValue,
    required this.holdingCount,
    required this.topGainer,
    required this.topLoser,
    required this.sectorWeights,
  });

  final double totalCost;
  final double totalValue;
  final int holdingCount;
  final String topGainer;
  final String topLoser;

  /// Sector → weight (0.0 – 1.0) based on market value.
  final Map<String, double> sectorWeights;

  /// Total unrealized P&L in dollars.
  double get totalUnrealizedPnl => totalValue - totalCost;

  /// Total unrealized P&L as a percentage.
  double get totalUnrealizedPnlPct =>
      totalCost > 0 ? (totalUnrealizedPnl / totalCost) * 100 : 0;

  @override
  List<Object?> get props => [
    totalCost,
    totalValue,
    holdingCount,
    topGainer,
    topLoser,
    sectorWeights,
  ];
}

/// Builds a [PortfolioSummary] from a list of [PortfolioHolding] objects.
class PortfolioSummarizer {
  const PortfolioSummarizer();

  /// Compute portfolio summary. Returns `null` when holdings is empty.
  PortfolioSummary? summarize(List<PortfolioHolding> holdings) {
    if (holdings.isEmpty) return null;

    var totalCost = 0.0;
    var totalValue = 0.0;
    String topGainer = holdings.first.ticker;
    String topLoser = holdings.first.ticker;
    double bestPct = holdings.first.unrealizedPnlPct;
    double worstPct = holdings.first.unrealizedPnlPct;

    final sectorValues = <String, double>{};

    for (final PortfolioHolding h in holdings) {
      totalCost += h.costBasis;
      totalValue += h.marketValue;

      if (h.unrealizedPnlPct > bestPct) {
        bestPct = h.unrealizedPnlPct;
        topGainer = h.ticker;
      }
      if (h.unrealizedPnlPct < worstPct) {
        worstPct = h.unrealizedPnlPct;
        topLoser = h.ticker;
      }

      if (h.sector.isNotEmpty) {
        sectorValues[h.sector] = (sectorValues[h.sector] ?? 0) + h.marketValue;
      }
    }

    final sectorWeights = <String, double>{};
    if (totalValue > 0) {
      for (final MapEntry<String, double> e in sectorValues.entries) {
        sectorWeights[e.key] = e.value / totalValue;
      }
    }

    return PortfolioSummary(
      totalCost: totalCost,
      totalValue: totalValue,
      holdingCount: holdings.length,
      topGainer: topGainer,
      topLoser: topLoser,
      sectorWeights: sectorWeights,
    );
  }
}
