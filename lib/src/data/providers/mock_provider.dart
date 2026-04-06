/// Mock Market Data Provider — For offline development and testing.
///
/// Generates deterministic synthetic price data with configurable patterns
/// to exercise cross-up detection logic.
library;

import 'dart:math';

import '../../domain/entities.dart';
import 'market_data_provider.dart';

class MockMarketDataProvider implements IMarketDataProvider {
  MockMarketDataProvider({this.seed = 42, this.delayMs = 200});

  final int seed;
  final int delayMs;

  @override
  String get name => 'Mock Provider';

  @override
  String get id => 'mock';

  @override
  Future<List<DailyCandle>> fetchDailyHistory(String ticker) async {
    // Simulate network delay
    if (delayMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: delayMs));
    }
    return generateCandles(ticker: ticker, days: 300, seed: seed);
  }

  /// Generate synthetic candles with a pattern that will produce a cross-up
  /// around day ~250 for deterministic testing.
  static List<DailyCandle> generateCandles({
    required String ticker,
    int days = 300,
    int seed = 42,
    double basePrice = 100.0,
  }) {
    final rng = Random(seed + ticker.hashCode);
    final candles = <DailyCandle>[];
    var price = basePrice;
    final startDate = DateTime.now().subtract(Duration(days: days));

    for (var i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));
      // Skip weekends (approximate; real providers already filter these)
      if (date.weekday == DateTime.saturday ||
          date.weekday == DateTime.sunday) {
        continue;
      }

      // Create a price pattern:
      // Days 0–200: gradual decline (price tends below future SMA)
      // Days 200–250: flat/slight decline
      // Days 250+: sharp rise (triggers cross-up)
      double drift;
      if (i < 200) {
        drift = -0.05 + rng.nextDouble() * 0.08; // slight downward bias
      } else if (i < 250) {
        drift = -0.02 + rng.nextDouble() * 0.04; // flat
      } else {
        drift = 0.1 + rng.nextDouble() * 0.15; // strong upward
      }

      price = price * (1 + drift / 100);
      final high = price * (1 + rng.nextDouble() * 0.02);
      final low = price * (1 - rng.nextDouble() * 0.02);
      final open = low + rng.nextDouble() * (high - low);

      candles.add(
        DailyCandle(
          date: date,
          open: _round(open),
          high: _round(high),
          low: _round(low),
          close: _round(price),
          volume: 1000000 + rng.nextInt(5000000),
        ),
      );
    }
    return candles;
  }

  static double _round(double v) => (v * 100).roundToDouble() / 100;
}
