import 'package:equatable/equatable.dart';

/// Settlement cycle configuration for a market or instrument (S512).
class SettlementCycleConfig extends Equatable {
  const SettlementCycleConfig({
    required this.configId,
    required this.marketId,
    required this.settlementDays,
    required this.currency,
    this.usesDeliveryVersusPayment = true,
    this.allowsEarlySettlement = false,
  });

  final String configId;
  final String marketId;

  /// Number of business days to settle (e.g. 2 for T+2).
  final int settlementDays;
  final String currency;

  /// Whether Delivery versus Payment (DvP) is used.
  final bool usesDeliveryVersusPayment;
  final bool allowsEarlySettlement;

  bool get isSameDay => settlementDays == 0;
  bool get isNextDay => settlementDays == 1;
  bool get isStandardUS => settlementDays == 1;

  @override
  List<Object?> get props => [
    configId,
    marketId,
    settlementDays,
    currency,
    usesDeliveryVersusPayment,
    allowsEarlySettlement,
  ];
}
