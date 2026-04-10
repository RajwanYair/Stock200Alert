import 'package:equatable/equatable.dart';

/// Classification of an insider trade transaction.
enum InsiderTradeType {
  purchase,
  sale,
  exerciseOption,
  grantAward,
  conversionDerivative,
}

/// A single insider trade transaction filed with a regulatory body.
class InsiderTradeRecord extends Equatable {
  const InsiderTradeRecord({
    required this.symbol,
    required this.insiderName,
    required this.title,
    required this.tradeType,
    required this.shares,
    required this.pricePerShare,
    required this.filedDate,
    this.transactionDate,
    this.secFormType,
  }) : assert(shares > 0, 'shares must be > 0'),
       assert(pricePerShare >= 0, 'pricePerShare must be >= 0');

  final String symbol;
  final String insiderName;
  final String title;
  final InsiderTradeType tradeType;
  final int shares;
  final double pricePerShare;
  final DateTime filedDate;
  final DateTime? transactionDate;

  /// SEC form type (e.g. 'Form 4', 'Form 5').
  final String? secFormType;

  double get totalValue => pricePerShare * shares;
  bool get isBuy => tradeType == InsiderTradeType.purchase;
  bool get isSell => tradeType == InsiderTradeType.sale;
  bool get isSignificant => totalValue >= 1_000_000;

  @override
  List<Object?> get props => [
    symbol,
    insiderName,
    title,
    tradeType,
    shares,
    pricePerShare,
    filedDate,
    transactionDate,
    secFormType,
  ];
}
