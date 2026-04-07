import 'package:cross_tide/src/application/daily_metrics_aggregator.dart';
import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

List<DailyCandle> _candles(int count, {double base = 100}) =>
    List.generate(count, (i) {
      final double price = base + i * 0.5;
      return DailyCandle(
        date: DateTime(2024, 1, 1).add(Duration(days: i)),
        open: price,
        high: price + 2,
        low: price - 2,
        close: price,
        volume: 1000000 + i * 100,
      );
    });

void main() {
  final aggregator = DailyMetricsAggregator();

  group('DailyMetricsAggregator', () {
    test('returns null for empty candles', () {
      final result = aggregator.aggregate(ticker: 'AAPL', candles: []);
      expect(result, isNull);
    });

    test('returns metrics for sufficient data', () {
      final candles = _candles(250);
      final result = aggregator.aggregate(ticker: 'AAPL', candles: candles);
      expect(result, isNotNull);
      expect(result!.ticker, 'AAPL');
      expect(result.close, candles.last.close);
      expect(result.sma50, isNotNull);
      expect(result.sma150, isNotNull);
      expect(result.sma200, isNotNull);
      expect(result.rsi, isNotNull);
      expect(result.atr, isNotNull);
      expect(result.volume, candles.last.volume);
    });

    test('alertsFired passed through', () {
      final candles = _candles(10);
      final result = aggregator.aggregate(
        ticker: 'AAPL',
        candles: candles,
        alertsFired: 3,
      );
      expect(result!.alertsFired, 3);
    });

    test('null SMA when insufficient data', () {
      final candles = _candles(30);
      final result = aggregator.aggregate(ticker: 'AAPL', candles: candles);
      expect(result, isNotNull);
      expect(result!.sma50, isNull);
      expect(result.sma150, isNull);
      expect(result.sma200, isNull);
    });

    test('exportJson produces valid JSON', () {
      final metrics = [
        DailyMetrics(
          ticker: 'AAPL',
          date: DateTime(2024, 6, 15),
          close: 150,
          sma200: 140,
          alertsFired: 1,
        ),
      ];
      final json = aggregator.exportJson(metrics);
      expect(json, contains('"ticker": "AAPL"'));
      expect(json, contains('"close": 150'));
      expect(json, contains('"sma200": 140'));
    });

    test('exportJson handles empty list', () {
      final json = aggregator.exportJson([]);
      expect(json, '[]');
    });
  });
}
