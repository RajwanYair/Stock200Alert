import 'package:equatable/equatable.dart';

/// A snapshot of the application's configuration at a point in time.
///
/// Supports serialization for export, import, and device-sync workflows.
/// All fields are plain Dart primitives or collections so the snapshot
/// can be serialized without external codec dependencies.
class AppConfigSnapshot extends Equatable {
  /// Creates an [AppConfigSnapshot].
  const AppConfigSnapshot({
    required this.snapshotId,
    required this.appVersion,
    required this.capturedAt,
    required this.settings,
    this.label,
  });

  /// Unique identifier for this snapshot (UUID or timestamp-based).
  final String snapshotId;

  /// Application version string at capture time (e.g. `'2.6.0+20'`).
  final String appVersion;

  /// Wall-clock time when the snapshot was captured.
  final DateTime capturedAt;

  /// Flat key-value map of all serializable settings.
  ///
  /// Values are typically `String`, `int`, `double`, or `bool`.
  final Map<String, Object> settings;

  /// Optional human-readable label (e.g. `'Pre-migration backup'`).
  final String? label;

  /// Returns `true` when the snapshot carries at least one setting.
  bool get hasSettings => settings.isNotEmpty;

  /// Returns the number of stored settings.
  int get settingCount => settings.length;

  @override
  List<Object?> get props => [
    snapshotId,
    appVersion,
    capturedAt,
    settings,
    label,
  ];
}
