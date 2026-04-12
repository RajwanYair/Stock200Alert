import 'package:cross_tide/src/domain/rebalance_execution.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RebalanceExecution', () {
    test('equality', () {
      final a = RebalanceExecution(
        executionId: 'exec1',
        portfolioId: 'port1',
        legs: const [],
        totalTurnoverPercent: 12.5,
        proposedAt: DateTime(2025, 10, 1),
      );
      final b = RebalanceExecution(
        executionId: 'exec1',
        portfolioId: 'port1',
        legs: const [],
        totalTurnoverPercent: 12.5,
        proposedAt: DateTime(2025, 10, 1),
      );
      expect(a, b);
    });

    test('copyWith changes totalTurnoverPercent', () {
      final base = RebalanceExecution(
        executionId: 'exec1',
        portfolioId: 'port1',
        legs: const [],
        totalTurnoverPercent: 12.5,
        proposedAt: DateTime(2025, 10, 1),
      );
      final updated = base.copyWith(totalTurnoverPercent: 15.0);
      expect(updated.totalTurnoverPercent, 15.0);
    });

    test('props length is 6', () {
      final obj = RebalanceExecution(
        executionId: 'exec1',
        portfolioId: 'port1',
        legs: const [],
        totalTurnoverPercent: 12.5,
        proposedAt: DateTime(2025, 10, 1),
      );
      expect(obj.props.length, 6);
    });
  });
}
