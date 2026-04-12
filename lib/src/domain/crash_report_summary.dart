import 'package:equatable/equatable.dart';

/// Aggregated crash analytics summary for a reporting period (S548).
class CrashReportSummary extends Equatable {
  const CrashReportSummary({
    required this.periodLabel,
    required this.appVersion,
    required this.totalCrashes,
    required this.affectedUsers,
    required this.crashFreeUserPercent,
    required this.topCrashReason,
    required this.generatedAtMs,
  });

  final String periodLabel;
  final String appVersion;
  final int totalCrashes;
  final int affectedUsers;

  /// Percent of users who did NOT experience a crash (0–100).
  final double crashFreeUserPercent;

  /// Most frequent crash reason or exception class.
  final String topCrashReason;

  /// Epoch milliseconds when this summary was generated.
  final int generatedAtMs;

  bool get isStable => crashFreeUserPercent >= 99.5;
  bool get hasCriticalInstability => crashFreeUserPercent < 95;
  bool get hasHighVolume => totalCrashes >= 100;

  @override
  List<Object?> get props => [
    periodLabel,
    appVersion,
    totalCrashes,
    affectedUsers,
    crashFreeUserPercent,
    topCrashReason,
    generatedAtMs,
  ];
}
