import 'package:equatable/equatable.dart';

/// Configuration for a feature tour (multi-step in-app walkthrough) (S487).
class FeatureTourConfig extends Equatable {
  const FeatureTourConfig({
    required this.tourId,
    required this.tourName,
    required this.stepCount,
    this.isSkippable = true,
    this.showProgressBar = true,
    this.repeatOnVersionUpgrade = false,
  });

  final String tourId;
  final String tourName;
  final int stepCount;

  /// Whether the user can skip the entire tour.
  final bool isSkippable;
  final bool showProgressBar;

  /// If true, the tour re-runs when the app version upgrades.
  final bool repeatOnVersionUpgrade;

  bool get isSingleStep => stepCount == 1;
  bool get isMultiStep => stepCount > 1;

  @override
  List<Object?> get props => [
    tourId,
    tourName,
    stepCount,
    isSkippable,
    showProgressBar,
    repeatOnVersionUpgrade,
  ];
}
