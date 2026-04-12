import 'package:equatable/equatable.dart';

/// Migration result status for a database schema change (S495).
enum MigrationStatus { pending, running, completed, failed, skipped }

/// Audit log entry for a database schema migration (S495).
class DatabaseMigrationLog extends Equatable {
  const DatabaseMigrationLog({
    required this.migrationId,
    required this.fromVersion,
    required this.toVersion,
    required this.status,
    required this.durationMs,
    this.errorMessage = '',
  });

  final String migrationId;
  final int fromVersion;
  final int toVersion;
  final MigrationStatus status;

  /// Elapsed time in milliseconds.
  final int durationMs;
  final String errorMessage;

  bool get isSuccess => status == MigrationStatus.completed;
  bool get isFailed => status == MigrationStatus.failed;
  bool get hasError => errorMessage.isNotEmpty;
  bool get isSlowMigration => durationMs > 5000;

  @override
  List<Object?> get props => [
    migrationId,
    fromVersion,
    toVersion,
    status,
    durationMs,
    errorMessage,
  ];
}
