import 'package:equatable/equatable.dart';

/// A record of a single trade execution, capturing fill price, quantity,
/// and slippage relative to the intended order price.
class TradeExecutionRecord extends Equatable {
  /// Creates a [TradeExecutionRecord].
  const TradeExecutionRecord({
    required this.executionId,
    required this.orderId,
    required this.ticker,
    required this.executedAt,
    required this.executedPrice,
    required this.executedQuantity,
    required this.slippageBps,
  });

  /// Unique identifier for this execution record.
  final String executionId;

  /// Identifier of the parent order.
  final String orderId;

  /// Ticker symbol.
  final String ticker;

  /// Timestamp of the execution fill.
  final DateTime executedAt;

  /// Fill price per share.
  final double executedPrice;

  /// Number of shares filled.
  final double executedQuantity;

  /// Slippage in basis points versus the intended price
  /// (positive = unfavorable, negative = price improvement).
  final int slippageBps;

  /// Total notional value of the fill.
  double get totalValue => executedPrice * executedQuantity;

  /// Returns `true` when slippage was non-zero.
  bool get hasSlippage => slippageBps != 0;

  /// Returns `true` when slippage was unfavorable (positive bps).
  bool get hasPositiveSlippage => slippageBps > 0;

  @override
  List<Object?> get props => [
    executionId,
    orderId,
    ticker,
    executedAt,
    executedPrice,
    executedQuantity,
    slippageBps,
  ];
}
