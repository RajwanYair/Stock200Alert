import 'package:equatable/equatable.dart';

/// Market ticker alias — alternative identifier mapping for a primary symbol.
enum TickerAliasSource { exchange, isin, cusip, userDefined, bloomberg }

class MarketTickerAlias extends Equatable {
  const MarketTickerAlias({
    required this.primaryTicker,
    required this.alias,
    required this.aliasSource,
    required this.exchange,
    required this.isActive,
  });

  final String primaryTicker;
  final String alias;
  final TickerAliasSource aliasSource;
  final String exchange;
  final bool isActive;

  MarketTickerAlias copyWith({
    String? primaryTicker,
    String? alias,
    TickerAliasSource? aliasSource,
    String? exchange,
    bool? isActive,
  }) => MarketTickerAlias(
    primaryTicker: primaryTicker ?? this.primaryTicker,
    alias: alias ?? this.alias,
    aliasSource: aliasSource ?? this.aliasSource,
    exchange: exchange ?? this.exchange,
    isActive: isActive ?? this.isActive,
  );

  @override
  List<Object?> get props => [
    primaryTicker,
    alias,
    aliasSource,
    exchange,
    isActive,
  ];
}
