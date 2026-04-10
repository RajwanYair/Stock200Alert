import 'package:equatable/equatable.dart';

/// Directional bias of an order-flow imbalance.
enum ImbalanceDirection { buyDominated, sellDominated, balanced }

/// Buy/sell volume ratio analysis for order flow monitoring.
class OrderFlowImbalance extends Equatable {
  const OrderFlowImbalance({
    required this.symbol,
    required this.buyVolume,
    required this.sellVolume,
    required this.measuredAt,
  }) : assert(buyVolume >= 0, 'buyVolume must be >= 0'),
       assert(sellVolume >= 0, 'sellVolume must be >= 0');

  final String symbol;
  final double buyVolume;
  final double sellVolume;
  final DateTime measuredAt;

  double get totalVolume => buyVolume + sellVolume;

  /// Buy/sell ratio; returns 1.0 when total volume is zero.
  double get imbalanceRatio => totalVolume == 0 ? 1.0 : buyVolume / totalVolume;

  ImbalanceDirection get direction {
    if (totalVolume == 0) return ImbalanceDirection.balanced;
    if (imbalanceRatio > 0.55) return ImbalanceDirection.buyDominated;
    if (imbalanceRatio < 0.45) return ImbalanceDirection.sellDominated;
    return ImbalanceDirection.balanced;
  }

  bool get isBuyDominated => direction == ImbalanceDirection.buyDominated;
  bool get isSellDominated => direction == ImbalanceDirection.sellDominated;
  bool get isBalanced => direction == ImbalanceDirection.balanced;

  @override
  List<Object?> get props => [symbol, buyVolume, sellVolume, measuredAt];
}
