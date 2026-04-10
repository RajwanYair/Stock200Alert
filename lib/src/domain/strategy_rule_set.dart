import 'package:equatable/equatable.dart';

/// A named, reusable set of rules that governs strategy activation.
class StrategyRuleSet extends Equatable {
  const StrategyRuleSet({
    required this.id,
    required this.name,
    required this.rules,
    required this.activatedAt,
    this.isActive = false,
    this.description,
  }) : assert(rules.length > 0, 'rules must not be empty');

  final String id;
  final String name;

  /// Human-readable rule expressions (e.g. 'RSI < 30', 'price > MA200').
  final List<String> rules;
  final DateTime activatedAt;
  final bool isActive;
  final String? description;

  int get ruleCount => rules.length;
  bool get hasDescription => description != null && description!.isNotEmpty;

  StrategyRuleSet activate() => StrategyRuleSet(
    id: id,
    name: name,
    rules: rules,
    activatedAt: activatedAt,
    isActive: true,
    description: description,
  );

  StrategyRuleSet deactivate() => StrategyRuleSet(
    id: id,
    name: name,
    rules: rules,
    activatedAt: activatedAt,
    isActive: false,
    description: description,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    rules,
    activatedAt,
    isActive,
    description,
  ];
}
