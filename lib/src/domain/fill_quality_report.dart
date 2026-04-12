import 'package:equatable/equatable.dart';

/// Execution fill quality assessment for a completed order (S508).
class FillQualityReport extends Equatable {
  const FillQualityReport({
    required this.orderId,
    required this.ticker,
    required this.requestedShares,
    required this.filledShares,
    required this.averageFillPrice,
    required this.referenceMidPrice,
    required this.slippageBps,
  });

  final String orderId;
  final String ticker;
  final int requestedShares;
  final int filledShares;
  final double averageFillPrice;

  /// NBBO mid-price at time of order submission.
  final double referenceMidPrice;

  /// Realised slippage in basis points (positive = cost).
  final double slippageBps;

  double get fillRatePercent =>
      requestedShares == 0 ? 0 : filledShares / requestedShares * 100;
  bool get isFullFill => filledShares >= requestedShares;
  bool get isGoodFill => slippageBps <= 5;
  bool get isHighSlippage => slippageBps >= 20;

  @override
  List<Object?> get props => [
    orderId,
    ticker,
    requestedShares,
    filledShares,
    averageFillPrice,
    referenceMidPrice,
    slippageBps,
  ];
}
