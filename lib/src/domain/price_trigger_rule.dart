import 'package:equatable/equatable.dart';

/// Condition type for a price-level trigger.
enum PriceTriggerCondition {
  crossesAbove,
  crossesBelow,
  percentChangeUp,
  percentChangeDown,
}

/// Lifecycle status of a [PriceTriggerRule].
enum PriceTriggerStatus { active, triggered, expired, disabled }

/// A declarative rule that fires when a price condition is met.
class PriceTriggerRule extends Equatable {
  const PriceTriggerRule({
    required this.id,
    required this.ticker,
    required this.condition,
    required this.threshold,
    required this.createdAt,
    this.status = PriceTriggerStatus.active,
    this.validUntil,
    this.triggerOnce = true,
    this.note,
  }) : assert(threshold > 0, 'threshold must be positive');

  final String id;
  final String ticker;
  final PriceTriggerCondition condition;

  /// Absolute price level or percentage value depending on [condition].
  final double threshold;
  final DateTime createdAt;
  final PriceTriggerStatus status;

  /// Optional expiry; rule auto-expires after this date.
  final DateTime? validUntil;

  /// When `true`, the rule disables itself after the first trigger.
  final bool triggerOnce;
  final String? note;

  bool get isActive => status == PriceTriggerStatus.active;
  bool get hasExpiry => validUntil != null;

  bool isExpiredAt(DateTime now) =>
      validUntil != null && now.isAfter(validUntil!);

  PriceTriggerRule withStatus(PriceTriggerStatus newStatus) => PriceTriggerRule(
    id: id,
    ticker: ticker,
    condition: condition,
    threshold: threshold,
    createdAt: createdAt,
    status: newStatus,
    validUntil: validUntil,
    triggerOnce: triggerOnce,
    note: note,
  );

  @override
  List<Object?> get props => [
    id,
    ticker,
    condition,
    threshold,
    createdAt,
    status,
    validUntil,
    triggerOnce,
    note,
  ];
}
