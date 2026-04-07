/// Digest Builder — pure domain utility.
///
/// Aggregates multiple alert events into a single digest summary
/// suitable for batch notification delivery.
library;

import 'package:equatable/equatable.dart';

import 'entities.dart';

/// A digest of grouped alert history entries.
class AlertDigest extends Equatable {
  const AlertDigest({
    required this.title,
    required this.entries,
    required this.createdAt,
  });

  /// Summary title (e.g., "3 alerts for AAPL").
  final String title;

  /// The grouped entries.
  final List<AlertHistoryEntry> entries;

  /// When this digest was built.
  final DateTime createdAt;

  /// Number of entries in this digest.
  int get count => entries.length;

  /// Unique symbols in this digest.
  List<String> get symbols {
    final Set<String> unique = {
      for (final AlertHistoryEntry e in entries) e.symbol,
    };
    return unique.toList()..sort();
  }

  @override
  List<Object?> get props => [title, entries, createdAt];
}

/// Builds notification digests from alert history entries.
class DigestBuilder {
  const DigestBuilder();

  /// Group [entries] by symbol and build a digest for each.
  List<AlertDigest> buildBySymbol(
    List<AlertHistoryEntry> entries, {
    required DateTime asOf,
  }) {
    final Map<String, List<AlertHistoryEntry>> grouped = {};
    for (final AlertHistoryEntry e in entries) {
      (grouped[e.symbol] ??= []).add(e);
    }

    final List<String> sortedSymbols = grouped.keys.toList()..sort();
    return [
      for (final String symbol in sortedSymbols)
        AlertDigest(
          title:
              '${grouped[symbol]!.length} alert${grouped[symbol]!.length == 1 ? '' : 's'} for $symbol',
          entries: grouped[symbol]!,
          createdAt: asOf,
        ),
    ];
  }

  /// Build a single combined digest from all entries.
  AlertDigest buildCombined(
    List<AlertHistoryEntry> entries, {
    required DateTime asOf,
  }) {
    final int symbolCount = {
      for (final AlertHistoryEntry e in entries) e.symbol,
    }.length;
    return AlertDigest(
      title:
          '${entries.length} alert${entries.length == 1 ? '' : 's'} across $symbolCount symbol${symbolCount == 1 ? '' : 's'}',
      entries: entries,
      createdAt: asOf,
    );
  }
}
