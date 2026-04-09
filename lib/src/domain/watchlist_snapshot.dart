import 'package:equatable/equatable.dart';

/// Point-in-time data for a single ticker within a watchlist snapshot.
class WatchlistTickerSnapshot extends Equatable {
  const WatchlistTickerSnapshot({
    required this.ticker,
    required this.closePrice,
    required this.sma200,
    this.sma50,
    this.rsi14,
    this.alertCount = 0,
  });

  final String ticker;
  final double closePrice;
  final double sma200;
  final double? sma50;
  final double? rsi14;
  final int alertCount;

  double get pctFromSma200 => (closePrice - sma200) / sma200;
  bool get isAboveSma200 => closePrice > sma200;

  @override
  List<Object?> get props => [
    ticker,
    closePrice,
    sma200,
    sma50,
    rsi14,
    alertCount,
  ];
}

/// A point-in-time capture of all tickers in a watchlist.
class WatchlistSnapshot extends Equatable {
  const WatchlistSnapshot({
    required this.snapshotId,
    required this.watchlistName,
    required this.tickers,
    required this.capturedAt,
  });

  final String snapshotId;
  final String watchlistName;
  final List<WatchlistTickerSnapshot> tickers;
  final DateTime capturedAt;

  int get size => tickers.length;

  WatchlistTickerSnapshot? tickerSnapshot(String ticker) =>
      tickers.where((t) => t.ticker == ticker).firstOrNull;

  List<WatchlistTickerSnapshot> get aboveSma200 =>
      tickers.where((t) => t.isAboveSma200).toList();

  double get pctAboveSma200 =>
      tickers.isEmpty ? 0.0 : aboveSma200.length / tickers.length;

  @override
  List<Object?> get props => [snapshotId, watchlistName, tickers, capturedAt];
}
