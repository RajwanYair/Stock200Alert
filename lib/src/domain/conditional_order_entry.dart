import 'package:equatable/equatable.dart';

/// Trigger type for a conditional order (S457).
enum ConditionalOrderTrigger {
  priceAbove,
  priceBelow,
  percentMove,
  indicatorCross,
  timeOfDay,
}

/// An order that activates only when a specified condition is met (S457).
class ConditionalOrderEntry extends Equatable {
  const ConditionalOrderEntry({
    required this.orderId,
    required this.ticker,
    required this.trigger,
    required this.triggerValue,
    required this.orderQuantity,
    this.isBuyOrder = true,
    this.isActive = true,
  });

  final String orderId;
  final String ticker;
  final ConditionalOrderTrigger trigger;

  /// Numeric threshold for the trigger (price, %, etc.).
  final double triggerValue;
  final int orderQuantity;
  final bool isBuyOrder;
  final bool isActive;

  bool get isSellOrder => !isBuyOrder;
  bool get isPriceTrigger =>
      trigger == ConditionalOrderTrigger.priceAbove ||
      trigger == ConditionalOrderTrigger.priceBelow;

  @override
  List<Object?> get props => [
    orderId,
    ticker,
    trigger,
    triggerValue,
    orderQuantity,
    isBuyOrder,
    isActive,
  ];
}
