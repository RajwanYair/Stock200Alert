import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TradingSessionSummary', () {
    TradingSessionSummary buildSession({
      double open = 100.0,
      double close = 110.0,
    }) => TradingSessionSummary(
      ticker: 'AAPL',
      sessionLabel: 'Regular',
      sessionDate: DateTime(2024, 6, 3),
      open: open,
      high: 115.0,
      low: 98.0,
      close: close,
      volume: 1000000,
    );

    test('range equals high minus low', () {
      expect(buildSession().range, closeTo(17.0, 0.001));
    });

    test('changePct is correct', () {
      expect(buildSession().changePct, closeTo(10.0, 0.001));
    });

    test('changePct is 0 when open is 0', () {
      expect(buildSession(open: 0).changePct, 0);
    });

    test('isBullishSession is true when close > open', () {
      expect(buildSession().isBullishSession, isTrue);
    });

    test('isBullishSession is false when close < open', () {
      expect(buildSession(close: 95.0).isBullishSession, isFalse);
    });

    test('vwap defaults to null', () {
      expect(buildSession().vwap, isNull);
    });

    test('vwap stored when provided', () {
      final s = TradingSessionSummary(
        ticker: 'X',
        sessionLabel: 'Regular',
        sessionDate: DateTime(2024, 6, 3),
        open: 100,
        high: 110,
        low: 95,
        close: 105,
        volume: 500000,
        vwap: 103.5,
      );
      expect(s.vwap, 103.5);
    });

    test('equality holds for same props', () {
      expect(buildSession(), equals(buildSession()));
    });
  });
}
