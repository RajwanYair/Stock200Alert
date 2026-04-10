import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SignalCalibrationRecord', () {
    test('creates instance with required fields', () {
      final record = SignalCalibrationRecord(
        methodName: 'RSI',
        symbol: 'AAPL',
        totalSignals: 20,
        correctSignals: 15,
        calibratedAt: DateTime(2025, 1, 1),
      );
      expect(record.methodName, 'RSI');
      expect(record.totalSignals, 20);
      expect(record.correctSignals, 15);
      expect(record.periodDays, 90);
    });

    test('accuracy computes correctly', () {
      final record = SignalCalibrationRecord(
        methodName: 'MACD',
        symbol: 'TSLA',
        totalSignals: 10,
        correctSignals: 8,
        calibratedAt: DateTime(2025, 3, 1),
      );
      expect(record.accuracy, closeTo(0.8, 0.001));
      expect(record.accuracyPercent, closeTo(80.0, 0.001));
    });

    test('accuracy is 1.0 when no signals', () {
      final record = SignalCalibrationRecord(
        methodName: 'Micho',
        symbol: 'MSFT',
        totalSignals: 0,
        correctSignals: 0,
        calibratedAt: DateTime(2025, 6, 1),
      );
      expect(record.accuracy, 1.0);
      expect(record.hasSignals, isFalse);
    });

    test('isReliable requires accuracy >= 0.60', () {
      final reliable = SignalCalibrationRecord(
        methodName: 'CCI',
        symbol: 'AMZN',
        totalSignals: 10,
        correctSignals: 7,
        calibratedAt: DateTime(2025, 1, 1),
      );
      expect(reliable.isReliable, isTrue);

      final unreliable = SignalCalibrationRecord(
        methodName: 'CCI',
        symbol: 'AMZN',
        totalSignals: 10,
        correctSignals: 5,
        calibratedAt: DateTime(2025, 1, 1),
      );
      expect(unreliable.isReliable, isFalse);
    });

    test('isHighlyReliable requires accuracy >= 0.80', () {
      final record = SignalCalibrationRecord(
        methodName: 'SAR',
        symbol: 'GOOGL',
        totalSignals: 5,
        correctSignals: 4,
        calibratedAt: DateTime(2025, 2, 1),
      );
      expect(record.isHighlyReliable, isTrue);
    });

    test('incorrectSignals computed correctly', () {
      final record = SignalCalibrationRecord(
        methodName: 'ADX',
        symbol: 'NVDA',
        totalSignals: 12,
        correctSignals: 9,
        calibratedAt: DateTime(2025, 4, 1),
      );
      expect(record.incorrectSignals, 3);
    });

    test('equality holds for identical records', () {
      final at = DateTime(2025, 5, 1);
      final a = SignalCalibrationRecord(
        methodName: 'RSI',
        symbol: 'AAPL',
        totalSignals: 10,
        correctSignals: 8,
        calibratedAt: at,
      );
      final b = SignalCalibrationRecord(
        methodName: 'RSI',
        symbol: 'AAPL',
        totalSignals: 10,
        correctSignals: 8,
        calibratedAt: at,
      );
      expect(a, equals(b));
    });
  });
}
