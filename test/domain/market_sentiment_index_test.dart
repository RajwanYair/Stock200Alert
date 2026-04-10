import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SentimentComponent', () {
    test('creates instance correctly', () {
      const c = SentimentComponent(name: 'VIX', score: 25.0);
      expect(c.name, 'VIX');
      expect(c.score, 25.0);
      expect(c.weight, 1.0);
    });
  });

  group('MarketSentimentIndex', () {
    late DateTime measured;

    setUp(() => measured = DateTime(2025, 6, 1));

    test('extreme fear label below 20', () {
      final idx = MarketSentimentIndex(
        fearGreedScore: 10.0,
        components: const [],
        measuredAt: measured,
      );
      expect(idx.label, SentimentLabel.extremeFear);
      expect(idx.isFearful, isTrue);
      expect(idx.isGreedy, isFalse);
    });

    test('fear label between 20 and 40', () {
      final idx = MarketSentimentIndex(
        fearGreedScore: 30.0,
        components: const [],
        measuredAt: measured,
      );
      expect(idx.label, SentimentLabel.fear);
    });

    test('neutral label between 40 and 60', () {
      final idx = MarketSentimentIndex(
        fearGreedScore: 50.0,
        components: const [],
        measuredAt: measured,
      );
      expect(idx.label, SentimentLabel.neutral);
      expect(idx.isNeutral, isTrue);
    });

    test('greed label between 60 and 80', () {
      final idx = MarketSentimentIndex(
        fearGreedScore: 70.0,
        components: const [],
        measuredAt: measured,
      );
      expect(idx.label, SentimentLabel.greed);
      expect(idx.isGreedy, isTrue);
    });

    test('extreme greed label at 80+', () {
      final idx = MarketSentimentIndex(
        fearGreedScore: 90.0,
        components: const [],
        measuredAt: measured,
      );
      expect(idx.label, SentimentLabel.extremeGreed);
    });

    test('componentCount is correct', () {
      final idx = MarketSentimentIndex(
        fearGreedScore: 55.0,
        components: const [
          SentimentComponent(name: 'A', score: 50),
          SentimentComponent(name: 'B', score: 60),
        ],
        measuredAt: measured,
      );
      expect(idx.componentCount, 2);
    });

    test('equality holds', () {
      final a = MarketSentimentIndex(
        fearGreedScore: 50.0,
        components: const [],
        measuredAt: measured,
      );
      final b = MarketSentimentIndex(
        fearGreedScore: 50.0,
        components: const [],
        measuredAt: measured,
      );
      expect(a, equals(b));
    });
  });
}
