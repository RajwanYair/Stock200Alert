import 'package:equatable/equatable.dart';

/// A fundamental data snapshot for a single ticker.
class TickerFundamentals extends Equatable {
  const TickerFundamentals({
    required this.symbol,
    required this.fetchedAt,
    this.peRatio,
    this.eps,
    this.revenueUsd,
    this.marketCapUsd,
    this.beta,
    this.dividendYieldPct,
    this.priceToBookRatio,
    this.debtToEquityRatio,
  });

  final String symbol;
  final DateTime fetchedAt;

  /// Price-to-earnings ratio.
  final double? peRatio;

  /// Earnings per share (trailing twelve months, USD).
  final double? eps;

  /// Annual revenue in USD.
  final double? revenueUsd;

  /// Market capitalisation in USD.
  final double? marketCapUsd;

  /// Beta relative to the market benchmark.
  final double? beta;
  final double? dividendYieldPct;
  final double? priceToBookRatio;
  final double? debtToEquityRatio;

  bool get isExpensive => peRatio != null && peRatio! > 30;
  bool get isCheap => peRatio != null && peRatio! < 10;
  bool get hasGoodDividend =>
      dividendYieldPct != null && dividendYieldPct! >= 2.0;

  /// Whether beta is higher-than-market (>1.0).
  bool get isHighBeta => beta != null && beta! > 1.0;

  bool get hasLargeCapSize =>
      marketCapUsd != null && marketCapUsd! >= 10_000_000_000;

  @override
  List<Object?> get props => [
    symbol,
    fetchedAt,
    peRatio,
    eps,
    revenueUsd,
    marketCapUsd,
    beta,
    dividendYieldPct,
    priceToBookRatio,
    debtToEquityRatio,
  ];
}
