import 'package:cross_tide/src/domain/signal_cascade_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignalCascadeConfig', () {
    test('equality', () {
      const a = SignalCascadeConfig(
        configId: 'cfg-1',
        name: 'Multi-confirm',
        triggerMode: CascadeTriggerMode.threshold,
        minimumSignals: 3,
        isEnabled: true,
      );
      const b = SignalCascadeConfig(
        configId: 'cfg-1',
        name: 'Multi-confirm',
        triggerMode: CascadeTriggerMode.threshold,
        minimumSignals: 3,
        isEnabled: true,
      );
      expect(a, b);
    });

    test('copyWith changes minimumSignals', () {
      const base = SignalCascadeConfig(
        configId: 'cfg-1',
        name: 'Multi-confirm',
        triggerMode: CascadeTriggerMode.threshold,
        minimumSignals: 3,
        isEnabled: true,
      );
      final updated = base.copyWith(minimumSignals: 2);
      expect(updated.minimumSignals, 2);
    });

    test('props length is 5', () {
      const obj = SignalCascadeConfig(
        configId: 'cfg-1',
        name: 'Multi-confirm',
        triggerMode: CascadeTriggerMode.threshold,
        minimumSignals: 3,
        isEnabled: true,
      );
      expect(obj.props.length, 5);
    });
  });
}
