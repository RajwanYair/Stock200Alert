import 'package:equatable/equatable.dart';

/// Treasury yield curve term structure snapshot (S533).
class YieldCurveSnapshot extends Equatable {
  const YieldCurveSnapshot({
    required this.currency,
    required this.rate1m,
    required this.rate3m,
    required this.rate6m,
    required this.rate1y,
    required this.rate2y,
    required this.rate5y,
    required this.rate10y,
    required this.rate30y,
    required this.capturedAtMs,
  });

  final String currency;
  final double rate1m;
  final double rate3m;
  final double rate6m;
  final double rate1y;
  final double rate2y;
  final double rate5y;
  final double rate10y;
  final double rate30y;

  /// Epoch milliseconds when this snapshot was captured.
  final int capturedAtMs;

  double get twosToTensSpreadBps => (rate10y - rate2y) * 100;
  bool get isInverted => rate2y > rate10y;
  bool get isFlat => twosToTensSpreadBps.abs() <= 20;

  @override
  List<Object?> get props => [
    currency,
    rate1m,
    rate3m,
    rate6m,
    rate1y,
    rate2y,
    rate5y,
    rate10y,
    rate30y,
    capturedAtMs,
  ];
}
