import 'package:equatable/equatable.dart';

/// Single parameter axis in a backtest sensitivity grid.
class SensitivityAxis extends Equatable {
  const SensitivityAxis({
    required this.parameterName,
    required this.minValue,
    required this.maxValue,
    required this.stepSize,
  });

  final String parameterName;
  final double minValue;
  final double maxValue;
  final double stepSize;

  @override
  List<Object?> get props => [parameterName, minValue, maxValue, stepSize];
}

/// A single cell in a backtest sensitivity grid: parameter values and
/// the resulting performance metric.
class SensitivityCell extends Equatable {
  const SensitivityCell({
    required this.parameterValues,
    required this.totalReturnPercent,
    required this.sharpeRatio,
    required this.maxDrawdownPercent,
  });

  final Map<String, double> parameterValues;
  final double totalReturnPercent;
  final double sharpeRatio;
  final double maxDrawdownPercent;

  @override
  List<Object?> get props => [
    parameterValues,
    totalReturnPercent,
    sharpeRatio,
    maxDrawdownPercent,
  ];
}

/// Sensitivity analysis result for a backtest: a grid of performance
/// outcomes across two parameter axes.
class BacktestSensitivityResult extends Equatable {
  const BacktestSensitivityResult({
    required this.backtestId,
    required this.ticker,
    required this.axisX,
    required this.axisY,
    required this.cells,
    required this.generatedAt,
  });

  final String backtestId;
  final String ticker;
  final SensitivityAxis axisX;
  final SensitivityAxis axisY;
  final List<SensitivityCell> cells;
  final DateTime generatedAt;

  BacktestSensitivityResult copyWith({
    String? backtestId,
    String? ticker,
    SensitivityAxis? axisX,
    SensitivityAxis? axisY,
    List<SensitivityCell>? cells,
    DateTime? generatedAt,
  }) => BacktestSensitivityResult(
    backtestId: backtestId ?? this.backtestId,
    ticker: ticker ?? this.ticker,
    axisX: axisX ?? this.axisX,
    axisY: axisY ?? this.axisY,
    cells: cells ?? this.cells,
    generatedAt: generatedAt ?? this.generatedAt,
  );

  @override
  List<Object?> get props => [
    backtestId,
    ticker,
    axisX,
    axisY,
    cells,
    generatedAt,
  ];
}
