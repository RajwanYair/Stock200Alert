import 'package:cross_tide/src/domain/custom_indicator_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('IndicatorType', () {
    test('label returns correct string', () {
      expect(IndicatorType.sma.label, 'SMA');
      expect(IndicatorType.ema.label, 'EMA');
    });

    test('values contains both types', () {
      expect(IndicatorType.values, hasLength(2));
    });
  });

  group('CustomIndicatorConfig', () {
    const config = CustomIndicatorConfig(type: IndicatorType.sma, period: 20);

    test('can be constructed at runtime', () {
      const CustomIndicatorConfig Function({
        required IndicatorType type,
        required int period,
      })
      create = CustomIndicatorConfig.new;
      final runtime = create(type: IndicatorType.ema, period: 50);
      expect(runtime.period, 50);
    });

    test('defaultLabel formats type and period', () {
      expect(config.defaultLabel, 'SMA 20');
      const ema = CustomIndicatorConfig(type: IndicatorType.ema, period: 50);
      expect(ema.defaultLabel, 'EMA 50');
    });

    test('displayLabel prefers custom label', () {
      expect(config.displayLabel, 'SMA 20');
      final custom = config.copyWith(label: 'Fast MA');
      expect(custom.displayLabel, 'Fast MA');
    });

    test('isValid accepts periods within range', () {
      expect(config.isValid, isTrue);
      const tooSmall = CustomIndicatorConfig(
        type: IndicatorType.sma,
        period: 1,
      );
      expect(tooSmall.isValid, isFalse);
      const tooLarge = CustomIndicatorConfig(
        type: IndicatorType.sma,
        period: 501,
      );
      expect(tooLarge.isValid, isFalse);
    });

    test('boundary periods are valid', () {
      const min = CustomIndicatorConfig(
        type: IndicatorType.sma,
        period: CustomIndicatorConfig.minPeriod,
      );
      expect(min.isValid, isTrue);
      const max = CustomIndicatorConfig(
        type: IndicatorType.sma,
        period: CustomIndicatorConfig.maxPeriod,
      );
      expect(max.isValid, isTrue);
    });

    test('equatable compares by value', () {
      const a = CustomIndicatorConfig(type: IndicatorType.sma, period: 20);
      const b = CustomIndicatorConfig(type: IndicatorType.sma, period: 20);
      expect(a, equals(b));
    });

    test('different configs are not equal', () {
      const a = CustomIndicatorConfig(type: IndicatorType.sma, period: 20);
      const b = CustomIndicatorConfig(type: IndicatorType.ema, period: 20);
      expect(a, isNot(equals(b)));
    });

    test('copyWith preserves fields', () {
      const original = CustomIndicatorConfig(
        id: 1,
        type: IndicatorType.sma,
        period: 20,
        symbol: 'AAPL',
        alertOnCrossover: true,
        colorValue: 0xFF00FF00,
        label: 'My SMA',
      );
      final copied = original.copyWith(period: 50);
      expect(copied.period, 50);
      expect(copied.type, IndicatorType.sma);
      expect(copied.symbol, 'AAPL');
      expect(copied.alertOnCrossover, isTrue);
      expect(copied.colorValue, 0xFF00FF00);
      expect(copied.label, 'My SMA');
    });

    test('props includes all fields', () {
      expect(config.props, hasLength(7));
    });

    test('default alertOnCrossover is false', () {
      expect(config.alertOnCrossover, isFalse);
    });

    test('global config has null symbol', () {
      expect(config.symbol, isNull);
    });

    test('scoped config has symbol', () {
      const scoped = CustomIndicatorConfig(
        type: IndicatorType.ema,
        period: 12,
        symbol: 'MSFT',
      );
      expect(scoped.symbol, 'MSFT');
    });
  });
}
