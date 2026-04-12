import 'package:equatable/equatable.dart';

/// Tax-year capital gains/losses summary (S451).
class TaxYearSummary extends Equatable {
  const TaxYearSummary({
    required this.taxYear,
    required this.shortTermGains,
    required this.longTermGains,
    required this.shortTermLosses,
    required this.longTermLosses,
    required this.dividendIncome,
    this.estimatedTaxOwed = 0.0,
  });

  final int taxYear;
  final double shortTermGains;
  final double longTermGains;
  final double shortTermLosses;
  final double longTermLosses;
  final double dividendIncome;
  final double estimatedTaxOwed;

  double get netShortTerm => shortTermGains - shortTermLosses;
  double get netLongTerm => longTermGains - longTermLosses;
  double get totalNetGain => netShortTerm + netLongTerm;
  bool get hasNetLoss => totalNetGain < 0;
  bool get isNetPositive => totalNetGain > 0;

  @override
  List<Object?> get props => [
    taxYear,
    shortTermGains,
    longTermGains,
    shortTermLosses,
    longTermLosses,
    dividendIncome,
    estimatedTaxOwed,
  ];
}
