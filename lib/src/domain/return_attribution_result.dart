import 'package:equatable/equatable.dart';

/// Brinson-Hood-Beebower return attribution breakdown (S531).
class ReturnAttributionResult extends Equatable {
  const ReturnAttributionResult({
    required this.portfolioId,
    required this.periodLabel,
    required this.allocationEffectPercent,
    required this.selectionEffectPercent,
    required this.interactionEffectPercent,
    required this.totalActiveReturnPercent,
  });

  final String portfolioId;
  final String periodLabel;

  /// Return from over/underweighting sectors vs benchmark.
  final double allocationEffectPercent;

  /// Return from security selection within sectors.
  final double selectionEffectPercent;

  /// Cross-product (interaction) attribution effect.
  final double interactionEffectPercent;

  /// Sum of all attribution effects = active return vs benchmark.
  final double totalActiveReturnPercent;

  bool get isSelectionDriven =>
      selectionEffectPercent.abs() > allocationEffectPercent.abs();
  bool get isOutperforming => totalActiveReturnPercent > 0;
  bool get isSignificantAlpha => totalActiveReturnPercent.abs() >= 1.0;

  @override
  List<Object?> get props => [
    portfolioId,
    periodLabel,
    allocationEffectPercent,
    selectionEffectPercent,
    interactionEffectPercent,
    totalActiveReturnPercent,
  ];
}
