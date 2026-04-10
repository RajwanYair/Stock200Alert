import 'package:equatable/equatable.dart';

/// A single ticker to watchlist group membership assignment.
class GroupMembershipEntry extends Equatable {
  const GroupMembershipEntry({
    required this.symbol,
    required this.groupId,
    this.addedAt,
    this.notes,
  });

  final String symbol;
  final String groupId;
  final DateTime? addedAt;
  final String? notes;

  bool get hasNotes => notes != null && notes!.isNotEmpty;

  @override
  List<Object?> get props => [symbol, groupId, addedAt, notes];
}

/// Manages multi-group membership for watchlist tickers.
class WatchlistGroupMembership extends Equatable {
  const WatchlistGroupMembership({required this.entries});

  final List<GroupMembershipEntry> entries;

  int get totalEntries => entries.length;

  /// All distinct group IDs present in this membership.
  List<String> get groupIds =>
      entries.map((final GroupMembershipEntry e) => e.groupId).toSet().toList();

  /// Entries for a specific group.
  List<GroupMembershipEntry> entriesForGroup(String groupId) => entries
      .where((final GroupMembershipEntry e) => e.groupId == groupId)
      .toList();

  /// All symbols belonging to a specific group.
  List<String> symbolsInGroup(String groupId) => entriesForGroup(
    groupId,
  ).map((final GroupMembershipEntry e) => e.symbol).toList();

  /// Groups that contain [symbol].
  List<String> groupsForSymbol(String symbol) => entries
      .where((final GroupMembershipEntry e) => e.symbol == symbol)
      .map((final GroupMembershipEntry e) => e.groupId)
      .toList();

  bool isMember(String symbol, String groupId) => entries.any(
    (final GroupMembershipEntry e) =>
        e.symbol == symbol && e.groupId == groupId,
  );

  @override
  List<Object?> get props => [entries];
}
