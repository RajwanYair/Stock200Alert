import 'package:equatable/equatable.dart';

/// Status of an order execution (S458).
enum OrderExecutionStatus { filled, partialFill, rejected, cancelled, pending }

/// Summary of a completed or attempted order execution (S458).
class OrderExecutionSummary extends Equatable {
  const OrderExecutionSummary({
    required this.executionId,
    required this.ticker,
    required this.requestedQuantity,
    required this.filledQuantity,
    required this.averageFillPrice,
    required this.status,
    this.commissionPaid = 0.0,
  });

  final String executionId;
  final String ticker;
  final int requestedQuantity;
  final int filledQuantity;
  final double averageFillPrice;
  final OrderExecutionStatus status;
  final double commissionPaid;

  bool get isFullyFilled =>
      status == OrderExecutionStatus.filled &&
      filledQuantity == requestedQuantity;
  bool get isPartial => status == OrderExecutionStatus.partialFill;
  double get fillRate =>
      requestedQuantity > 0 ? filledQuantity / requestedQuantity : 0.0;
  double get totalCost => averageFillPrice * filledQuantity + commissionPaid;

  @override
  List<Object?> get props => [
    executionId,
    ticker,
    requestedQuantity,
    filledQuantity,
    averageFillPrice,
    status,
    commissionPaid,
  ];
}
