import 'package:cross_tide/src/domain/chart_layer_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChartLayerConfig', () {
    test('equality', () {
      const a = ChartLayerConfig(
        layerId: 'l-1',
        layerType: ChartLayerType.sma,
        color: '#FF6B6B',
        lineWidth: 1.5,
        isVisible: true,
      );
      const b = ChartLayerConfig(
        layerId: 'l-1',
        layerType: ChartLayerType.sma,
        color: '#FF6B6B',
        lineWidth: 1.5,
        isVisible: true,
      );
      expect(a, b);
    });

    test('copyWith changes isVisible', () {
      const base = ChartLayerConfig(
        layerId: 'l-1',
        layerType: ChartLayerType.sma,
        color: '#FF6B6B',
        lineWidth: 1.5,
        isVisible: true,
      );
      final updated = base.copyWith(isVisible: false);
      expect(updated.isVisible, false);
    });

    test('props length is 5', () {
      const obj = ChartLayerConfig(
        layerId: 'l-1',
        layerType: ChartLayerType.sma,
        color: '#FF6B6B',
        lineWidth: 1.5,
        isVisible: true,
      );
      expect(obj.props.length, 5);
    });
  });
}
