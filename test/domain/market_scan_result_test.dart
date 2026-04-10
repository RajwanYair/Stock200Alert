import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarketScanResult', () {
    MarketScanResult buildResult({
      ScanMatchStatus status = ScanMatchStatus.matched,
      double score = 0.85,
    }) => MarketScanResult(
      ticker: 'NVDA',
      status: status,
      scannedAt: DateTime(2024, 6, 1),
      score: score,
      matchedCriteria: const ['rsi_oversold', 'above_ma150'],
      failedCriteria: const [],
    );

    test('isMatch is true when status is matched', () {
      expect(buildResult(status: ScanMatchStatus.matched).isMatch, isTrue);
    });

    test('isMatch is false when status is rejected', () {
      expect(buildResult(status: ScanMatchStatus.rejected).isMatch, isFalse);
    });

    test('passCount reflects matchedCriteria length', () {
      expect(buildResult().passCount, 2);
    });

    test('failedCriteria defaults to empty list', () {
      expect(buildResult().failedCriteria, isEmpty);
    });

    test('equality holds for same props', () {
      expect(buildResult(), equals(buildResult()));
    });
  });
}
