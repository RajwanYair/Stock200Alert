import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StrategyRuleSet', () {
    late DateTime activatedAt;

    setUp(() => activatedAt = DateTime(2025, 6, 1));

    test('creates inactive rule set', () {
      final rs = StrategyRuleSet(
        id: 'rs-1',
        name: 'Momentum',
        rules: const ['RSI < 30', 'price > MA200'],
        activatedAt: activatedAt,
      );
      expect(rs.isActive, isFalse);
      expect(rs.ruleCount, 2);
      expect(rs.hasDescription, isFalse);
    });

    test('activate() returns active rule set', () {
      final rs = StrategyRuleSet(
        id: 'rs-2',
        name: 'Test',
        rules: const ['MACD > signal'],
        activatedAt: activatedAt,
      );
      final active = rs.activate();
      expect(active.isActive, isTrue);
      expect(active.id, 'rs-2');
    });

    test('deactivate() returns inactive rule set', () {
      final rs = StrategyRuleSet(
        id: 'rs-3',
        name: 'Test',
        rules: const ['rule1'],
        activatedAt: activatedAt,
        isActive: true,
      );
      final inactive = rs.deactivate();
      expect(inactive.isActive, isFalse);
    });

    test('hasDescription is true when description provided', () {
      final rs = StrategyRuleSet(
        id: 'rs-4',
        name: 'Described',
        rules: const ['r1'],
        activatedAt: activatedAt,
        description: 'A strategy',
      );
      expect(rs.hasDescription, isTrue);
    });

    test('equality holds for identical rule sets', () {
      final a = StrategyRuleSet(
        id: 'x',
        name: 'A',
        rules: const ['r'],
        activatedAt: activatedAt,
      );
      final b = StrategyRuleSet(
        id: 'x',
        name: 'A',
        rules: const ['r'],
        activatedAt: activatedAt,
      );
      expect(a, equals(b));
    });
  });
}
