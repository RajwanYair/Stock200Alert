import 'package:equatable/equatable.dart';

/// A configurable benchmark index for performance comparison.
class BenchmarkIndexConfig extends Equatable {
  const BenchmarkIndexConfig({
    required this.symbol,
    required this.displayName,
    this.isDefault = false,
    this.color,
  }) : assert(symbol.length > 0, 'symbol must not be empty'),
       assert(displayName.length > 0, 'displayName must not be empty');

  /// Ticker symbol for the benchmark (e.g. '^GSPC', 'SPY', '^DJI').
  final String symbol;
  final String displayName;
  final bool isDefault;

  /// Optional hex color string for chart rendering.
  final String? color;

  /// Predefined S&P 500 benchmark.
  static const BenchmarkIndexConfig sp500 = BenchmarkIndexConfig(
    symbol: '^GSPC',
    displayName: 'S&P 500',
    isDefault: true,
    color: '#FF8C00',
  );

  /// Predefined NASDAQ-100 benchmark.
  static const BenchmarkIndexConfig nasdaq100 = BenchmarkIndexConfig(
    symbol: '^NDX',
    displayName: 'NASDAQ-100',
    color: '#4169E1',
  );

  /// Predefined Dow Jones Industrial Average benchmark.
  static const BenchmarkIndexConfig dow = BenchmarkIndexConfig(
    symbol: '^DJI',
    displayName: 'Dow Jones',
    color: '#228B22',
  );

  BenchmarkIndexConfig withDefault() => BenchmarkIndexConfig(
    symbol: symbol,
    displayName: displayName,
    isDefault: true,
    color: color,
  );

  @override
  List<Object?> get props => [symbol, displayName, isDefault, color];
}
