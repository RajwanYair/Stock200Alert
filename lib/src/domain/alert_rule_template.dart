/// Alert Rule Template — reusable named template for `AlertRuleEvaluator`
/// conditions that users can instantiate and customise (v2.0).
library;

import 'package:equatable/equatable.dart';

/// Broad category grouping for built-in and user-created rule templates.
enum RuleTemplateCategory {
  /// Templates based on SMA/EMA crossover conditions.
  movingAverageCrossover,

  /// Templates based on momentum indicators (RSI, MACD, Stochastic).
  momentumOscillator,

  /// Templates based on volatility bands (Bollinger, Keltner).
  volatilityBreakout,

  /// Templates that combine two or more methods (consensus-style).
  multiMethod,

  /// Custom user-defined templates.
  custom,
}

/// A configurable parameter within a rule template.
class TemplateParameter extends Equatable {
  const TemplateParameter({
    required this.key,
    required this.label,
    required this.defaultValue,
    this.minValue,
    this.maxValue,
  });

  /// Machine-readable key used in the rule expression.
  final String key;

  /// Human-readable label shown in the template editor.
  final String label;

  final double defaultValue;
  final double? minValue;
  final double? maxValue;

  bool get hasRange => minValue != null && maxValue != null;

  @override
  List<Object?> get props => [key, label, defaultValue, minValue, maxValue];
}

/// A named, shareable template for an alert rule.
class AlertRuleTemplate extends Equatable {
  const AlertRuleTemplate({
    required this.id,
    required this.name,
    required this.category,
    required this.conditionExpression,
    required this.parameters,
    this.description,
    this.isBuiltIn = false,
  });

  final String id;
  final String name;
  final RuleTemplateCategory category;

  /// DSL expression string compatible with `AlertRuleEvaluator`.
  final String conditionExpression;

  final List<TemplateParameter> parameters;
  final String? description;

  /// True if this template ships with the app (cannot be deleted).
  final bool isBuiltIn;

  /// Returns the default parameter map (key → defaultValue).
  Map<String, double> get defaultParameters => {
    for (final TemplateParameter p in parameters) p.key: p.defaultValue,
  };

  @override
  List<Object?> get props => [
    id,
    name,
    category,
    conditionExpression,
    parameters,
    description,
    isBuiltIn,
  ];
}
