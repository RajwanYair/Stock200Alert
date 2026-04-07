import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const BacktestEngine engine = BacktestEngine();
  const BacktestStrategy strategy = BacktestStrategy(
    name: 'TestStrategy',
    entryAlertTypes: {'buy'},
    exitAlertTypes: {'sell'},
  );

  List<DailyCandle> makeCandles(List<double> closes) => [
    for (int i = 0; i < closes.length; i++)
      DailyCandle(
        date: DateTime(2024, 1, 1).add(Duration(days: i)),
        open: closes[i],
        high: closes[i] + 1,
        low: closes[i] - 1,
        close: closes[i],
        volume: 1000,
      ),
  ];

  group('BacktestEngine', () {
    test('empty candles returns empty result', () {
      final BacktestResult result = engine.run(
        ticker: 'AAPL',
        strategy: strategy,
        candles: [],
      );
      expect(result.totalTrades, 0);
    });

    test('single candle returns empty result', () {
      final BacktestResult result = engine.run(
        ticker: 'AAPL',
        strategy: strategy,
        candles: makeCandles([100]),
      );
      expect(result.totalTrades, 0);
    });

    test('entry and exit signals produce a trade', () {
      final List<DailyCandle> candles = makeCandles([100, 105, 110, 108]);
      final BacktestResult result = engine.run(
        ticker: 'AAPL',
        strategy: strategy,
        candles: candles,
        signalResolver: (DailyCandle c) {
          if (c.close == 100) return ['buy'];
          if (c.close == 110) return ['sell'];
          return [];
        },
      );
      expect(result.totalTrades, 1);
      expect(result.trades[0].entryPrice, 100);
      expect(result.trades[0].exitPrice, 110);
      expect(result.trades[0].isWinner, isTrue);
    });

    test('stop-loss exits position', () {
      final List<DailyCandle> candles = makeCandles([100, 105, 90, 88]);
      const BacktestStrategy slStrategy = BacktestStrategy(
        name: 'SL',
        entryAlertTypes: {'buy'},
        exitAlertTypes: {'sell'},
        stopLossPct: 5,
      );
      final BacktestResult result = engine.run(
        ticker: 'AAPL',
        strategy: slStrategy,
        candles: candles,
        signalResolver: (DailyCandle c) {
          if (c.close == 100) return ['buy'];
          return [];
        },
      );
      expect(result.totalTrades, 1);
      expect(result.trades[0].exitPrice, 90);
    });

    test('take-profit exits position', () {
      final List<DailyCandle> candles = makeCandles([100, 105, 115, 120]);
      const BacktestStrategy tpStrategy = BacktestStrategy(
        name: 'TP',
        entryAlertTypes: {'buy'},
        exitAlertTypes: {'sell'},
        takeProfitPct: 10,
      );
      final BacktestResult result = engine.run(
        ticker: 'AAPL',
        strategy: tpStrategy,
        candles: candles,
        signalResolver: (DailyCandle c) {
          if (c.close == 100) return ['buy'];
          return [];
        },
      );
      expect(result.totalTrades, 1);
      expect(result.trades[0].exitPrice, 115);
    });

    test('max holding days exits position', () {
      final List<DailyCandle> candles = makeCandles([100, 101, 102, 103, 104]);
      const BacktestStrategy mhStrategy = BacktestStrategy(
        name: 'MH',
        entryAlertTypes: {'buy'},
        exitAlertTypes: {'sell'},
        maxHoldingDays: 2,
      );
      final BacktestResult result = engine.run(
        ticker: 'AAPL',
        strategy: mhStrategy,
        candles: candles,
        signalResolver: (DailyCandle c) {
          if (c.close == 100) return ['buy'];
          return [];
        },
      );
      expect(result.totalTrades, 1);
      expect(result.trades[0].exitPrice, 102);
    });

    test('no signal resolver produces no trades', () {
      final BacktestResult result = engine.run(
        ticker: 'AAPL',
        strategy: strategy,
        candles: makeCandles([100, 105, 110]),
      );
      expect(result.totalTrades, 0);
    });

    test('multiple round-trip trades', () {
      final List<DailyCandle> candles = makeCandles([100, 110, 105, 115]);
      final BacktestResult result = engine.run(
        ticker: 'AAPL',
        strategy: strategy,
        candles: candles,
        signalResolver: (DailyCandle c) {
          if (c.close == 100 || c.close == 105) return ['buy'];
          if (c.close == 110 || c.close == 115) return ['sell'];
          return [];
        },
      );
      expect(result.totalTrades, 2);
    });
  });
}
