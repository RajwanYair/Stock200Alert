import 'package:equatable/equatable.dart';

/// When an indicator alert fires.
enum IndicatorAlertMode { onCross, onThreshold, onChange }

/// Inclusive numeric band.  Alert fires when the value exits this band.
class IndicatorAlertThreshold extends Equatable {
  const IndicatorAlertThreshold({
    required this.lowerBound,
    required this.upperBound,
  }) : assert(
         lowerBound <= upperBound,
         'lowerBound must not exceed upperBound',
       );

  final double lowerBound;
  final double upperBound;

  bool contains(double value) => value >= lowerBound && value <= upperBound;
  bool isBelow(double value) => value < lowerBound;
  bool isAbove(double value) => value > upperBound;

  @override
  List<Object?> get props => [lowerBound, upperBound];
}

/// Alert configuration bound to a specific user-defined indicator.
class IndicatorAlertConfig extends Equatable {
  const IndicatorAlertConfig({
    required this.indicatorId,
    required this.mode,
    required this.threshold,
    this.isEnabled = true,
    this.cooldownMinutes = 60,
  }) : assert(cooldownMinutes >= 0, 'cooldownMinutes must be non-negative');

  final String indicatorId;
  final IndicatorAlertMode mode;
  final IndicatorAlertThreshold threshold;
  final bool isEnabled;

  /// Minimum minutes between consecutive alerts for this indicator.
  final int cooldownMinutes;

  /// `true` when [value] should trigger an alert.
  bool shouldAlert(double value) =>
      isEnabled &&
      (mode == IndicatorAlertMode.onThreshold
          ? !threshold.contains(value)
          : threshold.isBelow(value) || threshold.isAbove(value));

  @override
  List<Object?> get props => [
    indicatorId,
    mode,
    threshold,
    isEnabled,
    cooldownMinutes,
  ];
}
