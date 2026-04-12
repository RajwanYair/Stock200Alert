import 'package:equatable/equatable.dart';

/// Information ratio comparing active returns to tracking error (S477).
class InformationRatioResult extends Equatable {
  const InformationRatioResult({
    required this.portfolioId,
    required this.benchmarkTicker,
    required this.informationRatio,
    required this.activeReturnPercent,
    required this.trackingErrorPercent,
    required this.periodDays,
  });

  final String portfolioId;
  final String benchmarkTicker;

  /// Annualized information ratio.
  final double informationRatio;
  final double activeReturnPercent;
  final double trackingErrorPercent;
  final int periodDays;

  bool get isPositiveAlpha => activeReturnPercent > 0;
  bool get isGood => informationRatio >= 0.5;
  bool get isExcellent => informationRatio >= 1.0;

  @override
  List<Object?> get props => [
    portfolioId,
    benchmarkTicker,
    informationRatio,
    activeReturnPercent,
    trackingErrorPercent,
    periodDays,
  ];
}
