import 'package:equatable/equatable.dart';

/// Ticker price history — candle coverage summary by granularity.
enum PriceHistoryGranularity { daily, weekly, monthly, quarterly, annual }

class TickerPriceHistory extends Equatable {
  const TickerPriceHistory({
    required this.ticker,
    required this.granularity,
    required this.fromDate,
    required this.toDate,
    required this.candleCount,
  });

  final String ticker;
  final PriceHistoryGranularity granularity;
  final String fromDate;
  final String toDate;
  final int candleCount;

  TickerPriceHistory copyWith({
    String? ticker,
    PriceHistoryGranularity? granularity,
    String? fromDate,
    String? toDate,
    int? candleCount,
  }) => TickerPriceHistory(
    ticker: ticker ?? this.ticker,
    granularity: granularity ?? this.granularity,
    fromDate: fromDate ?? this.fromDate,
    toDate: toDate ?? this.toDate,
    candleCount: candleCount ?? this.candleCount,
  );

  @override
  List<Object?> get props => [
    ticker,
    granularity,
    fromDate,
    toDate,
    candleCount,
  ];
}
