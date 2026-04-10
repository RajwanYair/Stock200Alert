import 'package:equatable/equatable.dart';

/// Normalisation method applied to raw data.
enum NormalisationMethod {
  /// Scale to [0, 1] range.
  minMax,

  /// Scale to zero mean, unit standard deviation.
  zScore,

  /// Scale to [-1, 1].
  tanh,

  /// No normalisation applied.
  none,
}

/// Configuration for normalising a named data field.
class DataNormalizationConfig extends Equatable {
  const DataNormalizationConfig({
    required this.fieldName,
    required this.method,
    this.minClamp,
    this.maxClamp,
    this.windowPeriods = 0,
  });

  final String fieldName;
  final NormalisationMethod method;

  /// Optional lower clamp applied before normalisation.
  final double? minClamp;

  /// Optional upper clamp applied before normalisation.
  final double? maxClamp;

  /// Rolling window for running statistics (0 = use full history).
  final int windowPeriods;

  /// Returns true when clamping bounds are configured.
  bool get hasClamping => minClamp != null || maxClamp != null;

  /// Returns true when a rolling window is used instead of full history.
  bool get isRolling => windowPeriods > 0;

  @override
  List<Object?> get props => [
    fieldName,
    method,
    minClamp,
    maxClamp,
    windowPeriods,
  ];
}
