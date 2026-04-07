/// Custom Indicator Configuration — user-defined SMA/EMA periods.
///
/// Enables power users to define arbitrary moving-average periods beyond
/// the built-in SMA50/SMA150/SMA200 set. Each config specifies an
/// indicator type, period, and optional alert-on-crossover flag.
library;

import 'package:equatable/equatable.dart';

/// The type of moving-average indicator the user wants to compute.
enum IndicatorType {
  /// Simple Moving Average.
  sma,

  /// Exponential Moving Average.
  ema;

  String get label => switch (this) {
    IndicatorType.sma => 'SMA',
    IndicatorType.ema => 'EMA',
  };
}

/// A user-defined indicator configuration.
///
/// Immutable value object stored per-ticker or globally. The [period] must
/// be between [minPeriod] and [maxPeriod].
class CustomIndicatorConfig extends Equatable {
  const CustomIndicatorConfig({
    this.id,
    required this.type,
    required this.period,
    this.symbol,
    this.alertOnCrossover = false,
    this.colorValue,
    this.label,
  });

  /// Minimum supported period (must have at least 2 data points).
  static const int minPeriod = 2;

  /// Maximum supported period (prevents absurdly long lookbacks).
  static const int maxPeriod = 500;

  /// Database row ID; null when not yet persisted.
  final int? id;

  /// The indicator algorithm to use.
  final IndicatorType type;

  /// The lookback window in trading days.
  final int period;

  /// Ticker symbol this config is scoped to (null = global/all tickers).
  final String? symbol;

  /// Whether to fire an alert when price crosses this indicator line.
  final bool alertOnCrossover;

  /// Optional ARGB color value for the chart overlay line.
  final int? colorValue;

  /// User-facing label override (e.g. "My Custom EMA"). When null, defaults
  /// to [defaultLabel].
  final String? label;

  /// Auto-generated label: "SMA 20" or "EMA 50".
  String get defaultLabel => '${type.label} $period';

  /// Display label preferring [label] when provided.
  String get displayLabel => label ?? defaultLabel;

  /// Whether [period] is within the allowed range.
  bool get isValid => period >= minPeriod && period <= maxPeriod;

  CustomIndicatorConfig copyWith({
    IndicatorType? type,
    int? period,
    String? symbol,
    bool? alertOnCrossover,
    int? colorValue,
    String? label,
  }) {
    return CustomIndicatorConfig(
      id: id,
      type: type ?? this.type,
      period: period ?? this.period,
      symbol: symbol ?? this.symbol,
      alertOnCrossover: alertOnCrossover ?? this.alertOnCrossover,
      colorValue: colorValue ?? this.colorValue,
      label: label ?? this.label,
    );
  }

  @override
  List<Object?> get props => [
    id,
    type,
    period,
    symbol,
    alertOnCrossover,
    colorValue,
    label,
  ];
}
