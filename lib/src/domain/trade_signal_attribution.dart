import 'package:equatable/equatable.dart';

/// Records which trading signals were responsible for a specific trade,
/// enabling post-trade signal attribution analysis.
class TradeSignalAttribution extends Equatable {
  /// Creates a [TradeSignalAttribution].
  const TradeSignalAttribution({
    required this.tradeId,
    required this.ticker,
    required this.primarySignalMethod,
    required this.contributingMethods,
    required this.attributedAt,
  });

  /// Identifier of the trade being attributed.
  final String tradeId;

  /// Ticker symbol of the traded instrument.
  final String ticker;

  /// The primary method that triggered the trade decision.
  final String primarySignalMethod;

  /// Additional methods that contributed to the decision.
  final List<String> contributingMethods;

  /// Timestamp of attribution analysis.
  final DateTime attributedAt;

  /// Returns `true` when two or more methods agreed on the signal.
  bool get isConsensus => contributingMethods.length >= 2;

  /// Total method count (primary + contributing).
  int get methodCount => 1 + contributingMethods.length;

  /// Returns `true` when only the primary method fired.
  bool get isPrimaryOnly => contributingMethods.isEmpty;

  @override
  List<Object?> get props => [
    tradeId,
    ticker,
    primarySignalMethod,
    contributingMethods,
    attributedAt,
  ];
}
