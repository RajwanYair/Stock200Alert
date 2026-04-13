import 'package:cross_tide/src/domain/app_rating_prompt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRatingPrompt', () {
    test('equality', () {
      final a = AppRatingPrompt(
        promptId: 'p-1',
        outcome: RatingPromptOutcome.rated,
        shownAt: DateTime(2025, 1, 1),
        sessionCount: 5,
        starRating: 5,
      );
      final b = AppRatingPrompt(
        promptId: 'p-1',
        outcome: RatingPromptOutcome.rated,
        shownAt: DateTime(2025, 1, 1),
        sessionCount: 5,
        starRating: 5,
      );
      expect(a, b);
    });

    test('copyWith changes sessionCount', () {
      final base = AppRatingPrompt(
        promptId: 'p-1',
        outcome: RatingPromptOutcome.rated,
        shownAt: DateTime(2025, 1, 1),
        sessionCount: 5,
        starRating: 5,
      );
      final updated = base.copyWith(sessionCount: 6);
      expect(updated.sessionCount, 6);
    });

    test('props length is 5', () {
      final obj = AppRatingPrompt(
        promptId: 'p-1',
        outcome: RatingPromptOutcome.rated,
        shownAt: DateTime(2025, 1, 1),
        sessionCount: 5,
        starRating: 5,
      );
      expect(obj.props.length, 5);
    });
  });
}
