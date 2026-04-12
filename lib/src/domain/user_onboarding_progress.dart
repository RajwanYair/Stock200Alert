import 'package:equatable/equatable.dart';

/// Tracks how far a user has progressed through first-run onboarding (S489).
class UserOnboardingProgress extends Equatable {
  const UserOnboardingProgress({
    required this.userId,
    required this.totalSteps,
    required this.completedSteps,
    this.isOnboardingDismissed = false,
    this.hasAddedFirstTicker = false,
  });

  final String userId;
  final int totalSteps;
  final int completedSteps;
  final bool isOnboardingDismissed;

  /// True once the user has added at least one ticker to their watchlist.
  final bool hasAddedFirstTicker;

  double get progressPercent =>
      totalSteps == 0 ? 100.0 : completedSteps / totalSteps * 100;

  bool get isComplete => completedSteps >= totalSteps;
  bool get isStarted => completedSteps > 0;

  @override
  List<Object?> get props => [
    userId,
    totalSteps,
    completedSteps,
    isOnboardingDismissed,
    hasAddedFirstTicker,
  ];
}
