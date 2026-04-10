import 'package:equatable/equatable.dart';

/// Type of import session used to load tickers.
enum ImportSessionType { csvFile, pasteText, deepLink, qrCode, manualEntry }

/// Status of an import session.
enum ImportSessionStatus {
  pending,
  processing,
  completed,
  failed,
  partiallyCompleted,
}

/// A record of a single ticker import session.
class TickerImportSession extends Equatable {
  const TickerImportSession({
    required this.sessionId,
    required this.sessionType,
    required this.totalRequested,
    required this.totalImported,
    required this.totalFailed,
    required this.startedAt,
    this.status = ImportSessionStatus.pending,
    this.completedAt,
    this.errorMessage,
  }) : assert(totalRequested >= 0, 'totalRequested must be >= 0'),
       assert(totalImported >= 0, 'totalImported must be >= 0'),
       assert(totalFailed >= 0, 'totalFailed must be >= 0');

  final String sessionId;
  final ImportSessionType sessionType;
  final int totalRequested;
  final int totalImported;
  final int totalFailed;
  final DateTime startedAt;
  final ImportSessionStatus status;
  final DateTime? completedAt;
  final String? errorMessage;

  bool get isComplete => status == ImportSessionStatus.completed;
  bool get isFailed => status == ImportSessionStatus.failed;
  bool get isPartial => status == ImportSessionStatus.partiallyCompleted;
  bool get hasErrors => totalFailed > 0;

  double get successRate =>
      totalRequested == 0 ? 1.0 : totalImported / totalRequested;

  Duration? get duration => completedAt?.difference(startedAt);

  @override
  List<Object?> get props => [
    sessionId,
    sessionType,
    totalRequested,
    totalImported,
    totalFailed,
    startedAt,
    status,
    completedAt,
    errorMessage,
  ];
}
