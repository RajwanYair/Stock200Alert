import 'package:equatable/equatable.dart';

/// Snapshot of a single global market index level.
class GlobalIndexLevel extends Equatable {
  const GlobalIndexLevel({
    required this.symbol,
    required this.displayName,
    required this.price,
    this.changePercent,
  }) : assert(price >= 0, 'price must be >= 0');

  final String symbol;
  final String displayName;
  final double price;

  /// Daily change percent (null if unavailable).
  final double? changePercent;

  bool get isRising => changePercent != null && changePercent! > 0;
  bool get isFalling => changePercent != null && changePercent! < 0;

  @override
  List<Object?> get props => [symbol, displayName, price, changePercent];
}

/// A point-in-time snapshot of major global market index levels.
class GlobalMarketSnapshot extends Equatable {
  const GlobalMarketSnapshot({
    required this.indices,
    required this.snapshotDate,
  });

  final List<GlobalIndexLevel> indices;
  final DateTime snapshotDate;

  int get indexCount => indices.length;
  bool get isEmpty => indices.isEmpty;

  GlobalIndexLevel? indexFor(String symbol) =>
      indices.where((final GlobalIndexLevel i) => i.symbol == symbol).isEmpty
      ? null
      : indices.firstWhere((final GlobalIndexLevel i) => i.symbol == symbol);

  int get risingCount =>
      indices.where((final GlobalIndexLevel i) => i.isRising).length;

  int get fallingCount =>
      indices.where((final GlobalIndexLevel i) => i.isFalling).length;

  bool get isBroadlyUp => risingCount > fallingCount;

  @override
  List<Object?> get props => [indices, snapshotDate];
}
