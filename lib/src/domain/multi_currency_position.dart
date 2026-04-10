import 'package:equatable/equatable.dart';

/// A position held in a non-base currency, with live FX conversion.
///
/// Tracks both the native-currency value and the converted base-currency
/// value so that multi-currency portfolios can be aggregated consistently.
class MultiCurrencyPosition extends Equatable {
  /// Creates a [MultiCurrencyPosition].
  const MultiCurrencyPosition({
    required this.ticker,
    required this.nativeCurrency,
    required this.baseCurrency,
    required this.nativeMarketValue,
    required this.fxRate,
    required this.updatedAt,
    required this.quantity,
    required this.nativeCostBasis,
  });

  /// Ticker symbol of the held asset.
  final String ticker;

  /// ISO-4217 currency code of the asset's denominated currency
  /// (e.g. `'JPY'`, `'GBP'`).
  final String nativeCurrency;

  /// ISO-4217 currency code to which values are converted (e.g. `'USD'`).
  final String baseCurrency;

  /// Current market value in [nativeCurrency].
  final double nativeMarketValue;

  /// Exchange rate: 1 unit of [nativeCurrency] = [fxRate] of [baseCurrency].
  final double fxRate;

  /// Timestamp of the FX rate and market value quote.
  final DateTime updatedAt;

  /// Number of shares / units held.
  final double quantity;

  /// Total cost basis in [nativeCurrency].
  final double nativeCostBasis;

  /// Market value converted to [baseCurrency].
  double get baseMarketValue => nativeMarketValue * fxRate;

  /// Cost basis converted to [baseCurrency].
  double get baseCostBasis => nativeCostBasis * fxRate;

  /// Unrealised P&L in [baseCurrency].
  double get unrealisedPnlBase => baseMarketValue - baseCostBasis;

  /// Returns `true` when the position is profitable at current rates.
  bool get isProfitable => unrealisedPnlBase > 0;

  @override
  List<Object?> get props => [
    ticker,
    nativeCurrency,
    baseCurrency,
    nativeMarketValue,
    fxRate,
    updatedAt,
    quantity,
    nativeCostBasis,
  ];
}
