import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SymbolMappingEntry', () {
    const entry = SymbolMappingEntry(
      canonicalSymbol: 'BRKA',
      mappings: {'yahoo': 'BRK-A', 'nasdaq': 'BRK.A'},
      primaryExchange: 'NYSE',
    );

    test('symbolFor returns mapped symbol when provider is registered', () {
      expect(entry.symbolFor('yahoo'), 'BRK-A');
    });

    test('symbolFor falls back to canonicalSymbol for unknown provider', () {
      expect(entry.symbolFor('unknown'), 'BRKA');
    });

    test('hasMappings is true when mappings map is non-empty', () {
      expect(entry.hasMappings, isTrue);
    });

    test('hasMappings is false when mappings map is empty', () {
      const empty = SymbolMappingEntry(canonicalSymbol: 'AAPL', mappings: {});
      expect(empty.hasMappings, isFalse);
    });

    test('primaryExchange defaults to null when omitted', () {
      const noExchange = SymbolMappingEntry(canonicalSymbol: 'X', mappings: {});
      expect(noExchange.primaryExchange, isNull);
    });

    test('equality holds for same props', () {
      const a = SymbolMappingEntry(
        canonicalSymbol: 'BRKA',
        mappings: {'yahoo': 'BRK-A', 'nasdaq': 'BRK.A'},
        primaryExchange: 'NYSE',
      );
      expect(a, equals(entry));
    });
  });
}
