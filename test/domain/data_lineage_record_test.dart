import 'package:cross_tide/src/domain/data_lineage_record.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataLineageRecord', () {
    test('equality', () {
      final a = DataLineageRecord(
        recordId: 'rec1',
        sourceProvider: 'YahooFinance',
        ticker: 'GOOG',
        qualityTier: DataQualityTier.validated,
        transformationSteps: const ['normalize'],
        checksum: 'abc123',
        ingestedAt: DateTime(2025, 5, 1),
      );
      final b = DataLineageRecord(
        recordId: 'rec1',
        sourceProvider: 'YahooFinance',
        ticker: 'GOOG',
        qualityTier: DataQualityTier.validated,
        transformationSteps: const ['normalize'],
        checksum: 'abc123',
        ingestedAt: DateTime(2025, 5, 1),
      );
      expect(a, b);
    });

    test('copyWith changes sourceProvider', () {
      final base = DataLineageRecord(
        recordId: 'rec1',
        sourceProvider: 'YahooFinance',
        ticker: 'GOOG',
        qualityTier: DataQualityTier.validated,
        transformationSteps: const ['normalize'],
        checksum: 'abc123',
        ingestedAt: DateTime(2025, 5, 1),
      );
      final updated = base.copyWith(sourceProvider: 'Tiingo');
      expect(updated.sourceProvider, 'Tiingo');
    });

    test('props length is 7', () {
      final obj = DataLineageRecord(
        recordId: 'rec1',
        sourceProvider: 'YahooFinance',
        ticker: 'GOOG',
        qualityTier: DataQualityTier.validated,
        transformationSteps: const ['normalize'],
        checksum: 'abc123',
        ingestedAt: DateTime(2025, 5, 1),
      );
      expect(obj.props.length, 7);
    });
  });
}
