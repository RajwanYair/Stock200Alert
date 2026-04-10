import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataRetentionCategory', () {
    test('has 6 values', () {
      expect(DataRetentionCategory.values.length, 6);
    });
  });

  group('DataRetentionPolicy', () {
    test('isForever is true when retentionDays is -1', () {
      const p = DataRetentionPolicy(
        category: DataRetentionCategory.priceHistory,
        retentionDays: -1,
      );
      expect(p.isForever, isTrue);
    });

    test('isForever is false when retentionDays >= 0', () {
      const p = DataRetentionPolicy(
        category: DataRetentionCategory.alertHistory,
        retentionDays: 90,
      );
      expect(p.isForever, isFalse);
    });

    test('hasArchive is true when archiveAfterDays is set', () {
      const p = DataRetentionPolicy(
        category: DataRetentionCategory.auditLog,
        retentionDays: 365,
        archiveAfterDays: 30,
      );
      expect(p.hasArchive, isTrue);
    });

    test('hasArchive is false when archiveAfterDays is null', () {
      const p = DataRetentionPolicy(
        category: DataRetentionCategory.tradeJournal,
        retentionDays: 180,
      );
      expect(p.hasArchive, isFalse);
    });

    test('compressArchive defaults to false', () {
      const p = DataRetentionPolicy(
        category: DataRetentionCategory.notificationLog,
        retentionDays: 30,
      );
      expect(p.compressArchive, isFalse);
    });

    test('equality holds for same props', () {
      const a = DataRetentionPolicy(
        category: DataRetentionCategory.priceHistory,
        retentionDays: 365,
        archiveAfterDays: 90,
        compressArchive: true,
      );
      const b = DataRetentionPolicy(
        category: DataRetentionCategory.priceHistory,
        retentionDays: 365,
        archiveAfterDays: 90,
        compressArchive: true,
      );
      expect(a, equals(b));
    });
  });
}
