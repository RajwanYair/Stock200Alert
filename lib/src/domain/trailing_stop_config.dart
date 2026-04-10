import 'package:equatable/equatable.dart';

/// Trailing stop distance unit.
enum TrailingStopUnit {
  /// Stop distance expressed as a percentage of price.
  percentage,

  /// Stop distance expressed in absolute currency units.
  absoluteValue,

  /// Stop distance expressed as a multiple of ATR.
  atrMultiple,
}

/// Configuration for a trailing stop-loss on a position.
///
/// The stop price trails the best price seen since entry by [trailDistance]
/// units. Exposed helpers compute the current stop price and check whether
/// a given price would trigger the stop.
class TrailingStopConfig extends Equatable {
  /// Creates a [TrailingStopConfig].
  const TrailingStopConfig({
    required this.ticker,
    required this.unit,
    required this.trailDistance,
    required this.entryPrice,
    required this.highWatermark,
    this.isActive = true,
  });

  /// Ticker for which the trailing stop is configured.
  final String ticker;

  /// Unit of measurement for [trailDistance].
  final TrailingStopUnit unit;

  /// Distance from the high-watermark at which the stop fires.
  final double trailDistance;

  /// Original entry price when the position was opened.
  final double entryPrice;

  /// Highest price seen since entry (updated by the tracking service).
  final double highWatermark;

  /// Whether the stop is currently active.
  final bool isActive;

  /// Computes the current stop price based on the [unit] and [highWatermark].
  double get stopPrice {
    switch (unit) {
      case TrailingStopUnit.percentage:
        return highWatermark * (1 - trailDistance / 100);
      case TrailingStopUnit.absoluteValue:
        return highWatermark - trailDistance;
      case TrailingStopUnit.atrMultiple:
        // Caller is expected to pre-multiply trailDistance by ATR before storing.
        return highWatermark - trailDistance;
    }
  }

  /// Returns `true` when [currentPrice] is at or below [stopPrice].
  bool isTriggered(double currentPrice) =>
      isActive && currentPrice <= stopPrice;

  @override
  List<Object?> get props => [
    ticker,
    unit,
    trailDistance,
    entryPrice,
    highWatermark,
    isActive,
  ];
}
