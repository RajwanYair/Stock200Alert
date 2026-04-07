import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AlertEvent', () {
    final now = DateTime(2024, 6, 15, 10, 30);

    test('const constructor and equality', () {
      final e1 = AlertEvent(
        ticker: 'AAPL',
        alertType: 'michoMethodBuy',
        firedAt: now,
        price: 150.0,
      );
      final e2 = AlertEvent(
        ticker: 'AAPL',
        alertType: 'michoMethodBuy',
        firedAt: now,
        price: 150.0,
      );
      expect(e1, equals(e2));
    });

    test('acknowledged defaults to false', () {
      final event = AlertEvent(
        ticker: 'AAPL',
        alertType: 'rsiMethodBuy',
        firedAt: now,
        price: 148.0,
      );
      expect(event.acknowledged, isFalse);
    });

    test('acknowledge returns new event with acknowledged=true', () {
      final event = AlertEvent(
        ticker: 'AAPL',
        alertType: 'michoMethodBuy',
        firedAt: now,
        price: 150.0,
        sma200: 145.0,
        methodName: 'Micho',
        description: 'Test',
      );
      final acked = event.acknowledge();
      expect(acked.acknowledged, isTrue);
      expect(acked.ticker, event.ticker);
      expect(acked.price, event.price);
      expect(acked.sma200, event.sma200);
    });

    test('toJson includes all non-null fields', () {
      final event = AlertEvent(
        ticker: 'AAPL',
        alertType: 'michoMethodBuy',
        firedAt: now,
        price: 150.0,
        sma200: 145.0,
        methodName: 'Micho',
        description: 'Cross-up detected',
      );
      final json = event.toJson();
      expect(json['ticker'], 'AAPL');
      expect(json['alertType'], 'michoMethodBuy');
      expect(json['price'], 150.0);
      expect(json['sma200'], 145.0);
      expect(json['methodName'], 'Micho');
      expect(json['description'], 'Cross-up detected');
      expect(json['acknowledged'], isFalse);
    });

    test('toJson omits null optional fields', () {
      final event = AlertEvent(
        ticker: 'AAPL',
        alertType: 'michoMethodBuy',
        firedAt: now,
        price: 150.0,
      );
      final json = event.toJson();
      expect(json.containsKey('sma200'), isFalse);
      expect(json.containsKey('methodName'), isFalse);
      expect(json.containsKey('description'), isFalse);
    });
  });
}
