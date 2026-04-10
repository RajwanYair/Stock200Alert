import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GroupMembershipEntry', () {
    test('creates entry and reports hasNotes', () {
      const e = GroupMembershipEntry(symbol: 'AAPL', groupId: 'tech');
      expect(e.symbol, 'AAPL');
      expect(e.groupId, 'tech');
      expect(e.hasNotes, isFalse);
    });
  });

  group('WatchlistGroupMembership', () {
    late DateTime addedAt;

    setUp(() => addedAt = DateTime(2025, 5, 1));

    test('groupIds returns distinct group IDs', () {
      final membership = WatchlistGroupMembership(
        entries: [
          GroupMembershipEntry(
            symbol: 'AAPL',
            groupId: 'tech',
            addedAt: addedAt,
          ),
          GroupMembershipEntry(
            symbol: 'MSFT',
            groupId: 'tech',
            addedAt: addedAt,
          ),
          GroupMembershipEntry(
            symbol: 'JNJ',
            groupId: 'health',
            addedAt: addedAt,
          ),
        ],
      );
      expect(membership.groupIds.length, 2);
      expect(membership.groupIds, containsAll(['tech', 'health']));
    });

    test('symbolsInGroup returns correct symbols', () {
      final membership = WatchlistGroupMembership(
        entries: [
          GroupMembershipEntry(
            symbol: 'AAPL',
            groupId: 'tech',
            addedAt: addedAt,
          ),
          GroupMembershipEntry(
            symbol: 'NVDA',
            groupId: 'tech',
            addedAt: addedAt,
          ),
          GroupMembershipEntry(
            symbol: 'JNJ',
            groupId: 'health',
            addedAt: addedAt,
          ),
        ],
      );
      expect(membership.symbolsInGroup('tech'), containsAll(['AAPL', 'NVDA']));
      expect(membership.symbolsInGroup('health'), ['JNJ']);
    });

    test('groupsForSymbol returns all groups for a symbol', () {
      final membership = WatchlistGroupMembership(
        entries: [
          GroupMembershipEntry(
            symbol: 'AAPL',
            groupId: 'tech',
            addedAt: addedAt,
          ),
          GroupMembershipEntry(
            symbol: 'AAPL',
            groupId: 'favorites',
            addedAt: addedAt,
          ),
        ],
      );
      expect(
        membership.groupsForSymbol('AAPL'),
        containsAll(['tech', 'favorites']),
      );
    });

    test('isMember returns true for matching entry', () {
      final membership = WatchlistGroupMembership(
        entries: [
          GroupMembershipEntry(symbol: 'TSLA', groupId: 'ev', addedAt: addedAt),
        ],
      );
      expect(membership.isMember('TSLA', 'ev'), isTrue);
      expect(membership.isMember('TSLA', 'tech'), isFalse);
    });

    test('totalEntries is correct', () {
      const membership = WatchlistGroupMembership(
        entries: [
          GroupMembershipEntry(symbol: 'A', groupId: 'g1'),
          GroupMembershipEntry(symbol: 'B', groupId: 'g2'),
        ],
      );
      expect(membership.totalEntries, 2);
    });

    test('equality holds for identical memberships', () {
      const a = WatchlistGroupMembership(
        entries: [GroupMembershipEntry(symbol: 'X', groupId: 'y')],
      );
      const b = WatchlistGroupMembership(
        entries: [GroupMembershipEntry(symbol: 'X', groupId: 'y')],
      );
      expect(a, equals(b));
    });
  });
}
