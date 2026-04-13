import 'package:cross_tide/src/domain/composite_score_card.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CompositeScoreCard', () {
    test('equality', () {
      const a = CompositeScoreCard(
        ticker: 'AAPL',
        dimension: ScoreCardDimension.momentum,
        score: 78.5,
        rank: 42,
        percentile: 85.0,
      );
      const b = CompositeScoreCard(
        ticker: 'AAPL',
        dimension: ScoreCardDimension.momentum,
        score: 78.5,
        rank: 42,
        percentile: 85.0,
      );
      expect(a, b);
    });

    test('copyWith changes score', () {
      const base = CompositeScoreCard(
        ticker: 'AAPL',
        dimension: ScoreCardDimension.momentum,
        score: 78.5,
        rank: 42,
        percentile: 85.0,
      );
      final updated = base.copyWith(score: 80.0);
      expect(updated.score, 80.0);
    });

    test('props length is 5', () {
      const obj = CompositeScoreCard(
        ticker: 'AAPL',
        dimension: ScoreCardDimension.momentum,
        score: 78.5,
        rank: 42,
        percentile: 85.0,
      );
      expect(obj.props.length, 5);
    });
  });
}
