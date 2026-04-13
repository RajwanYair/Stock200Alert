import 'package:equatable/equatable.dart';

/// Macro event impact — historical market impact estimate for macro events.
enum MacroImpactLevel { negligible, low, medium, high, extreme }

class MacroEventImpact extends Equatable {
  const MacroEventImpact({
    required this.eventName,
    required this.assetClass,
    required this.impactLevel,
    required this.expectedMovePct,
    required this.historicalInstances,
  });

  final String eventName;
  final String assetClass;
  final MacroImpactLevel impactLevel;
  final double expectedMovePct;
  final int historicalInstances;

  MacroEventImpact copyWith({
    String? eventName,
    String? assetClass,
    MacroImpactLevel? impactLevel,
    double? expectedMovePct,
    int? historicalInstances,
  }) => MacroEventImpact(
    eventName: eventName ?? this.eventName,
    assetClass: assetClass ?? this.assetClass,
    impactLevel: impactLevel ?? this.impactLevel,
    expectedMovePct: expectedMovePct ?? this.expectedMovePct,
    historicalInstances: historicalInstances ?? this.historicalInstances,
  );

  @override
  List<Object?> get props => [
    eventName,
    assetClass,
    impactLevel,
    expectedMovePct,
    historicalInstances,
  ];
}
