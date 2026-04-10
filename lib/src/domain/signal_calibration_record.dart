import 'package:equatable/equatable.dart';

/// A historical calibration record for a trading method's signal accuracy.
class SignalCalibrationRecord extends Equatable {
  const SignalCalibrationRecord({
    required this.methodName,
    required this.symbol,
    required this.totalSignals,
    required this.correctSignals,
    required this.calibratedAt,
    this.periodDays = 90,
  }) : assert(totalSignals >= 0, 'totalSignals must be >= 0'),
       assert(correctSignals >= 0, 'correctSignals must be >= 0'),
       assert(periodDays > 0, 'periodDays must be > 0');

  final String methodName;
  final String symbol;
  final int totalSignals;
  final int correctSignals;
  final DateTime calibratedAt;

  /// Rolling window in calendar days used for this calibration.
  final int periodDays;

  int get incorrectSignals => totalSignals - correctSignals;

  /// Accuracy fraction (0.0–1.0); 1.0 when no signals.
  double get accuracy =>
      totalSignals == 0 ? 1.0 : correctSignals / totalSignals;

  double get accuracyPercent => accuracy * 100;

  bool get isReliable => accuracy >= 0.60;
  bool get isHighlyReliable => accuracy >= 0.80;
  bool get hasSignals => totalSignals > 0;

  @override
  List<Object?> get props => [
    methodName,
    symbol,
    totalSignals,
    correctSignals,
    calibratedAt,
    periodDays,
  ];
}
