import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

List<DailyCandle> _candles(List<double> prices) => [
  for (int i = 0; i < prices.length; i++)
    DailyCandle(
      date: DateTime(2024, 1, 1).add(Duration(days: i)),
      open: prices[i],
      high: prices[i] + 1,
      low: prices[i] - 1,
      close: prices[i],
      volume: 1000,
    ),
];

void main() {
  const benchmark = PerformanceBenchmark();

  group('PerformanceBenchmark', () {
    test('const constructor', () {
      const PerformanceBenchmark Function() create = PerformanceBenchmark.new;
      expect(create(), isNotNull);
    });

    test('returns null for no common dates', () {
      final tickerCandles = _candles([100, 110]);
      final benchCandles = [
        DailyCandle(
          date: DateTime(2025, 1, 1),
          open: 100,
          high: 101,
          low: 99,
          close: 100,
          volume: 1000,
        ),
      ];
      final result = benchmark.compare(
        ticker: 'AAPL',
        tickerCandles: tickerCandles,
        benchmarkSymbol: '^GSPC',
        benchmarkCandles: benchCandles,
      );
      expect(result, isNull);
    });

    test('computes returns for matching dates', () {
      final prices = [100.0, 110.0, 105.0, 120.0, 115.0];
      final benchPrices = [1000.0, 1020.0, 1010.0, 1050.0, 1040.0];
      final tickerCandles = _candles(prices);
      final benchCandles = [
        for (int i = 0; i < benchPrices.length; i++)
          DailyCandle(
            date: DateTime(2024, 1, 1).add(Duration(days: i)),
            open: benchPrices[i],
            high: benchPrices[i] + 10,
            low: benchPrices[i] - 10,
            close: benchPrices[i],
            volume: 5000,
          ),
      ];

      final result = benchmark.compare(
        ticker: 'AAPL',
        tickerCandles: tickerCandles,
        benchmarkSymbol: '^GSPC',
        benchmarkCandles: benchCandles,
      );
      expect(result, isNotNull);
      expect(result!.ticker, 'AAPL');
      expect(result.benchmarkSymbol, '^GSPC');
      expect(result.series.length, 5);
      // First point should be 0% for both
      expect(result.series.first.tickerReturn, 0.0);
      expect(result.series.first.benchmarkReturn, 0.0);
      // Ticker: (115-100)/100 = 15%
      expect(result.tickerTotalReturn, closeTo(15.0, 0.01));
      // Bench: (1040-1000)/1000 = 4%
      expect(result.benchmarkTotalReturn, closeTo(4.0, 0.01));
    });

    test('alpha is outperformance', () {
      final prices = [100.0, 120.0, 130.0];
      final benchPrices = [100.0, 105.0, 110.0];
      final tickerCandles = _candles(prices);
      final benchCandles = [
        for (int i = 0; i < benchPrices.length; i++)
          DailyCandle(
            date: DateTime(2024, 1, 1).add(Duration(days: i)),
            open: benchPrices[i],
            high: benchPrices[i] + 1,
            low: benchPrices[i] - 1,
            close: benchPrices[i],
            volume: 1000,
          ),
      ];
      final result = benchmark.compare(
        ticker: 'AAPL',
        tickerCandles: tickerCandles,
        benchmarkSymbol: '^GSPC',
        benchmarkCandles: benchCandles,
      );
      expect(result!.totalAlpha, closeTo(20.0, 0.01));
    });

    test('BenchmarkPoint alpha', () {
      final point = BenchmarkPoint(
        date: DateTime(2024, 1, 1),
        tickerReturn: 10.0,
        benchmarkReturn: 4.0,
      );
      expect(point.alpha, 6.0);
    });
  });
}
