import 'package:equatable/equatable.dart';

/// Order fill estimate — pre-trade fill rate and slippage prediction.
enum FillConfidenceLevel { low, medium, high, veryHigh }

class OrderFillEstimate extends Equatable {
  const OrderFillEstimate({
    required this.orderId,
    required this.ticker,
    required this.estimatedFillPct,
    required this.estimatedSlippageBps,
    required this.confidence,
  });

  final String orderId;
  final String ticker;
  final double estimatedFillPct;
  final double estimatedSlippageBps;
  final FillConfidenceLevel confidence;

  OrderFillEstimate copyWith({
    String? orderId,
    String? ticker,
    double? estimatedFillPct,
    double? estimatedSlippageBps,
    FillConfidenceLevel? confidence,
  }) => OrderFillEstimate(
    orderId: orderId ?? this.orderId,
    ticker: ticker ?? this.ticker,
    estimatedFillPct: estimatedFillPct ?? this.estimatedFillPct,
    estimatedSlippageBps: estimatedSlippageBps ?? this.estimatedSlippageBps,
    confidence: confidence ?? this.confidence,
  );

  @override
  List<Object?> get props => [
    orderId,
    ticker,
    estimatedFillPct,
    estimatedSlippageBps,
    confidence,
  ];
}
