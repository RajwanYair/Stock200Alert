import 'package:cross_tide/src/domain/sector_rotation_scorer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scorer = SectorRotationScorer();

  group('SectorRotationScorer', () {
    test('returns empty for fewer than 2 sectors', () {
      expect(scorer.score({'Tech': 5.0}), isEmpty);
    });

    test('scores sectors by relative momentum', () {
      final result = scorer.score({
        'Tech': 10.0,
        'Energy': -5.0,
        'Health': 3.0,
      });

      expect(result, hasLength(3));
      expect(result.first.sector, 'Tech');
      expect(result.first.rank, 1);
      expect(result.first.score, closeTo(100, 0.01));
      expect(result.last.sector, 'Energy');
      expect(result.last.rank, 3);
      expect(result.last.score, closeTo(0, 0.01));
    });

    test('gives score 50 when all returns are equal', () {
      final result = scorer.score({'A': 5.0, 'B': 5.0});
      for (final SectorScore s in result) {
        expect(s.score, closeTo(50, 0.01));
      }
    });

    test('SectorScore props equality', () {
      const a = SectorScore(
        sector: 'Tech',
        averageReturn: 5.0,
        score: 80,
        rank: 1,
      );
      const b = SectorScore(
        sector: 'Tech',
        averageReturn: 5.0,
        score: 80,
        rank: 1,
      );
      expect(a, equals(b));
    });
  });
}
