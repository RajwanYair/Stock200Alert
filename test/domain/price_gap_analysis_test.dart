import 'package:cross_tide/src/domain/price_gap_analysis.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PriceGapAnalysis', () {
    test('equality', () {
      final a = PriceGapAnalysis(
        ticker: 'TSLA',
        gapDate: DateTime(2025, 8, 10),
        prevClose: 200.0,
        openPrice: 210.0,
        gapSizePercent: 5.0,
        gapType: PriceGapType.breakaway,
        fillProbabilityPercent: 30.0,
        isUpGap: true,
      );
      final b = PriceGapAnalysis(
        ticker: 'TSLA',
        gapDate: DateTime(2025, 8, 10),
        prevClose: 200.0,
        openPrice: 210.0,
        gapSizePercent: 5.0,
        gapType: PriceGapType.breakaway,
        fillProbabilityPercent: 30.0,
        isUpGap: true,
      );
      expect(a, b);
    });

    test('copyWith changes isUpGap', () {
      final base = PriceGapAnalysis(
        ticker: 'TSLA',
        gapDate: DateTime(2025, 8, 10),
        prevClose: 200.0,
        openPrice: 210.0,
        gapSizePercent: 5.0,
        gapType: PriceGapType.breakaway,
        fillProbabilityPercent: 30.0,
        isUpGap: true,
      );
      final updated = base.copyWith(isUpGap: false);
      expect(updated.isUpGap, false);
    });

    test('props length is 8', () {
      final obj = PriceGapAnalysis(
        ticker: 'TSLA',
        gapDate: DateTime(2025, 8, 10),
        prevClose: 200.0,
        openPrice: 210.0,
        gapSizePercent: 5.0,
        gapType: PriceGapType.breakaway,
        fillProbabilityPercent: 30.0,
        isUpGap: true,
      );
      expect(obj.props.length, 8);
    });
  });
}
