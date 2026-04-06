/// Crash Log Service — Persistent crash logging to disk.
///
/// Writes detailed crash reports to `crash.log` in the app's data directory.
/// Each entry includes: timestamp (UTC), error type, message, full stack trace,
/// platform info, and Dart VM details.
///
/// The log file is kept below 1 MB — older entries are trimmed on write.
library;

import 'dart:io' show File, FileMode, Platform;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

const _maxLogBytes = 1024 * 1024; // 1 MB
final _separator = '\n${'=' * 72}\n';

class CrashLogService {
  CrashLogService._();
  static final instance = CrashLogService._();

  File? _logFile;

  /// Initialize the log file path. Must be called before [write].
  Future<void> initialize() async {
    try {
      final dir = await getApplicationSupportDirectory();
      _logFile = File(p.join(dir.path, 'crash.log'));
    } catch (_) {
      // Fallback: write next to the executable
      _logFile = File(
        p.join(p.dirname(Platform.resolvedExecutable), 'crash.log'),
      );
    }
  }

  /// Path to the crash log file, or null if not yet initialized.
  String? get logPath => _logFile?.path;

  /// Write a crash entry with full diagnostic detail.
  Future<void> write({
    required Object error,
    required StackTrace stackTrace,
    String? context,
  }) async {
    final file = _logFile;
    if (file == null) return; // Not yet initialized — drop silently

    try {
      final buf = StringBuffer()
        ..writeln(_separator)
        ..writeln('CRASH REPORT')
        ..writeln('Timestamp : ${DateTime.now().toUtc().toIso8601String()}')
        ..writeln('Platform  : ${_platformInfo()}')
        ..writeln('Dart      : ${Platform.version}')
        ..writeln(
          'App mode  : ${kReleaseMode
              ? 'release'
              : kProfileMode
              ? 'profile'
              : 'debug'}',
        );

      if (context != null) {
        buf.writeln('Context   : $context');
      }

      buf
        ..writeln('Error type: ${error.runtimeType}')
        ..writeln('Message   : $error')
        ..writeln()
        ..writeln('--- Stack Trace ---')
        ..writeln(stackTrace)
        ..writeln(_separator);

      // Append — create if missing
      await file.create(recursive: true);
      await file.writeAsString(
        buf.toString(),
        mode: FileMode.append,
        flush: true,
      );

      // Trim if > 1 MB: keep the last half
      await _trimIfNeeded(file);
    } catch (_) {
      // Crash logger must never throw
    }
  }

  /// Write a Flutter framework error (FlutterError / ErrorDetails).
  Future<void> writeFlutterError(FlutterErrorDetails details) async {
    await write(
      error: details.exception,
      stackTrace: details.stack ?? StackTrace.current,
      context: details.context?.toDescription(),
    );
  }

  Future<void> _trimIfNeeded(File file) async {
    try {
      final stat = await file.stat();
      if (stat.size > _maxLogBytes) {
        final content = await file.readAsString();
        // Keep last 50% of content
        final trimmed = content.substring(content.length ~/ 2);
        await file.writeAsString(
          '[...truncated — log exceeded 1 MB...]\n$trimmed',
          flush: true,
        );
      }
    } catch (_) {
      // Best-effort
    }
  }

  static String _platformInfo() {
    final parts = <String>[];
    if (Platform.isWindows) parts.add('Windows');
    if (Platform.isAndroid) parts.add('Android');
    if (Platform.isIOS) parts.add('iOS');
    if (Platform.isMacOS) parts.add('macOS');
    if (Platform.isLinux) parts.add('Linux');
    parts.add(Platform.operatingSystemVersion);
    parts.add('locale=${Platform.localeName}');
    return parts.join(' · ');
  }
}
