import 'package:equatable/equatable.dart';

/// Configuration controlling when a method signal expires (S466).
class SignalExpiryConfig extends Equatable {
  const SignalExpiryConfig({
    required this.configId,
    required this.methodName,
    required this.maxAgeSeconds,
    this.invalidateOnNewCandle = true,
    this.invalidateOnOppositeSignal = true,
  });

  final String configId;
  final String methodName;

  /// Maximum age in seconds before the signal is considered stale.
  final int maxAgeSeconds;

  /// Invalidate when a new candle closes.
  final bool invalidateOnNewCandle;

  /// Invalidate when the opposite direction signal fires.
  final bool invalidateOnOppositeSignal;

  bool get isAggressiveExpiry =>
      maxAgeSeconds < 3600 || invalidateOnOppositeSignal;
  bool get requiresCandelAlignment =>
      invalidateOnNewCandle && invalidateOnOppositeSignal;

  @override
  List<Object?> get props => [
    configId,
    methodName,
    maxAgeSeconds,
    invalidateOnNewCandle,
    invalidateOnOppositeSignal,
  ];
}
