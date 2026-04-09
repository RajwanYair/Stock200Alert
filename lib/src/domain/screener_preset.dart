import 'package:equatable/equatable.dart';

/// Indicator fields available for screener conditions.
enum ScreenerConditionField {
  rsi14,
  macd,
  sma50,
  sma150,
  sma200,
  adx14,
  volumeRatio,
  pctFromSma200,
  dayChange,
}

/// Comparison operation for a [ScreenerCondition].
enum ScreenerCompareOp { greaterThan, lessThan, crossesAbove, crossesBelow }

/// A single filter condition: [field] [op] [value].
class ScreenerCondition extends Equatable {
  const ScreenerCondition({
    required this.field,
    required this.op,
    required this.value,
  });

  final ScreenerConditionField field;
  final ScreenerCompareOp op;
  final double value;

  @override
  List<Object?> get props => [field, op, value];
}

/// A saved, named set of screener conditions.
class ScreenerPreset extends Equatable {
  const ScreenerPreset({
    required this.id,
    required this.name,
    required this.conditions,
    this.description,
    this.isBuiltIn = false,
    this.createdAt,
  });

  final String id;
  final String name;
  final List<ScreenerCondition> conditions;
  final String? description;
  final bool isBuiltIn;
  final DateTime? createdAt;

  bool get hasConditions => conditions.isNotEmpty;

  ScreenerPreset withCondition(ScreenerCondition condition) => ScreenerPreset(
    id: id,
    name: name,
    conditions: [...conditions, condition],
    description: description,
    isBuiltIn: isBuiltIn,
    createdAt: createdAt,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    conditions,
    description,
    isBuiltIn,
    createdAt,
  ];
}
