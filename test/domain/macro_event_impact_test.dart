import 'package:cross_tide/src/domain/macro_event_impact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MacroEventImpact', () {
    test('equality', () {
      const a = MacroEventImpact(
        eventName: 'CPI Release',
        assetClass: 'equity',
        impactLevel: MacroImpactLevel.high,
        expectedMovePct: 1.5,
        historicalInstances: 24,
      );
      const b = MacroEventImpact(
        eventName: 'CPI Release',
        assetClass: 'equity',
        impactLevel: MacroImpactLevel.high,
        expectedMovePct: 1.5,
        historicalInstances: 24,
      );
      expect(a, b);
    });

    test('copyWith changes expectedMovePct', () {
      const base = MacroEventImpact(
        eventName: 'CPI Release',
        assetClass: 'equity',
        impactLevel: MacroImpactLevel.high,
        expectedMovePct: 1.5,
        historicalInstances: 24,
      );
      final updated = base.copyWith(expectedMovePct: 2.0);
      expect(updated.expectedMovePct, 2.0);
    });

    test('props length is 5', () {
      const obj = MacroEventImpact(
        eventName: 'CPI Release',
        assetClass: 'equity',
        impactLevel: MacroImpactLevel.high,
        expectedMovePct: 1.5,
        historicalInstances: 24,
      );
      expect(obj.props.length, 5);
    });
  });
}
