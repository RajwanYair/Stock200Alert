/// User-Defined Indicator — a user's named, persisted custom indicator that
/// references an `IndicatorFormula` and carries display preferences (v2.0).
library;

import 'package:equatable/equatable.dart';

/// How the indicator value is rendered on the chart.
enum IndicatorDisplayStyle {
  /// Drawn as a line overlaid on the price chart.
  overlayLine,

  /// Drawn in a separate sub-pane below the price chart.
  separatePane,

  /// Displayed as a histogram (bar chart) in the sub-pane.
  histogram,

  /// Not shown on the chart; value only visible in the data panel.
  dataOnly,
}

/// A user-created, named indicator backed by a stored formula ID.
class UserDefinedIndicator extends Equatable {
  const UserDefinedIndicator({
    required this.id,
    required this.name,
    required this.formulaId,
    required this.displayStyle,
    required this.createdAt,
    this.description,
    this.colorHex,
    this.isVisible = true,
    this.decimalPlaces = 2,
  }) : assert(decimalPlaces >= 0, 'decimalPlaces must be non-negative');

  /// Stable unique identifier (UUID or slug).
  final String id;
  final String name;

  /// References the `IndicatorFormula.id` stored in the DB.
  final String formulaId;

  final IndicatorDisplayStyle displayStyle;
  final DateTime createdAt;
  final String? description;

  /// Hex color string (e.g. '#FF6600') for the chart overlay line.
  final String? colorHex;

  final bool isVisible;
  final int decimalPlaces;

  /// Returns a copy with [isVisible] toggled.
  UserDefinedIndicator toggleVisibility() => UserDefinedIndicator(
    id: id,
    name: name,
    formulaId: formulaId,
    displayStyle: displayStyle,
    createdAt: createdAt,
    description: description,
    colorHex: colorHex,
    isVisible: !isVisible,
    decimalPlaces: decimalPlaces,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    formulaId,
    displayStyle,
    createdAt,
    description,
    colorHex,
    isVisible,
    decimalPlaces,
  ];
}
