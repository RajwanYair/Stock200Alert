import 'package:equatable/equatable.dart';

/// Immutable record of a trade execution confirmation (S514).
class TradeConfirmationRecord extends Equatable {
  const TradeConfirmationRecord({
    required this.confirmationId,
    required this.orderId,
    required this.ticker,
    required this.executedShares,
    required this.executedPriceUsd,
    required this.feesUsd,
    required this.settlementDateMs,
    this.isCancelled = false,
  });

  final String confirmationId;
  final String orderId;
  final String ticker;
  final int executedShares;
  final double executedPriceUsd;
  final double feesUsd;

  /// Settlement date as epoch milliseconds (midnight UTC).
  final int settlementDateMs;
  final bool isCancelled;

  double get grossValueUsd => executedShares * executedPriceUsd;
  double get netValueUsd => grossValueUsd + feesUsd;
  bool get hasSignificantFees => feesUsd / grossValueUsd.abs() >= 0.01;

  @override
  List<Object?> get props => [
    confirmationId,
    orderId,
    ticker,
    executedShares,
    executedPriceUsd,
    feesUsd,
    settlementDateMs,
    isCancelled,
  ];
}
