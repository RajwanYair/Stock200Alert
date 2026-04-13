import 'package:equatable/equatable.dart';

/// User session record — app login session with termination reason.
enum SessionTerminationReason {
  userLogout,
  timeout,
  appCrash,
  backgroundKill,
  deviceRestart,
}

class UserSessionRecord extends Equatable {
  const UserSessionRecord({
    required this.sessionId,
    required this.startedAt,
    required this.durationSeconds,
    required this.terminationReason,
    required this.screenCount,
  });

  final String sessionId;
  final DateTime startedAt;
  final int durationSeconds;
  final SessionTerminationReason terminationReason;
  final int screenCount;

  UserSessionRecord copyWith({
    String? sessionId,
    DateTime? startedAt,
    int? durationSeconds,
    SessionTerminationReason? terminationReason,
    int? screenCount,
  }) => UserSessionRecord(
    sessionId: sessionId ?? this.sessionId,
    startedAt: startedAt ?? this.startedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    terminationReason: terminationReason ?? this.terminationReason,
    screenCount: screenCount ?? this.screenCount,
  );

  @override
  List<Object?> get props => [
    sessionId,
    startedAt,
    durationSeconds,
    terminationReason,
    screenCount,
  ];
}
