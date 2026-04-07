import 'package:cross_tide/src/domain/alert_rule_evaluator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const evaluator = AlertRuleEvaluator();

  group('AlertCondition', () {
    test('evaluates greater-than correctly', () {
      const cond = AlertCondition(
        leftVariable: 'sma50',
        op: CompareOp.greaterThan,
        rightVariable: 'sma200',
      );
      const ctx = RuleContext(
        ticker: 'AAPL',
        close: 150,
        values: {'sma50': 160, 'sma200': 140},
      );
      expect(cond.evaluate(ctx), isTrue);
    });

    test('returns null when variable is missing', () {
      const cond = AlertCondition(
        leftVariable: 'sma50',
        op: CompareOp.greaterThan,
        rightVariable: 'sma200',
      );
      const ctx = RuleContext(
        ticker: 'AAPL',
        close: 150,
        values: {'sma50': 160},
      );
      expect(cond.evaluate(ctx), isNull);
    });

    test('evaluates with literal right-hand value', () {
      const cond = AlertCondition(
        leftVariable: 'rsi',
        op: CompareOp.lessThan,
        rightVariable: null,
        rightLiteral: 30,
      );
      const ctx = RuleContext(ticker: 'AAPL', close: 150, values: {'rsi': 25});
      expect(cond.evaluate(ctx), isTrue);
    });

    test('equal uses epsilon comparison', () {
      const cond = AlertCondition(
        leftVariable: 'close',
        op: CompareOp.equal,
        rightVariable: null,
        rightLiteral: 150.0,
      );
      const ctx = RuleContext(ticker: 'AAPL', close: 150.0, values: {});
      expect(cond.evaluate(ctx), isTrue);
    });

    test('lessOrEqual returns true when equal', () {
      const cond = AlertCondition(
        leftVariable: 'close',
        op: CompareOp.lessOrEqual,
        rightVariable: null,
        rightLiteral: 100,
      );
      const ctx = RuleContext(ticker: 'X', close: 100, values: {});
      expect(cond.evaluate(ctx), isTrue);
    });

    test('props equality', () {
      const a = AlertCondition(
        leftVariable: 'rsi',
        op: CompareOp.lessThan,
        rightVariable: null,
        rightLiteral: 30,
      );
      const b = AlertCondition(
        leftVariable: 'rsi',
        op: CompareOp.lessThan,
        rightVariable: null,
        rightLiteral: 30,
      );
      expect(a, equals(b));
    });
  });

  group('AlertRuleEvaluator', () {
    test('triggers when all conditions met', () {
      const rule = AlertRule(
        name: 'Buy dip',
        conditions: [
          AlertCondition(
            leftVariable: 'sma50',
            op: CompareOp.greaterThan,
            rightVariable: 'sma200',
          ),
          AlertCondition(
            leftVariable: 'rsi',
            op: CompareOp.lessThan,
            rightVariable: null,
            rightLiteral: 30,
          ),
        ],
        action: RuleAction.buy,
      );
      const ctx = RuleContext(
        ticker: 'AAPL',
        close: 150,
        values: {'sma50': 160, 'sma200': 140, 'rsi': 25},
      );
      final result = evaluator.evaluate(rule, ctx);
      expect(result.triggered, isTrue);
    });

    test('does not trigger when one condition fails', () {
      const rule = AlertRule(
        name: 'Buy dip',
        conditions: [
          AlertCondition(
            leftVariable: 'rsi',
            op: CompareOp.lessThan,
            rightVariable: null,
            rightLiteral: 30,
          ),
        ],
        action: RuleAction.buy,
      );
      const ctx = RuleContext(ticker: 'AAPL', close: 150, values: {'rsi': 50});
      expect(evaluator.evaluate(rule, ctx).triggered, isFalse);
    });

    test('disabled rule never triggers', () {
      const rule = AlertRule(
        name: 'Disabled',
        conditions: [],
        action: RuleAction.alert,
        enabled: false,
      );
      const ctx = RuleContext(ticker: 'X', close: 100, values: {});
      expect(evaluator.evaluate(rule, ctx).triggered, isFalse);
    });

    test('evaluateAll returns only triggered rules', () {
      const rules = [
        AlertRule(
          name: 'A',
          conditions: [
            AlertCondition(
              leftVariable: 'close',
              op: CompareOp.greaterThan,
              rightVariable: null,
              rightLiteral: 100,
            ),
          ],
          action: RuleAction.buy,
        ),
        AlertRule(
          name: 'B',
          conditions: [
            AlertCondition(
              leftVariable: 'close',
              op: CompareOp.lessThan,
              rightVariable: null,
              rightLiteral: 50,
            ),
          ],
          action: RuleAction.sell,
        ),
      ];
      const ctx = RuleContext(ticker: 'X', close: 120, values: {});
      final results = evaluator.evaluateAll(rules, ctx);
      expect(results, hasLength(1));
      expect(results.first.rule.name, 'A');
    });

    test('RuleEvaluationResult props equality', () {
      const rule = AlertRule(
        name: 'R',
        conditions: [],
        action: RuleAction.alert,
      );
      const a = RuleEvaluationResult(rule: rule, triggered: true, ticker: 'X');
      const b = RuleEvaluationResult(rule: rule, triggered: true, ticker: 'X');
      expect(a, equals(b));
    });
  });
}
