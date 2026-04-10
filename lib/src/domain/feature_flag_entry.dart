import 'package:equatable/equatable.dart';

/// Status of a recurring feature flag in the app.
enum FeatureFlagStatus { enabled, disabled, rollout }

/// A feature flag entry controlling optional app functionality.
class FeatureFlagEntry extends Equatable {
  const FeatureFlagEntry({
    required this.key,
    required this.status,
    this.rolloutPercent = 100,
    this.description,
    this.enabledAt,
  }) : assert(
         rolloutPercent >= 0 && rolloutPercent <= 100,
         'rolloutPercent must be 0–100',
       );

  final String key;
  final FeatureFlagStatus status;

  /// Percentage of users receiving the feature (for rollout status).
  final int rolloutPercent;
  final String? description;
  final DateTime? enabledAt;

  bool get isEnabled => status == FeatureFlagStatus.enabled;
  bool get isDisabled => status == FeatureFlagStatus.disabled;
  bool get isRollout => status == FeatureFlagStatus.rollout;
  bool get hasDescription => description != null && description!.isNotEmpty;

  FeatureFlagEntry enable() => FeatureFlagEntry(
    key: key,
    status: FeatureFlagStatus.enabled,
    rolloutPercent: 100,
    description: description,
    enabledAt: enabledAt,
  );

  FeatureFlagEntry disable() => FeatureFlagEntry(
    key: key,
    status: FeatureFlagStatus.disabled,
    rolloutPercent: 0,
    description: description,
    enabledAt: enabledAt,
  );

  @override
  List<Object?> get props => [
    key,
    status,
    rolloutPercent,
    description,
    enabledAt,
  ];
}

/// A registry of app feature flags.
class FeatureFlagRegistry extends Equatable {
  const FeatureFlagRegistry({required this.flags});

  final List<FeatureFlagEntry> flags;

  int get count => flags.length;
  int get enabledCount =>
      flags.where((final FeatureFlagEntry f) => f.isEnabled).length;

  bool isEnabled(String key) =>
      flags.any((final FeatureFlagEntry f) => f.key == key && f.isEnabled);

  FeatureFlagEntry? flagFor(String key) =>
      flags.where((final FeatureFlagEntry f) => f.key == key).isEmpty
      ? null
      : flags.firstWhere((final FeatureFlagEntry f) => f.key == key);

  @override
  List<Object?> get props => [flags];
}
