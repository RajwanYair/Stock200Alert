import 'package:equatable/equatable.dart';

/// A single equity-curve data point from a backtest run (S484).
class BacktestEquityPoint extends Equatable {
  const BacktestEquityPoint({
    required this.backtestId,
    required this.dayIndex,
    required this.equity,
    required this.drawdownPercent,
    required this.cumulativeReturnPercent,
  });

  final String backtestId;

  /// Zero-based day index within the backtest period.
  final int dayIndex;

  /// Portfolio equity value at this point.
  final double equity;

  /// Drawdown from peak equity at this point (0..100).
  final double drawdownPercent;
  final double cumulativeReturnPercent;

  bool get isDrawdown => drawdownPercent > 0;
  bool get isDeepDrawdown => drawdownPercent >= 20;
  bool get isProfitable => cumulativeReturnPercent > 0;

  @override
  List<Object?> get props => [
    backtestId,
    dayIndex,
    equity,
    drawdownPercent,
    cumulativeReturnPercent,
  ];
}
