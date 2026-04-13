import 'package:equatable/equatable.dart';

/// Price alert history — historical record of a triggered price alert.
enum PriceAlertTriggerType {
  crossAbove,
  crossBelow,
  percentMove,
  absoluteTarget,
}

class PriceAlertHistory extends Equatable {
  const PriceAlertHistory({
    required this.alertId,
    required this.ticker,
    required this.triggerType,
    required this.triggeredPrice,
    required this.triggeredAt,
  });

  final String alertId;
  final String ticker;
  final PriceAlertTriggerType triggerType;
  final double triggeredPrice;
  final DateTime triggeredAt;

  PriceAlertHistory copyWith({
    String? alertId,
    String? ticker,
    PriceAlertTriggerType? triggerType,
    double? triggeredPrice,
    DateTime? triggeredAt,
  }) => PriceAlertHistory(
    alertId: alertId ?? this.alertId,
    ticker: ticker ?? this.ticker,
    triggerType: triggerType ?? this.triggerType,
    triggeredPrice: triggeredPrice ?? this.triggeredPrice,
    triggeredAt: triggeredAt ?? this.triggeredAt,
  );

  @override
  List<Object?> get props => [
    alertId,
    ticker,
    triggerType,
    triggeredPrice,
    triggeredAt,
  ];
}
