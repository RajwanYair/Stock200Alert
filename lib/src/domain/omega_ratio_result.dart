import 'package:equatable/equatable.dart';

/// Omega ratio: probability-weighted gains vs losses above a threshold (S479).
class OmegaRatioResult extends Equatable {
  const OmegaRatioResult({
    required this.portfolioId,
    required this.omegaRatio,
    required this.thresholdReturnPercent,
    required this.gainsProbabilityMass,
    required this.lossesProbabilityMass,
    required this.periodDays,
  });

  final String portfolioId;
  final double omegaRatio;

  /// The minimum acceptable return used as the threshold.
  final double thresholdReturnPercent;
  final double gainsProbabilityMass;
  final double lossesProbabilityMass;
  final int periodDays;

  /// Omega > 1 means gains outweigh losses above threshold.
  bool get isFavorable => omegaRatio > 1.0;
  bool get isStrong => omegaRatio >= 2.0;

  @override
  List<Object?> get props => [
    portfolioId,
    omegaRatio,
    thresholdReturnPercent,
    gainsProbabilityMass,
    lossesProbabilityMass,
    periodDays,
  ];
}
