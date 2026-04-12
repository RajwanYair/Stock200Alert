import 'package:equatable/equatable.dart';

/// Direction of a detected signal divergence.
enum DivergenceDirection {
  /// Price making higher highs but indicator making lower highs (bearish).
  bearish,

  /// Price making lower lows but indicator making higher lows (bullish).
  bullish,
}

/// An alert fired when price action diverges from an indicator signal.
class SignalDivergenceAlert extends Equatable {
  const SignalDivergenceAlert({
    required this.ticker,
    required this.methodName,
    required this.direction,
    required this.pricePivot,
    required this.indicatorPivot,
    required this.detectedAt,
    this.confirmationBars = 0,
  });

  final String ticker;
  final String methodName;
  final DivergenceDirection direction;

  /// Price value at the divergence pivot.
  final double pricePivot;

  /// Indicator value at the corresponding pivot.
  final double indicatorPivot;

  final DateTime detectedAt;

  /// Number of subsequent bars that confirmed the divergence.
  final int confirmationBars;

  SignalDivergenceAlert copyWith({
    String? ticker,
    String? methodName,
    DivergenceDirection? direction,
    double? pricePivot,
    double? indicatorPivot,
    DateTime? detectedAt,
    int? confirmationBars,
  }) => SignalDivergenceAlert(
    ticker: ticker ?? this.ticker,
    methodName: methodName ?? this.methodName,
    direction: direction ?? this.direction,
    pricePivot: pricePivot ?? this.pricePivot,
    indicatorPivot: indicatorPivot ?? this.indicatorPivot,
    detectedAt: detectedAt ?? this.detectedAt,
    confirmationBars: confirmationBars ?? this.confirmationBars,
  );

  @override
  List<Object?> get props => [
    ticker,
    methodName,
    direction,
    pricePivot,
    indicatorPivot,
    detectedAt,
    confirmationBars,
  ];
}
