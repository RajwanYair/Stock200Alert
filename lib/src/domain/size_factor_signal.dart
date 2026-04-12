import 'package:equatable/equatable.dart';

/// Size (small-cap) factor signal for a ticker (S540).
class SizeFactorSignal extends Equatable {
  const SizeFactorSignal({
    required this.ticker,
    required this.marketCapUsd,
    required this.smbExposure,
    required this.universePercentileRank,
    required this.isBuy,
  });

  final String ticker;

  /// Market capitalisation in USD.
  final double marketCapUsd;

  /// Fama-French SMB (small-minus-big) factor exposure.
  final double smbExposure;

  /// Percentile rank in size universe (0 = largest, 100 = smallest).
  final double universePercentileRank;

  /// True → underweight small caps (buy); false → sell.
  final bool isBuy;

  bool get isMicroCap => marketCapUsd < 300000000;
  bool get isSmallCap => marketCapUsd >= 300000000 && marketCapUsd < 2000000000;
  bool get isPositiveSmbTilt => smbExposure >= 0.3;

  @override
  List<Object?> get props => [
    ticker,
    marketCapUsd,
    smbExposure,
    universePercentileRank,
    isBuy,
  ];
}
