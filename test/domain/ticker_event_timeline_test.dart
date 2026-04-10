import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TickerEventType', () {
    test('has 9 values', () {
      expect(TickerEventType.values.length, 9);
    });
  });

  group('TickerTimelineEvent', () {
    test('equality holds for same props without metadata', () {
      final a = TickerTimelineEvent(
        eventType: TickerEventType.earningsRelease,
        eventDate: DateTime(2024, 4, 1),
        description: 'Q1 earnings',
        value: 1.25,
      );
      final b = TickerTimelineEvent(
        eventType: TickerEventType.earningsRelease,
        eventDate: DateTime(2024, 4, 1),
        description: 'Q1 earnings',
        value: 1.25,
      );
      expect(a, equals(b));
    });
  });

  group('TickerEventTimeline', () {
    late TickerEventTimeline timeline;

    setUp(() {
      timeline = TickerEventTimeline(
        ticker: 'AAPL',
        events: [
          TickerTimelineEvent(
            eventType: TickerEventType.earningsRelease,
            eventDate: DateTime(2024, 1, 1),
            description: 'Q4 2023 earnings',
          ),
          TickerTimelineEvent(
            eventType: TickerEventType.dividendEx,
            eventDate: DateTime(2024, 2, 1),
            description: 'Q1 dividend ex-date',
          ),
          TickerTimelineEvent(
            eventType: TickerEventType.earningsRelease,
            eventDate: DateTime(2024, 4, 1),
            description: 'Q1 2024 earnings',
          ),
        ],
      );
    });

    test('ofType returns only events of the given type', () {
      final earnings = timeline.ofType(TickerEventType.earningsRelease);
      expect(earnings.length, 2);
    });

    test('ofType returns empty list when type not present', () {
      final splits = timeline.ofType(TickerEventType.split);
      expect(splits, isEmpty);
    });

    test('latestEvent returns the last event in list', () {
      expect(timeline.latestEvent?.eventDate, DateTime(2024, 4, 1));
    });

    test('latestEvent is null for empty timeline', () {
      const empty = TickerEventTimeline(ticker: 'X', events: []);
      expect(empty.latestEvent, isNull);
    });

    test('equality holds for same props', () {
      final copy = TickerEventTimeline(
        ticker: timeline.ticker,
        events: List.from(timeline.events),
      );
      expect(timeline, equals(copy));
    });
  });
}
