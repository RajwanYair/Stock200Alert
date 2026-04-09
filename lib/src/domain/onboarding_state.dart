import 'package:equatable/equatable.dart';

/// Steps presented to a first-time user.
enum OnboardingStep {
  addFirstTicker,
  configureSmaAlert,
  selectProfile,
  enableNotifications,
  reviewWatchlist,
}

/// Tracks progress through the first-run onboarding checklist.
class OnboardingState extends Equatable {
  const OnboardingState({
    required this.completedSteps,
    this.skippedSteps = const [],
    this.startedAt,
  });

  const OnboardingState.fresh()
    : completedSteps = const [],
      skippedSteps = const [],
      startedAt = null;

  final List<OnboardingStep> completedSteps;
  final List<OnboardingStep> skippedSteps;
  final DateTime? startedAt;

  bool isCompleted(OnboardingStep step) => completedSteps.contains(step);
  bool isSkipped(OnboardingStep step) => skippedSteps.contains(step);

  /// Fraction of steps completed (0.0–1.0).
  double get completionPct {
    final total = OnboardingStep.values.length;
    return total == 0 ? 1.0 : completedSteps.length / total;
  }

  bool get isFullyComplete => OnboardingStep.values.every(
    (s) => completedSteps.contains(s) || skippedSteps.contains(s),
  );

  OnboardingStep? get nextStep => OnboardingStep.values
      .where((s) => !isCompleted(s) && !isSkipped(s))
      .firstOrNull;

  OnboardingState completeStep(OnboardingStep step) => OnboardingState(
    completedSteps: [...completedSteps, step],
    skippedSteps: skippedSteps,
    startedAt: startedAt,
  );

  OnboardingState skipStep(OnboardingStep step) => OnboardingState(
    completedSteps: completedSteps,
    skippedSteps: [...skippedSteps, step],
    startedAt: startedAt,
  );

  @override
  List<Object?> get props => [completedSteps, skippedSteps, startedAt];
}
