import 'package:equatable/equatable.dart';

/// Clearing house initial and maintenance margin requirements (S513).
class ClearingHouseMargin extends Equatable {
  const ClearingHouseMargin({
    required this.instrumentId,
    required this.clearingHouseName,
    required this.initialMarginPercent,
    required this.maintenanceMarginPercent,
    required this.stressMarginPercent,
    this.concentrationSurchargePercent = 0.0,
  });

  final String instrumentId;
  final String clearingHouseName;

  /// Initial margin as a percentage of notional.
  final double initialMarginPercent;

  /// Maintenance margin as a percentage of notional.
  final double maintenanceMarginPercent;

  /// Stress-scenario margin percentage.
  final double stressMarginPercent;

  /// Additional surcharge for concentrated positions.
  final double concentrationSurchargePercent;

  double get marginCallThreshold =>
      maintenanceMarginPercent - concentrationSurchargePercent;
  bool get hasConcentrationSurcharge => concentrationSurchargePercent > 0;
  bool get isHighMargin => initialMarginPercent >= 20;

  @override
  List<Object?> get props => [
    instrumentId,
    clearingHouseName,
    initialMarginPercent,
    maintenanceMarginPercent,
    stressMarginPercent,
    concentrationSurchargePercent,
  ];
}
