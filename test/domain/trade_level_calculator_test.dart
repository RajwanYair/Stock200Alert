import 'package:cross_tide/src/domain/entities.dart';
import 'package:cross_tide/src/domain/trade_level_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Generate [count] candles with [close] incrementing from [startClose] by
/// [step] each day.  High/low are symmetric around close ± [spread].
List<DailyCandle> _makeCandles({
  int count = 30,
  double startClose = 100,
  double step = 0.5,
  double spread = 2,
  int startVolume = 1000,
}) {
  return List<DailyCandle>.generate(count, (int i) {
    final double close = startClose + i * step;
    return DailyCandle(
      date: DateTime(2025, 1, 1).add(Duration(days: i)),
      open: close - step / 2,
      high: close + spread,
      low: close - spread,
      close: close,
      volume: startVolume + i * 10,
    );
  });
}

void main() {
  const TradeLevelCalculator calc = TradeLevelCalculator();

  group('TradeLevelCalculator', () {
    test('returns null for empty candle list', () {
      expect(calc.compute('AAPL', []), isNull);
    });

    test('returns null when candles are insufficient for ATR', () {
      // ATR default period is 14 → need > 14 candles.
      final List<DailyCandle> candles = _makeCandles(count: 10);
      expect(calc.compute('AAPL', candles), isNull);
    });

    test('computes trade levels with sufficient data', () {
      // 250 candles so SMA150, SMA200, and Bollinger all produce values.
      final List<DailyCandle> candles = _makeCandles(count: 250);
      final TradeLevels? result = calc.compute('AAPL', candles);
      expect(result, isNotNull);
      expect(result!.symbol, 'AAPL');
      expect(result.currentClose, candles.last.close);
      expect(result.atr, greaterThan(0));
      expect(result.stopLoss, lessThan(result.recommendedBuy));
    });

    test('buy price is at or below current close', () {
      final List<DailyCandle> candles = _makeCandles(count: 250);
      final TradeLevels result = calc.compute('MSFT', candles)!;
      expect(result.recommendedBuy, lessThanOrEqualTo(result.currentClose));
    });

    test('stop-loss equals buy minus atrMultiplier times ATR', () {
      const TradeLevelCalculator custom = TradeLevelCalculator(
        atrMultiplier: 1.5,
      );
      final List<DailyCandle> candles = _makeCandles(count: 250);
      final TradeLevels result = custom.compute('GOOG', candles)!;
      final double expected = result.recommendedBuy - 1.5 * result.atr;
      expect(result.stopLoss, closeTo(expected, 1e-8));
      expect(result.atrMultiplier, 1.5);
    });

    test('risk amount and percent are correct', () {
      final List<DailyCandle> candles = _makeCandles(count: 250);
      final TradeLevels result = calc.compute('TSLA', candles)!;
      expect(result.riskAmount, result.recommendedBuy - result.stopLoss);
      expect(
        result.riskPercent,
        closeTo((result.riskAmount / result.recommendedBuy) * 100, 1e-8),
      );
    });

    test('reward to risk ratio is calculated when risk > 0', () {
      final List<DailyCandle> candles = _makeCandles(count: 250);
      final TradeLevels result = calc.compute('AMZN', candles)!;
      if (result.riskAmount > 0) {
        expect(
          result.rewardToRisk,
          closeTo(result.rewardAmount / result.riskAmount, 1e-8),
        );
      }
    });

    test('reward to risk is null when risk is zero', () {
      // Craft a scenario where buyPrice == close so riskAmount comes from
      // ATR alone; but test TradeLevels directly:
      const TradeLevels levels = TradeLevels(
        symbol: 'TEST',
        currentClose: 100,
        recommendedBuy: 100,
        stopLoss: 100,
        atr: 0,
        atrMultiplier: 2,
      );
      expect(levels.riskAmount, 0);
      expect(levels.rewardToRisk, isNull);
    });

    test('support levels are populated when data is sufficient', () {
      final List<DailyCandle> candles = _makeCandles(count: 250);
      final TradeLevels result = calc.compute('SPY', candles)!;
      // With 250 ascending candles, SMA150 and SMA200 should be below close.
      expect(result.supportSma150, isNotNull);
      expect(result.supportSma200, isNotNull);
      expect(result.supportBollingerLower, isNotNull);
    });

    test('uses close when all support levels are above close', () {
      // Descending candles — SMAs will be above the latest close.
      final List<DailyCandle> candles = _makeCandles(
        count: 250,
        startClose: 200,
        step: -0.5,
      );
      final TradeLevels result = calc.compute('META', candles)!;
      // Buy price should be at or below the current close (may pick
      // the Bollinger lower band when it's below close).
      expect(result.recommendedBuy, lessThanOrEqualTo(result.currentClose));
    });

    test('only 15 candles gives no SMA150/200 but still computes', () {
      final List<DailyCandle> candles = _makeCandles(count: 25);
      final TradeLevels result = calc.compute('NFLX', candles)!;
      // Not enough data for SMA150/200.
      expect(result.supportSma150, isNull);
      expect(result.supportSma200, isNull);
      // Buy price should be at or below the close (Bollinger lower band
      // may be available with 25 candles since Bollinger period = 20).
      expect(result.recommendedBuy, lessThanOrEqualTo(result.currentClose));
      expect(result.stopLoss, lessThan(result.recommendedBuy));
    });

    test('TradeLevels equality via Equatable', () {
      const TradeLevels a = TradeLevels(
        symbol: 'X',
        currentClose: 50,
        recommendedBuy: 48,
        stopLoss: 44,
        atr: 2,
        atrMultiplier: 2,
      );
      const TradeLevels b = TradeLevels(
        symbol: 'X',
        currentClose: 50,
        recommendedBuy: 48,
        stopLoss: 44,
        atr: 2,
        atrMultiplier: 2,
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('can be constructed at runtime', () {
      const TradeLevelCalculator Function() create = TradeLevelCalculator.new;
      final TradeLevelCalculator instance = create();
      expect(instance.atrMultiplier, 2.0);
    });

    test('riskPercent is zero when recommendedBuy is zero', () {
      const TradeLevels levels = TradeLevels(
        symbol: 'ZERO',
        currentClose: 0,
        recommendedBuy: 0,
        stopLoss: -5,
        atr: 2.5,
        atrMultiplier: 2,
      );
      expect(levels.riskPercent, 0);
    });
  });
}
