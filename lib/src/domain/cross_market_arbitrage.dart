import 'package:equatable/equatable.dart';

/// Cross-market arbitrage — inter-exchange spread opportunity.
enum ArbitrageDirection { longLeg, shortLeg, neutral }

class CrossMarketArbitrage extends Equatable {
  const CrossMarketArbitrage({
    required this.ticker,
    required this.exchange1,
    required this.exchange2,
    required this.spreadPercent,
    required this.direction,
  });

  final String ticker;
  final String exchange1;
  final String exchange2;
  final double spreadPercent;
  final ArbitrageDirection direction;

  CrossMarketArbitrage copyWith({
    String? ticker,
    String? exchange1,
    String? exchange2,
    double? spreadPercent,
    ArbitrageDirection? direction,
  }) => CrossMarketArbitrage(
    ticker: ticker ?? this.ticker,
    exchange1: exchange1 ?? this.exchange1,
    exchange2: exchange2 ?? this.exchange2,
    spreadPercent: spreadPercent ?? this.spreadPercent,
    direction: direction ?? this.direction,
  );

  @override
  List<Object?> get props => [
    ticker,
    exchange1,
    exchange2,
    spreadPercent,
    direction,
  ];
}
