import 'package:cross_tide/src/domain/signal_generator_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignalGeneratorConfig', () {
    test('equality', () {
      const a = SignalGeneratorConfig(
        configId: 'cfg1',
        name: 'Balanced',
        methodWeights: [],
        minimumConsensusCount: 2,
        buyThreshold: 0.6,
        sellThreshold: 0.4,
      );
      const b = SignalGeneratorConfig(
        configId: 'cfg1',
        name: 'Balanced',
        methodWeights: [],
        minimumConsensusCount: 2,
        buyThreshold: 0.6,
        sellThreshold: 0.4,
      );
      expect(a, b);
    });

    test('copyWith changes name', () {
      const base = SignalGeneratorConfig(
        configId: 'cfg1',
        name: 'Balanced',
        methodWeights: [],
        minimumConsensusCount: 2,
        buyThreshold: 0.6,
        sellThreshold: 0.4,
      );
      final updated = base.copyWith(name: 'Conservative');
      expect(updated.name, 'Conservative');
    });

    test('props length is 7', () {
      const obj = SignalGeneratorConfig(
        configId: 'cfg1',
        name: 'Balanced',
        methodWeights: [],
        minimumConsensusCount: 2,
        buyThreshold: 0.6,
        sellThreshold: 0.4,
      );
      expect(obj.props.length, 7);
    });
  });
}
