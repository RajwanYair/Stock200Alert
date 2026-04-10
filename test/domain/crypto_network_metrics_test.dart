import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CryptoNetworkMetrics', () {
    CryptoNetworkMetrics buildMetrics({
      int transactionCount = 100000,
      double networkValueUsd = 2e9,
    }) => CryptoNetworkMetrics(
      symbol: 'BTC',
      networkName: 'Bitcoin',
      recordedAt: DateTime(2024, 6, 1),
      activeAddresses: 500000,
      transactionCount: transactionCount,
      hashRateEh: 620.5,
      averageFeeSat: 15.0,
      networkValueUsd: networkValueUsd,
    );

    test('isHighActivity is true when transactions >= 50000', () {
      expect(buildMetrics(transactionCount: 50000).isHighActivity, isTrue);
    });

    test('isHighActivity is false when transactions < 50000', () {
      expect(buildMetrics(transactionCount: 49999).isHighActivity, isFalse);
    });

    test('isLargeNetwork is true when networkValueUsd >= 1e9', () {
      expect(buildMetrics(networkValueUsd: 1e9).isLargeNetwork, isTrue);
    });

    test('isLargeNetwork is false when networkValueUsd < 1e9', () {
      expect(buildMetrics(networkValueUsd: 9e8).isLargeNetwork, isFalse);
    });

    test('mempoolSizeKb defaults to null', () {
      expect(buildMetrics().mempoolSizeKb, isNull);
    });

    test('mempoolSizeKb stored when provided', () {
      final m = CryptoNetworkMetrics(
        symbol: 'BTC',
        networkName: 'Bitcoin',
        recordedAt: DateTime(2024, 6, 1),
        activeAddresses: 1,
        transactionCount: 1,
        hashRateEh: 1.0,
        averageFeeSat: 1.0,
        networkValueUsd: 1.0,
        mempoolSizeKb: 42.5,
      );
      expect(m.mempoolSizeKb, 42.5);
    });

    test('equality holds for same props', () {
      expect(buildMetrics(), equals(buildMetrics()));
    });
  });
}
