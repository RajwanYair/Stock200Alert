import 'package:cross_tide/src/domain/performance_scorer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const scorer = PerformanceScorer();

  group('PerformanceScorer', () {
    test('empty samples returns max score', () {
      final result = scorer.score([]);
      expect(result.overallScore, 100);
      expect(result.rating, 'EXCELLENT');
      expect(result.sampleCount, 0);
    });

    test('computes operation stats correctly', () {
      final samples = [
        PerformanceSample(
          operation: 'refresh',
          durationMs: 100,
          timestamp: DateTime(2025, 1, 1),
        ),
        PerformanceSample(
          operation: 'refresh',
          durationMs: 200,
          timestamp: DateTime(2025, 1, 2),
        ),
        PerformanceSample(
          operation: 'refresh',
          durationMs: 300,
          timestamp: DateTime(2025, 1, 3),
        ),
        PerformanceSample(
          operation: 'refresh',
          durationMs: 400,
          timestamp: DateTime(2025, 1, 4),
        ),
        PerformanceSample(
          operation: 'refresh',
          durationMs: 500,
          timestamp: DateTime(2025, 1, 5),
        ),
      ];

      final result = scorer.score(samples);
      expect(result.operationStats, hasLength(1));

      final stats = result.operationStats.first;
      expect(stats.operation, 'refresh');
      expect(stats.meanMs, closeTo(300, 0.1));
      expect(stats.medianMs, closeTo(300, 0.1));
      expect(stats.maxMs, 500);
      expect(stats.count, 5);
    });

    test('fast operations yield high score', () {
      final samples = List.generate(
        10,
        (int i) => PerformanceSample(
          operation: 'refresh',
          durationMs: 5,
          timestamp: DateTime(2025, 1, 1 + i),
        ),
      );

      final result = scorer.score(samples);
      expect(result.refreshScore, greaterThan(90));
      expect(result.rating, 'EXCELLENT');
    });

    test('slow operations yield low score', () {
      final samples = List.generate(
        20,
        (int i) => PerformanceSample(
          operation: 'refresh',
          durationMs: 10000,
          timestamp: DateTime(2025, 1, 1 + i),
        ),
      );

      final result = scorer.score(samples);
      expect(result.refreshScore, lessThan(20));
    });

    test('multiple operation types tracked separately', () {
      final samples = [
        PerformanceSample(
          operation: 'refresh',
          durationMs: 10,
          timestamp: DateTime(2025, 1, 1),
        ),
        PerformanceSample(
          operation: 'dataLoad',
          durationMs: 300,
          timestamp: DateTime(2025, 1, 1),
        ),
      ];

      final result = scorer.score(samples);
      expect(result.operationStats, hasLength(2));
    });

    test('PerformanceSample props equality', () {
      final a = PerformanceSample(
        operation: 'x',
        durationMs: 100,
        timestamp: DateTime(2025, 1, 1),
      );
      final b = PerformanceSample(
        operation: 'x',
        durationMs: 100,
        timestamp: DateTime(2025, 1, 1),
      );
      expect(a, equals(b));
    });

    test('PerformanceScore props equality', () {
      const a = PerformanceScore(
        overallScore: 90,
        refreshScore: 95,
        dataLoadScore: 85,
        operationStats: [],
        sampleCount: 10,
      );
      const b = PerformanceScore(
        overallScore: 90,
        refreshScore: 95,
        dataLoadScore: 85,
        operationStats: [],
        sampleCount: 10,
      );
      expect(a, equals(b));
    });

    test('OperationStats props equality', () {
      const a = OperationStats(
        operation: 'x',
        count: 5,
        meanMs: 100,
        medianMs: 100,
        p95Ms: 120,
        maxMs: 150,
      );
      const b = OperationStats(
        operation: 'x',
        count: 5,
        meanMs: 100,
        medianMs: 100,
        p95Ms: 120,
        maxMs: 150,
      );
      expect(a, equals(b));
    });
  });
}
