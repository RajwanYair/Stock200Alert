import 'package:equatable/equatable.dart';

/// A candidate position for tax-loss harvesting.
///
/// Identifies unrealized losses that can be realized to offset capital
/// gains while respecting wash-sale restrictions.
class TaxHarvestOpportunity extends Equatable {
  /// Creates a [TaxHarvestOpportunity].
  const TaxHarvestOpportunity({
    required this.ticker,
    required this.currentLoss,
    required this.costBasis,
    required this.currentPrice,
    required this.holdingDays,
    required this.isLongTerm,
  });

  /// Ticker symbol.
  final String ticker;

  /// Unrealised loss in base currency (expected to be negative or zero).
  final double currentLoss;

  /// Original cost basis per share.
  final double costBasis;

  /// Current market price per share.
  final double currentPrice;

  /// Number of days the position has been held.
  final int holdingDays;

  /// `true` when the holding period qualifies for long-term treatment.
  final bool isLongTerm;

  /// Loss as a percentage of cost basis.
  double get lossPercent =>
      costBasis == 0.0 ? 0.0 : currentLoss / costBasis * 100;

  /// Returns `true` when the absolute loss exceeds \$500.
  bool get isSignificant => currentLoss.abs() > 500;

  /// Standard 30-day wash-sale window after harvest.
  int get washSaleWindowDays => 30;

  @override
  List<Object?> get props => [
    ticker,
    currentLoss,
    costBasis,
    currentPrice,
    holdingDays,
    isLongTerm,
  ];
}
