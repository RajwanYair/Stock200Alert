import 'package:cross_tide/src/domain/signal_filter_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignalFilterConfig', () {
    test('equality', () {
      const a = SignalFilterConfig(
        filterId: 'f-1',
        filterField: SignalFilterField.ticker,
        filterOperator: 'equals',
        value: 'AAPL',
        isActive: true,
      );
      const b = SignalFilterConfig(
        filterId: 'f-1',
        filterField: SignalFilterField.ticker,
        filterOperator: 'equals',
        value: 'AAPL',
        isActive: true,
      );
      expect(a, b);
    });

    test('copyWith changes value', () {
      const base = SignalFilterConfig(
        filterId: 'f-1',
        filterField: SignalFilterField.ticker,
        filterOperator: 'equals',
        value: 'AAPL',
        isActive: true,
      );
      final updated = base.copyWith(value: 'MSFT');
      expect(updated.value, 'MSFT');
    });

    test('props length is 5', () {
      const obj = SignalFilterConfig(
        filterId: 'f-1',
        filterField: SignalFilterField.ticker,
        filterOperator: 'equals',
        value: 'AAPL',
        isActive: true,
      );
      expect(obj.props.length, 5);
    });
  });
}
