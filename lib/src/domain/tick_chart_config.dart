import 'package:equatable/equatable.dart';

/// Configuration for a tick-based chart (S463).
enum TickChartType { tickBar, volumeBar, rangeBar, renko }

/// Configuration for a non-time chart rendering (S463).
class TickChartConfig extends Equatable {
  const TickChartConfig({
    required this.configId,
    required this.ticker,
    required this.type,
    required this.brickSize,
    this.showWicks = true,
    this.colorUpCandle = 0xFF26A69A,
    this.colorDownCandle = 0xFFEF5350,
  });

  final String configId;
  final String ticker;
  final TickChartType type;

  /// Tick / volume / range size per bar.
  final double brickSize;
  final bool showWicks;
  final int colorUpCandle;
  final int colorDownCandle;

  bool get isRenko => type == TickChartType.renko;
  bool get isVolumeBased => type == TickChartType.volumeBar;

  @override
  List<Object?> get props => [
    configId,
    ticker,
    type,
    brickSize,
    showWicks,
    colorUpCandle,
    colorDownCandle,
  ];
}
