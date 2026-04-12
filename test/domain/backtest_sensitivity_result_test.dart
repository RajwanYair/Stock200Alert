import 'package:cross_tide/src/domain/backtest_sensitivity_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BacktestSensitivityResult', () {
    test('equality', () {
      final a = BacktestSensitivityResult(
        backtestId: 'bt1',
        ticker: 'SPY',
        axisX: const SensitivityAxis(
          parameterName: 'period',
          minValue: 10,
          maxValue: 200,
          stepSize: 10,
        ),
        axisY: const SensitivityAxis(
          parameterName: 'threshold',
          minValue: 1,
          maxValue: 10,
          stepSize: 1,
        ),
        cells: const [],
        generatedAt: DateTime(2025, 7, 1),
      );
      final b = BacktestSensitivityResult(
        backtestId: 'bt1',
        ticker: 'SPY',
        axisX: const SensitivityAxis(
          parameterName: 'period',
          minValue: 10,
          maxValue: 200,
          stepSize: 10,
        ),
        axisY: const SensitivityAxis(
          parameterName: 'threshold',
          minValue: 1,
          maxValue: 10,
          stepSize: 1,
        ),
        cells: const [],
        generatedAt: DateTime(2025, 7, 1),
      );
      expect(a, b);
    });

    test('copyWith changes ticker', () {
      final base = BacktestSensitivityResult(
        backtestId: 'bt1',
        ticker: 'SPY',
        axisX: const SensitivityAxis(
          parameterName: 'period',
          minValue: 10,
          maxValue: 200,
          stepSize: 10,
        ),
        axisY: const SensitivityAxis(
          parameterName: 'threshold',
          minValue: 1,
          maxValue: 10,
          stepSize: 1,
        ),
        cells: const [],
        generatedAt: DateTime(2025, 7, 1),
      );
      final updated = base.copyWith(ticker: 'QQQ');
      expect(updated.ticker, 'QQQ');
    });

    test('props length is 6', () {
      final obj = BacktestSensitivityResult(
        backtestId: 'bt1',
        ticker: 'SPY',
        axisX: const SensitivityAxis(
          parameterName: 'period',
          minValue: 10,
          maxValue: 200,
          stepSize: 10,
        ),
        axisY: const SensitivityAxis(
          parameterName: 'threshold',
          minValue: 1,
          maxValue: 10,
          stepSize: 1,
        ),
        cells: const [],
        generatedAt: DateTime(2025, 7, 1),
      );
      expect(obj.props.length, 6);
    });
  });
}
