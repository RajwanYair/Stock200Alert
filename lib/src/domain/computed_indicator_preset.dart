import 'package:equatable/equatable.dart';

/// Computed indicator preset — saved indicator layout preset by category.
enum IndicatorPresetCategory { momentum, trend, volatility, volume, custom }

class ComputedIndicatorPreset extends Equatable {
  const ComputedIndicatorPreset({
    required this.presetId,
    required this.name,
    required this.category,
    required this.indicatorCount,
    required this.isDefault,
  });

  final String presetId;
  final String name;
  final IndicatorPresetCategory category;
  final int indicatorCount;
  final bool isDefault;

  ComputedIndicatorPreset copyWith({
    String? presetId,
    String? name,
    IndicatorPresetCategory? category,
    int? indicatorCount,
    bool? isDefault,
  }) => ComputedIndicatorPreset(
    presetId: presetId ?? this.presetId,
    name: name ?? this.name,
    category: category ?? this.category,
    indicatorCount: indicatorCount ?? this.indicatorCount,
    isDefault: isDefault ?? this.isDefault,
  );

  @override
  List<Object?> get props => [
    presetId,
    name,
    category,
    indicatorCount,
    isDefault,
  ];
}
