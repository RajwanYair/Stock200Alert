import 'package:equatable/equatable.dart';

/// A bracket order linking an entry, profit-target, and stop-loss (S459).
class BracketOrderConfig extends Equatable {
  const BracketOrderConfig({
    required this.bracketId,
    required this.ticker,
    required this.entryPrice,
    required this.profitTargetPrice,
    required this.stopLossPrice,
    required this.quantity,
    this.isLong = true,
  });

  final String bracketId;
  final String ticker;
  final double entryPrice;
  final double profitTargetPrice;
  final double stopLossPrice;
  final int quantity;
  final bool isLong;

  double get riskPerShare => (entryPrice - stopLossPrice).abs();
  double get rewardPerShare => (profitTargetPrice - entryPrice).abs();
  double get riskRewardRatio =>
      riskPerShare > 0 ? rewardPerShare / riskPerShare : 0.0;
  bool get isFavorableRiskReward => riskRewardRatio >= 2.0;

  @override
  List<Object?> get props => [
    bracketId,
    ticker,
    entryPrice,
    profitTargetPrice,
    stopLossPrice,
    quantity,
    isLong,
  ];
}
