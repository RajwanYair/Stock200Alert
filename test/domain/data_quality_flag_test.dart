import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataQualityFlag', () {
    late DateTime candleDate;
    late DateTime detectedAt;

    setUp(() {
      candleDate = DateTime(2025, 5, 20);
      detectedAt = DateTime(2025, 5, 21);
    });

    test('creates flag with required fields', () {
      final flag = DataQualityFlag(
        symbol: 'AAPL',
        candleDate: candleDate,
        flagType: DataQualityFlagType.gap,
        severity: DataQualitySeverity.warning,
      );
      expect(flag.symbol, 'AAPL');
      expect(flag.flagType, DataQualityFlagType.gap);
      expect(flag.severity, DataQualitySeverity.warning);
      expect(flag.isWarning, isTrue);
      expect(flag.isCritical, isFalse);
      expect(flag.isInfo, isFalse);
      expect(flag.requiresAction, isTrue);
    });

    test('critical flag requiresAction and isCritical', () {
      final flag = DataQualityFlag(
        symbol: 'TSLA',
        candleDate: candleDate,
        flagType: DataQualityFlagType.missing,
        severity: DataQualitySeverity.critical,
        message: 'Missing close price',
        detectedAt: detectedAt,
      );
      expect(flag.isCritical, isTrue);
      expect(flag.requiresAction, isTrue);
      expect(flag.message, 'Missing close price');
    });

    test('info flag does not requiresAction', () {
      final flag = DataQualityFlag(
        symbol: 'MSFT',
        candleDate: candleDate,
        flagType: DataQualityFlagType.stale,
        severity: DataQualitySeverity.info,
      );
      expect(flag.isInfo, isTrue);
      expect(flag.requiresAction, isFalse);
    });

    test('all flag types are instantiable', () {
      for (final type in DataQualityFlagType.values) {
        final flag = DataQualityFlag(
          symbol: 'X',
          candleDate: candleDate,
          flagType: type,
          severity: DataQualitySeverity.info,
        );
        expect(flag.flagType, type);
      }
    });

    test('equality holds for identical flags', () {
      final a = DataQualityFlag(
        symbol: 'Z',
        candleDate: candleDate,
        flagType: DataQualityFlagType.spike,
        severity: DataQualitySeverity.warning,
      );
      final b = DataQualityFlag(
        symbol: 'Z',
        candleDate: candleDate,
        flagType: DataQualityFlagType.spike,
        severity: DataQualitySeverity.warning,
      );
      expect(a, equals(b));
    });
  });
}
