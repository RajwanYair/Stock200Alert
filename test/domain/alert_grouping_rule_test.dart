import 'package:cross_tide/src/domain/domain.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GroupingStrategy', () {
    test('has 5 values', () {
      expect(GroupingStrategy.values.length, 5);
    });
  });

  group('AlertGroupingRule', () {
    const base = AlertGroupingRule(
      ruleId: 'gr1',
      groupingStrategy: GroupingStrategy.byTicker,
      maxGroupSize: 5,
      groupingWindowSeconds: 30,
    );

    test('isRealTime is true when groupingWindowSeconds <= 60', () {
      expect(base.isRealTime, isTrue);
    });

    test('isRealTime is true at exactly 60 seconds', () {
      const r = AlertGroupingRule(
        ruleId: 'gr2',
        groupingStrategy: GroupingStrategy.byMethod,
        maxGroupSize: 10,
        groupingWindowSeconds: 60,
      );
      expect(r.isRealTime, isTrue);
    });

    test('isRealTime is false when groupingWindowSeconds > 60', () {
      const r = AlertGroupingRule(
        ruleId: 'gr3',
        groupingStrategy: GroupingStrategy.bySeverity,
        maxGroupSize: 20,
        groupingWindowSeconds: 61,
      );
      expect(r.isRealTime, isFalse);
    });

    test('isEnabled defaults to true', () {
      expect(base.isEnabled, isTrue);
    });

    test('equality holds for same props', () {
      const copy = AlertGroupingRule(
        ruleId: 'gr1',
        groupingStrategy: GroupingStrategy.byTicker,
        maxGroupSize: 5,
        groupingWindowSeconds: 30,
      );
      expect(base, equals(copy));
    });
  });
}
