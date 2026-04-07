import 'package:cross_tide/src/domain/notification_channel_ranker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ranker = NotificationChannelRanker();

  group('NotificationChannelRanker', () {
    test('returns empty for no available channels', () {
      expect(ranker.rank([]), isEmpty);
    });

    test('excludes unavailable channels', () {
      final statuses = [
        const ChannelStatus(
          channel: NotificationChannelType.push,
          isAvailable: false,
          reliability: 1.0,
          lastSuccessAt: null,
          failureCount: 0,
        ),
        ChannelStatus(
          channel: NotificationChannelType.silentLog,
          isAvailable: true,
          reliability: 1.0,
          lastSuccessAt: DateTime(2025, 4, 7),
          failureCount: 0,
        ),
      ];

      final result = ranker.rank(statuses);
      expect(result, hasLength(1));
      expect(result.first.channel, NotificationChannelType.silentLog);
    });

    test('ranks by base priority × reliability', () {
      final statuses = [
        ChannelStatus(
          channel: NotificationChannelType.silentLog,
          isAvailable: true,
          reliability: 1.0,
          lastSuccessAt: DateTime(2025, 4, 7),
          failureCount: 0,
        ),
        ChannelStatus(
          channel: NotificationChannelType.push,
          isAvailable: true,
          reliability: 1.0,
          lastSuccessAt: DateTime(2025, 4, 7),
          failureCount: 0,
        ),
      ];

      final result = ranker.rank(statuses);
      expect(result.first.channel, NotificationChannelType.push);
      expect(result.first.rank, 1);
      expect(result.last.channel, NotificationChannelType.silentLog);
      expect(result.last.rank, 2);
    });

    test('failure penalty reduces score', () {
      final healthy = ChannelStatus(
        channel: NotificationChannelType.push,
        isAvailable: true,
        reliability: 1.0,
        lastSuccessAt: DateTime(2025, 4, 7),
        failureCount: 0,
      );
      final failing = ChannelStatus(
        channel: NotificationChannelType.push,
        isAvailable: true,
        reliability: 0.5,
        lastSuccessAt: DateTime(2025, 4, 5),
        failureCount: 5,
      );

      final healthyResult = ranker.rank([healthy]);
      final failingResult = ranker.rank([failing]);
      expect(failingResult.first.score, lessThan(healthyResult.first.score));
    });

    test('ChannelStatus props equality', () {
      final a = ChannelStatus(
        channel: NotificationChannelType.push,
        isAvailable: true,
        reliability: 1.0,
        lastSuccessAt: DateTime(2025, 1, 1),
        failureCount: 0,
      );
      final b = ChannelStatus(
        channel: NotificationChannelType.push,
        isAvailable: true,
        reliability: 1.0,
        lastSuccessAt: DateTime(2025, 1, 1),
        failureCount: 0,
      );
      expect(a, equals(b));
    });

    test('RankedChannel props equality', () {
      const a = RankedChannel(
        channel: NotificationChannelType.push,
        score: 90,
        rank: 1,
      );
      const b = RankedChannel(
        channel: NotificationChannelType.push,
        score: 90,
        rank: 1,
      );
      expect(a, equals(b));
    });
  });
}
