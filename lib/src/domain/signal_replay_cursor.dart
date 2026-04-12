import 'package:equatable/equatable.dart';

/// Cursor position within a signal replay session (S470).
class SignalReplayCursor extends Equatable {
  const SignalReplayCursor({
    required this.sessionId,
    required this.ticker,
    required this.totalCandles,
    required this.currentIndex,
    required this.signalsFiredCount,
    this.isPaused = false,
  });

  final String sessionId;
  final String ticker;
  final int totalCandles;
  final int currentIndex;
  final int signalsFiredCount;
  final bool isPaused;

  double get progressPercent =>
      totalCandles > 0 ? currentIndex / totalCandles * 100 : 0.0;
  bool get isComplete => currentIndex >= totalCandles;
  bool get isRunning => !isPaused && !isComplete;

  @override
  List<Object?> get props => [
    sessionId,
    ticker,
    totalCandles,
    currentIndex,
    signalsFiredCount,
    isPaused,
  ];
}
