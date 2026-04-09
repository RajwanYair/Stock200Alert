/// Tier Feature Gate — evaluates per-feature access decisions based on the
/// user's current subscription tier (v2.0).
library;

import 'package:equatable/equatable.dart';

import 'subscription_tier.dart';

/// Reason code explaining a gate denial.
enum UpgradeReason {
  /// Feature requires the Pro tier.
  requiresPro,

  /// Feature requires the Enterprise tier.
  requiresEnterprise,

  /// Feature is in beta — invitation only.
  betaInviteOnly,

  /// User has exceeded their tier's usage quota.
  quotaExceeded,
}

/// The result of evaluating access to a specific [TierFeature].
class GateDecision extends Equatable {
  const GateDecision._({
    required this.feature,
    required this.allowed,
    this.upgradeReason,
    this.upgradePrompt,
  });

  /// Creates an allowed access decision.
  factory GateDecision.allowed(TierFeature feature) =>
      GateDecision._(feature: feature, allowed: true);

  /// Creates a denied access decision with an optional [upgradeReason] and
  /// user-facing [upgradePrompt].
  factory GateDecision.denied(
    TierFeature feature, {
    required UpgradeReason upgradeReason,
    String? upgradePrompt,
  }) => GateDecision._(
    feature: feature,
    allowed: false,
    upgradeReason: upgradeReason,
    upgradePrompt: upgradePrompt,
  );

  final TierFeature feature;
  final bool allowed;
  final UpgradeReason? upgradeReason;

  /// Short message shown in the UI when access is denied.
  final String? upgradePrompt;

  @override
  List<Object?> get props => [feature, allowed, upgradeReason, upgradePrompt];
}

/// Evaluates [GateDecision]s for a given [SubscriptionTier].
class TierFeatureGate extends Equatable {
  const TierFeatureGate({required this.tier});

  final SubscriptionTier tier;

  /// Returns a [GateDecision] for [feature] based on the current [tier].
  GateDecision evaluate(TierFeature feature) {
    if (tier.hasFeature(feature)) return GateDecision.allowed(feature);

    final UpgradeReason reason = tier.tier == AppTier.free
        ? UpgradeReason.requiresPro
        : UpgradeReason.requiresEnterprise;

    return GateDecision.denied(
      feature,
      upgradeReason: reason,
      upgradePrompt: 'Upgrade to unlock ${feature.name}',
    );
  }

  @override
  List<Object?> get props => [tier];
}
