import 'package:cross_tide/src/domain/ticker_media_coverage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TickerMediaCoverage', () {
    test('equality', () {
      const a = TickerMediaCoverage(
        ticker: 'AAPL',
        articleCount: 38,
        intensity: MediaCoverageIntensity.high,
        sentimentScore: 0.72,
        coverageDate: '2025-01-15',
      );
      const b = TickerMediaCoverage(
        ticker: 'AAPL',
        articleCount: 38,
        intensity: MediaCoverageIntensity.high,
        sentimentScore: 0.72,
        coverageDate: '2025-01-15',
      );
      expect(a, b);
    });

    test('copyWith changes articleCount', () {
      const base = TickerMediaCoverage(
        ticker: 'AAPL',
        articleCount: 38,
        intensity: MediaCoverageIntensity.high,
        sentimentScore: 0.72,
        coverageDate: '2025-01-15',
      );
      final updated = base.copyWith(articleCount: 50);
      expect(updated.articleCount, 50);
    });

    test('props length is 5', () {
      const obj = TickerMediaCoverage(
        ticker: 'AAPL',
        articleCount: 38,
        intensity: MediaCoverageIntensity.high,
        sentimentScore: 0.72,
        coverageDate: '2025-01-15',
      );
      expect(obj.props.length, 5);
    });
  });
}
