import 'package:cross_tide/src/domain/computed_indicator_preset.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ComputedIndicatorPreset', () {
    test('equality', () {
      const a = ComputedIndicatorPreset(
        presetId: 'p-1',
        name: 'Momentum Suite',
        category: IndicatorPresetCategory.momentum,
        indicatorCount: 5,
        isDefault: true,
      );
      const b = ComputedIndicatorPreset(
        presetId: 'p-1',
        name: 'Momentum Suite',
        category: IndicatorPresetCategory.momentum,
        indicatorCount: 5,
        isDefault: true,
      );
      expect(a, b);
    });

    test('copyWith changes indicatorCount', () {
      const base = ComputedIndicatorPreset(
        presetId: 'p-1',
        name: 'Momentum Suite',
        category: IndicatorPresetCategory.momentum,
        indicatorCount: 5,
        isDefault: true,
      );
      final updated = base.copyWith(indicatorCount: 6);
      expect(updated.indicatorCount, 6);
    });

    test('props length is 5', () {
      const obj = ComputedIndicatorPreset(
        presetId: 'p-1',
        name: 'Momentum Suite',
        category: IndicatorPresetCategory.momentum,
        indicatorCount: 5,
        isDefault: true,
      );
      expect(obj.props.length, 5);
    });
  });
}
