/// Dividend Tracker — domain entities and calculator for dividend income.
library;

import 'package:equatable/equatable.dart';

/// A single dividend payment.
class DividendPayment extends Equatable {
  const DividendPayment({
    required this.ticker,
    required this.exDate,
    required this.payDate,
    required this.amountPerShare,
  });

  final String ticker;
  final DateTime exDate;
  final DateTime payDate;
  final double amountPerShare;

  @override
  List<Object?> get props => [ticker, exDate, payDate, amountPerShare];
}

/// Annualized dividend summary for one ticker.
class DividendSummary extends Equatable {
  const DividendSummary({
    required this.ticker,
    required this.annualDividend,
    required this.dividendYield,
    required this.paymentCount,
    required this.lastExDate,
  });

  final String ticker;

  /// Total annual dividend per share.
  final double annualDividend;

  /// Dividend yield as a percentage.
  final double dividendYield;

  /// Number of payments in the trailing 12 months.
  final int paymentCount;

  /// Most recent ex-dividend date.
  final DateTime? lastExDate;

  @override
  List<Object?> get props => [
    ticker,
    annualDividend,
    dividendYield,
    paymentCount,
    lastExDate,
  ];
}

/// Portfolio-level dividend income projection.
class DividendProjection extends Equatable {
  const DividendProjection({
    required this.annualIncome,
    required this.monthlyIncome,
    required this.yieldOnCost,
    required this.holdingIncomes,
  });

  final double annualIncome;
  final double monthlyIncome;
  final double yieldOnCost;

  /// Per-ticker annual income.
  final Map<String, double> holdingIncomes;

  @override
  List<Object?> get props => [
    annualIncome,
    monthlyIncome,
    yieldOnCost,
    holdingIncomes,
  ];
}

/// Computes dividend summaries and projections.
class DividendCalculator {
  const DividendCalculator();

  /// Summarize dividends for a single ticker over the trailing 12 months.
  ///
  /// [currentPrice] is used to compute yield.
  DividendSummary summarize({
    required String ticker,
    required List<DividendPayment> payments,
    required double currentPrice,
    required DateTime asOf,
  }) {
    final cutoff = DateTime(asOf.year - 1, asOf.month, asOf.day);
    final trailing =
        payments.where((DividendPayment d) => d.exDate.isAfter(cutoff)).toList()
          ..sort(
            (DividendPayment a, DividendPayment b) =>
                a.exDate.compareTo(b.exDate),
          );

    final annual = trailing.fold<double>(
      0,
      (double acc, DividendPayment d) => acc + d.amountPerShare,
    );
    final yield_ = currentPrice > 0 ? (annual / currentPrice) * 100 : 0.0;

    return DividendSummary(
      ticker: ticker,
      annualDividend: annual,
      dividendYield: yield_,
      paymentCount: trailing.length,
      lastExDate: trailing.isNotEmpty ? trailing.last.exDate : null,
    );
  }

  /// Project portfolio dividend income.
  ///
  /// [holdings] maps ticker → number of shares.
  /// [summaries] provides per-ticker dividend data.
  DividendProjection project({
    required Map<String, double> holdings,
    required Map<String, DividendSummary> summaries,
    required double totalCost,
  }) {
    var annualIncome = 0.0;
    final holdingIncomes = <String, double>{};

    for (final MapEntry<String, double> entry in holdings.entries) {
      final summary = summaries[entry.key];
      if (summary != null) {
        final income = entry.value * summary.annualDividend;
        annualIncome += income;
        holdingIncomes[entry.key] = income;
      }
    }

    return DividendProjection(
      annualIncome: annualIncome,
      monthlyIncome: annualIncome / 12,
      yieldOnCost: totalCost > 0 ? (annualIncome / totalCost) * 100 : 0,
      holdingIncomes: holdingIncomes,
    );
  }
}
