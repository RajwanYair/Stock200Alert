import 'package:equatable/equatable.dart';

/// Direction of a macroeconomic surprise (S462).
enum MacroSurpriseDirection { positiveSuprise, negativeSuprise, inline }

/// Composite index measuring how macro data diverges from consensus (S462).
class MacroSurpriseIndex extends Equatable {
  const MacroSurpriseIndex({
    required this.indexId,
    required this.region,
    required this.compositeScore,
    required this.direction,
    required this.contributingIndicators,
  });

  final String indexId;
  final String region;

  /// Normalized surprise score (−100 to +100).
  final double compositeScore;
  final MacroSurpriseDirection direction;

  /// Names of indicators contributing to this composite.
  final List<String> contributingIndicators;

  bool get isPositiveSurprise => compositeScore > 10;
  bool get isNegativeSurprise => compositeScore < -10;
  bool get isSignificant => compositeScore.abs() >= 25;

  @override
  List<Object?> get props => [
    indexId,
    region,
    compositeScore,
    direction,
    contributingIndicators,
  ];
}
