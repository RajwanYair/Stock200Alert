import 'package:equatable/equatable.dart';

/// Method weight contribution for a composite signal generator.
class MethodWeightEntry extends Equatable {
  const MethodWeightEntry({
    required this.methodName,
    required this.weight,
    required this.enabled,
  });

  final String methodName;

  /// Relative weight (0.0–1.0).
  final double weight;

  final bool enabled;

  MethodWeightEntry copyWith({
    String? methodName,
    double? weight,
    bool? enabled,
  }) => MethodWeightEntry(
    methodName: methodName ?? this.methodName,
    weight: weight ?? this.weight,
    enabled: enabled ?? this.enabled,
  );

  @override
  List<Object?> get props => [methodName, weight, enabled];
}

/// Configuration for a composite signal generator that aggregates
/// multiple trading method outputs with per-method weights.
class SignalGeneratorConfig extends Equatable {
  const SignalGeneratorConfig({
    required this.configId,
    required this.name,
    required this.methodWeights,
    required this.minimumConsensusCount,
    required this.buyThreshold,
    required this.sellThreshold,
    this.description,
  });

  final String configId;
  final String name;
  final List<MethodWeightEntry> methodWeights;

  /// Minimum number of methods that must agree to fire a signal.
  final int minimumConsensusCount;

  /// Weighted-score threshold for a BUY signal (0.0–1.0).
  final double buyThreshold;

  /// Weighted-score threshold for a SELL signal (0.0–1.0).
  final double sellThreshold;

  final String? description;

  SignalGeneratorConfig copyWith({
    String? configId,
    String? name,
    List<MethodWeightEntry>? methodWeights,
    int? minimumConsensusCount,
    double? buyThreshold,
    double? sellThreshold,
    String? description,
  }) => SignalGeneratorConfig(
    configId: configId ?? this.configId,
    name: name ?? this.name,
    methodWeights: methodWeights ?? this.methodWeights,
    minimumConsensusCount: minimumConsensusCount ?? this.minimumConsensusCount,
    buyThreshold: buyThreshold ?? this.buyThreshold,
    sellThreshold: sellThreshold ?? this.sellThreshold,
    description: description ?? this.description,
  );

  @override
  List<Object?> get props => [
    configId,
    name,
    methodWeights,
    minimumConsensusCount,
    buyThreshold,
    sellThreshold,
    description,
  ];
}
