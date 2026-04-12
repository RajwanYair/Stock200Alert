import 'package:equatable/equatable.dart';

/// Exchange circuit-breaker trigger level (S509).
enum CircuitBreakerLevel { level1, level2, level3 }

/// Current circuit-breaker status for a market or ticker (S509).
class CircuitBreakerStatus extends Equatable {
  const CircuitBreakerStatus({
    required this.marketId,
    required this.isTriggered,
    this.level,
    required this.haltDurationSeconds,
    this.resumeAtMs,
  });

  final String marketId;
  final bool isTriggered;

  /// Null when not triggered.
  final CircuitBreakerLevel? level;

  /// Duration of the halt in seconds.
  final int haltDurationSeconds;

  /// Epoch milliseconds when trading resumes (null if undetermined).
  final int? resumeAtMs;

  bool get isLevel3 => level == CircuitBreakerLevel.level3;
  bool get hasKnownResumeTime => resumeAtMs != null;
  bool get isLongHalt => haltDurationSeconds >= 900;

  @override
  List<Object?> get props => [
    marketId,
    isTriggered,
    level,
    haltDurationSeconds,
    resumeAtMs,
  ];
}
