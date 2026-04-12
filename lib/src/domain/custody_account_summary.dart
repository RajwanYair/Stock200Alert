import 'package:equatable/equatable.dart';

/// Point-in-time summary of a custody account balance (S511).
class CustodyAccountSummary extends Equatable {
  const CustodyAccountSummary({
    required this.accountId,
    required this.custodianName,
    required this.totalValueUsd,
    required this.cashBalanceUsd,
    required this.securitiesValueUsd,
    required this.positionCount,
    this.marginUsedUsd = 0.0,
  });

  final String accountId;
  final String custodianName;
  final double totalValueUsd;
  final double cashBalanceUsd;
  final double securitiesValueUsd;
  final int positionCount;
  final double marginUsedUsd;

  double get cashPercent =>
      totalValueUsd == 0 ? 0 : cashBalanceUsd / totalValueUsd * 100;
  bool get isMarginAccount => marginUsedUsd > 0;
  bool get isLargeCash => cashPercent >= 20;

  @override
  List<Object?> get props => [
    accountId,
    custodianName,
    totalValueUsd,
    cashBalanceUsd,
    securitiesValueUsd,
    positionCount,
    marginUsedUsd,
  ];
}
