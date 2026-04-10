import 'package:equatable/equatable.dart';

/// A single tier in a progressive achievement system.
class AchievementTier extends Equatable {
  const AchievementTier({
    required this.name,
    required this.requiredPoints,
    this.badgeIcon,
  }) : assert(requiredPoints >= 0, 'requiredPoints must be >= 0');

  final String name;
  final int requiredPoints;
  final String? badgeIcon;

  @override
  List<Object?> get props => [name, requiredPoints, badgeIcon];
}

/// An in-app user achievement with progress tracking.
class UserAchievement extends Equatable {
  const UserAchievement({
    required this.achievementId,
    required this.title,
    required this.description,
    required this.currentPoints,
    required this.tiers,
    this.isUnlocked = false,
    this.unlockedAt,
  }) : assert(currentPoints >= 0, 'currentPoints must be >= 0'),
       assert(tiers.length > 0, 'tiers must not be empty');

  final String achievementId;
  final String title;
  final String description;
  final int currentPoints;
  final List<AchievementTier> tiers;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  /// The current tier the user has reached.
  AchievementTier? get currentTier {
    final reached = tiers
        .where((final AchievementTier t) => currentPoints >= t.requiredPoints)
        .toList();
    if (reached.isEmpty) return null;
    return reached.last;
  }

  /// Next tier not yet reached, or null if all tiers are complete.
  AchievementTier? get nextTier {
    final notReached = tiers
        .where((final AchievementTier t) => currentPoints < t.requiredPoints)
        .toList();
    if (notReached.isEmpty) return null;
    return notReached.first;
  }

  bool get isMaxTier => nextTier == null;

  /// Progress towards next tier as fraction (0.0–1.0).
  double get progressToNextTier {
    if (nextTier == null) return 1.0;
    final prev = currentTier?.requiredPoints ?? 0;
    final next = nextTier!.requiredPoints;
    if (next == prev) return 1.0;
    return (currentPoints - prev) / (next - prev);
  }

  @override
  List<Object?> get props => [
    achievementId,
    title,
    description,
    currentPoints,
    tiers,
    isUnlocked,
    unlockedAt,
  ];
}
