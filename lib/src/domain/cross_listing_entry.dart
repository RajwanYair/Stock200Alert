import 'package:equatable/equatable.dart';

/// Entry recording a ticker's cross-listing on a foreign exchange (S510).
class CrossListingEntry extends Equatable {
  const CrossListingEntry({
    required this.primaryTicker,
    required this.foreignTicker,
    required this.primaryExchange,
    required this.foreignExchange,
    required this.foreignCurrency,
    required this.conversionRatio,
  });

  /// Domestic primary ticker symbol.
  final String primaryTicker;

  /// Symbol on the foreign exchange.
  final String foreignTicker;
  final String primaryExchange;
  final String foreignExchange;
  final String foreignCurrency;

  /// Shares of foreign listing per one primary share (e.g. ADS ratio).
  final double conversionRatio;

  bool get isOneToOne => conversionRatio == 1.0;
  bool get isAdr =>
      foreignCurrency == 'USD' &&
      primaryExchange != 'NASDAQ' &&
      primaryExchange != 'NYSE';
  bool get isMultiShareAds => conversionRatio > 1.0;

  @override
  List<Object?> get props => [
    primaryTicker,
    foreignTicker,
    primaryExchange,
    foreignExchange,
    foreignCurrency,
    conversionRatio,
  ];
}
