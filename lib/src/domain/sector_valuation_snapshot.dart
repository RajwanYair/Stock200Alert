import 'package:equatable/equatable.dart';

/// Valuation snapshot for a market sector (S460).
class SectorValuationSnapshot extends Equatable {
  const SectorValuationSnapshot({
    required this.sectorName,
    required this.medianPeRatio,
    required this.medianPbRatio,
    required this.forwardPeRatio,
    required this.dividendYieldPercent,
    required this.revenueGrowthPercent,
  });

  final String sectorName;
  final double medianPeRatio;
  final double medianPbRatio;
  final double forwardPeRatio;
  final double dividendYieldPercent;
  final double revenueGrowthPercent;

  bool get isExpensive => medianPeRatio > 25.0;
  bool get isCheap => medianPeRatio < 12.0;
  bool get isGrowthSector => revenueGrowthPercent >= 15.0;
  bool get isHighYield => dividendYieldPercent >= 4.0;

  @override
  List<Object?> get props => [
    sectorName,
    medianPeRatio,
    medianPbRatio,
    forwardPeRatio,
    dividendYieldPercent,
    revenueGrowthPercent,
  ];
}
