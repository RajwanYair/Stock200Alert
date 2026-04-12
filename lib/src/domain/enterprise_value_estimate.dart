import 'package:equatable/equatable.dart';

/// Enterprise value estimate with EV/EBITDA multiple (S544).
class EnterpriseValueEstimate extends Equatable {
  const EnterpriseValueEstimate({
    required this.ticker,
    required this.marketCapUsd,
    required this.totalDebtUsd,
    required this.cashUsd,
    required this.ebitdaUsd,
    required this.evToEbitdaMultiple,
  });

  final String ticker;
  final double marketCapUsd;
  final double totalDebtUsd;
  final double cashUsd;
  final double ebitdaUsd;

  /// EV / EBITDA valuation multiple.
  final double evToEbitdaMultiple;

  double get enterpriseValueUsd => marketCapUsd + totalDebtUsd - cashUsd;
  bool get isCheap => evToEbitdaMultiple <= 12;
  bool get isExpensive => evToEbitdaMultiple >= 25;
  bool get isNegativeEbitda => ebitdaUsd < 0;

  @override
  List<Object?> get props => [
    ticker,
    marketCapUsd,
    totalDebtUsd,
    cashUsd,
    ebitdaUsd,
    evToEbitdaMultiple,
  ];
}
