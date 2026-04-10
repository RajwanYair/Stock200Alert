import 'package:equatable/equatable.dart';

/// Configuration for a synthetic (virtual/composite) ticker.
class SyntheticTickerConfig extends Equatable {
  const SyntheticTickerConfig({
    required this.syntheticId,
    required this.displayName,
    required this.components,
    this.description,
  });

  final String syntheticId;
  final String displayName;

  /// Map of real ticker symbol → weight (weights should sum to 1.0).
  final Map<String, double> components;

  final String? description;

  /// Number of component tickers.
  int get componentCount => components.length;

  /// Returns true when component weights sum to approximately 1.0 (± 0.01).
  bool get isNormalised {
    final total = components.values.fold(0.0, (sum, w) => sum + w);
    return (total - 1.0).abs() <= 0.01;
  }

  @override
  List<Object?> get props => [
    syntheticId,
    displayName,
    components,
    description,
  ];
}
