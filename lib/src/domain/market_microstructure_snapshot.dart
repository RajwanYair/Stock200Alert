import 'package:equatable/equatable.dart';

/// Point-in-time market microstructure snapshot for a ticker (S515).
class MarketMicrostructureSnapshot extends Equatable {
  const MarketMicrostructureSnapshot({
    required this.ticker,
    required this.bidPrice,
    required this.askPrice,
    required this.lastTradePrice,
    required this.bidSizeShares,
    required this.askSizeShares,
    required this.tradedVolumeShares,
    required this.capturedAtMs,
  });

  final String ticker;
  final double bidPrice;
  final double askPrice;
  final double lastTradePrice;
  final int bidSizeShares;
  final int askSizeShares;
  final int tradedVolumeShares;

  /// Epoch milliseconds when this snapshot was captured.
  final int capturedAtMs;

  double get spreadUsd => askPrice - bidPrice;
  double get midPrice => (bidPrice + askPrice) / 2;
  double get spreadBps => midPrice == 0 ? 0 : spreadUsd / midPrice * 10000;
  bool get isTightSpread => spreadBps <= 5;
  bool get isLargeSpread => spreadBps >= 50;

  @override
  List<Object?> get props => [
    ticker,
    bidPrice,
    askPrice,
    lastTradePrice,
    bidSizeShares,
    askSizeShares,
    tradedVolumeShares,
    capturedAtMs,
  ];
}
