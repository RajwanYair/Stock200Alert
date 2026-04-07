import 'package:cross_tide/src/domain/dividend_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calc = DividendCalculator();

  final now = DateTime(2025, 4, 7);

  group('DividendCalculator.summarize', () {
    test('summarizes trailing 12-month dividends', () {
      final payments = [
        DividendPayment(
          ticker: 'AAPL',
          exDate: DateTime(2025, 1, 15),
          payDate: DateTime(2025, 2, 1),
          amountPerShare: 0.25,
        ),
        DividendPayment(
          ticker: 'AAPL',
          exDate: DateTime(2024, 10, 15),
          payDate: DateTime(2024, 11, 1),
          amountPerShare: 0.24,
        ),
        DividendPayment(
          ticker: 'AAPL',
          exDate: DateTime(2024, 7, 15),
          payDate: DateTime(2024, 8, 1),
          amountPerShare: 0.24,
        ),
        DividendPayment(
          ticker: 'AAPL',
          exDate: DateTime(2024, 4, 15),
          payDate: DateTime(2024, 5, 1),
          amountPerShare: 0.23,
        ),
      ];

      final result = calc.summarize(
        ticker: 'AAPL',
        payments: payments,
        currentPrice: 200,
        asOf: now,
      );

      expect(result.ticker, 'AAPL');
      expect(result.paymentCount, 4);
      expect(result.annualDividend, closeTo(0.96, 0.01));
      expect(result.dividendYield, closeTo(0.48, 0.01));
      expect(result.lastExDate, DateTime(2025, 1, 15));
    });

    test('excludes payments older than 12 months', () {
      final payments = [
        DividendPayment(
          ticker: 'X',
          exDate: DateTime(2023, 1, 1),
          payDate: DateTime(2023, 2, 1),
          amountPerShare: 1.0,
        ),
      ];

      final result = calc.summarize(
        ticker: 'X',
        payments: payments,
        currentPrice: 100,
        asOf: now,
      );

      expect(result.paymentCount, 0);
      expect(result.annualDividend, 0);
    });

    test('handles zero price', () {
      final result = calc.summarize(
        ticker: 'X',
        payments: [
          DividendPayment(
            ticker: 'X',
            exDate: DateTime(2025, 1, 1),
            payDate: DateTime(2025, 2, 1),
            amountPerShare: 1.0,
          ),
        ],
        currentPrice: 0,
        asOf: now,
      );
      expect(result.dividendYield, 0);
    });

    test('DividendPayment props equality', () {
      final a = DividendPayment(
        ticker: 'X',
        exDate: DateTime(2025, 1, 1),
        payDate: DateTime(2025, 2, 1),
        amountPerShare: 1.0,
      );
      final b = DividendPayment(
        ticker: 'X',
        exDate: DateTime(2025, 1, 1),
        payDate: DateTime(2025, 2, 1),
        amountPerShare: 1.0,
      );
      expect(a, equals(b));
    });
  });

  group('DividendCalculator.project', () {
    test('projects annual income from holdings', () {
      final summaries = {
        'AAPL': DividendSummary(
          ticker: 'AAPL',
          annualDividend: 1.0,
          dividendYield: 0.5,
          paymentCount: 4,
          lastExDate: DateTime(2025, 1, 1),
        ),
        'MSFT': DividendSummary(
          ticker: 'MSFT',
          annualDividend: 3.0,
          dividendYield: 0.8,
          paymentCount: 4,
          lastExDate: DateTime(2025, 1, 1),
        ),
      };

      final result = calc.project(
        holdings: {'AAPL': 100.0, 'MSFT': 50.0},
        summaries: summaries,
        totalCost: 20000,
      );

      expect(result.annualIncome, closeTo(250, 0.01));
      expect(result.monthlyIncome, closeTo(250 / 12, 0.01));
      expect(result.holdingIncomes['AAPL'], closeTo(100, 0.01));
      expect(result.holdingIncomes['MSFT'], closeTo(150, 0.01));
    });

    test('handles zero total cost', () {
      final result = calc.project(holdings: {}, summaries: {}, totalCost: 0);
      expect(result.yieldOnCost, 0);
    });

    test('DividendProjection props equality', () {
      const a = DividendProjection(
        annualIncome: 100,
        monthlyIncome: 8.33,
        yieldOnCost: 1.0,
        holdingIncomes: {'A': 100},
      );
      const b = DividendProjection(
        annualIncome: 100,
        monthlyIncome: 8.33,
        yieldOnCost: 1.0,
        holdingIncomes: {'A': 100},
      );
      expect(a, equals(b));
    });
  });
}
