import 'package:equatable/equatable.dart';

/// A margin call event on a leveraged portfolio position (S454).
class PortfolioMarginCall extends Equatable {
  const PortfolioMarginCall({
    required this.portfolioId,
    required this.marginCallAmount,
    required this.currentMarginLevel,
    required this.minimumMarginLevel,
    required this.affectedTickers,
    this.isResolved = false,
  });

  final String portfolioId;

  /// Dollar amount required to meet the margin call.
  final double marginCallAmount;

  /// Current margin level as a percentage.
  final double currentMarginLevel;

  /// Broker minimum margin requirement as a percentage.
  final double minimumMarginLevel;

  final List<String> affectedTickers;
  final bool isResolved;

  double get marginDeficit => minimumMarginLevel - currentMarginLevel;
  bool get isUrgent => marginDeficit >= 10.0;
  bool get isActive => !isResolved;

  @override
  List<Object?> get props => [
    portfolioId,
    marginCallAmount,
    currentMarginLevel,
    minimumMarginLevel,
    affectedTickers,
    isResolved,
  ];
}
