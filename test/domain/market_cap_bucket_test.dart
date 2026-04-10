import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MarketCapBucket', () {
    MarketCapBucket bucket(double capUsd) => MarketCapBucket(
      ticker: 'TEST',
      marketCapUsd: capUsd,
      recordedAt: DateTime(2024, 6, 1),
    );

    test('tier is micro when < 300M', () {
      expect(bucket(299e6).tier, MarketCapTier.micro);
    });

    test('tier is small at 300M boundary', () {
      expect(bucket(300e6).tier, MarketCapTier.small);
    });

    test('tier is mid at 2B boundary', () {
      expect(bucket(2e9).tier, MarketCapTier.mid);
    });

    test('tier is large at 10B boundary', () {
      expect(bucket(10e9).tier, MarketCapTier.large);
    });

    test('tier is mega at 200B boundary', () {
      expect(bucket(200e9).tier, MarketCapTier.mega);
    });

    test('isLargeOrAbove is true for large cap', () {
      expect(bucket(50e9).isLargeOrAbove, isTrue);
    });

    test('isLargeOrAbove is true for mega cap', () {
      expect(bucket(500e9).isLargeOrAbove, isTrue);
    });

    test('isLargeOrAbove is false for mid cap', () {
      expect(bucket(5e9).isLargeOrAbove, isFalse);
    });

    test('equality holds for same props', () {
      expect(bucket(10e9), equals(bucket(10e9)));
    });
  });
}
