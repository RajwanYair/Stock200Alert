import 'package:equatable/equatable.dart';

/// A custom What-If stress scenario definition used for portfolio stress testing.
///
/// Defines hypothetical market conditions (equity sell-off, rate shock,
/// volatility spike) applied to portfolio positions to estimate impact.
class PortfolioStressScenario extends Equatable {
  /// Creates a [PortfolioStressScenario].
  const PortfolioStressScenario({
    required this.scenarioId,
    required this.name,
    required this.description,
    required this.marketDropPercent,
    required this.interestRateChangeBps,
    required this.volatilityMultiplier,
  });

  /// Unique identifier for this scenario.
  final String scenarioId;

  /// Short display name (e.g. `'2008 Crisis Replay'`).
  final String name;

  /// Detailed description of what this scenario models.
  final String description;

  /// Assumed market-wide equity drawdown in percent (positive = drop).
  final double marketDropPercent;

  /// Assumed change in the risk-free rate in basis points
  /// (positive = rate rise; negative = cut).
  final int interestRateChangeBps;

  /// Multiplier applied to current implied volatility (e.g. 2.0 = doubled).
  final double volatilityMultiplier;

  /// Returns `true` when the scenario assumes an equity drawdown > 20%.
  bool get isSevere => marketDropPercent > 20.0;

  /// Returns `true` when the scenario involves a rate change >= 100 bps.
  bool get isRateStress => interestRateChangeBps.abs() >= 100;

  /// Returns `true` when the scenario models a bearish market environment.
  bool get isBearish => marketDropPercent > 0.0;

  @override
  List<Object?> get props => [
    scenarioId,
    name,
    description,
    marketDropPercent,
    interestRateChangeBps,
    volatilityMultiplier,
  ];
}
