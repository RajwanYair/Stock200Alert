import 'package:cross_tide/src/domain/earnings_surprise_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EarningsSurpriseRecord', () {
    test('equality', () {
      final a = EarningsSurpriseRecord(
        ticker: 'AMZN',
        fiscalQuarter: 'Q3 2025',
        actualEps: 1.43,
        estimatedEps: 1.30,
        surprisePercent: 10.0,
        direction: EarningsSurpriseDirection.beat,
        reportedAt: DateTime(2025, 10, 28),
      );
      final b = EarningsSurpriseRecord(
        ticker: 'AMZN',
        fiscalQuarter: 'Q3 2025',
        actualEps: 1.43,
        estimatedEps: 1.30,
        surprisePercent: 10.0,
        direction: EarningsSurpriseDirection.beat,
        reportedAt: DateTime(2025, 10, 28),
      );
      expect(a, b);
    });

    test('copyWith changes surprisePercent', () {
      final base = EarningsSurpriseRecord(
        ticker: 'AMZN',
        fiscalQuarter: 'Q3 2025',
        actualEps: 1.43,
        estimatedEps: 1.30,
        surprisePercent: 10.0,
        direction: EarningsSurpriseDirection.beat,
        reportedAt: DateTime(2025, 10, 28),
      );
      final updated = base.copyWith(surprisePercent: 12.0);
      expect(updated.surprisePercent, 12.0);
    });

    test('props length is 7', () {
      final obj = EarningsSurpriseRecord(
        ticker: 'AMZN',
        fiscalQuarter: 'Q3 2025',
        actualEps: 1.43,
        estimatedEps: 1.30,
        surprisePercent: 10.0,
        direction: EarningsSurpriseDirection.beat,
        reportedAt: DateTime(2025, 10, 28),
      );
      expect(obj.props.length, 7);
    });
  });
}
