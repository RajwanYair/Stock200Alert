import 'package:equatable/equatable.dart';

/// Price level cluster identified by volume concentration (S452).
class PriceLevelCluster extends Equatable {
  const PriceLevelCluster({
    required this.ticker,
    required this.priceLevel,
    required this.volumeConcentration,
    required this.clusterWidth,
    required this.touchCount,
    this.isSupport = true,
  });

  final String ticker;
  final double priceLevel;

  /// Percentage of total volume concentrated at this level (0–1).
  final double volumeConcentration;

  /// Width of the cluster band in absolute price units.
  final double clusterWidth;

  /// Number of times price tested this level.
  final int touchCount;
  final bool isSupport;

  bool get isResistance => !isSupport;
  bool get isStrongLevel => touchCount >= 3;
  bool get isHighConcentration => volumeConcentration >= 0.15;

  @override
  List<Object?> get props => [
    ticker,
    priceLevel,
    volumeConcentration,
    clusterWidth,
    touchCount,
    isSupport,
  ];
}
