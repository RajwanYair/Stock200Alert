import 'package:equatable/equatable.dart';

/// A snapshot of market breadth indicators for a given session.
class MarketBreadthSnapshot extends Equatable {
  const MarketBreadthSnapshot({
    required this.advancers,
    required this.decliners,
    required this.unchanged,
    required this.newHighs52w,
    required this.newLows52w,
    required this.snapshotDate,
  });

  /// Number of issues that rose on the session.
  final int advancers;

  /// Number of issues that fell on the session.
  final int decliners;

  /// Number of issues that closed flat.
  final int unchanged;

  /// New 52-week highs on this session.
  final int newHighs52w;

  /// New 52-week lows on this session.
  final int newLows52w;

  final DateTime snapshotDate;

  /// Total issues counted.
  int get totalIssues => advancers + decliners + unchanged;

  /// Advance-decline ratio; returns null if no decliners.
  double? get adRatio {
    if (decliners == 0) return null;
    return advancers / decliners;
  }

  /// Breadth reading: positive when advancers outnumber decliners.
  int get netAdvancers => advancers - decliners;

  /// Returns true when market breadth is broadly positive (>= 60 % advancers).
  bool get isBullish => totalIssues > 0 && advancers / totalIssues >= 0.60;

  @override
  List<Object?> get props => [
    advancers,
    decliners,
    unchanged,
    newHighs52w,
    newLows52w,
    snapshotDate,
  ];
}
