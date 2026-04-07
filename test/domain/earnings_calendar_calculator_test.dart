import 'package:cross_tide/src/domain/earnings_calendar_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const calc = EarningsCalendarCalculator(alertWindowDays: 7);

  final now = DateTime(2025, 4, 7);

  group('EarningsEvent', () {
    test('isReported detects actual EPS', () {
      final reported = EarningsEvent(
        ticker: 'AAPL',
        reportDate: DateTime(2025, 1, 30),
        estimatedEps: 2.10,
        actualEps: 2.18,
      );
      expect(reported.isReported, isTrue);
      expect(reported.epsSurprise, closeTo(0.08, 0.001));
      expect(reported.epsSurprisePct, closeTo(3.81, 0.1));
    });

    test('epsSurprise is null when not reported', () {
      final pending = EarningsEvent(
        ticker: 'AAPL',
        reportDate: DateTime(2025, 4, 30),
        estimatedEps: 2.10,
      );
      expect(pending.isReported, isFalse);
      expect(pending.epsSurprise, isNull);
      expect(pending.epsSurprisePct, isNull);
    });

    test('epsSurprisePct handles zero estimate', () {
      final e = EarningsEvent(
        ticker: 'X',
        reportDate: DateTime(2025, 4, 30),
        estimatedEps: 0,
        actualEps: 1.0,
      );
      expect(e.epsSurprisePct, isNull);
    });

    test('props equality', () {
      final a = EarningsEvent(
        ticker: 'AAPL',
        reportDate: DateTime(2025, 1, 30),
        estimatedEps: 2.10,
      );
      final b = EarningsEvent(
        ticker: 'AAPL',
        reportDate: DateTime(2025, 1, 30),
        estimatedEps: 2.10,
      );
      expect(a, equals(b));
    });
  });

  group('EarningsCalendarCalculator.nextEarnings', () {
    test('finds next upcoming earnings', () {
      final events = [
        EarningsEvent(
          ticker: 'AAPL',
          reportDate: DateTime(2025, 4, 10),
          estimatedEps: 2.0,
        ),
        EarningsEvent(
          ticker: 'AAPL',
          reportDate: DateTime(2025, 7, 30),
          estimatedEps: 2.5,
        ),
      ];

      final result = calc.nextEarnings(
        ticker: 'AAPL',
        events: events,
        asOf: now,
      );

      expect(result, isNotNull);
      expect(result!.daysUntilEarnings, 3);
      expect(result.isWithinAlertWindow, isTrue);
    });

    test('returns null when no future events', () {
      final events = [
        EarningsEvent(
          ticker: 'AAPL',
          reportDate: DateTime(2025, 1, 30),
          estimatedEps: 2.0,
        ),
      ];

      final result = calc.nextEarnings(
        ticker: 'AAPL',
        events: events,
        asOf: now,
      );

      expect(result, isNull);
    });

    test('outside alert window flags correctly', () {
      final events = [
        EarningsEvent(
          ticker: 'AAPL',
          reportDate: DateTime(2025, 5, 1),
          estimatedEps: 2.0,
        ),
      ];

      final result = calc.nextEarnings(
        ticker: 'AAPL',
        events: events,
        asOf: now,
      );

      expect(result!.isWithinAlertWindow, isFalse);
    });
  });

  group('EarningsCalendarCalculator.upcomingEarnings', () {
    test('lists all tickers with earnings in window', () {
      final events = [
        EarningsEvent(
          ticker: 'AAPL',
          reportDate: DateTime(2025, 4, 8),
          estimatedEps: 2.0,
        ),
        EarningsEvent(
          ticker: 'MSFT',
          reportDate: DateTime(2025, 4, 10),
          estimatedEps: 3.0,
        ),
        EarningsEvent(
          ticker: 'GOOG',
          reportDate: DateTime(2025, 5, 1),
          estimatedEps: 1.5,
        ),
      ];

      final result = calc.upcomingEarnings(events: events, asOf: now, days: 7);

      expect(result, hasLength(2));
      expect(result.first.ticker, 'AAPL');
      expect(result.last.ticker, 'MSFT');
    });

    test('deduplicates tickers', () {
      final events = [
        EarningsEvent(
          ticker: 'AAPL',
          reportDate: DateTime(2025, 4, 8),
          estimatedEps: 2.0,
        ),
        EarningsEvent(
          ticker: 'AAPL',
          reportDate: DateTime(2025, 4, 9),
          estimatedEps: 2.0,
        ),
      ];

      final result = calc.upcomingEarnings(events: events, asOf: now, days: 7);

      expect(result, hasLength(1));
    });

    test('EarningsProximity props equality', () {
      final a = EarningsProximity(
        ticker: 'X',
        daysUntilEarnings: 3,
        nextEarningsDate: DateTime(2025, 4, 10),
        isWithinAlertWindow: true,
      );
      final b = EarningsProximity(
        ticker: 'X',
        daysUntilEarnings: 3,
        nextEarningsDate: DateTime(2025, 4, 10),
        isWithinAlertWindow: true,
      );
      expect(a, equals(b));
    });
  });
}
