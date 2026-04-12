import 'package:cross_tide/src/domain/analyst_rating_change.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnalystRatingChange', () {
    test('equality', () {
      final a = AnalystRatingChange(
        ticker: 'META',
        analystFirm: 'Goldman Sachs',
        direction: RatingChangeDirection.upgrade,
        newRating: AnalystRatingTier.buy,
        publishedAt: DateTime(2025, 11, 15),
      );
      final b = AnalystRatingChange(
        ticker: 'META',
        analystFirm: 'Goldman Sachs',
        direction: RatingChangeDirection.upgrade,
        newRating: AnalystRatingTier.buy,
        publishedAt: DateTime(2025, 11, 15),
      );
      expect(a, b);
    });

    test('copyWith changes analystFirm', () {
      final base = AnalystRatingChange(
        ticker: 'META',
        analystFirm: 'Goldman Sachs',
        direction: RatingChangeDirection.upgrade,
        newRating: AnalystRatingTier.buy,
        publishedAt: DateTime(2025, 11, 15),
      );
      final updated = base.copyWith(analystFirm: 'Morgan Stanley');
      expect(updated.analystFirm, 'Morgan Stanley');
    });

    test('props length is 8', () {
      final obj = AnalystRatingChange(
        ticker: 'META',
        analystFirm: 'Goldman Sachs',
        direction: RatingChangeDirection.upgrade,
        newRating: AnalystRatingTier.buy,
        publishedAt: DateTime(2025, 11, 15),
      );
      expect(obj.props.length, 8);
    });
  });
}
