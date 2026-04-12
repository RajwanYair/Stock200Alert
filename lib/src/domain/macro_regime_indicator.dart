import 'package:equatable/equatable.dart';

/// Macroeconomic growth/inflation regime phase (S535).
enum MacroRegimePhase { goldilocks, reflationary, stagflation, deflationary }

/// Composite macroeconomic regime indicator (S535).
class MacroRegimeIndicator extends Equatable {
  const MacroRegimeIndicator({
    required this.regionCode,
    required this.phase,
    required this.growthScore,
    required this.inflationScore,
    required this.confidencePercent,
    required this.assessedAtMs,
  });

  final String regionCode;
  final MacroRegimePhase phase;

  /// Normalised growth score −100 to +100.
  final double growthScore;

  /// Normalised inflation score −100 to +100.
  final double inflationScore;

  /// Model confidence 0–100.
  final double confidencePercent;

  /// Epoch milliseconds when assessed.
  final int assessedAtMs;

  bool get isGoldilocks => phase == MacroRegimePhase.goldilocks;
  bool get isStagflation => phase == MacroRegimePhase.stagflation;
  bool get isHighConfidence => confidencePercent >= 70;

  @override
  List<Object?> get props => [
    regionCode,
    phase,
    growthScore,
    inflationScore,
    confidencePercent,
    assessedAtMs,
  ];
}
