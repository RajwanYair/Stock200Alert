import 'package:cross_tide/src/domain/alert_batching_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlertBatchingConfig', () {
    test('equality', () {
      const a = AlertBatchingConfig(
        profileId: 'prof-1',
        strategy: BatchingStrategy.digest,
        batchWindowMinutes: 30,
        maxBatchSize: 10,
        isEnabled: true,
      );
      const b = AlertBatchingConfig(
        profileId: 'prof-1',
        strategy: BatchingStrategy.digest,
        batchWindowMinutes: 30,
        maxBatchSize: 10,
        isEnabled: true,
      );
      expect(a, b);
    });

    test('copyWith changes batchWindowMinutes', () {
      const base = AlertBatchingConfig(
        profileId: 'prof-1',
        strategy: BatchingStrategy.digest,
        batchWindowMinutes: 30,
        maxBatchSize: 10,
        isEnabled: true,
      );
      final updated = base.copyWith(batchWindowMinutes: 60);
      expect(updated.batchWindowMinutes, 60);
    });

    test('props length is 5', () {
      const obj = AlertBatchingConfig(
        profileId: 'prof-1',
        strategy: BatchingStrategy.digest,
        batchWindowMinutes: 30,
        maxBatchSize: 10,
        isEnabled: true,
      );
      expect(obj.props.length, 5);
    });
  });
}
