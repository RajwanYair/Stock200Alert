import 'package:equatable/equatable.dart';

/// Override mode for a trading method evaluation (S467).
enum MethodOverrideMode { disabled, forceEnable, adjustThreshold }

/// Per-ticker override for a specific trading method (S467).
class MethodOverrideConfig extends Equatable {
  const MethodOverrideConfig({
    required this.configId,
    required this.ticker,
    required this.methodName,
    required this.mode,
    this.thresholdAdjustment = 0.0,
    this.reason = '',
  });

  final String configId;
  final String ticker;
  final String methodName;
  final MethodOverrideMode mode;

  /// Delta applied to the method's native threshold (positive = stricter).
  final double thresholdAdjustment;
  final String reason;

  bool get isDisabled => mode == MethodOverrideMode.disabled;
  bool get hasThresholdAdjustment =>
      mode == MethodOverrideMode.adjustThreshold && thresholdAdjustment != 0.0;
  bool get hasReason => reason.isNotEmpty;

  @override
  List<Object?> get props => [
    configId,
    ticker,
    methodName,
    mode,
    thresholdAdjustment,
    reason,
  ];
}
