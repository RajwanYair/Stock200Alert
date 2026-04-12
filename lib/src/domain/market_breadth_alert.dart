import 'package:equatable/equatable.dart';

/// Alert fired when market breadth crosses a threshold (S461).
enum BreadthAlertType {
  advanceDeclineExtremeUp,
  advanceDeclineExtremeDown,
  newHighsExpanding,
  newLowsExpanding,
  percentAboveMaExtreme,
}

/// An alert triggered by market-breadth conditions (S461).
class MarketBreadthAlert extends Equatable {
  const MarketBreadthAlert({
    required this.alertId,
    required this.type,
    required this.breadthValue,
    required this.threshold,
    required this.exchange,
  });

  final String alertId;
  final BreadthAlertType type;

  /// Observed breadth metric value (e.g. advance/decline ratio).
  final double breadthValue;
  final double threshold;
  final String exchange;

  bool get isBullish =>
      type == BreadthAlertType.advanceDeclineExtremeUp ||
      type == BreadthAlertType.newHighsExpanding ||
      type == BreadthAlertType.percentAboveMaExtreme;
  bool get isBearish => !isBullish;
  double get deviationFromThreshold => breadthValue - threshold;

  @override
  List<Object?> get props => [alertId, type, breadthValue, threshold, exchange];
}
