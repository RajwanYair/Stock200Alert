/// REST API Request Log — records request/response details for the in-app
/// REST API (`/api/alerts`, `/api/config`, `/api/metrics`) (future backlog).
library;

import 'package:equatable/equatable.dart';

/// HTTP method for the request.
enum ApiHttpMethod { get, post, put, patch, delete }

/// A single logged request/response entry.
class ApiRequestEntry extends Equatable {
  const ApiRequestEntry({
    required this.requestId,
    required this.method,
    required this.path,
    required this.statusCode,
    required this.durationMs,
    required this.requestedAt,
    this.clientIp,
    this.errorMessage,
  }) : assert(
         statusCode >= 100 && statusCode < 600,
         'statusCode must be a valid HTTP status',
       ),
       assert(durationMs >= 0, 'durationMs must be non-negative');

  final String requestId;
  final ApiHttpMethod method;
  final String path;
  final int statusCode;
  final int durationMs;
  final DateTime requestedAt;
  final String? clientIp;
  final String? errorMessage;

  bool get isSuccess => statusCode >= 200 && statusCode < 300;
  bool get isError => statusCode >= 400;

  @override
  List<Object?> get props => [
    requestId,
    method,
    path,
    statusCode,
    durationMs,
    requestedAt,
    clientIp,
    errorMessage,
  ];
}

/// Rolling log of recent API request entries with basic aggregation helpers.
class RestApiRequestLog extends Equatable {
  const RestApiRequestLog({required this.entries, required this.maxEntries})
    : assert(maxEntries > 0, 'maxEntries must be positive');

  /// Creates a new empty log with the given [maxEntries] capacity.
  factory RestApiRequestLog.empty({int maxEntries = 500}) =>
      RestApiRequestLog(entries: const [], maxEntries: maxEntries);

  final List<ApiRequestEntry> entries;
  final int maxEntries;

  /// Returns the fraction of entries where [isSuccess] is true.
  double get successRate {
    if (entries.isEmpty) return 1.0;
    final int successes = entries
        .where((ApiRequestEntry e) => e.isSuccess)
        .length;
    return successes / entries.length;
  }

  /// Returns the average response time in milliseconds.
  double get avgDurationMs {
    if (entries.isEmpty) return 0.0;
    final int total = entries.fold(
      0,
      (int acc, ApiRequestEntry e) => acc + e.durationMs,
    );
    return total / entries.length;
  }

  /// Returns a new log with [entry] appended, trimmed to [maxEntries].
  RestApiRequestLog withEntry(ApiRequestEntry entry) {
    final List<ApiRequestEntry> updated = [...entries, entry];
    final List<ApiRequestEntry> trimmed = updated.length > maxEntries
        ? updated.sublist(updated.length - maxEntries)
        : updated;
    return RestApiRequestLog(entries: trimmed, maxEntries: maxEntries);
  }

  @override
  List<Object?> get props => [entries, maxEntries];
}
