import 'package:equatable/equatable.dart';

/// Interest rate carry trade signal between two currencies (S536).
class CarryTradeSignal extends Equatable {
  const CarryTradeSignal({
    required this.signalId,
    required this.longCurrency,
    required this.shortCurrency,
    required this.interestRateDifferentialBps,
    required this.expectedAnnualisedCarryPercent,
    required this.isBuy,
  });

  final String signalId;

  /// Higher-yielding currency to go long.
  final String longCurrency;

  /// Lower-yielding currency to go short.
  final String shortCurrency;

  /// Overnight rate differential in basis points.
  final int interestRateDifferentialBps;

  /// Expected annualised carry yield in percent.
  final double expectedAnnualisedCarryPercent;

  /// True → long the carry pair; false → unwind.
  final bool isBuy;

  bool get isHighCarry => expectedAnnualisedCarryPercent >= 5;
  bool get isWideDifferential => interestRateDifferentialBps >= 200;

  @override
  List<Object?> get props => [
    signalId,
    longCurrency,
    shortCurrency,
    interestRateDifferentialBps,
    expectedAnnualisedCarryPercent,
    isBuy,
  ];
}
