/// Alert Rule DSL — declarative rules engine for custom alert conditions.
///
/// Users define conditions like:
/// ```
/// IF sma50 > sma200 AND rsi < 30 THEN BUY
/// IF close < bollingerLower THEN SELL
/// ```
///
/// Rules are parsed into an AST of [AlertCondition] nodes and evaluated
/// against a [RuleContext] snapshot.
library;

import 'package:equatable/equatable.dart';

/// Snapshot of indicator values for rule evaluation.
class RuleContext extends Equatable {
  const RuleContext({
    required this.ticker,
    required this.close,
    required this.values,
  });

  final String ticker;
  final double close;

  /// Named values: 'sma50', 'sma200', 'rsi', 'macd', 'bollingerUpper', etc.
  final Map<String, double> values;

  /// Resolve a variable name to its value. Returns `null` if unknown.
  double? resolve(String variable) {
    if (variable == 'close') return close;
    return values[variable];
  }

  @override
  List<Object?> get props => [ticker, close, values];
}

/// Comparison operators supported in alert conditions.
enum CompareOp { greaterThan, lessThan, greaterOrEqual, lessOrEqual, equal }

/// A single comparison condition: `left <op> right`.
class AlertCondition extends Equatable {
  const AlertCondition({
    required this.leftVariable,
    required this.op,
    required this.rightVariable,
    this.rightLiteral,
  });

  /// Left-hand variable name (e.g. 'sma50', 'close', 'rsi').
  final String leftVariable;

  final CompareOp op;

  /// Right-hand variable name (e.g. 'sma200'). Null if [rightLiteral] is set.
  final String? rightVariable;

  /// Right-hand literal value. Null if [rightVariable] is set.
  final double? rightLiteral;

  /// Evaluate this condition against [ctx]. Returns null if a variable is
  /// not available in the context.
  bool? evaluate(RuleContext ctx) {
    final left = ctx.resolve(leftVariable);
    if (left == null) return null;

    final double? right;
    if (rightLiteral != null) {
      right = rightLiteral;
    } else if (rightVariable != null) {
      right = ctx.resolve(rightVariable!);
    } else {
      return null;
    }
    if (right == null) return null;

    return switch (op) {
      CompareOp.greaterThan => left > right,
      CompareOp.lessThan => left < right,
      CompareOp.greaterOrEqual => left >= right,
      CompareOp.lessOrEqual => left <= right,
      CompareOp.equal => (left - right).abs() < 1e-9,
    };
  }

  @override
  List<Object?> get props => [leftVariable, op, rightVariable, rightLiteral];
}

/// The action to take when a rule's conditions are met.
enum RuleAction { buy, sell, alert }

/// A complete alert rule: conditions + action.
class AlertRule extends Equatable {
  const AlertRule({
    required this.name,
    required this.conditions,
    required this.action,
    this.enabled = true,
  });

  final String name;
  final List<AlertCondition> conditions;
  final RuleAction action;
  final bool enabled;

  @override
  List<Object?> get props => [name, conditions, action, enabled];
}

/// Result of evaluating one alert rule.
class RuleEvaluationResult extends Equatable {
  const RuleEvaluationResult({
    required this.rule,
    required this.triggered,
    required this.ticker,
  });

  final AlertRule rule;
  final bool triggered;
  final String ticker;

  @override
  List<Object?> get props => [rule.name, triggered, ticker];
}

/// Evaluates [AlertRule] objects against a [RuleContext].
class AlertRuleEvaluator {
  const AlertRuleEvaluator();

  /// Evaluate a single rule. All conditions must be true (AND logic).
  /// Returns not-triggered if any condition's variable is unavailable.
  RuleEvaluationResult evaluate(AlertRule rule, RuleContext ctx) {
    if (!rule.enabled) {
      return RuleEvaluationResult(
        rule: rule,
        triggered: false,
        ticker: ctx.ticker,
      );
    }

    for (final AlertCondition cond in rule.conditions) {
      final result = cond.evaluate(ctx);
      if (result == null || !result) {
        return RuleEvaluationResult(
          rule: rule,
          triggered: false,
          ticker: ctx.ticker,
        );
      }
    }

    return RuleEvaluationResult(
      rule: rule,
      triggered: true,
      ticker: ctx.ticker,
    );
  }

  /// Evaluate multiple rules, returning only the triggered ones.
  List<RuleEvaluationResult> evaluateAll(
    List<AlertRule> rules,
    RuleContext ctx,
  ) {
    return rules
        .map((AlertRule r) => evaluate(r, ctx))
        .where((RuleEvaluationResult r) => r.triggered)
        .toList();
  }
}
