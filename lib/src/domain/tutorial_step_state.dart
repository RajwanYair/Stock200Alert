import 'package:equatable/equatable.dart';

/// Completion state of a single in-app tutorial step (S486).
class TutorialStepState extends Equatable {
  const TutorialStepState({
    required this.stepId,
    required this.tutorialId,
    required this.stepIndex,
    required this.isCompleted,
    this.skippedByUser = false,
    this.timesViewed = 0,
  });

  final String stepId;
  final String tutorialId;

  /// Zero-based position within the tutorial flow.
  final int stepIndex;
  final bool isCompleted;
  final bool skippedByUser;
  final int timesViewed;

  bool get isFirstStep => stepIndex == 0;
  bool get wasEngaged => timesViewed > 0;
  bool get isDismissed => skippedByUser && !isCompleted;

  @override
  List<Object?> get props => [
    stepId,
    tutorialId,
    stepIndex,
    isCompleted,
    skippedByUser,
    timesViewed,
  ];
}
