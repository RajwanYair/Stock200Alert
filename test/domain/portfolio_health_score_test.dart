import 'package:cross_tide/src/domain/portfolio_health_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PortfolioHealthScore', () {
    test('equality', () {
      final a = PortfolioHealthScore(
        portfolioId: 'p1',
        overallScore: 78.5,
        components: const [],
        calculatedAt: DateTime(2025, 9, 1),
      );
      final b = PortfolioHealthScore(
        portfolioId: 'p1',
        overallScore: 78.5,
        components: const [],
        calculatedAt: DateTime(2025, 9, 1),
      );
      expect(a, b);
    });

    test('copyWith changes overallScore', () {
      final base = PortfolioHealthScore(
        portfolioId: 'p1',
        overallScore: 78.5,
        components: const [],
        calculatedAt: DateTime(2025, 9, 1),
      );
      final updated = base.copyWith(overallScore: 85.0);
      expect(updated.overallScore, 85.0);
    });

    test('props length is 5', () {
      final obj = PortfolioHealthScore(
        portfolioId: 'p1',
        overallScore: 78.5,
        components: const [],
        calculatedAt: DateTime(2025, 9, 1),
      );
      expect(obj.props.length, 5);
    });
  });
}
