import 'package:equatable/equatable.dart';

/// Side of a paper trade order.
enum PaperTradeSide { buy, sell }

/// Status of a paper trade order lifecycle.
enum PaperTradeStatus { pending, filled, cancelled, rejected }

/// A simulated (paper) trade order with optional fill simulation.
class PaperTradeOrder extends Equatable {
  const PaperTradeOrder({
    required this.orderId,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.limitPrice,
    required this.createdAt,
    this.fillPrice,
    this.filledAt,
    this.status = PaperTradeStatus.pending,
    this.notes,
  }) : assert(quantity > 0, 'quantity must be > 0'),
       assert(limitPrice > 0, 'limitPrice must be > 0');

  final String orderId;
  final String symbol;
  final PaperTradeSide side;
  final int quantity;

  /// Desired limit price.
  final double limitPrice;
  final DateTime createdAt;

  /// Actual simulated fill price, if filled.
  final double? fillPrice;
  final DateTime? filledAt;
  final PaperTradeStatus status;
  final String? notes;

  bool get isFilled => status == PaperTradeStatus.filled;
  bool get isPending => status == PaperTradeStatus.pending;
  bool get isCancelled => status == PaperTradeStatus.cancelled;
  bool get isBuy => side == PaperTradeSide.buy;
  bool get isSell => side == PaperTradeSide.sell;

  /// Slippage in absolute price units (positive = adverse).
  double? get slippage {
    if (fillPrice == null) return null;
    return isBuy ? fillPrice! - limitPrice : limitPrice - fillPrice!;
  }

  double? get notionalValue => fillPrice == null ? null : fillPrice! * quantity;

  PaperTradeOrder fill({required double atPrice, required DateTime at}) =>
      PaperTradeOrder(
        orderId: orderId,
        symbol: symbol,
        side: side,
        quantity: quantity,
        limitPrice: limitPrice,
        createdAt: createdAt,
        fillPrice: atPrice,
        filledAt: at,
        status: PaperTradeStatus.filled,
        notes: notes,
      );

  @override
  List<Object?> get props => [
    orderId,
    symbol,
    side,
    quantity,
    limitPrice,
    createdAt,
    fillPrice,
    filledAt,
    status,
    notes,
  ];
}
