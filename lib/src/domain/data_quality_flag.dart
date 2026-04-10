import 'package:equatable/equatable.dart';

/// Type of data quality issue found on a candle.
enum DataQualityFlagType {
  /// Missing OHLC data for a trading day.
  missing,

  /// Price gap that is unusually large relative to recent history.
  gap,

  /// Single-bar price spike inconsistent with market movement.
  spike,

  /// Data has not been refreshed within the expected time window.
  stale,

  /// Stock split that has not yet been backward-adjusted.
  split,

  /// Volume is zero or unrealistically low.
  zeroVolume,
}

/// Severity of a data quality flag.
enum DataQualitySeverity { info, warning, critical }

/// A quality annotation attached to a specific candle date for a ticker.
class DataQualityFlag extends Equatable {
  const DataQualityFlag({
    required this.symbol,
    required this.candleDate,
    required this.flagType,
    required this.severity,
    this.message,
    this.detectedAt,
  });

  final String symbol;
  final DateTime candleDate;
  final DataQualityFlagType flagType;
  final DataQualitySeverity severity;

  /// Human-readable description of the quality issue.
  final String? message;
  final DateTime? detectedAt;

  bool get isCritical => severity == DataQualitySeverity.critical;
  bool get isWarning => severity == DataQualitySeverity.warning;
  bool get isInfo => severity == DataQualitySeverity.info;

  bool get requiresAction =>
      severity == DataQualitySeverity.critical ||
      severity == DataQualitySeverity.warning;

  @override
  List<Object?> get props => [
    symbol,
    candleDate,
    flagType,
    severity,
    message,
    detectedAt,
  ];
}
