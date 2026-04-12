import 'package:equatable/equatable.dart';

/// Over-the-air update metadata manifest (S546).
class AppUpdateManifest extends Equatable {
  const AppUpdateManifest({
    required this.currentVersion,
    required this.latestVersion,
    required this.minRequiredVersion,
    required this.releaseNotes,
    required this.downloadUrlAndroid,
    required this.downloadUrlWindows,
    this.isMandatory = false,
  });

  final String currentVersion;
  final String latestVersion;
  final String minRequiredVersion;
  final String releaseNotes;
  final String downloadUrlAndroid;
  final String downloadUrlWindows;
  final bool isMandatory;

  bool get isUpdateAvailable => latestVersion != currentVersion;
  bool get hasReleaseNotes => releaseNotes.isNotEmpty;
  bool get hasAndroidDownload => downloadUrlAndroid.isNotEmpty;

  @override
  List<Object?> get props => [
    currentVersion,
    latestVersion,
    minRequiredVersion,
    releaseNotes,
    downloadUrlAndroid,
    downloadUrlWindows,
    isMandatory,
  ];
}
