import 'package:equatable/equatable.dart';

/// A staking reward record for a validator/protocol position (S493).
class StakingRewardRecord extends Equatable {
  const StakingRewardRecord({
    required this.recordId,
    required this.validatorId,
    required this.assetSymbol,
    required this.rewardAmount,
    required this.epochNumber,
    required this.aprPercent,
    this.isClaimed = false,
  });

  final String recordId;
  final String validatorId;
  final String assetSymbol;

  /// Reward amount in native token units.
  final double rewardAmount;
  final int epochNumber;
  final double aprPercent;
  final bool isClaimed;

  bool get isHighApr => aprPercent >= 10.0;
  bool get isPending => !isClaimed;
  bool get hasSignificantReward => rewardAmount >= 0.001;

  @override
  List<Object?> get props => [
    recordId,
    validatorId,
    assetSymbol,
    rewardAmount,
    epochNumber,
    aprPercent,
    isClaimed,
  ];
}
