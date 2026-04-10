import 'package:equatable/equatable.dart';

/// Direction of a price momentum signal.
enum MomentumDirection { accelerating, decelerating, reversing, flat }

/// A price momentum snapshot for a ticker over a lookback window.
class PriceMomentumSnapshot extends Equatable {
  const PriceMomentumSnapshot({
    required this.symbol,
    required this.momentumPct,
    required this.lookbackDays,
    required this.measuredAt,
    this.direction = MomentumDirection.flat,
    this.relativeStrength,
  }) : assert(lookbackDays > 0, 'lookbackDays must be > 0');

  final String symbol;

  /// Percentage price change over [lookbackDays].
  final double momentumPct;
  final int lookbackDays;
  final DateTime measuredAt;
  final MomentumDirection direction;

  /// Optional relative strength vs benchmark (0–100).
  final double? relativeStrength;

  bool get isPositive => momentumPct > 0;
  bool get isNegative => momentumPct < 0;
  bool get isStrong => momentumPct.abs() > 10.0;
  bool get isAccelerating => direction == MomentumDirection.accelerating;
  bool get hasRelativeStrength => relativeStrength != null;

  @override
  List<Object?> get props => [
    symbol,
    momentumPct,
    lookbackDays,
    measuredAt,
    direction,
    relativeStrength,
  ];
}
