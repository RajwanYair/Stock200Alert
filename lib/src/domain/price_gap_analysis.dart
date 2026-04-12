import 'package:equatable/equatable.dart';

/// Gap type classification based on context and volume.
enum PriceGapType {
  /// Common gap — low volume, likely to fill quickly.
  common,

  /// Breakaway gap — high volume, breaks support/resistance.
  breakaway,

  /// Runaway (continuation) gap — occurs mid-trend.
  runaway,

  /// Exhaustion gap — signals trend reversal.
  exhaustion,
}

/// Analysis of a price gap between two consecutive candles,
/// including type classification and fill probability estimate.
class PriceGapAnalysis extends Equatable {
  const PriceGapAnalysis({
    required this.ticker,
    required this.gapDate,
    required this.prevClose,
    required this.openPrice,
    required this.gapSizePercent,
    required this.gapType,
    required this.fillProbabilityPercent,
    required this.isUpGap,
  });

  final String ticker;
  final DateTime gapDate;

  /// Previous session close price.
  final double prevClose;

  /// Current session open price.
  final double openPrice;

  /// Gap size as a percentage of prevClose.
  final double gapSizePercent;

  final PriceGapType gapType;

  /// Estimated probability (0–100) that the gap fills within the session.
  final double fillProbabilityPercent;

  /// `true` for an upward gap, `false` for a downward gap.
  final bool isUpGap;

  PriceGapAnalysis copyWith({
    String? ticker,
    DateTime? gapDate,
    double? prevClose,
    double? openPrice,
    double? gapSizePercent,
    PriceGapType? gapType,
    double? fillProbabilityPercent,
    bool? isUpGap,
  }) => PriceGapAnalysis(
    ticker: ticker ?? this.ticker,
    gapDate: gapDate ?? this.gapDate,
    prevClose: prevClose ?? this.prevClose,
    openPrice: openPrice ?? this.openPrice,
    gapSizePercent: gapSizePercent ?? this.gapSizePercent,
    gapType: gapType ?? this.gapType,
    fillProbabilityPercent:
        fillProbabilityPercent ?? this.fillProbabilityPercent,
    isUpGap: isUpGap ?? this.isUpGap,
  );

  @override
  List<Object?> get props => [
    ticker,
    gapDate,
    prevClose,
    openPrice,
    gapSizePercent,
    gapType,
    fillProbabilityPercent,
    isUpGap,
  ];
}
