import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CandlestickPatternType', () {
    test('has 14 values', () {
      expect(CandlestickPatternType.values.length, 14);
    });
  });

  group('PatternBias', () {
    test('has 3 values', () {
      expect(PatternBias.values.length, 3);
    });
  });

  group('CandlestickPatternMatch', () {
    CandlestickPatternMatch buildMatch({double confidenceScore = 0.85}) {
      return CandlestickPatternMatch(
        ticker: 'AAPL',
        patternType: CandlestickPatternType.hammer,
        bias: PatternBias.bullish,
        candleDate: DateTime(2024, 6, 15),
        confidenceScore: confidenceScore,
      );
    }

    test('isHighConfidence is true when confidenceScore >= 0.75', () {
      expect(buildMatch(confidenceScore: 0.75).isHighConfidence, isTrue);
    });

    test('isHighConfidence is false when confidenceScore < 0.75', () {
      expect(buildMatch(confidenceScore: 0.74).isHighConfidence, isFalse);
    });

    test('equality holds for same props', () {
      expect(buildMatch(), equals(buildMatch()));
    });

    test('bearish pattern equality', () {
      final a = CandlestickPatternMatch(
        ticker: 'MSFT',
        patternType: CandlestickPatternType.eveningStar,
        bias: PatternBias.bearish,
        candleDate: DateTime(2024, 6, 1),
        confidenceScore: 0.9,
      );
      final b = CandlestickPatternMatch(
        ticker: 'MSFT',
        patternType: CandlestickPatternType.eveningStar,
        bias: PatternBias.bearish,
        candleDate: DateTime(2024, 6, 1),
        confidenceScore: 0.9,
      );
      expect(a, equals(b));
    });
  });
}
