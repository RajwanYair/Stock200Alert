import 'package:equatable/equatable.dart';

/// Chart layer config — per-indicator overlay line appearance.
enum ChartLayerType {
  price,
  volume,
  rsi,
  macd,
  bollinger,
  ema,
  sma,
  vwap,
  custom,
}

class ChartLayerConfig extends Equatable {
  const ChartLayerConfig({
    required this.layerId,
    required this.layerType,
    required this.color,
    required this.lineWidth,
    required this.isVisible,
  });

  final String layerId;
  final ChartLayerType layerType;

  /// Hex colour string, e.g. '#FF6B6B'.
  final String color;
  final double lineWidth;
  final bool isVisible;

  ChartLayerConfig copyWith({
    String? layerId,
    ChartLayerType? layerType,
    String? color,
    double? lineWidth,
    bool? isVisible,
  }) => ChartLayerConfig(
    layerId: layerId ?? this.layerId,
    layerType: layerType ?? this.layerType,
    color: color ?? this.color,
    lineWidth: lineWidth ?? this.lineWidth,
    isVisible: isVisible ?? this.isVisible,
  );

  @override
  List<Object?> get props => [layerId, layerType, color, lineWidth, isVisible];
}
