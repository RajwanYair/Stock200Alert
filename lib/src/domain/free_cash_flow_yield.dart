import 'package:equatable/equatable.dart';

/// Free cash flow yield calculation for a ticker (S543).
class FreeCashFlowYield extends Equatable {
  const FreeCashFlowYield({
    required this.ticker,
    required this.freeCashFlowUsd,
    required this.marketCapUsd,
    required this.enterpriseValueUsd,
    required this.fcfYieldPercent,
    required this.evFcfMultiple,
  });

  final String ticker;

  /// Trailing twelve-month free cash flow in USD.
  final double freeCashFlowUsd;
  final double marketCapUsd;
  final double enterpriseValueUsd;

  /// FCF / Market Cap × 100.
  final double fcfYieldPercent;

  /// Enterprise Value / FCF multiple.
  final double evFcfMultiple;

  bool get isHighYield => fcfYieldPercent >= 5;
  bool get isCheapOnFcf => evFcfMultiple <= 15;
  bool get isNegativeFcf => freeCashFlowUsd < 0;

  @override
  List<Object?> get props => [
    ticker,
    freeCashFlowUsd,
    marketCapUsd,
    enterpriseValueUsd,
    fcfYieldPercent,
    evFcfMultiple,
  ];
}
