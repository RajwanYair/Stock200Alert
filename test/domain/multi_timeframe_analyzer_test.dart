import 'package:cross_tide/src/domain/entities.dart';
import 'package:cross_tide/src/domain/multi_timeframe_analyzer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CandleAggregator', () {
    const agg = CandleAggregator();

    test('returns empty for empty input', () {
      expect(agg.toWeekly([]), isEmpty);
      expect(agg.toMonthly([]), isEmpty);
    });

    test('aggregates daily candles into monthly bars', () {
      final candles = [
        DailyCandle(
          date: DateTime(2025, 1, 2),
          open: 100,
          high: 110,
          low: 95,
          close: 105,
          volume: 1000,
        ),
        DailyCandle(
          date: DateTime(2025, 1, 15),
          open: 105,
          high: 115,
          low: 100,
          close: 112,
          volume: 1200,
        ),
        DailyCandle(
          date: DateTime(2025, 2, 3),
          open: 112,
          high: 120,
          low: 108,
          close: 118,
          volume: 800,
        ),
      ];

      final monthly = agg.toMonthly(candles);
      expect(monthly, hasLength(2));

      // January bar
      expect(monthly[0].open, 100);
      expect(monthly[0].high, 115);
      expect(monthly[0].low, 95);
      expect(monthly[0].close, 112);
      expect(monthly[0].volume, 2200);
    });

    test('aggregates daily candles into weekly bars', () {
      final candles = [
        DailyCandle(
          date: DateTime(2025, 1, 6), // Monday
          open: 100,
          high: 105,
          low: 98,
          close: 103,
          volume: 500,
        ),
        DailyCandle(
          date: DateTime(2025, 1, 7),
          open: 103,
          high: 108,
          low: 101,
          close: 106,
          volume: 600,
        ),
        DailyCandle(
          date: DateTime(2025, 1, 13), // Next Monday
          open: 106,
          high: 112,
          low: 104,
          close: 110,
          volume: 700,
        ),
      ];

      final weekly = agg.toWeekly(candles);
      expect(weekly, hasLength(2));
      expect(weekly[0].volume, 1100);
    });
  });

  group('MultiTimeframeAnalyzer', () {
    const analyzer = MultiTimeframeAnalyzer();

    test('returns NEUTRAL for empty input', () {
      final result = analyzer.analyze(ticker: 'AAPL', timeframeBiases: []);
      expect(result.confluenceBias, 'NEUTRAL');
      expect(result.confluenceScore, 0);
    });

    test('BUY confluence when all timeframes agree', () {
      final result = analyzer.analyze(
        ticker: 'AAPL',
        timeframeBiases: const [
          TimeframeBias(
            timeframe: Timeframe.daily,
            bias: 'BUY',
            strength: 1.0,
            signalCount: 3,
          ),
          TimeframeBias(
            timeframe: Timeframe.weekly,
            bias: 'BUY',
            strength: 0.8,
            signalCount: 2,
          ),
          TimeframeBias(
            timeframe: Timeframe.monthly,
            bias: 'BUY',
            strength: 0.9,
            signalCount: 1,
          ),
        ],
      );

      expect(result.confluenceBias, 'BUY');
      expect(result.confluenceScore, greaterThan(80));
    });

    test('mixed biases reduce confluence score', () {
      final result = analyzer.analyze(
        ticker: 'AAPL',
        timeframeBiases: const [
          TimeframeBias(
            timeframe: Timeframe.daily,
            bias: 'BUY',
            strength: 1.0,
            signalCount: 3,
          ),
          TimeframeBias(
            timeframe: Timeframe.weekly,
            bias: 'SELL',
            strength: 1.0,
            signalCount: 2,
          ),
        ],
      );

      // weekly weight (2) > daily (1), so SELL wins
      expect(result.confluenceBias, 'SELL');
    });

    test('equal scores produce NEUTRAL', () {
      final result = analyzer.analyze(
        ticker: 'X',
        timeframeBiases: const [
          TimeframeBias(
            timeframe: Timeframe.daily,
            bias: 'BUY',
            strength: 1.0,
            signalCount: 1,
          ),
          TimeframeBias(
            timeframe: Timeframe.daily,
            bias: 'SELL',
            strength: 1.0,
            signalCount: 1,
          ),
        ],
      );
      expect(result.confluenceBias, 'NEUTRAL');
    });

    test('MultiTimeframeResult props equality', () {
      const a = MultiTimeframeResult(
        ticker: 'X',
        biases: [],
        confluenceBias: 'NEUTRAL',
        confluenceScore: 0,
      );
      const b = MultiTimeframeResult(
        ticker: 'X',
        biases: [],
        confluenceBias: 'NEUTRAL',
        confluenceScore: 0,
      );
      expect(a, equals(b));
    });

    test('TimeframeBias props equality', () {
      const a = TimeframeBias(
        timeframe: Timeframe.daily,
        bias: 'BUY',
        strength: 0.5,
        signalCount: 3,
      );
      const b = TimeframeBias(
        timeframe: Timeframe.daily,
        bias: 'BUY',
        strength: 0.5,
        signalCount: 3,
      );
      expect(a, equals(b));
    });
  });
}
