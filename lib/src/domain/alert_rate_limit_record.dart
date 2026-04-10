import 'package:equatable/equatable.dart';

/// Interval granularity for alert frequency enforcement.
enum AlertRateLimitInterval { perMinute, perHour, perDay }

/// Per-ticker per-method alert rate limit enforcement record.
class AlertRateLimitRecord extends Equatable {
  const AlertRateLimitRecord({
    required this.symbol,
    required this.methodName,
    required this.interval,
    required this.maxAlerts,
    required this.alertsFired,
    required this.windowStart,
  }) : assert(maxAlerts > 0, 'maxAlerts must be > 0'),
       assert(alertsFired >= 0, 'alertsFired must be >= 0');

  final String symbol;
  final String methodName;
  final AlertRateLimitInterval interval;
  final int maxAlerts;
  final int alertsFired;
  final DateTime windowStart;

  bool get isExhausted => alertsFired >= maxAlerts;
  int get remaining => maxAlerts - alertsFired;
  bool get hasCapacity => !isExhausted;

  AlertRateLimitRecord increment() => AlertRateLimitRecord(
    symbol: symbol,
    methodName: methodName,
    interval: interval,
    maxAlerts: maxAlerts,
    alertsFired: alertsFired + 1,
    windowStart: windowStart,
  );

  AlertRateLimitRecord reset(DateTime newWindowStart) => AlertRateLimitRecord(
    symbol: symbol,
    methodName: methodName,
    interval: interval,
    maxAlerts: maxAlerts,
    alertsFired: 0,
    windowStart: newWindowStart,
  );

  @override
  List<Object?> get props => [
    symbol,
    methodName,
    interval,
    maxAlerts,
    alertsFired,
    windowStart,
  ];
}
