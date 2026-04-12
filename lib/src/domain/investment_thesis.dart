import 'package:equatable/equatable.dart';

/// A structured investment thesis for a single ticker position.
///
/// Captures the investor's rationale, expected catalysts, key risks,
/// and price target so they can be revisited as conditions change.
class InvestmentThesis extends Equatable {
  /// Creates an [InvestmentThesis].
  const InvestmentThesis({
    required this.thesisId,
    required this.ticker,
    required this.summary,
    required this.catalysts,
    required this.risks,
    required this.targetPrice,
    this.isActive = true,
  });

  /// Unique identifier for this thesis.
  final String thesisId;

  /// Ticker symbol this thesis applies to.
  final String ticker;

  /// High-level summary of the investment case.
  final String summary;

  /// Expected catalysts that could drive price appreciation.
  final List<String> catalysts;

  /// Key risks that could impair the investment.
  final List<String> risks;

  /// Price target for this investment thesis.
  final double targetPrice;

  /// Whether this thesis is currently active (not invalidated or closed).
  final bool isActive;

  /// Returns `true` when at least one catalyst is documented.
  bool get hasCatalysts => catalysts.isNotEmpty;

  /// Returns `true` when at least one risk is documented.
  bool get hasRisks => risks.isNotEmpty;

  /// Returns `true` when both catalysts and risks are documented.
  bool get isBalanced => hasCatalysts && hasRisks;

  @override
  List<Object?> get props => [
    thesisId,
    ticker,
    summary,
    catalysts,
    risks,
    targetPrice,
    isActive,
  ];
}
