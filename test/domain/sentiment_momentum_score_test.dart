import 'package:cross_tide/src/domain/sentiment_momentum_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SentimentMomentumScore', () {
    test('equality', () {
      const a = SentimentMomentumScore(
        ticker: 'AAPL',
        score: 72.5,
        rating: SentimentMomentumRating.bullish,
        sampleSize: 500,
        dataSource: 'news',
      );
      const b = SentimentMomentumScore(
        ticker: 'AAPL',
        score: 72.5,
        rating: SentimentMomentumRating.bullish,
        sampleSize: 500,
        dataSource: 'news',
      );
      expect(a, b);
    });

    test('copyWith changes score', () {
      const base = SentimentMomentumScore(
        ticker: 'AAPL',
        score: 72.5,
        rating: SentimentMomentumRating.bullish,
        sampleSize: 500,
        dataSource: 'news',
      );
      final updated = base.copyWith(score: 80.0);
      expect(updated.score, 80.0);
    });

    test('props length is 5', () {
      const obj = SentimentMomentumScore(
        ticker: 'AAPL',
        score: 72.5,
        rating: SentimentMomentumRating.bullish,
        sampleSize: 500,
        dataSource: 'news',
      );
      expect(obj.props.length, 5);
    });
  });
}
