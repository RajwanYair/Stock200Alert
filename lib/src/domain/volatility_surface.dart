import 'package:equatable/equatable.dart';

/// A single data point in a historical volatility series.
class VolatilityDataPoint extends Equatable {
  const VolatilityDataPoint({
    required this.date,
    required this.historicalVolatility,
    this.impliedVolatility,
  }) : assert(historicalVolatility >= 0, 'historicalVolatility must be >= 0');

  final DateTime date;

  /// 30-day historical (realised) volatility (%).
  final double historicalVolatility;

  /// Implied volatility from options market (%), if available.
  final double? impliedVolatility;

  bool get hasImpliedVolatility => impliedVolatility != null;

  /// Volatility spread = IV − HV; positive = options pricing in elevated risk.
  double? get volSpread => impliedVolatility == null
      ? null
      : impliedVolatility! - historicalVolatility;

  @override
  List<Object?> get props => [date, historicalVolatility, impliedVolatility];
}

/// Historical volatility surface (series) for a single ticker.
class VolatilitySurface extends Equatable {
  const VolatilitySurface({
    required this.symbol,
    required this.dataPoints,
    required this.lookbackDays,
  }) : assert(lookbackDays > 0, 'lookbackDays must be > 0');

  final String symbol;
  final List<VolatilityDataPoint> dataPoints;
  final int lookbackDays;

  bool get isEmpty => dataPoints.isEmpty;
  int get length => dataPoints.length;

  double? get avgHistoricalVolatility {
    if (dataPoints.isEmpty) return null;
    final sum = dataPoints.fold(
      0.0,
      (final double s, final VolatilityDataPoint p) =>
          s + p.historicalVolatility,
    );
    return sum / dataPoints.length;
  }

  VolatilityDataPoint? get latest =>
      dataPoints.isEmpty ? null : dataPoints.last;

  bool get isCurrentlyElevated {
    final avg = avgHistoricalVolatility;
    final l = latest;
    if (avg == null || l == null) return false;
    return l.historicalVolatility > avg * 1.5;
  }

  @override
  List<Object?> get props => [symbol, dataPoints, lookbackDays];
}
