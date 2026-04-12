import 'package:equatable/equatable.dart';

/// Investment-grade and high-yield credit spread snapshot (S534).
class CreditSpreadSnapshot extends Equatable {
  const CreditSpreadSnapshot({
    required this.currency,
    required this.igOasSpreadBps,
    required this.hyOasSpreadBps,
    required this.emSpreadBps,
    required this.capturedAtMs,
  });

  final String currency;

  /// Investment-grade OAS spread in basis points.
  final double igOasSpreadBps;

  /// High-yield OAS spread in basis points.
  final double hyOasSpreadBps;

  /// Emerging-market sovereign spread in basis points.
  final double emSpreadBps;

  /// Epoch milliseconds when captured.
  final int capturedAtMs;

  double get igHyRatioSpread => hyOasSpreadBps - igOasSpreadBps;
  bool get isWideningCredit => hyOasSpreadBps >= 600;
  bool get isNarrowingCredit => hyOasSpreadBps <= 300;

  @override
  List<Object?> get props => [
    currency,
    igOasSpreadBps,
    hyOasSpreadBps,
    emSpreadBps,
    capturedAtMs,
  ];
}
