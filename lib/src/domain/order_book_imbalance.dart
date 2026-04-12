import 'package:equatable/equatable.dart';

/// Real-time bid/ask volume imbalance from the order book (S506).
class OrderBookImbalance extends Equatable {
  const OrderBookImbalance({
    required this.ticker,
    required this.bidVolume,
    required this.askVolume,
    required this.levels,
    required this.isBuyPressure,
  });

  final String ticker;

  /// Aggregate bid volume across tracked levels.
  final int bidVolume;

  /// Aggregate ask volume across tracked levels.
  final int askVolume;

  /// Number of order book levels sampled.
  final int levels;

  /// True when bid volume dominates ask volume.
  final bool isBuyPressure;

  double get imbalanceRatio =>
      (bidVolume + askVolume) == 0 ? 0.5 : bidVolume / (bidVolume + askVolume);

  bool get isStrongImbalance =>
      imbalanceRatio >= 0.65 || imbalanceRatio <= 0.35;

  @override
  List<Object?> get props => [
    ticker,
    bidVolume,
    askVolume,
    levels,
    isBuyPressure,
  ];
}
