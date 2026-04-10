import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BenchmarkIndexConfig', () {
    test('creates instance with required fields', () {
      const config = BenchmarkIndexConfig(
        symbol: 'SPY',
        displayName: 'SPDR S&P 500',
      );
      expect(config.symbol, 'SPY');
      expect(config.displayName, 'SPDR S&P 500');
      expect(config.isDefault, isFalse);
      expect(config.color, isNull);
    });

    test('withDefault() sets isDefault true', () {
      const config = BenchmarkIndexConfig(symbol: 'QQQ', displayName: 'QQQ');
      final defaulted = config.withDefault();
      expect(defaulted.isDefault, isTrue);
      expect(defaulted.symbol, 'QQQ');
    });

    test('predefined sp500 benchmark is correct', () {
      expect(BenchmarkIndexConfig.sp500.symbol, '^GSPC');
      expect(BenchmarkIndexConfig.sp500.isDefault, isTrue);
      expect(BenchmarkIndexConfig.sp500.color, '#FF8C00');
    });

    test('predefined nasdaq100 benchmark is correct', () {
      expect(BenchmarkIndexConfig.nasdaq100.symbol, '^NDX');
      expect(BenchmarkIndexConfig.nasdaq100.isDefault, isFalse);
    });

    test('predefined dow benchmark is correct', () {
      expect(BenchmarkIndexConfig.dow.symbol, '^DJI');
    });

    test('equality holds for same values', () {
      const a = BenchmarkIndexConfig(symbol: 'IWM', displayName: 'Russell');
      const b = BenchmarkIndexConfig(symbol: 'IWM', displayName: 'Russell');
      expect(a, equals(b));
    });

    test('inequality when symbol differs', () {
      const a = BenchmarkIndexConfig(symbol: 'IWM', displayName: 'Russell');
      const b = BenchmarkIndexConfig(symbol: 'SPY', displayName: 'Russell');
      expect(a, isNot(equals(b)));
    });
  });
}
