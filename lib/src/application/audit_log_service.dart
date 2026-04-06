/// Audit Log Service — records every user-initiated settings change.
///
/// Call [record] after each settings mutation so the user can see a history
/// of what changed, when, and from where (which screen).
///
/// Entries are stored in the `audit_log` table (schema v12) and exposed
/// through the `/audit-log` screen.
library;

import 'package:drift/drift.dart';
import 'package:logger/logger.dart';

import '../data/database/database.dart';
import '../domain/entities.dart';

class AuditLogService {
  AuditLogService({required this.db, Logger? logger})
    : _logger = logger ?? Logger();

  final AppDatabase db;
  final Logger _logger;

  /// Records a single settings change.
  ///
  /// [field] — the name of the field that changed (e.g. 'refreshIntervalMinutes')
  /// [oldValue] — previous value stringified
  /// [newValue] — new value stringified
  /// [screen] — originating screen name (e.g. 'SettingsScreen')
  Future<void> record({
    required String field,
    required String oldValue,
    required String newValue,
    String screen = '',
  }) async {
    _logger.d('AuditLog: $screen.$field: "$oldValue" → "$newValue"');
    await db.insertAuditLog(
      AuditLogTableCompanion(
        timestamp: Value(DateTime.now()),
        field: Value(field),
        oldValue: Value(oldValue),
        newValue: Value(newValue),
        screen: Value(screen),
      ),
    );
  }

  /// Returns the most recent [limit] audit entries (newest first).
  Future<List<AuditLogEntry>> getLog({int limit = 200}) async {
    final rows = await db.getAuditLog(limit: limit);
    return rows
        .map(
          (r) => AuditLogEntry(
            id: r.id,
            timestamp: r.timestamp,
            field: r.field,
            oldValue: r.oldValue,
            newValue: r.newValue,
            screen: r.screen,
          ),
        )
        .toList();
  }

  /// Deletes all entries from the audit log.
  Future<void> clear() => db.clearAuditLog();
}
