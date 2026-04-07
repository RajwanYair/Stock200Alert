import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BacktestStrategy', () {
    test('isEntry matches entry alert types', () {
      const BacktestStrategy strategy = BacktestStrategy(
        name: 'Micho',
        entryAlertTypes: {'michoMethodBuy'},
        exitAlertTypes: {'michoMethodSell'},
      );
      expect(strategy.isEntry('michoMethodBuy'), isTrue);
      expect(strategy.isEntry('rsiMethodBuy'), isFalse);
    });

    test('isExit matches exit alert types', () {
      const BacktestStrategy strategy = BacktestStrategy(
        name: 'Micho',
        entryAlertTypes: {'michoMethodBuy'},
        exitAlertTypes: {'michoMethodSell'},
      );
      expect(strategy.isExit('michoMethodSell'), isTrue);
      expect(strategy.isExit('michoMethodBuy'), isFalse);
    });

    test('hasRiskRules false when no rules', () {
      const BacktestStrategy strategy = BacktestStrategy(
        name: 'Micho',
        entryAlertTypes: {'michoMethodBuy'},
        exitAlertTypes: {'michoMethodSell'},
      );
      expect(strategy.hasRiskRules, isFalse);
    });

    test('hasRiskRules true with stop-loss', () {
      const BacktestStrategy strategy = BacktestStrategy(
        name: 'Micho',
        entryAlertTypes: {'michoMethodBuy'},
        exitAlertTypes: {'michoMethodSell'},
        stopLossPct: 5,
      );
      expect(strategy.hasRiskRules, isTrue);
    });

    test('hasRiskRules true with take-profit', () {
      const BacktestStrategy strategy = BacktestStrategy(
        name: 'Micho',
        entryAlertTypes: {'michoMethodBuy'},
        exitAlertTypes: {'michoMethodSell'},
        takeProfitPct: 10,
      );
      expect(strategy.hasRiskRules, isTrue);
    });

    test('hasRiskRules true with max holding days', () {
      const BacktestStrategy strategy = BacktestStrategy(
        name: 'Micho',
        entryAlertTypes: {'michoMethodBuy'},
        exitAlertTypes: {'michoMethodSell'},
        maxHoldingDays: 30,
      );
      expect(strategy.hasRiskRules, isTrue);
    });

    test('equality via Equatable', () {
      const BacktestStrategy a = BacktestStrategy(
        name: 'Micho',
        entryAlertTypes: {'michoMethodBuy'},
        exitAlertTypes: {'michoMethodSell'},
      );
      const BacktestStrategy b = BacktestStrategy(
        name: 'Micho',
        entryAlertTypes: {'michoMethodBuy'},
        exitAlertTypes: {'michoMethodSell'},
      );
      expect(a, equals(b));
    });
  });
}
