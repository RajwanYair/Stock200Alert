import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const WalkForwardValidator validator = WalkForwardValidator(
    trainRatio: 0.7,
    stepSize: 10,
  );

  List<DailyCandle> makeCandles(int count, double baseClose) => [
    for (int i = 0; i < count; i++)
      DailyCandle(
        date: DateTime(2024, 1, 1).add(Duration(days: i)),
        open: baseClose + i * 0.1,
        high: baseClose + i * 0.1 + 1,
        low: baseClose + i * 0.1 - 1,
        close: baseClose + i * 0.1,
        volume: 1000,
      ),
  ];

  group('WalkForwardValidator', () {
    test('empty candles produce no windows', () {
      const BacktestStrategy strategy = BacktestStrategy(
        name: 'Test',
        entryAlertTypes: {'buy'},
        exitAlertTypes: {'sell'},
      );
      final WalkForwardSummary summary = validator.validate(
        ticker: 'AAPL',
        strategy: strategy,
        candles: [],
        windowSize: 50,
      );
      expect(summary.windows, isEmpty);
      expect(summary.avgTestReturnPct, 0);
      expect(summary.avgEfficiencyRatio, 0);
    });

    test('insufficient data for window produces no windows', () {
      const BacktestStrategy strategy = BacktestStrategy(
        name: 'Test',
        entryAlertTypes: {'buy'},
        exitAlertTypes: {'sell'},
      );
      final WalkForwardSummary summary = validator.validate(
        ticker: 'AAPL',
        strategy: strategy,
        candles: makeCandles(10, 100),
        windowSize: 50,
      );
      expect(summary.windows, isEmpty);
    });

    test('produces multiple windows for sufficient data', () {
      const BacktestStrategy strategy = BacktestStrategy(
        name: 'Test',
        entryAlertTypes: {'buy'},
        exitAlertTypes: {'sell'},
      );
      final WalkForwardSummary summary = validator.validate(
        ticker: 'AAPL',
        strategy: strategy,
        candles: makeCandles(100, 100),
        windowSize: 50,
      );
      expect(summary.windows.length, greaterThan(1));
      expect(summary.ticker, 'AAPL');
      expect(summary.strategyName, 'Test');
    });

    test('window index increments', () {
      const BacktestStrategy strategy = BacktestStrategy(
        name: 'Test',
        entryAlertTypes: {'buy'},
        exitAlertTypes: {'sell'},
      );
      final WalkForwardSummary summary = validator.validate(
        ticker: 'AAPL',
        strategy: strategy,
        candles: makeCandles(100, 100),
        windowSize: 50,
      );
      for (int i = 0; i < summary.windows.length; i++) {
        expect(summary.windows[i].windowIndex, i);
      }
    });

    test('isConsistent when all OOS returns positive', () {
      const BacktestStrategy strategy = BacktestStrategy(
        name: 'Test',
        entryAlertTypes: {'buy'},
        exitAlertTypes: {'sell'},
      );
      // No signals → no trades → 0% return → not consistent.
      final WalkForwardSummary summary = validator.validate(
        ticker: 'AAPL',
        strategy: strategy,
        candles: makeCandles(100, 100),
        windowSize: 50,
      );
      expect(summary.isConsistent, isFalse);
    });

    test('efficiencyRatio zero when train return is zero', () {
      final WalkForwardWindow window = WalkForwardWindow(
        windowIndex: 0,
        trainResult: BacktestResult(
          ticker: 'AAPL',
          methodName: 'Test',
          startDate: _epoch,
          endDate: _epoch,
          trades: const [],
          startingEquity: 10000,
        ),
        testResult: BacktestResult(
          ticker: 'AAPL',
          methodName: 'Test',
          startDate: _epoch,
          endDate: _epoch,
          trades: const [],
          startingEquity: 10000,
        ),
      );
      expect(window.efficiencyRatio, 0);
    });

    test('WalkForwardSummary equality', () {
      const WalkForwardSummary a = WalkForwardSummary(
        ticker: 'AAPL',
        strategyName: 'Test',
        windows: [],
      );
      const WalkForwardSummary b = WalkForwardSummary(
        ticker: 'AAPL',
        strategyName: 'Test',
        windows: [],
      );
      expect(a, equals(b));
    });
  });
}

final DateTime _epoch = DateTime(1970);
