import 'package:equatable/equatable.dart';

/// Aggregated performance summary for a named watchlist group.
class WatchlistPerformanceSummary extends Equatable {
  const WatchlistPerformanceSummary({
    required this.groupName,
    required this.symbols,
    required this.avgReturnPct,
    required this.bestPerformerSymbol,
    required this.worstPerformerSymbol,
    required this.bestReturnPct,
    required this.worstReturnPct,
    required this.calculatedAt,
  }) : assert(symbols.length > 0, 'symbols must not be empty');

  final String groupName;
  final List<String> symbols;

  /// Average return across all symbols in the group (%).
  final double avgReturnPct;
  final String bestPerformerSymbol;
  final String worstPerformerSymbol;
  final double bestReturnPct;
  final double worstReturnPct;
  final DateTime calculatedAt;

  int get symbolCount => symbols.length;

  /// Return spread between best and worst performer in percentage points.
  double get returnSpread => bestReturnPct - worstReturnPct;

  bool get isGroupPositive => avgReturnPct > 0;
  bool get hasHighDispersion => returnSpread > 20.0;

  @override
  List<Object?> get props => [
    groupName,
    symbols,
    avgReturnPct,
    bestPerformerSymbol,
    worstPerformerSymbol,
    bestReturnPct,
    worstReturnPct,
    calculatedAt,
  ];
}
