import 'package:equatable/equatable.dart';

/// Severity level of a single diagnostic entry.
enum DiagnosticSeverity { ok, warning, critical }

/// A single named diagnostic measurement.
class DiagnosticEntry extends Equatable {
  const DiagnosticEntry({
    required this.key,
    required this.value,
    required this.severity,
    this.detail,
  });

  final String key;
  final String value;
  final DiagnosticSeverity severity;
  final String? detail;

  bool get isHealthy => severity == DiagnosticSeverity.ok;

  @override
  List<Object?> get props => [key, value, severity, detail];
}

/// Point-in-time report of the application's runtime health.
class AppDiagnosticReport extends Equatable {
  const AppDiagnosticReport({
    required this.entries,
    required this.generatedAt,
    required this.appVersion,
  });

  final List<DiagnosticEntry> entries;
  final DateTime generatedAt;
  final String appVersion;

  bool get isHealthy =>
      entries.every((e) => e.severity != DiagnosticSeverity.critical);

  List<DiagnosticEntry> get criticalEntries =>
      entries.where((e) => e.severity == DiagnosticSeverity.critical).toList();

  List<DiagnosticEntry> get warningEntries =>
      entries.where((e) => e.severity == DiagnosticSeverity.warning).toList();

  DiagnosticSeverity get overallSeverity {
    if (criticalEntries.isNotEmpty) return DiagnosticSeverity.critical;
    if (warningEntries.isNotEmpty) return DiagnosticSeverity.warning;
    return DiagnosticSeverity.ok;
  }

  @override
  List<Object?> get props => [entries, generatedAt, appVersion];
}
