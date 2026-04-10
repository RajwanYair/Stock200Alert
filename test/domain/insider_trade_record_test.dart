import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InsiderTradeRecord', () {
    late DateTime filedDate;

    setUp(() => filedDate = DateTime(2025, 5, 15));

    test('creates buy record with computed values', () {
      final record = InsiderTradeRecord(
        symbol: 'MSFT',
        insiderName: 'Satya Nadella',
        title: 'CEO',
        tradeType: InsiderTradeType.purchase,
        shares: 1000,
        pricePerShare: 420.0,
        filedDate: filedDate,
      );
      expect(record.isBuy, isTrue);
      expect(record.isSell, isFalse);
      expect(record.totalValue, closeTo(420_000.0, 0.001));
      expect(record.isSignificant, isFalse);
    });

    test('isSignificant true when totalValue >= 1M', () {
      final record = InsiderTradeRecord(
        symbol: 'AAPL',
        insiderName: 'Tim Cook',
        title: 'CEO',
        tradeType: InsiderTradeType.sale,
        shares: 10000,
        pricePerShare: 200.0,
        filedDate: filedDate,
      );
      expect(record.isSell, isTrue);
      expect(record.totalValue, closeTo(2_000_000.0, 0.001));
      expect(record.isSignificant, isTrue);
    });

    test('secFormType and transactionDate are optional', () {
      final record = InsiderTradeRecord(
        symbol: 'NVDA',
        insiderName: 'Jensen Huang',
        title: 'CEO',
        tradeType: InsiderTradeType.grantAward,
        shares: 5000,
        pricePerShare: 0.0,
        filedDate: filedDate,
        secFormType: 'Form 4',
        transactionDate: DateTime(2025, 5, 10),
      );
      expect(record.secFormType, 'Form 4');
      expect(record.transactionDate, isNotNull);
    });

    test('equality holds for identical records', () {
      final a = InsiderTradeRecord(
        symbol: 'X',
        insiderName: 'A',
        title: 'CFO',
        tradeType: InsiderTradeType.sale,
        shares: 100,
        pricePerShare: 50.0,
        filedDate: filedDate,
      );
      final b = InsiderTradeRecord(
        symbol: 'X',
        insiderName: 'A',
        title: 'CFO',
        tradeType: InsiderTradeType.sale,
        shares: 100,
        pricePerShare: 50.0,
        filedDate: filedDate,
      );
      expect(a, equals(b));
    });
  });
}
