/// Walk-Forward Validator — pure domain utility.
///
/// Splits candle data into rolling train/test windows and runs a strategy
/// on each to validate out-of-sample consistency.
library;

import 'package:equatable/equatable.dart';

import 'backtest_engine.dart';
import 'backtest_result.dart';
import 'backtest_strategy.dart';
import 'entities.dart';

/// A single walk-forward window result.
class WalkForwardWindow extends Equatable {
  const WalkForwardWindow({
    required this.windowIndex,
    required this.trainResult,
    required this.testResult,
  });

  /// Index of this window (0-based).
  final int windowIndex;

  /// Backtest result on the training (in-sample) data.
  final BacktestResult trainResult;

  /// Backtest result on the test (out-of-sample) data.
  final BacktestResult testResult;

  /// Efficiency ratio: test return / train return.
  /// Values near 1.0 indicate consistent performance.
  double get efficiencyRatio {
    if (trainResult.totalReturnPercent == 0) return 0;
    return testResult.totalReturnPercent / trainResult.totalReturnPercent;
  }

  @override
  List<Object?> get props => [windowIndex, trainResult, testResult];
}

/// Summary of the walk-forward validation.
class WalkForwardSummary extends Equatable {
  const WalkForwardSummary({
    required this.ticker,
    required this.strategyName,
    required this.windows,
  });

  final String ticker;
  final String strategyName;
  final List<WalkForwardWindow> windows;

  /// Average out-of-sample return %.
  double get avgTestReturnPct {
    if (windows.isEmpty) return 0;
    final double sum = windows.fold<double>(
      0,
      (double s, WalkForwardWindow w) => s + w.testResult.totalReturnPercent,
    );
    return sum / windows.length;
  }

  /// Average efficiency ratio.
  double get avgEfficiencyRatio {
    if (windows.isEmpty) return 0;
    final double sum = windows.fold<double>(
      0,
      (double s, WalkForwardWindow w) => s + w.efficiencyRatio,
    );
    return sum / windows.length;
  }

  /// Whether the strategy is consistently profitable out-of-sample.
  bool get isConsistent =>
      windows.isNotEmpty &&
      windows.every(
        (WalkForwardWindow w) => w.testResult.totalReturnPercent > 0,
      );

  @override
  List<Object?> get props => [ticker, strategyName, windows];
}

/// Validates strategy robustness via rolling walk-forward windows.
class WalkForwardValidator {
  const WalkForwardValidator({this.trainRatio = 0.7, this.stepSize = 60});

  /// Fraction of each window used for training (0.0 – 1.0).
  final double trainRatio;

  /// Number of candles to step forward per window.
  final int stepSize;

  /// Run walk-forward validation on [candles].
  WalkForwardSummary validate({
    required String ticker,
    required BacktestStrategy strategy,
    required List<DailyCandle> candles,
    required int windowSize,
    List<String> Function(DailyCandle candle)? signalResolver,
    double startingEquity = 10000,
  }) {
    final List<WalkForwardWindow> windows = [];
    final BacktestEngine engine = BacktestEngine(
      startingEquity: startingEquity,
    );
    int windowIndex = 0;

    for (
      int start = 0;
      start + windowSize <= candles.length;
      start += stepSize
    ) {
      final List<DailyCandle> window = candles.sublist(
        start,
        start + windowSize,
      );
      final int splitAt = (window.length * trainRatio).round();
      if (splitAt < 2 || window.length - splitAt < 2) continue;

      final List<DailyCandle> trainData = window.sublist(0, splitAt);
      final List<DailyCandle> testData = window.sublist(splitAt);

      final BacktestResult trainResult = engine.run(
        ticker: ticker,
        strategy: strategy,
        candles: trainData,
        signalResolver: signalResolver,
      );
      final BacktestResult testResult = engine.run(
        ticker: ticker,
        strategy: strategy,
        candles: testData,
        signalResolver: signalResolver,
      );

      windows.add(
        WalkForwardWindow(
          windowIndex: windowIndex++,
          trainResult: trainResult,
          testResult: testResult,
        ),
      );
    }

    return WalkForwardSummary(
      ticker: ticker,
      strategyName: strategy.name,
      windows: windows,
    );
  }
}
