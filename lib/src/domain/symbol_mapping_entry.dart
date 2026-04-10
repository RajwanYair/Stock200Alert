import 'package:equatable/equatable.dart';

/// Maps a canonical ticker symbol to its equivalent representations on
/// different data providers or exchanges.
///
/// For example, `'BRK.B'` on Yahoo Finance vs `'BRK/B'` on a broker API.
class SymbolMappingEntry extends Equatable {
  /// Creates a [SymbolMappingEntry].
  const SymbolMappingEntry({
    required this.canonicalSymbol,
    required this.mappings,
    this.primaryExchange,
  });

  /// The canonical, normalized symbol used internally (e.g. `'BRKA'`).
  final String canonicalSymbol;

  /// Provider-keyed map of alternative symbols.
  ///
  /// Keys are provider/exchange identifiers (e.g. `'yahoo'`, `'nasdaq'`).
  /// Values are the symbol string for that provider.
  final Map<String, String> mappings;

  /// Primary exchange for this symbol (e.g. `'NYSE'`, `'NASDAQ'`).
  final String? primaryExchange;

  /// Returns the mapped symbol for [provider], or the [canonicalSymbol]
  /// when no specific mapping is registered.
  String symbolFor(String provider) => mappings[provider] ?? canonicalSymbol;

  /// Returns `true` when there are provider-specific mappings registered.
  bool get hasMappings => mappings.isNotEmpty;

  @override
  List<Object?> get props => [canonicalSymbol, mappings, primaryExchange];
}
